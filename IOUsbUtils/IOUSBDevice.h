//
//  IOUSBDevice.h
//  idevice
//
//  Created by Danil Korotenko on 6/18/24.
//

#import <Foundation/Foundation.h>
#import <IOKit/usb/IOUSBLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface IOUSBDevice : NSObject

- (instancetype)initWithIoServiceT:(io_service_t)aService;

@property(readonly) NSString *name;
@property(readonly) NSString *vendorID;
@property(readonly) NSString *productID;

@end

NS_ASSUME_NONNULL_END
