//
//  UsbMuxPacket.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMPacket : NSObject

- (instancetype)initWithMessage:(NSString *)aMessageType;
- (instancetype)initWithPayloadData:(NSData *)aPayloadData;

@property (readonly) NSData *xmlData;

@property (readwrite) NSUInteger tag;

@property (readonly) NSArray *deviceList;

@end

NS_ASSUME_NONNULL_END
