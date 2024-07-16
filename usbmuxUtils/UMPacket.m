//
//  UsbMuxPacket.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import "UMPacket.h"
#import "UMDevice.h"

@interface UMPacket ()

@property (readonly) NSDictionary *payload;

@end

@implementation UMPacket

@synthesize payload;
@synthesize xmlData;

- (instancetype)initWithMessage:(NSString *)aMessageType
{
    self = [super init];
    if (self)
    {
        payload =
            @{
                @"ClientVersionString": @"usbmuxd-323",
                @"MessageType": aMessageType,
                @"kLibUSBMuxVersion": @(3),
                @"ProgName": [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] lastPathComponent],
                @"BundleId": @"com.danilkorotenko.idevice"
            };
    }
    return self;
}

- (instancetype)initWithConnectDeviceId:(NSInteger)aDeviceId
{
    self = [self initWithMessage:@"Connect"];
    if (self)
    {
        NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionaryWithDictionary:payload];
        [mutablePayload setObject:@(aDeviceId) forKey:@"DeviceID"];
        [mutablePayload setObject:@(0x7ef2) forKey:@"PortNumber"];
        //[mutablePayload setObject:@(0xf27e) forKey:@"PortNumber"];
        payload = [NSDictionary dictionaryWithDictionary:mutablePayload];
    }
    return self;
}

- (instancetype)initWithGetValueForDomain:(NSString *)aDomain key:(NSString *)aKey
{
    self = [super init];
    if (self)
    {
        NSMutableDictionary *mutablePayload = [NSMutableDictionary dictionary];
        [mutablePayload setObject:[[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] lastPathComponent]
            forKey:@"Label"];
        if (aDomain)
        {
            [mutablePayload setObject:aDomain forKey:@"Domain"];
        }
        if (aKey)
        {
            [mutablePayload setObject:aKey forKey:@"Key"];
        }
        [mutablePayload setObject:@"GetValue" forKey:@"Request"];

        payload = [NSDictionary dictionaryWithDictionary:mutablePayload];
    }
    return self;
}

- (instancetype)initWithPayloadData:(NSData *)aPayloadData
{
    self = [super init];
    if (self)
    {
        NSError *error = nil;
        payload = [NSPropertyListSerialization propertyListWithData:aPayloadData options:NSPropertyListImmutable format:NULL
            error:&error];
    }
    return self;
}

- (NSData *)xmlData
{
    if (xmlData == nil)
    {
        NSError *error = nil;
        xmlData = [NSPropertyListSerialization dataWithPropertyList:self.payload format:NSPropertyListXMLFormat_v1_0 options:0
            error:&error];
    }
    return xmlData;
}

#pragma mark -

- (NSArray *)deviceList
{
    NSArray *result = nil;

    NSArray *deviceList = self.payload[@"DeviceList"];
    if (deviceList.count > 0)
    {
        NSMutableArray *deviceInfoList = [NSMutableArray array];
        for (NSDictionary *deviceInfo in deviceList)
        {
            [deviceInfoList addObject:[[UMDevice alloc] initWithDeviceInfoDictionary:deviceInfo]];
        }
        result = [NSArray arrayWithArray:deviceInfoList];
    }

    return result;
}

- (UsbmuxdResult)result
{
    return (UsbmuxdResult)((NSNumber *)self.payload[@"Result"]).integerValue;
}

@end
