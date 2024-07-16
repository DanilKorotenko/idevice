//
//  UsbMuxConnection.h
//  idevice
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>
#import <Network/Network.h>

#import "UMPacket.h"

NS_ASSUME_NONNULL_BEGIN

@interface UMConnection : NSObject

- (BOOL)sendListDevicesPacket:(NSUInteger *)aTag error:(NSError **)anError;
- (BOOL)sendConnectPacket:(NSUInteger *)aTag deviceId:(NSInteger)aDeviceId error:(NSError **)anError;
- (BOOL)sendGetValuePacket:(NSUInteger *)aTag
    domain:(NSString * _Nullable)aDomain key:(NSString * _Nullable)aKey error:(NSError **)anError;

- (BOOL)receive_packet:(UMPacket *_Nonnull*_Nonnull)payload;

@end

NS_ASSUME_NONNULL_END
