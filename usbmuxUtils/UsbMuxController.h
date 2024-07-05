//
//  UsbMuxController.h
//  idevice
//
//  Created by Danil Korotenko on 7/4/24.
//

#import <Foundation/Foundation.h>

#import "UsbMuxConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface UsbMuxController : NSObject<UsbMuxConnectionDelegate>

+ (UsbMuxController *)sharedInstance;

- (void)start;

@end

NS_ASSUME_NONNULL_END
