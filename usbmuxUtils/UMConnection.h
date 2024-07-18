//
//  UsbMuxConnection.h
//  idevice
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>
#import <Network/Network.h>

#import "UMPacket.h"
#import "UMDeviceMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UMConnection : NSObject

+ (UMConnection *)startNewConnection;

- (BOOL)sendUsbMuxListDevicesPacket:(NSUInteger *)aTag error:(NSError **)anError;
- (BOOL)sendUsbMuxConnectPacket:(NSUInteger *)aTag deviceId:(NSInteger)aDeviceId error:(NSError **)anError;
- (BOOL)receiveUsbMuxPacket:(UMPacket *_Nonnull*_Nonnull)payload;

- (BOOL)serviceSend:(NSData *)data;
- (BOOL)serviceReceiveMessage:(UMDeviceMessage *_Nullable*_Nullable)data;

@end

NS_ASSUME_NONNULL_END
