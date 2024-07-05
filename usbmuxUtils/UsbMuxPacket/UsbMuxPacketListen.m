//
//  UsbMuxPacketListen.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UsbMuxPacketListen.h"

@implementation UsbMuxPacketListen

- (dispatch_time_t)timeout
{
    return dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30);
}

@end
