//
//  UsbMuxDeviceInfo.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UsbMuxDevice : NSObject

- (instancetype)initWithDeviceInfoDictionary:(NSDictionary *)aDeviceInfoDictionary;

@end

NS_ASSUME_NONNULL_END
