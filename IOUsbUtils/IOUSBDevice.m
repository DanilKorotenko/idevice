//
//  IOUSBDevice.m
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import "IOUSBDevice.h"
#import <IOKit/IOCFPlugIn.h>
#import "IOUSBInterface.h"

UInt16	Swap16(void *p)
{
    * (UInt16 *) p = CFSwapInt16LittleToHost(*(UInt16 *)p);
    return * (UInt16 *) p;
}

@interface IOUSBDevice ()

@property (readonly) BOOL isApple;
@property (readonly) BOOL isIPhoneProduct;
@property (readonly) NSNumber *vendorIdNumber;
@property (readonly) NSNumber *productIdNumber;
@property (readonly) NSArray *interfaces;

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
@synthesize interfaces;

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

- (NSString *)description
{
//    NSDictionary *descr = (__bridge NSDictionary *)(_entryProperties);
    NSDictionary *descr =
        @{
            @"name" :       self.name == nil ?      @"<none>" : self.name,
            @"vendorID" :   self.vendorID == nil ?  @"<none>" : self.vendorID,
            @"productID" :  self.productID == nil ? @"<none>" : self.productID,
            @"isApple" :    self.isApple ? @"YES" : @"NO",
            @"isIPhone" :   self.isIPhone ? @"YES" : @"NO",
//            @"hasImageInterface" : self.hasImageInterface ? @"YES" : @"NO"
            @"interfaces" : self.interfaces
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

- (BOOL)isMtpPtp
{
    for (IOUSBInterface *interface in self.interfaces)
    {
        if (interface.isMtpPtp)
        {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)interfaces
{
    if (interfaces == nil)
    {
        IOReturn                    kr;
        IOUSBFindInterfaceRequest   request;
        io_iterator_t               iterator;
        io_service_t                usbInterface;
        IOCFPlugInInterface         **plugInInterface = NULL;
        IOUSBInterfaceInterface     **interface = NULL;
        HRESULT                     result;
        SInt32                      score;
        UInt8                       interfaceClass;
        UInt8                       interfaceSubClass;
        UInt8                       interfaceNumEndpoints;

        NSMutableArray *mutableInterfaces = [NSMutableArray array];

        //Placing the constant kIOUSBFindInterfaceDontCare into the following
        //fields of the IOUSBFindInterfaceRequest structure will allow you
        //to find all the interfaces
        request.bInterfaceClass = kIOUSBFindInterfaceDontCare;
        request.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
        request.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
        request.bAlternateSetting = kIOUSBFindInterfaceDontCare;

        //Get an iterator for the interfaces on the device
        kr = (*_deviceInterface)->CreateInterfaceIterator(_deviceInterface, &request, &iterator);
        while ((usbInterface = IOIteratorNext(iterator)))
        {
            //Create an intermediate plug-in
            kr = IOCreatePlugInInterfaceForService(usbInterface, kIOUSBInterfaceUserClientTypeID,
                kIOCFPlugInInterfaceID, &plugInInterface, &score);

            //Release the usbInterface object after getting the plug-in
            kr = IOObjectRelease(usbInterface);
            if ((kr != kIOReturnSuccess) || !plugInInterface)
            {
                printf("Unable to create a plug-in (%08x)\n", kr);
                break;
            }

            //Now create the device interface for the interface
            result = (*plugInInterface)->QueryInterface(plugInInterface,
                CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID),
                (LPVOID *) &interface);

            //No longer need the intermediate plug-in
            (*plugInInterface)->Release(plugInInterface);

            if (result || !interface)
            {
                printf("Couldn’t create a device interface for the interface (%08x)\n", (int) result);
                break;
            }

            //Get interface class and subclass
            kr = (*interface)->GetInterfaceClass(interface, &interfaceClass);
            kr = (*interface)->GetInterfaceSubClass(interface, &interfaceSubClass);

            UInt8 stringIndex = 0;
            kr = (*interface)->USBInterfaceGetStringIndex(interface, &stringIndex);

            NSString *interfaceName = [self getStringFromIndex:stringIndex];
            if (interfaceName == nil)
            {
                continue;
            }
            //Get the number of endpoints associated with this interface
            kr = (*interface)->GetNumEndpoints(interface, &interfaceNumEndpoints);
            if (kr != kIOReturnSuccess)
            {
                printf("Unable to get number of endpoints (%08x)\n", kr);
                (void) (*interface)->USBInterfaceClose(interface);
                (void) (*interface)->Release(interface);
                break;
            }

            [mutableInterfaces addObject:
                [[IOUSBInterface alloc] initWithNumOfEndpoints:interfaceNumEndpoints name:interfaceName]];
        }
        interfaces = [NSArray arrayWithArray:mutableInterfaces];
    }
    return interfaces;
}

- (NSString *)getStringFromIndex:(UInt8)strIndex
{
    Byte buf[256];

    if (strIndex > 0)
    {
        int len;
        buf[0] = 0;
        len = [self getStringDescriptor:strIndex buf:buf len:sizeof(buf)];

        if (len > 2)
        {
            Byte *p;
            for (p = buf + 2; p < buf + len; p += 2)
            {
                Swap16(p);
            }

            NSString *str = [[NSString alloc] initWithCharacters:(const UniChar *)(buf+2) length:(len-2)/2];
            return str;
        }
    }

    return nil;
}

- (int)getStringDescriptor:(UInt8)descIndex buf:(void *)buf len:(UInt16)len
{
    IOUSBDevRequest req;
    UInt8 		desc[256]; // Max possible descriptor length
    int stringLen;
    IOReturn err;
    UInt16 lang = 0;
    if (lang == 0) // set default langID
    {
        lang=0x0409;
    }

    bzero(&req, sizeof(req));
    req.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
    req.bRequest = kUSBRqGetDescriptor;
    req.wValue = (kUSBStringDesc << 8) | descIndex;
    req.wIndex = lang;	// English
    req.wLength = 2;
    req.pData = &desc;
//    verify_noerr(err = (*deviceIntf)->DeviceRequest(deviceIntf, &req));
    err = (*_deviceInterface)->DeviceRequest(_deviceInterface, &req);
    if ( (err != kIOReturnSuccess) && (err != kIOReturnOverrun) )
    {
        return -1;
    }

    // If the string is 0 (it happens), then just return 0 as the length
    //
    stringLen = desc[0];
    if (stringLen == 0)
    {
        return 0;
    }
    
    // OK, now that we have the string length, make a request for the full length
    //
	bzero(&req, sizeof(req));
    req.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
    req.bRequest = kUSBRqGetDescriptor;
    req.wValue = (kUSBStringDesc << 8) | descIndex;
    req.wIndex = lang;	// English
    req.wLength = stringLen;
    req.pData = buf;
    
//    verify_noerr(err = (*deviceIntf)->DeviceRequest(deviceIntf, &req));
    err = (*_deviceInterface)->DeviceRequest(_deviceInterface, &req);
    if ( err )
    {
        return -1;
    }

    return req.wLenDone;
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
