//
//  UsbMuxDeviceProperties.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import "UMDeviceProperties.h"

/*
        ConnectionSpeed = 480000000;
        ConnectionType = USB;
        DeviceID = 19;
        LocationID = 17895424;
        ProductID = 4776;
        SerialNumber = "00008020-000E1C121EBA002E";
        USBSerialNumber = 00008020000E1C121EBA002E;
*/

@interface UMDeviceProperties ()

@property (readonly) NSDictionary *dictionary;

@end

@implementation UMDeviceProperties

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

- (NSString *)description
{
    return [dictionary description];
}

#pragma mark -

- (UMDeviceConnectionType)connectionType
{
//    NSString *connectionTypeString = dictionary[@"ConnectionType"];
//    if ([connectionTypeString isEqualToString:@"USB"])
//    {
        return UMDeviceConnectionTypeUSB;
//    }
}

- (NSString *)udid
{
    return dictionary[@"SerialNumber"];
}

@end
