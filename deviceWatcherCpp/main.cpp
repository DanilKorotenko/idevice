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
                USBDeviceEject(aDevice);
            }
        });
    dispatch_main();
    return 0;
}
