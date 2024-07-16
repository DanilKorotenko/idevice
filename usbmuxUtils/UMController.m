//
//  UsbMuxController.m
//  idevice
//
//  Created by Danil Korotenko on 7/4/24.
//

#import "UMController.h"
#import "UMConnection.h"

@interface UMController ()

@property (readonly) UMConnection *connection;

@end

@implementation UMController

@synthesize connection;

+ (UMController *)sharedInstance
{
    static UMController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedInstance = [[UMController alloc] init];
    });
    return sharedInstance;
}

#pragma mark -

- (UMConnection *)connection
{
    if (connection == nil)
    {
        connection = [[UMConnection alloc] init];
    }
    return connection;
}

#pragma mark -

- (NSArray *)devices
{
    NSUInteger tag = 0;
    NSArray *result = nil;
    NSError *error = nil;
    if ([self.connection sendListDevicesPacket:&tag error:&error])
    {
        UMPacket *packet = nil;
        if ([self.connection receive_packet:&packet])
        {
            result = packet.deviceList;
        }
    }
    return result;
}

@end
