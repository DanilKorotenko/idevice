//
//  UsbMuxDeviceInfo.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UsbMuxDevice.h"

@interface UsbMuxDevice ()

@property (readonly) NSDictionary *deviceInfoDictionary;

@end

@implementation UsbMuxDevice

@synthesize deviceInfoDictionary;

- (instancetype)initWithDeviceInfoDictionary:(NSDictionary *)aDeviceInfoDictionary
{
    self = [super init];
    if (self)
    {
        deviceInfoDictionary = aDeviceInfoDictionary;
    }
    return self;
}

@end
