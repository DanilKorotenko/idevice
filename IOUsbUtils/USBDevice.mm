//
//  USBDevice.cpp
//  deviceWatcherCpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#include "USBDevice.hpp"
#import "IUDevice.h"

#import "NSString+SafeUTF8String.h"

USBDeviceRef USBDeviceCreateWithIOUSBDevice(void *anIOUSBDevice)
{
    USBDeviceRef device = (USBDeviceRef)malloc(sizeof(USBDevice));
    device->_usbdevice = anIOUSBDevice;
    return device;
}

void USBDeviceReleaseAndMakeNull(USBDeviceRef *aDevice)
{
    free(*aDevice);
    *aDevice = NULL;
}

//bool USBDeviceSupportsIPhoneOS(USBDeviceRef aDevice)
//{
//    IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
//    return device.supportsIPhoneOS == YES ? true : false;
//}

const char *USBDeviceGetDescription(USBDeviceRef aDevice)
{
    const char *result = NULL;

    IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
    result = GTBGetSafeUTF8String([device description]);

    return result;
}

const char *USBDeviceGetName(USBDeviceRef aDevice)
{
    const char *result = NULL;

    IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
    result = GTBGetSafeUTF8String(device.name);

    return result;
}

const char *USBDeviceGetSerial(USBDeviceRef aDevice)
{
    const char *result = NULL;

    IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
    result = GTBGetSafeUTF8String(device.serial);

    return result;
}

bool USBDeviceIsIPhone(USBDeviceRef aDevice)
{
    bool result = false;
    @autoreleasepool
    {
        IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
        result = device.isIPhone == YES ? true : false;
    }
    return result;
}

bool USBDeviceIsIPad(USBDeviceRef aDevice)
{
    bool result = false;
    @autoreleasepool
    {
        IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
        result = device.isIPad == YES ? true : false;
    }
    return result;
}

bool USBDeviceIsMtpPtp(USBDeviceRef aDevice)
{
    bool result = false;
    @autoreleasepool
    {
        IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
        result = device.isMtpPtp == YES ? true : false;
    }
    return result;
}

bool USBDeviceEject(USBDeviceRef aDevice)
{
    bool result = false;
    @autoreleasepool
    {
        IUDevice *device = (__bridge IUDevice *)aDevice->_usbdevice;
        result = [device eject] == YES ? true : false;
    }
    return result;
}
