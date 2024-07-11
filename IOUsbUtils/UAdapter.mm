//
//  UAdapter.mm
//
//  Created by Danil Korotenko on 6/19/24.
//

#include "UAdapter.hpp"
#import "IUController.h"

bool IOUSBStartWatchingWithBlock(void (^block)(USBDeviceRef aDevice))
{
    BOOL result =[[IUController sharedController] startWatchingWithBlock:
        ^(IUDevice * _Nonnull aDevice)
        {
            USBDeviceRef device = USBDeviceCreateWithIOUSBDevice((__bridge void *)aDevice);
            block(device);
            USBDeviceReleaseAndMakeNull(&device);
        }];
    return result == YES ? true : false;
}

void IOUSBReenumerateDevices()
{
    [[IUController sharedController] reenumerateDevices];
}
