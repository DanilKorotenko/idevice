//
//  ICController.h
//  idevice
//
//  Created by Danil Korotenko on 7/9/24.
//

#import <Foundation/Foundation.h>
#import <ImageCaptureCore/ImageCaptureCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICController : NSObject<ICDeviceBrowserDelegate>

+ (ICController *)sharedInstance;

@property (readonly) NSArray *devices;

@end

NS_ASSUME_NONNULL_END
