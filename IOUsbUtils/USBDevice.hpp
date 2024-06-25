//
//  USBDevice.hpp
//  deviceWatcherCpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#ifndef USBDevice_hpp
#define USBDevice_hpp

#include <stdio.h>
#include <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
    void *_usbdevice;
} USBDevice;

typedef USBDevice* USBDeviceRef;

USBDeviceRef USBDeviceCreateWithIOUSBDevice(void *anIOUSBDevice);
void USBDeviceReleaseAndMakeNull(USBDeviceRef *aDevice);

//bool USBDeviceSupportsIPhoneOS(USBDeviceRef aDevice);
void USBDeviceCopyDescription(USBDeviceRef aDevice, CFStringRef *aDescription);
bool USBDeviceIsIPhone(USBDeviceRef aDevice);
bool USBDeviceEject(USBDeviceRef aDevice);

#ifdef __cplusplus
}
#endif

#endif /* USBDevice_hpp */
