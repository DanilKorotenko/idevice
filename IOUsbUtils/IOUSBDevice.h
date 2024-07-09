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
@property(readonly) NSString *serial;
//@property(readonly) BOOL supportsIPhoneOS;
@property(readonly) BOOL isIPhone;
@property(readonly) BOOL hasImageInterface;

// Process must be superuser, instead nothing will happen
- (BOOL)eject;

@end

NS_ASSUME_NONNULL_END
