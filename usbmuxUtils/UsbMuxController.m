//
//  UsbMuxController.m
//  idevice
//
//  Created by Danil Korotenko on 7/4/24.
//

#import "UsbMuxController.h"
#import "UsbMuxConnection.h"

static NSUInteger tag = 0;

@interface UsbMuxController ()

@property (readonly) UsbMuxConnection *connection;

@end

@implementation UsbMuxController

@synthesize connection;

+ (UsbMuxController *)sharedInstance
{
    static UsbMuxController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedInstance = [[UsbMuxController alloc] init];
    });
    return sharedInstance;
}

#pragma mark -

- (UsbMuxConnection *)connection
{
    if (connection == nil)
    {
        connection = [UsbMuxConnection startWithDelegate:self];
        [connection waitConnected];
    }
    return connection;
}

#pragma mark -

- (NSArray *)devices
{
    tag++;
    NSError *error = nil;
    if ([self.connection sendListDevicesPacket:tag error:&error])
    {
        UsbMuxPacket *packet = nil;
        [self.connection receive_packet:&packet];
    }

    return @[];
}

#pragma mark -

- (void)connectionCanceled:(nonnull UsbMuxConnection *)aConnection
{
    connection = nil;
}

- (void)didConnect:(nonnull UsbMuxConnection *)aConnection
{
    NSLog(@"didConnect");
}

- (void)log:(nonnull NSString *)aLogMessage
{
    NSLog(@"%@", aLogMessage);
}

- (void)stringReceived:(nonnull NSString *)aStringReceived
{
    NSLog(@"stringReceived");
}

@end
