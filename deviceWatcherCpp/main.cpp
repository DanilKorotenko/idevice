//
//  main.cpp
//  deviceWatcherCpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#include <iostream>
#include <dispatch/dispatch.h>
#include "IOUSB.hpp"

int main(int argc, const char * argv[])
{
    std::cout << "Hello, Device watcher!\n";
    IOUSBStartWatchingWithBlock(
        ^(USBDeviceRef aDevice)
        {
            CFStringRef description = NULL;
            USBDeviceCopyDescription(aDevice, &description);
            if (description != NULL)
            {
                CFIndex len = CFStringGetLength(description);
                len++;
                char *buffer = (char *)malloc(len);
                CFStringGetCString(description, buffer, len, kCFStringEncodingUTF8);
                std::cout << "Device: " << buffer << std::endl;
                free(buffer);
                CFRelease(description);
            }
//            if (USBDeviceSupportsIPhoneOS(aDevice))
            if (USBDeviceIsIPhone(aDevice))
            {
                std::cout << "Device eject" << std::endl;
                USBDeviceEject(aDevice);
            }
        });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
        ^{
            IOUSBReenumerateDevices();
        });

    dispatch_main();
    return 0;
}
