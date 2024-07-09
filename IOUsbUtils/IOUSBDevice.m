//
//  IOUSBDevice.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IOUSBDevice.h"
#import <IOKit/IOCFPlugIn.h>

@interface IOUSBDevice ()

@property (readonly) BOOL isApple;
@property (readonly) BOOL isIPhoneProduct;
@property (readonly) NSNumber *vendorIdNumber;
@property (readonly) NSNumber *productIdNumber;

@end

@implementation IOUSBDevice
{
    IOUSBDeviceInterface    **_deviceInterface;
    CFMutableDictionaryRef  _entryProperties;
}

@synthesize name;
@synthesize vendorIdNumber;
@synthesize vendorID;
@synthesize productIdNumber;
@synthesize productID;
@synthesize serial;

- (instancetype)initWithIoServiceT:(io_service_t)aService
{
    self = [super init];
    if (self)
    {
        if (aService == 0)
        {
            return nil;
        }

        IORegistryEntryCreateCFProperties(aService, &_entryProperties, NULL, 0);

        IOCFPlugInInterface     **plugInInterface = NULL;

        SInt32 score;
        kern_return_t kernelReturn = IOCreatePlugInInterfaceForService(aService,
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
}

- (NSString *)description
{
//    NSDictionary *descr = (__bridge NSDictionary *)(_entryProperties);
    NSDictionary *descr =
        @{
            @"name" :       self.name == nil ?      @"<none>" : self.name,
            @"vendorID" :   self.vendorID == nil ?  @"<none>" : self.vendorID,
            @"productID" :  self.productID == nil ? @"<none>" : self.productID,
            @"isApple" :    self.isApple ? @"YES" : @"NO",
            @"isIPhone" :   self.isIPhone ? @"YES" : @"NO"
        };
    return [descr description];
}

#pragma mark -

- (NSString *)name
{
    if (name == nil)
    {
        name = (NSString *)CFDictionaryGetValue(_entryProperties, CFSTR(kUSBProductString));
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return name;
}

- (NSNumber *)vendorIdNumber
{
    if (vendorIdNumber == nil)
    {
        UInt16 value;
        (*_deviceInterface)->GetDeviceVendor(_deviceInterface, &value);
        vendorIdNumber = [NSNumber numberWithUnsignedInteger:value];
    }
    return vendorIdNumber;
}

- (NSString *)vendorID
{
    if (vendorID == nil)
    {
        vendorID = [NSString stringWithFormat: @"0x%04x", self.vendorIdNumber.unsignedIntValue];
    }
    return vendorID;
}

- (NSNumber *)productIdNumber
{
    if (productIdNumber == nil)
    {
        UInt16 value;
        (*_deviceInterface)->GetDeviceProduct(_deviceInterface, &value);
        productIdNumber = [NSNumber numberWithUnsignedInteger:value];
    }
    return productIdNumber;
}

- (NSString *)productID
{
    if (productID == nil)
    {
        productID = [NSString stringWithFormat: @"0x%04x", self.productIdNumber.unsignedIntValue];
    }
    return productID;
}

- (NSString *)serial
{
    if (serial == nil)
    {
        serial = (NSString *)CFDictionaryGetValue(_entryProperties, CFSTR(kUSBSerialNumberString));
        serial = [serial stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return serial;
}

//- (BOOL)supportsIPhoneOS
//{
//    NSNumber *value = (NSNumber *)CFDictionaryGetValue(_entryProperties, CFSTR("SupportsIPhoneOS"));
//    return value.boolValue;
//}

- (BOOL)isApple
{
    return self.vendorIdNumber.unsignedIntegerValue == kAppleVendorID;
}

- (BOOL)isIPhoneProduct
{
    static NSArray *iPhoneProducts = nil;
    if (iPhoneProducts == nil)
    {
        iPhoneProducts =
        @[
            @(0x1290), //  iPhone
            @(0x1292), //  iPhone 3G
            @(0x1294), //  iPhone 3GS
            @(0x1297), //  iPhone 4
            @(0x129c), //  iPhone 4(CDMA)
            @(0x129d), //  iPhone
            @(0x12a0), //  iPhone 4S
            @(0x12a1), //  iPhone
            @(0x12a8), //  iPhone 5/5C/5S/6/SE/7/8/X/XR
            @(0x12ac), //  iPhone
        ];
    }
    return [iPhoneProducts containsObject:self.productIdNumber];
}

- (BOOL)isIPhone
{
    return self.isApple && self.isIPhoneProduct;
}

#pragma mark -

- (BOOL)eject
{
    kern_return_t kernelReturn = (*_deviceInterface)->USBDeviceReEnumerate(_deviceInterface, kUSBReEnumerateCaptureDeviceMask);
    if (kernelReturn)
    {
        return NO;
    }
    return YES;
}

@end
