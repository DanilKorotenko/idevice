//
//  UsbMuxPacket.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UsbMuxPacket : NSObject

@property(readonly) dispatch_time_t timeout;

@end

NS_ASSUME_NONNULL_END
