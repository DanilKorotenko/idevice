//
//  UsbMuxDeviceInfo.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>
#import "UMDeviceProperties.h"
#import "UMConnection.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UMDeviceMessageType)
{
    UMDeviceMessageTypeAttached = 0,
};

@interface UMDevice : NSObject

- (instancetype)initWithDeviceInfoDictionary:(NSDictionary *)aDeviceInfoDictionary;

@property (readonly) NSInteger deviceID; // mux_id, handle
@property (readonly) UMDeviceProperties *properties;

@property (readonly) UMDeviceMessageType messageType;

@property (readonly) NSDictionary *allValues;

@end

NS_ASSUME_NONNULL_END
