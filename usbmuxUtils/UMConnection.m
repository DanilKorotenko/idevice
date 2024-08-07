//
//  UsbMuxConnection.m
//  idevice
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UMConnection.h"

#import <Network/Network.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/un.h>

#import "UMPacket.h"

static NSUInteger tag = 0;

typedef NS_ENUM(NSUInteger, ConnectionState)
{
    ConnectionStateNone,
    ConnectionStateConnected,
    ConnectionStateCancelled,
};

typedef NS_ENUM(NSUInteger, usbmuxd_msgtype)
{
    MESSAGE_RESULT  = 1,
    MESSAGE_CONNECT = 2,
    MESSAGE_LISTEN = 3,
    MESSAGE_DEVICE_ADD = 4,
    MESSAGE_DEVICE_REMOVE = 5,
    MESSAGE_DEVICE_PAIRED = 6,
    //???
    MESSAGE_PLIST = 8,
};

struct usbmuxd_header
{
    uint32_t length;    // length of message, including header
    uint32_t version;   // protocol version
    uint32_t message;   // message type
    uint32_t tag;       // responses to this query will echo back this tag
} __attribute__((__packed__));

static uint32_t proto_version = 1;

@interface UMConnection ()

@property (strong) nw_connection_t connection;
@property (strong) dispatch_queue_t queue;

@property (readwrite) ConnectionState state;
@property (readonly) BOOL isSSL;
@end

@implementation UMConnection

+ (nw_connection_t)newConnection
{
    char *mux = "/var/run/usbmuxd";
    struct sockaddr_un address;
    address.sun_family = AF_UNIX;
    strncpy(address.sun_path, mux, sizeof(address.sun_path));
    address.sun_len = SUN_LEN(&address);
    nw_endpoint_t endpoint = nw_endpoint_create_address((const struct sockaddr *)&address);

    nw_parameters_t parameters = nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL,
        NW_PARAMETERS_DEFAULT_CONFIGURATION);

    nw_connection_t result = nw_connection_create(endpoint, parameters);

    return result;
}

+ (UMConnection *)startNewConnection
{
    nw_connection_t connection = [UMConnection newConnection];
    return [UMConnection startWithNWConnection:connection];
}

+ (UMConnection *)startWithNWConnection:(nw_connection_t)aConnection
{
    UMConnection *result = [[UMConnection alloc] init];
    [result start:aConnection];
    [result waitConnected];
    return result;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.queue = dispatch_queue_create("UsbMuxConnectionsManager.queue", NULL);
    }
    return self;
}

- (void)dealloc
{
    [self reset];
    self.queue = nil;
}

#pragma mark -

- (void)start:(nw_connection_t)aConnection
{
    self.connection = aConnection;
    self.state = ConnectionStateNone;

    nw_connection_set_queue(aConnection, self.queue);
    nw_connection_set_state_changed_handler(aConnection,
        ^(nw_connection_state_t state, nw_error_t  _Nullable error)
        {
            switch (state)
            {
                case nw_connection_state_invalid:   { [self connectionInvalid]; break; }
                case nw_connection_state_waiting:   { [self connectionWaiting]; break; }
                case nw_connection_state_preparing: { [self connectionPreparing]; break; }
                case nw_connection_state_ready:     { [self connectionReady]; break; }
                case nw_connection_state_failed:    { [self connectionFailedError:error]; break; }
                case nw_connection_state_cancelled: { [self connectionCancelledError:error]; break;}
            }
        });
    nw_connection_start(aConnection);
}

#pragma mark -

- (void)connectionInvalid
{
    [self logOutside:@"Connection Invalid"];
}

- (void)connectionWaiting
{
    [self logOutside:@"Connection waiting"];
}

- (void)connectionPreparing
{
    [self logOutside:@"Connection Preparing"];
}

- (void)connectionReady
{
    [self logOutside:@"Connection Ready"];
    self.state = ConnectionStateConnected;
}

- (void)connectionFailedError:(nw_error_t  _Nullable)error
{
    [self logOutside:@"Connection Failed"];
    if (error)
    {
        CFErrorRef errorRef = nw_error_copy_cf_error(error);
        if (NULL != errorRef)
        {
            NSError *err = CFBridgingRelease(errorRef);
            if (err.code != 54) // connection reset by peer
            {
                [self logOutside:@"Connection error: %@", err];
            }
        }
    }

    [self logOutside:@"Connection closed."];
    [self connectionCancelled];
}

- (void)connectionCancelledError:(nw_error_t _Nullable)error
{
    [self logOutside:@"Connection Cancelled"];
    if (error)
    {
        CFErrorRef errorRef = nw_error_copy_cf_error(error);
        if (NULL != errorRef)
        {
            NSError *err = CFBridgingRelease(errorRef);
            if (err.code != 54) // connection reset by peer
            {
                [self logOutside:@"Connection error: %@", err];
            }
        }
    }

    [self logOutside:@"Connection closed."];
    [self connectionCancelled];
}

#pragma mark -

- (BOOL)sendUsbMuxListDevicesPacket:(NSUInteger *)aTag error:(NSError *__autoreleasing  _Nullable * _Nullable)anError
{
    tag++;
    *aTag = tag;
    UMPacket *plist = [[UMPacket alloc] initWithMessage:@"ListDevices"];
    return [self sendPlistPacket:tag message:plist error:(anError)];
}

- (BOOL)sendUsbMuxConnectPacket:(NSUInteger *)aTag deviceId:(NSInteger)aDeviceId error:(NSError **)anError
{
    tag++;
    *aTag = tag;
    UMPacket *plist = [[UMPacket alloc] initWithConnectDeviceId:aDeviceId];
    return [self sendPlistPacket:tag message:plist error:(anError)];
}

#pragma mark -

- (BOOL)sendPlistPacket:(NSUInteger)tag message:(UMPacket *)message error:(NSError **)anError
{
    return [self send_packet:MESSAGE_PLIST tag:tag payload:[message xmlData] error:anError];
}

- (BOOL)sendConnectPacket:(NSUInteger)tag message:(UMPacket *)message error:(NSError **)anError
{
    return [self send_packet:MESSAGE_CONNECT tag:tag payload:[message xmlData] error:anError];
}

- (BOOL)send_packet:(usbmuxd_msgtype)message tag:(NSUInteger)tag payload:(NSData *)payload error:(NSError **)anError
{
    if (self.state != ConnectionStateConnected)
    {
        if (anError != NULL)
        {
            *anError = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOTCONN userInfo:
                @{NSLocalizedDescriptionKey: @"Not connected."}];
        }
        return NO;
    }

    struct usbmuxd_header header;

    header.length = sizeof(struct usbmuxd_header);
    header.version = proto_version;
    header.message = (uint32_t)message;
    header.tag = (uint32_t)tag;
    if (payload && (payload.length > 0))
    {
        header.length += payload.length;
    }

    dispatch_data_t headerData = dispatch_data_create(&header, sizeof(header), self.queue, DISPATCH_DATA_DESTRUCTOR_DEFAULT);

    __block BOOL sendingDone = NO;
    __block NSError *outError = nil;

    bool isCompleted = (payload == nil) || payload.length == 0;
    nw_connection_send(self.connection, headerData, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, isCompleted,
        ^(nw_error_t _Nullable error)
        {
            if (error)
            {
                CFErrorRef errRef = nw_error_copy_cf_error(error);
                if (NULL != errRef)
                {
                    outError = CFBridgingRelease(errRef);
                    sendingDone = YES;
                }
            }
            else
            {
                dispatch_data_t payloadData = dispatch_data_create(payload.bytes, payload.length, self.queue, DISPATCH_DATA_DESTRUCTOR_DEFAULT);

                nw_connection_send(self.connection, payloadData, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true,
                    ^(nw_error_t _Nullable error)
                    {
                        if (error)
                        {
                            CFErrorRef errRef = nw_error_copy_cf_error(error);
                            if (NULL != errRef)
                            {
                                outError = CFBridgingRelease(errRef);
                            }
                        }
                        sendingDone = YES;
                    });
            }
        });

    while (!sendingDone)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    if (anError != NULL)
    {
        *anError = outError;
    }
    return outError == nil;
}

- (BOOL)usbmuxd_get_result:(NSUInteger)tag result_plist:(UMPacket **)aPacket
{
    BOOL result = [self receiveUsbMuxPacket:aPacket];

    if (result && (*aPacket).tag != tag)
    {
        return NO;
    }

    return result;
}

- (BOOL)receiveUsbMuxPacket:(UMPacket **)payload
{
    __block BOOL recivingIsDone = NO;
    __block NSError *error = nil;
    __block UMPacket *outPayload = nil;

    nw_connection_receive(self.connection, sizeof(struct usbmuxd_header), sizeof(struct usbmuxd_header),
        ^(dispatch_data_t  _Nullable content, nw_content_context_t  _Nullable context, bool is_complete, nw_error_t  _Nullable error)
        {
            if (content != NULL)
            {
                NSData *data = [NSData dataWithData:(NSData *)content];
                struct usbmuxd_header *hdr = (struct usbmuxd_header *)data.bytes;
                uint32_t payload_size = hdr->length - sizeof(struct usbmuxd_header);
                if (payload_size > 0)
                {
                    nw_connection_receive(self.connection, payload_size, payload_size,
                        ^(dispatch_data_t  _Nullable content, nw_content_context_t  _Nullable context, bool is_complete, nw_error_t  _Nullable error)
                        {
                            if (content != NULL)
                            {
                                NSData *data = [NSData dataWithData:(NSData *)content];
                                outPayload = [[UMPacket alloc] initWithPayloadData:data];
                                outPayload.tag = hdr->tag;
                            }
                            // If the context is marked as complete, and is the final context,
                            // we're read-closed.
                            if (is_complete &&
                                (context == NULL || nw_content_context_get_is_final(context)))
                            {
                                [self connectionCancelled];
                            }
                            recivingIsDone = YES;
                        });
                }
            }

            // If the context is marked as complete, and is the final context,
            // we're read-closed.
            if (is_complete &&
                (context == NULL || nw_content_context_get_is_final(context)))
            {
                [self connectionCancelled];
                recivingIsDone = YES;
            }
        });

    while (!recivingIsDone)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }

    *payload = outPayload;

    return error == nil;
}

- (BOOL)serviceSend:(NSData *)data
{
    if (!self.connection)
    {
        return NO;
    }

    NSInteger msgLen = data.length;

    msgLen = htonl((uint32_t)msgLen);

    dispatch_data_t dataLengthData = dispatch_data_create(&msgLen, sizeof(uint32_t), self.queue, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
    __block BOOL sendingDone = NO;
    __block NSError *outError = nil;
    nw_connection_send(self.connection, dataLengthData, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, false, ^(nw_error_t  _Nullable error)
    {
        if (error)
        {
            CFErrorRef errRef = nw_error_copy_cf_error(error);
            outError = CFBridgingRelease(errRef);
            sendingDone = YES;
            return;
        }

        dispatch_data_t payloadData = dispatch_data_create(data.bytes, data.length, self.queue, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
        nw_connection_send(self.connection, payloadData, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t  _Nullable error)
        {
            if (error)
            {
                CFErrorRef errRef = nw_error_copy_cf_error(error);
                outError = CFBridgingRelease(errRef);
            }
            sendingDone = YES;
        });
    });

    while (!sendingDone)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
//                if (anError != NULL)
//                {
//                    *anError = outError;
//                }
    return YES;
}

- (size_t)serviceReceiveBytesSock:(NSData **)buffer length:(size_t)length
{
    if (self.connection)
    {
        __block BOOL recivingIsDone = NO;
//        __block NSError *error = nil;
        __block NSData *outData = nil;

        nw_connection_receive(self.connection, (uint32_t)length, (uint32_t)length, ^(dispatch_data_t  _Nullable content, nw_content_context_t  _Nullable context, bool is_complete, nw_error_t  _Nullable error)
        {
            if (content != NULL)
            {
                outData = [NSData dataWithData:(NSData *)content];
            }
            recivingIsDone = YES;
        });

        while (!recivingIsDone)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }

        *buffer = outData;
    }
    else
    {
        printf("%s: Invalid Socket!\n", __PRETTY_FUNCTION__);
    }

    return [*buffer length];
}

/*
 * Assumes buffer is allocated up to length
 * Returns received byte length
 */
- (size_t)serviceReceiveBytes:(NSData **)buffer length:(size_t)length
{
    if (self.isSSL)
    {
//        // Note: SSL only handles int sizes :(
//        return SDMMD__ServiceReceiveBytesSSL(handle, buffer, (int)length);
    }

    return [self serviceReceiveBytesSock:buffer length:length];
}

- (BOOL)serviceReceive:(NSData **)data
{
    size_t received = 0;

    BOOL response = NO;

    // Receive data length header
    // Note: in iOS 8 the header 4-byte int may have to be read in multiple parts
    NSData *lengthData = nil;
    received = [self serviceReceiveBytes:&lengthData length:4];

    if (received == 4)
    {
        // Convert from device byte order
        uint32_t length = *(uint32_t*)lengthData.bytes;

        length = ntohl(length);

        // Receive data body
        NSData *buffer = nil;
        received = [self serviceReceiveBytes:&buffer length:length];

        // Create data object only from received byte length
        *data = buffer;

        response = YES;
    }

    return response;
}

- (BOOL)serviceReceiveMessage:(UMDeviceMessage **)data
{
    NSData *dataBuffer = nil;
    BOOL result = NO;
    *data = NULL;

    result = [self serviceReceive:&dataBuffer];
    if (result)
    {
        // ServiceReceive success does not guarantee that valid data is available
        if (dataBuffer)
        {
            // CFPropertyListCreateWithData will return NULL if data is invalid format
            *data = [[UMDeviceMessage alloc] initWithData:dataBuffer];
        }

        if (*data == nil)
        {
            // Could not parse received data
            result = NO;
        }
    }
    return result;
}

#pragma mark -

- (void)reset
{
    if (self.connection)
    {
        nw_connection_cancel(self.connection);
        while (self.state == ConnectionStateCancelled)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
        }
    }
}

- (BOOL)waitConnected
{
    while (self.state == ConnectionStateNone)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
    }
    return self.state == ConnectionStateConnected;
}

#pragma mark -

- (void)logOutside:(NSString *)aLogMessage, ...
{
    NSString *message = nil;
    va_list args;
    va_start(args, aLogMessage);
    message = [[NSString alloc] initWithFormat:aLogMessage arguments:args];
    va_end(args);
    NSLog(@"%@", message);
}

- (void)connectionCancelled
{
    self.connection = nil;
    self.state = ConnectionStateCancelled;
}

@end
