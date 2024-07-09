//
//  USBDevice.cpp
//  deviceWatcherCpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#include "USBDevice.hpp"
#import "IOUSBDevice.h"

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
//    IOUSBDevice *device = (__bridge IOUSBDevice *)aDevice->_usbdevice;
//    return device.supportsIPhoneOS == YES ? true : false;
//}

const char *USBDeviceGetDescription(USBDeviceRef aDevice)
{
    IOUSBDevice *device = (__bridge IOUSBDevice *)aDevice->_usbdevice;
    return GetSafeUTF8String([device description]);
}

const char *USBDeviceGetName(USBDeviceRef aDevice)
{
    IOUSBDevice *device = (__bridge IOUSBDevice *)aDevice->_usbdevice;
    return GetSafeUTF8String(device.name);
}

const char *USBDeviceGetSerial(USBDeviceRef aDevice)
{
    IOUSBDevice *device = (__bridge IOUSBDevice *)aDevice->_usbdevice;
    return GetSafeUTF8String(device.serial);
}

bool USBDeviceIsIPhone(USBDeviceRef aDevice)
{
    IOUSBDevice *device = (__bridge IOUSBDevice *)aDevice->_usbdevice;
    return device.isIPhone == YES ? true : false;
}

bool USBDeviceEject(USBDeviceRef aDevice)
{
    IOUSBDevice *device = (__bridge IOUSBDevice *)aDevice->_usbdevice;
    return [device eject] == YES ? true : false;
}
