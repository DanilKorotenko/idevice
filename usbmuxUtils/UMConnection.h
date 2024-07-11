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

@class UMConnection;

@protocol UMConnectionDelegate <NSObject>

@required

- (void)log:(NSString *)aLogMessage;
- (void)stringReceived:(NSString *)aStringReceived;
- (void)didConnect:(UMConnection *)aConnection;
- (void)connectionCanceled:(UMConnection *)aConnection;

@end

@interface UMConnection : NSObject

+ (UMConnection *)startWithDelegate:(id<UMConnectionDelegate>)aDelegate;

- (BOOL)sendListDevicesPacket:(NSUInteger *)aTag error:(NSError **)anError;

- (BOOL)receive_packet:(UMPacket *_Nonnull*_Nonnull)payload;

- (void)reset;
- (BOOL)waitConnected;

@end

NS_ASSUME_NONNULL_END
