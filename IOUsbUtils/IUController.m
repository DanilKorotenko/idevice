//
//  IUController.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IUController.h"

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

@interface IUController ()

@property (strong) void (^deviceAddedBlock)(IUDevice *aDevice);

@property (assign) IONotificationPortRef    notifyPort;

- (void)deviceAdded:(io_iterator_t)anIterator;
- (void)deviceRemoved:(io_iterator_t)anIterator;

@end

#pragma mark -

static void staticDeviceAdded(void *refCon, io_iterator_t iterator)
{
    IUController *controller = (__bridge IUController *)(refCon);
    if (controller)
    {
        [controller deviceAdded:iterator];
    }
}

//static void staticDeviceRemoved(void *refCon, io_iterator_t iterator)
//{
//    IUController *controller = (__bridge IUController *)(refCon);
//    if (controller)
//    {
//        [controller deviceRemoved:iterator];
//    }
//}

#pragma mark -

@implementation IUController
{
    io_iterator_t _deviceAddedIter;
    io_iterator_t _deviceRemovedIter;
    dispatch_queue_t _queue;
}

+ (IUController *)sharedController
{
    static IUController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedController = [[IUController alloc] init];
    });
    return sharedController;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("IUControllerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark -

- (BOOL)startWatchingWithBlock:(void (^)(IUDevice *aDevice))aBlock
{
    self.deviceAddedBlock = aBlock;

    CFMutableDictionaryRef matchingDict = [self createMatchingDict];
    if (matchingDict == NULL)
    {
        return NO;
    }

    self.notifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    IONotificationPortSetDispatchQueue(self.notifyPort, _queue);

    IOServiceAddMatchingNotification(self.notifyPort,
        kIOFirstMatchNotification, matchingDict,
        staticDeviceAdded, (__bridge void *)(self), &_deviceAddedIter);

    [self deviceAdded:_deviceAddedIter];

    return YES;
}

- (void)reenumerateDevices
{
    CFMutableDictionaryRef matchingDict = [self createMatchingDict];
    io_iterator_t iterator;
    IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator);
    [self deviceAdded:iterator];
}

#pragma mark -

- (void)deviceAdded:(io_iterator_t)anIterator
{
    io_service_t serviceObject;
    while (IOIteratorIsValid(anIterator) && (serviceObject = IOIteratorNext(anIterator)))
    {
        IUDevice *device = [[IUDevice alloc] initWithIoServiceT:serviceObject];
        if (device)
        {
            if (self.deviceAddedBlock)
            {
                self.deviceAddedBlock(device);
            }
        }
        IOObjectRelease(serviceObject);
    }
}

- (void)deviceRemoved:(io_iterator_t)anIterator
{

}

#pragma mark -

- (CFMutableDictionaryRef)createMatchingDict
{
    CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);

// NOTE: If we set vendorID then we have to set product ID. We cannot set only one of this.
//    iokit_cfdictionary_set_short(matchingDict, CFSTR(kUSBVendorID), kAppleVendorID);
//    iokit_cfdictionary_set_short(matchingDict, CFSTR(kUSBProductID), 0x12A8);

    return matchingDict;
}

@end
