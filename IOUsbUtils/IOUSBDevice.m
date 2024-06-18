//
//  IOUSBDevice.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IOUSBDevice.h"

@interface IOUSBDevice ()

@property (readonly) CFMutableDictionaryRef entryProperties;

@end

@implementation IOUSBDevice
{
    io_service_t            _ioService;
    IOUSBDeviceInterface    **_deviceInterface;
}

@synthesize entryProperties;
@synthesize name;
@synthesize vendorID;
@synthesize productID;

- (instancetype)initWithIoServiceT:(io_service_t)aService
{
    self = [super init];
    if (self)
    {
        if (aService == 0)
        {
            return nil;
        }
        _ioService = aService;

        IOCFPlugInInterface     **plugInInterface = NULL;

        SInt32 score;
        kern_return_t kernelReturn = IOCreatePlugInInterfaceForService(_ioService,
            kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
            &plugInInterface, &score);

        if ((kernelReturn != kIOReturnSuccess) || !plugInInterface)
        {
            return nil;
        }

        HRESULT result = (*plugInInterface)->QueryInterface(plugInInterface,
            CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
            (LPVOID *)&_deviceInterface);

        // don’t need the intermediate plug-in after device interface is created
        (*plugInInterface)->Release(plugInInterface);

        if (result || !_deviceInterface)
        {
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_ioService != 0)
    {
        IOObjectRelease(_ioService);
    }
}

- (NSString *)description
{
    NSDictionary *descr =
        @{
            @"name" :       self.name == nil ? @"<none>" : self.name,
            @"vendorID" :   self.vendorID == nil ? @"<none>" : self.vendorID,
            @"productID" :  self.productID == nil ? @"<none>" : self.productID
        };
    return [descr description];
}

#pragma mark -

- (CFMutableDictionaryRef)entryProperties
{
    if (entryProperties == NULL)
    {
        IORegistryEntryCreateCFProperties(_ioService, &entryProperties, NULL, 0);
    }
    return entryProperties;
}

- (NSString *)name
{
    if (name == nil)
    {
        name = (NSString *)CFDictionaryGetValue(self.entryProperties, CFSTR(kUSBProductString));
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return name;
}

- (NSString *)vendorID
{
    if (vendorID == nil)
    {
        UInt16 vendorIDNumber;
        (*_deviceInterface)->GetDeviceVendor(_deviceInterface, &vendorIDNumber);
        vendorID = [NSString stringWithFormat: @"0x%04x", vendorIDNumber];
    }
    return vendorID;
}

- (NSString *)productID
{
    if (productID == nil)
    {
        UInt16 productIDNumber;
        (*_deviceInterface)->GetDeviceProduct(_deviceInterface, &productIDNumber);
        productID = [NSString stringWithFormat: @"0x%04x", productIDNumber];
    }
    return productID;
}

@end
