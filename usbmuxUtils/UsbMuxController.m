//
//  UsbMuxController.m
//  idevice
//
//  Created by Danil Korotenko on 7/4/24.
//

#import "UsbMuxController.h"
#import "UsbMuxConnection.h"

@interface UsbMuxController ()

@property (strong) UsbMuxConnection *connection;

@end

@implementation UsbMuxController

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

- (void)start
{
    self.connection = [UsbMuxConnection startWithDelegate:self];
}

#pragma mark -

- (void)connectionCanceled:(nonnull UsbMuxConnection *)aConnection
{
    self.connection = [UsbMuxConnection startWithDelegate:self];
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
