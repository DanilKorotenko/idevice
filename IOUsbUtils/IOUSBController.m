//
//  IOUSBController.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IOUSBController.h"

@implementation IOUSBController

+ (IOUSBController *)sharedController
{
    static IOUSBController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedController = [[IOUSBController alloc] init];
    });
    return sharedController;
}

@end
