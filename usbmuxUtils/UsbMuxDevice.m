//
//  UsbMuxDeviceInfo.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UsbMuxDevice.h"


/*
Printing description of ((__NSDictionaryM *)0x0000600002f44940):
{
    DeviceID = 19;
    MessageType = Attached;
    Properties =     {
        ConnectionSpeed = 480000000;
        ConnectionType = USB;
        DeviceID = 19;
        LocationID = 17895424;
        ProductID = 4776;
        SerialNumber = "00008020-000E1C121EBA002E";
        USBSerialNumber = 00008020000E1C121EBA002E;
    };
}
*/
@interface UsbMuxDevice ()

@property (readonly) NSDictionary *deviceInfoDictionary;

@end

@implementation UsbMuxDevice

@synthesize deviceInfoDictionary;
@synthesize properties;

- (instancetype)initWithDeviceInfoDictionary:(NSDictionary *)aDeviceInfoDictionary
{
    self = [super init];
    if (self)
    {
        deviceInfoDictionary = aDeviceInfoDictionary;
    }
    return self;
}

- (NSInteger)deviceID
{
    return [(NSNumber *)self.deviceInfoDictionary[@"DeviceID"] integerValue];
}

- (NSString *)messageType
{
    return self.deviceInfoDictionary[@"MessageType"];
}

- (UsbMuxDeviceProperties *)properties
{
    if (properties == nil)
    {
        properties = [[UsbMuxDeviceProperties alloc] initWithDictionary:self.deviceInfoDictionary[@"Properties"]];
    }
    return properties;
}


@end
