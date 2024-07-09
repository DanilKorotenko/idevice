//
//  UsbMuxDeviceProperties.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import "UsbMuxDeviceProperties.h"

/*
        ConnectionSpeed = 480000000;
        ConnectionType = USB;
        DeviceID = 19;
        LocationID = 17895424;
        ProductID = 4776;
        SerialNumber = "00008020-000E1C121EBA002E";
        USBSerialNumber = 00008020000E1C121EBA002E;
*/

@interface UsbMuxDeviceProperties ()

@property (readonly) NSDictionary *dictionary;

@end

@implementation UsbMuxDeviceProperties

@synthesize dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)aDictionary
{
    self = [super init];
    if (self)
    {
        dictionary = aDictionary;
    }
    return self;
}

@end
