//
//  IOUSBController.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IOUSBController.h"

@interface IOUSBController ()

- (void)deviceAdded:(io_iterator_t)anIterator;
- (void)deviceRemoved:(io_iterator_t)anIterator;

@end

#pragma mark -

static void staticDeviceAdded(void *refCon, io_iterator_t iterator)
{
    IOUSBController *controller = (__bridge IOUSBController *)(refCon);
    if (controller)
    {
        [controller deviceAdded:iterator];
    }
}

static void staticDeviceRemoved(void *refCon, io_iterator_t iterator)
{
    IOUSBController *controller = (__bridge IOUSBController *)(refCon);
    if (controller)
    {
        [controller deviceRemoved:iterator];
    }
}

#pragma mark -

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

- (void)startWatching
{

}

#pragma mark -

- (void)deviceAdded:(io_iterator_t)anIterator
{

}

- (void)deviceRemoved:(io_iterator_t)anIterator
{

}

@end
