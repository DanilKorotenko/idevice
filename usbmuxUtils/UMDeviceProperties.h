//
//  UsbMuxDeviceProperties.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UMDeviceConnectionType)
{
    UMDeviceConnectionTypeUSB = 0,
};

@interface UMDeviceProperties : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)aDictionary;

@property (readonly) UMDeviceConnectionType connectionType;
@property (readonly) NSString *udid;

@end

NS_ASSUME_NONNULL_END
