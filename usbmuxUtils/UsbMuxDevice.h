//
//  UsbMuxDeviceInfo.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>
#import "UsbMuxDeviceProperties.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UsbMuxDeviceMessageType)
{
    UsbMuxDeviceMessageTypeAttached = 0,
};

@interface UsbMuxDevice : NSObject

- (instancetype)initWithDeviceInfoDictionary:(NSDictionary *)aDeviceInfoDictionary;

@property (readonly) NSInteger deviceID;
@property (readonly) UsbMuxDeviceProperties *properties;

@property (readonly) UsbMuxDeviceMessageType messageType;

@end

NS_ASSUME_NONNULL_END
