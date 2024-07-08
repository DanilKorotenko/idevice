//
//  UsbMuxDeviceInfo.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>
#import "UsbMuxDeviceProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface UsbMuxDevice : NSObject

- (instancetype)initWithDeviceInfoDictionary:(NSDictionary *)aDeviceInfoDictionary;

@property (readonly) NSInteger deviceID;
@property (readonly) NSString *messageType;
@property (readonly) UsbMuxDeviceProperties *properties;

@end

NS_ASSUME_NONNULL_END
