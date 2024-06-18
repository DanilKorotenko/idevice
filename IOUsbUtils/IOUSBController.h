//
//  IOUSBController.h
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import <Foundation/Foundation.h>
#import "IOUSBDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface IOUSBController : NSObject

// singleton instance
+ (IOUSBController *)sharedController;

@property (strong) void (^deviceAddedBlock)(IOUSBDevice *aDevice);

- (BOOL)startWatching;

@end

NS_ASSUME_NONNULL_END
