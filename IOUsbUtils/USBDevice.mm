//
//  USBDevice.cpp
//  deviceWatcherCpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#include "USBDevice.hpp"
#import "IOUSBDevice.h"

#include <stdlib.h>

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

void USBDeviceCopyDescription(USBDeviceRef aDevice, CFStringRef *aDescription)
{
    IOUSBDevice *device = (__bridge IOUSBDevice *)aDevice->_usbdevice;
    if (aDescription != NULL)
    {
        *aDescription = (CFStringRef)CFBridgingRetain([device description]);
    }
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
