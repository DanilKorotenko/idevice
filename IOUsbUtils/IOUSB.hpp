//
//  IOUSBControllerAdapter.hpp
//  deviceWatcherCpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#ifndef IOUSBControllerAdapter_hpp
#define IOUSBControllerAdapter_hpp

#include "USBDevice.hpp"

#ifdef __cplusplus
extern "C"
{
#endif

bool IOUSBStartWatchingWithBlock(void (^block)(USBDeviceRef aDevice));
void IOUSBReenumerateDevices();

#ifdef __cplusplus
}
#endif


#endif /* IOUSBControllerAdapter_hpp */
