//
//  UsbMuxDeviceInfo.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UMDevice.h"


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
@interface UMDevice ()

@property (readonly) NSDictionary *deviceInfoDictionary;

@end

@implementation UMDevice

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

- (UMDeviceMessageType)messageType
{
//    NSString *messageTypeString = self.deviceInfoDictionary[@"MessageType"];
//    if ([messageTypeString isEqualToString:@"Attached"])
//    {
        return UMDeviceMessageTypeAttached;
//    }
}

- (UMDeviceProperties *)properties
{
    if (properties == nil)
    {
        properties = [[UMDeviceProperties alloc] initWithDictionary:self.deviceInfoDictionary[@"Properties"]];
    }
    return properties;
}


@end
