//
//  IOUSBController.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IOUSBController.h"

#import <IOKit/usb/IOUSBLib.h>

static void iokit_cfdictionary_set_short(CFMutableDictionaryRef dict, const void *key, SInt16 value)
{
    CFNumberRef numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberShortType, &value);
    if (numberRef)
    {
        CFDictionarySetValue(dict, key, numberRef);
        CFRelease(numberRef);
    }
}

@interface IOUSBController ()

@property (strong) NSMutableArray           *deviceArray;
@property (assign) IONotificationPortRef    notifyPort;

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
{
    io_iterator_t _deviceAddedIter;
    io_iterator_t _deviceRemovedIter;
}

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
    self.deviceArray = [[NSMutableArray alloc] initWithCapacity: 0];

    CFMutableDictionaryRef classToMatch = IOServiceMatching(kIOUSBDeviceClassName);

    // increase the reference count by 1 since die dict is used twice.
    CFRetain(classToMatch);

    self.notifyPort = IONotificationPortCreate(kIOMainPortDefault);
    CFRunLoopSourceRef runLoopSource = IONotificationPortGetRunLoopSource(self.notifyPort);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);

    IOServiceAddMatchingNotification(self.notifyPort,
        kIOFirstMatchNotification, classToMatch,
        staticDeviceAdded, (__bridge void *)(self), &_deviceAddedIter);

    // Iterate once to get already-present devices and arm the notification
    [self deviceAdded:_deviceAddedIter];
}

#pragma mark -

- (void)deviceAdded:(io_iterator_t)anIterator
{

}

- (void)deviceRemoved:(io_iterator_t)anIterator
{

}

@end
