//
//  UMDeviceMessage.h
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/16/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMDeviceMessage : NSObject

+ (UMDeviceMessage *)messageRequestQueryType;
+ (UMDeviceMessage *)messageRequestGetValueForDomain:(NSString * _Nullable)aDomain key:(NSString *_Nullable)aKey;

- (instancetype)initWithRequest:(NSString *)aType;
- (instancetype)initMessageWithRequest:(NSString *)aType;

- (instancetype)initWithData:(NSData *)aData;

@property(readonly) NSData *xmlData;

@property(readonly) NSString *request;
@property(readonly) NSString *type;
@property(readonly) NSString *error;
@property(readonly) id value;

@end

NS_ASSUME_NONNULL_END
