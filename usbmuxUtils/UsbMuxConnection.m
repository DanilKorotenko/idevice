//
//  UsbMuxConnection.m
//  idevice
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UsbMuxConnection.h"

#import <Network/Network.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/un.h>

#import "DispatchData.h"

typedef NS_ENUM(NSUInteger, ConnectionState)
{
    ConnectionStateNone,
    ConnectionStateConnected,
    ConnectionStateCancelled,
};

@interface UsbMuxConnection ()

@property (strong) nw_connection_t connection;
@property (strong) dispatch_queue_t queue;

@property (weak) id<UsbMuxConnectionDelegate> delegate;

@property (readwrite) ConnectionState state;

@end

@implementation UsbMuxConnection

+ (nw_connection_t)newConnection
{
    char *mux = "/var/run/usbmuxd";
    struct sockaddr_un address;
    address.sun_family = AF_UNIX;
    strncpy(address.sun_path, mux, sizeof(address.sun_path));
    address.sun_len = SUN_LEN(&address);

    nw_endpoint_t endpoint = nw_endpoint_create_address(&address);

    nw_parameters_t parameters = nw_parameters_create_secure_tcp(NW_PARAMETERS_DISABLE_PROTOCOL,
        NW_PARAMETERS_DEFAULT_CONFIGURATION);

    nw_connection_t result = nw_connection_create(endpoint, parameters);

    return result;
}

+ (UsbMuxConnection *)startWithDelegate:(id<UsbMuxConnectionDelegate>)aDelegate
{
    nw_connection_t connection = [UsbMuxConnection newConnection];
    return [UsbMuxConnection startWithNWConnection:connection delegate:aDelegate];
}

+ (UsbMuxConnection *)startSynchronously
{
    nw_connection_t connection = [UsbMuxConnection newConnection];
    UsbMuxConnection *result = [UsbMuxConnection startWithNWConnection:connection delegate:nil];
    if (![result waitConnected])
    {
        result = nil;
    }
    return result;
}

+ (UsbMuxConnection *)startWithNWConnection:(nw_connection_t)aConnection
    delegate:(id<UsbMuxConnectionDelegate> _Nullable)aDelegate
{
    UsbMuxConnection *result = [[UsbMuxConnection alloc] init];
    result.delegate = aDelegate;
    [result start:aConnection];
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
    [self.delegate didConnect:self];
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

- (void)sendData:(dispatch_data_t)aData
    withSendCompletionBlock:(void (^)(NSError *error))aSendCompletionBlock
{
    if (self.state == ConnectionStateConnected)
    {
        nw_connection_send(self.connection, aData, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true,
            ^(nw_error_t  _Nullable error)
            {
                NSError *err = nil;
                if (error)
                {
                    CFErrorRef errRef = nw_error_copy_cf_error(error);
                    if (NULL != errRef)
                    {
                        err = CFBridgingRelease(errRef);
                        if (aSendCompletionBlock)
                        {
                            aSendCompletionBlock(err);
                        }
                    }
                }
                else if (aSendCompletionBlock)
                {
                    aSendCompletionBlock(nil);
                }
            });
    }
    else if (aSendCompletionBlock)
    {
        aSendCompletionBlock(nil);
    }
}

- (void)sendString:(NSString *)aString
    withSendCompletionBlock:(void (^)(NSError *error))aSendCompletionBlock
{
    dispatch_data_t data = [DispatchData dispatch_data_from_NSString:aString queue:self.queue];
    [self sendData:data withSendCompletionBlock:aSendCompletionBlock];
}

- (BOOL)sendStringSynchronously:(NSString *)aString error:(NSError * __autoreleasing *)anError
{
    __block BOOL didSend = NO;
    __block NSError *outError = nil;
    [self sendString:aString withSendCompletionBlock:^(NSError * _Nonnull error)
        {
            didSend = YES;
            outError = error;
        }];
    while (!didSend)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
    }
    if (anError != NULL)
    {
        *anError = outError;
    }
    return outError == nil;
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

- (void)startReceiving
{
    nw_connection_receive(self.connection, 1, UINT32_MAX,
        ^(dispatch_data_t  _Nullable content, nw_content_context_t _Nullable context,
            bool is_complete, nw_error_t  _Nullable receive_error)
        {
            if (content != NULL)
            {
                NSData *data = [NSData dataWithData:(NSData *)content];
                NSString *stringRecieved = [[NSString alloc] initWithData:data
                    encoding:NSUTF8StringEncoding];
                [self stringReceived:stringRecieved];
            }

            // If the context is marked as complete, and is the final context,
            // we're read-closed.
            if (is_complete &&
                (context == NULL || nw_content_context_get_is_final(context)))
            {
                [self connectionCancelled];
            }
            else if (receive_error == NULL)
            {
                // If there was no error in receiving, request more data
                [self startReceiving];
            }
        });
}

#pragma mark -

- (void)logOutside:(NSString *)aLogMessage, ...
{
    NSString *message = nil;
    va_list args;
    va_start(args, aLogMessage);
    message = [[NSString alloc] initWithFormat:aLogMessage arguments:args];
    va_end(args);
    [self.delegate log:message];
}

- (void)stringReceived:(NSString *)aStringReceived
{
    [self.delegate stringReceived:aStringReceived];
}

- (void)connectionCancelled
{
    self.connection = nil;
    self.state = ConnectionStateCancelled;
    [self.delegate connectionCanceled:self];
}

@end
