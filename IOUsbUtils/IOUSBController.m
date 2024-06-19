//
//  IOUSBController.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IOUSBController.h"

#import <IOKit/usb/IOUSBLib.h>

//static void iokit_cfdictionary_set_short(CFMutableDictionaryRef dict, const void *key, SInt16 value)
//{
//    if (dict == NULL)
//    {
//        return;
//    }
//
//    CFNumberRef numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberShortType, &value);
//    if (numberRef)
//    {
//        CFDictionarySetValue(dict, key, numberRef);
//        CFRelease(numberRef);
//    }
//}

@interface IOUSBController ()

@property (strong) void (^deviceAddedBlock)(IOUSBDevice *aDevice);

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

//static void staticDeviceRemoved(void *refCon, io_iterator_t iterator)
//{
//    IOUSBController *controller = (__bridge IOUSBController *)(refCon);
//    if (controller)
//    {
//        [controller deviceRemoved:iterator];
//    }
//}

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

#pragma mark -

- (BOOL)startWatchingWithBlock:(void (^)(IOUSBDevice *aDevice))aBlock
{
    self.deviceAddedBlock = aBlock;

    CFMutableDictionaryRef matchingDict = [self createMatchingDict];
    if (matchingDict == NULL)
    {
        return NO;
    }

    self.notifyPort = IONotificationPortCreate(kIOMainPortDefault);
    CFRunLoopSourceRef runLoopSource = IONotificationPortGetRunLoopSource(self.notifyPort);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);

    IOServiceAddMatchingNotification(self.notifyPort,
        kIOFirstMatchNotification, matchingDict,
        staticDeviceAdded, (__bridge void *)(self), &_deviceAddedIter);

    [self deviceAdded:_deviceAddedIter];

    return YES;
}

- (CFMutableDictionaryRef)createMatchingDict
{
    CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);

// NOTE: If we set vendorID then we have to set product ID. We cannot set only one of this.
//    iokit_cfdictionary_set_short(matchingDict, CFSTR(kUSBVendorID), kAppleVendorID);
//    iokit_cfdictionary_set_short(matchingDict, CFSTR(kUSBProductID), 0x12A8);

    return matchingDict;
}

#pragma mark -

- (void)deviceAdded:(io_iterator_t)anIterator
{
    io_service_t serviceObject;
    while ((serviceObject = IOIteratorNext(anIterator)))
    {
        IOUSBDevice *device = [[IOUSBDevice alloc] initWithIoServiceT:serviceObject];
        if (device)
        {
            self.deviceAddedBlock(device);
        }
        IOObjectRelease(serviceObject);
    }
}

- (void)deviceRemoved:(io_iterator_t)anIterator
{

}

@end
