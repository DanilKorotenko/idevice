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
                @"kLibUSBMuxVersion": @(3)
            };
//	if (!bundle_id)
//    {
//		get_bundle_id();
//	}
//	if (!prog_name) {
//		get_prog_name();
//	}

//	if (bundle_id) {
//		plist_dict_set_item(plist, "BundleID", plist_new_string(bundle_id));
//	}
//	if (prog_name) {
//		plist_dict_set_item(plist, "ProgName", plist_new_string(prog_name));
//	}

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
        //[mutablePayload setObject:@(0x7ef2) forKey:@"PortNumber"];
        [mutablePayload setObject:@(0xf27e) forKey:@"PortNumber"];
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

@end
