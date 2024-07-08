//
//  UsbMuxPacket.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import "UsbMuxPacket.h"

@interface UsbMuxPacket ()

@property (readonly) NSDictionary *payload;

@end

@implementation UsbMuxPacket

@synthesize payload;
@synthesize xmlData;

- (instancetype)initWithMessage:(NSString *)aMessageType
{
    self = [super init];
    if (self)
    {
        payload = @{
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

@end