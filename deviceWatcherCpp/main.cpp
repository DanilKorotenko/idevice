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
            if (USBDeviceSupportsIPhoneOS(aDevice))
            {
                std::cout << "Device added" << std::endl;
//                USBDeviceEject(aDevice);
            }
        });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
        ^{
            IOUSBReenumerateDevices();
        });

    dispatch_main();
    return 0;
}
