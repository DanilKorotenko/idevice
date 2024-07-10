//
//  IOUSBInterface.h
//  idevice
//
//  Created by Danil Korotenko on 7/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IOUSBInterface : NSObject

- (instancetype)initWithNumOfEndpoints:(NSUInteger)aNumOfEndpoints name:(NSString *)aName;

@property (readonly) NSUInteger numberOfEndpoints;
@property (readonly) NSString *name;
@property (readonly) BOOL isMtpPtp;

@end

NS_ASSUME_NONNULL_END
