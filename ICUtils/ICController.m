//
//  ICController.m
//  idevice
//
//  Created by Danil Korotenko on 7/9/24.
//

#import "ICController.h"

@interface ICController ()

@property (readonly) ICDeviceBrowser *deviceBrowser;

@end

@implementation ICController

@synthesize deviceBrowser;

+ (ICController *)sharedInstance
{
    static ICController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedInstance = [[ICController alloc] init];
    });
    return sharedInstance;
}

- (ICDeviceBrowser *)deviceBrowser
{
    if (deviceBrowser == nil)
    {
        deviceBrowser = [[ICDeviceBrowser alloc] init];
        deviceBrowser.delegate = self;
//        deviceBrowser.browsedDeviceTypeMask = ICDeviceTypeMaskCamera | ICDeviceLocationTypeMaskLocal;
        [deviceBrowser start];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0f]];
    }
    return deviceBrowser;
}

- (NSArray *)devices
{
    NSArray *devices = self.deviceBrowser.devices;
    return devices;
}

- (void)deviceBrowser:(nonnull ICDeviceBrowser *)browser didAddDevice:(nonnull ICDevice *)device moreComing:(BOOL)moreComing
{
    NSLog(@"%@", device);
}

- (void)deviceBrowser:(nonnull ICDeviceBrowser *)browser didRemoveDevice:(nonnull ICDevice *)device moreGoing:(BOOL)moreGoing
{
    NSLog(@"%@", device);
}

@end
