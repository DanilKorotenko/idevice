//
//  UsbMuxConnection.m
//  idevice
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UMConnection.h"

#include <sys/socket.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/un.h>

#import "DispatchData.h"
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

@property (readwrite) uint32_t socket;
@end

@implementation UMConnection

/*
 debugging traffic:
 sudo mv /var/run/usbmuxd /var/run/usbmuxx
 sudo socat -t100 -x -v UNIX-LISTEN:/var/run/usbmuxd,mode=777,reuseaddr,fork UNIX-CONNECT:/var/run/usbmuxx
 */
+ (uint32_t)connectToUSBMux:(time_t)recvTimeoutSec
{
    int result = 0;

    // Initialize socket
    uint32_t sock = socket(AF_UNIX, SOCK_STREAM, 0);

    if (recvTimeoutSec != 0)
    {
        struct timeval timeout = {.tv_sec = recvTimeoutSec, .tv_usec = 0};
        if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)))
        {
            int err = errno;
            NSLog(@"setsockopt SO_RCVTIMEO failed: %d - %s\n", err, strerror(err));
        }
    }

    // Set send/receive buffer sizes
    uint32_t bufSize = 0x00010400;
    if (!result)
    {
        if (setsockopt(sock, SOL_SOCKET, SO_SNDBUF, &bufSize, sizeof(bufSize)))
        {
            result = 1;
            int err = errno;
            NSLog(@"setsockopt SO_SNDBUF failed: %d - %s\n", errno, strerror(err));
        }
    }

    if (!result)
    {
        if (setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &bufSize, sizeof(bufSize)))
        {
            result = 2;
            int err = errno;
            NSLog(@"setsockopt SO_SNDBUF failed: %d - %s\n", errno, strerror(err));
        }
    }

    if (!result)
    {
        uint32_t noPipe = 1; // Disable SIGPIPE on socket i/o error
        if (setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, &noPipe, sizeof(noPipe)))
        {
            result = 3;
            int err = errno;
            NSLog(@"setsockopt SO_SNDBUF failed: %d - %s\n", errno, strerror(err));
        }
    }

    if (!result)
    {
        // Create address structure to point to usbmuxd socket
        char *mux = "/var/run/usbmuxd";
        struct sockaddr_un address;
        address.sun_family = AF_UNIX;
        strncpy(address.sun_path, mux, sizeof(address.sun_path));
        address.sun_len = SUN_LEN(&address);

        // Connect socket
        if (connect(sock, (const struct sockaddr *)&address, sizeof(struct sockaddr_un)))
        {
            result = 4;
            int err = errno;
            NSLog(@"connect socket failed: %d - %s\n", err, strerror(err));
        }
    }

    if (!result)
    {
        // Set socket to blocking IO mode
        uint32_t nonblock = 0;
        if (ioctl(sock, FIONBIO, &nonblock))
        {
            result = 5;
            int err = errno;
            NSLog(@"ioctl FIONBIO failed: %d - %s\n", err, strerror(err));
        }
    }

    if (result)
    {
        // Socket creation failed
        close(sock);
        sock = -1;
    }

    return sock;
}

- (instancetype)init
{
    self = [self initWithTimeOut:10];
    if (self)
    {

    }
    return self;
}

- (instancetype)initWithTimeOut:(time_t)aTimeout
{
    self = [super init];
    if (self)
    {
        self.socket = [UMConnection connectToUSBMux:aTimeout];
        if (!self.socket)
        {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (self.socket)
    {
        close(self.socket);
        self.socket = -1;
    }
}

#pragma mark -

- (BOOL)sendListDevicesPacket:(NSUInteger *)aTag error:(NSError *__autoreleasing  _Nullable * _Nullable)anError
{
    tag++;
    *aTag = tag;
    UMPacket *plist = [[UMPacket alloc] initWithMessage:@"ListDevices"];
    return [self sendPlistPacket:tag message:plist error:(anError)];
}

- (BOOL)sendConnectPacket:(NSUInteger *)aTag deviceId:(NSInteger)aDeviceId error:(NSError **)anError
{
    tag++;
    *aTag = tag;
    UMPacket *plist = [[UMPacket alloc] initWithConnectDeviceId:aDeviceId];
    return [self sendPlistPacket:tag message:plist error:(anError)];
}

- (BOOL)sendGetValuePacket:(NSUInteger *)aTag domain:(NSString*)aDomain key:(NSString *)aKey error:(NSError **)anError
{
    tag++;
    *aTag = tag;
    UMPacket *plist = [[UMPacket alloc] initWithGetValueForDomain:aDomain key:aKey];
    return [self sendPlistPacket:tag message:plist error:(anError)];
}

#pragma mark -

- (BOOL)sendPlistPacket:(NSUInteger)tag message:(UMPacket *)message error:(NSError **)anError
{
    return [self send_packet:MESSAGE_PLIST tag:tag payload:[message xmlData] error:anError];
}

- (BOOL)send_packet:(usbmuxd_msgtype)message tag:(NSUInteger)tag payload:(NSData *)payload error:(NSError **)anError
{
    struct usbmuxd_header header;

    header.length = sizeof(struct usbmuxd_header);
    header.version = proto_version;
    header.message = (uint32_t)message;
    header.tag = (uint32_t)tag;
    if (payload && (payload.length > 0))
    {
        header.length += payload.length;
    }

    ssize_t result = send(self.socket, &header, sizeof(struct usbmuxd_header), 0);
    if (result == sizeof(struct usbmuxd_header))
    {
        if (header.length > result)
        {
            char *buffer = (char *)malloc(payload.length);
            [payload getBytes:buffer length:payload.length];

            ssize_t remainder = payload.length;
            while (remainder)
            {
                result = send(self.socket, &buffer[payload.length - remainder], sizeof(char), 0);
                if (result != sizeof(char))
                {
                    break;
                }
                remainder -= result;
            }
        }
    }
    return YES;
}

- (BOOL)usbmuxd_get_result:(NSUInteger)tag result_plist:(UMPacket **)aPacket
{
    BOOL result = [self receive_packet:aPacket];

    if (result && (*aPacket).tag != tag)
    {
        return NO;
    }

    return result;
}

- (BOOL)receive_packet:(UMPacket **)payload
{
    UMPacket *packet = nil;

    ssize_t headerSize = sizeof(struct usbmuxd_header);

    struct usbmuxd_header *header = malloc(headerSize);
    ssize_t result = recv(self.socket, (void *)header, headerSize, 0);
    if (result == headerSize)
    {
        ssize_t payloadSize = header->length - result;
        if (payloadSize)
        {
            char *buffer = calloc(1, payloadSize);
            ssize_t remainder = payloadSize;
            while (remainder)
            {
                result = recv(self.socket, &buffer[payloadSize - remainder], sizeof(char), 0);
                if (result != sizeof(char))
                {
                    break;
                }
                remainder -= result;
            }
            NSData *xmlData = [NSData dataWithBytes:buffer length:payloadSize];
            packet = [[UMPacket alloc] initWithPayloadData:xmlData];
            packet.tag = header->tag;

            free(buffer);
        }
    }
    free(header);

    *payload = packet;

    return packet != nil;
}

@end
