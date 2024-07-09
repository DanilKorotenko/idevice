//
//  UsbMuxController.h
//  idevice
//
//  Created by Danil Korotenko on 7/4/24.
//

#import <Foundation/Foundation.h>

#import "UMConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface UMController : NSObject<UMConnectionDelegate>

+ (UMController *)sharedInstance;

@property (readonly) NSArray *devices;

@end

NS_ASSUME_NONNULL_END
