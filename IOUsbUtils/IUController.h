//
//  IUController.h
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import <Foundation/Foundation.h>
#import "IUDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface IUController : NSObject

// singleton instance
+ (IUController *)sharedController;

- (BOOL)startWatchingWithBlock:(void (^)(IUDevice *aDevice))aBlock;

- (void)reenumerateDevices;

@end

NS_ASSUME_NONNULL_END
