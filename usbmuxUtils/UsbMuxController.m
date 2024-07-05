//
//  UsbMuxController.m
//  idevice
//
//  Created by Danil Korotenko on 7/4/24.
//

#import "UsbMuxController.h"

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

@end
