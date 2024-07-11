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
const char *USBDeviceGetDescription(USBDeviceRef aDevice);
const char *USBDeviceGetName(USBDeviceRef aDevice);
const char *USBDeviceGetSerial(USBDeviceRef aDevice);

bool USBDeviceIsIPhone(USBDeviceRef aDevice);
bool USBDeviceIsMtpPtp(USBDeviceRef aDevice);


bool USBDeviceEject(USBDeviceRef aDevice);

#ifdef __cplusplus
}
#endif

#endif /* USBDevice_hpp */
