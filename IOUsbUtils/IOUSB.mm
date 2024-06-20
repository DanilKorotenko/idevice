//
//  IOUSBControllerAdapter.cpp
//  deviceWatcherCpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#include "IOUSB.hpp"
#import "IOUSBController.h"

bool IOUSBStartWatchingWithBlock(void (^block)(USBDeviceRef aDevice))
{
    BOOL result =[[IOUSBController sharedController] startWatchingWithBlock:
        ^(IOUSBDevice * _Nonnull aDevice)
        {
            USBDeviceRef device = USBDeviceCreateWithIOUSBDevice((__bridge void *)aDevice);
            block(device);
            USBDeviceReleaseAndMakeNull(&device);
        }];
    return result == YES ? true : false;
}

void IOUSBReenumerateDevices()
{
    [[IOUSBController sharedController] reenumerateDevices];
}
