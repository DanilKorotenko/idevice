//
//  UAdapter.hpp
//
//  Created by Danil Korotenko on 6/19/24.
//

#ifndef UAdapter_hpp
#define UAdapter_hpp

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


#endif /* UAdapter_hpp */
