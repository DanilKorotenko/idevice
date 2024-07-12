//
//  UsbMuxPacket.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UsbmuxdResult)
{
    UsbmuxdResultOK = 0,
    UsbmuxdResultBADCOMMAND = 1,
    UsbmuxdResultBADDEV = 2,
    UsbmuxdResultCONNREFUSED = 3,
    // ???
    // ???
    UsbmuxdResultBADVERSION = 6,
};

@interface UMPacket : NSObject

- (instancetype)initWithMessage:(NSString *)aMessageType;
- (instancetype)initWithConnectDeviceId:(NSInteger)aDeviceId;
- (instancetype)initWithGetValueForDomain:(NSString *)aDomain key:(NSString *)aKey;

- (instancetype)initWithPayloadData:(NSData *)aPayloadData;

@property (readonly) NSData *xmlData;

@property (readwrite) NSUInteger tag;

@property (readonly) NSArray *deviceList;

@property (readonly) UsbmuxdResult result;

@end

NS_ASSUME_NONNULL_END
