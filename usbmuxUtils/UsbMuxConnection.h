//
//  UsbMuxConnection.h
//  idevice
//
//  Created by Danil Korotenko on 7/5/24.
//

#import <Foundation/Foundation.h>
#import <Network/Network.h>

NS_ASSUME_NONNULL_BEGIN

@class UsbMuxConnection;

@protocol UsbMuxConnectionDelegate <NSObject>

@required

- (void)log:(NSString *)aLogMessage;
- (void)stringReceived:(NSString *)aStringReceived;
- (void)didConnect:(UsbMuxConnection *)aConnection;
- (void)connectionCanceled:(UsbMuxConnection *)aConnection;

@end

@interface UsbMuxConnection : NSObject

+ (UsbMuxConnection *)startWithDelegate:(id<UsbMuxConnectionDelegate>)aDelegate;
+ (UsbMuxConnection *)startSynchronously;
+ (UsbMuxConnection *)startWithNWConnection:(nw_connection_t)aConnection
    delegate:(id<UsbMuxConnectionDelegate> _Nullable)aDelegate;

- (void)sendData:(dispatch_data_t)aData
    withSendCompletionBlock:(void (^)(NSError *error))aSendCompletionBlock;
- (void)sendString:(NSString *)aString
    withSendCompletionBlock:(void (^)(NSError *error))aSendCompletionBlock;
- (BOOL)sendStringSynchronously:(NSString *)aString error:(NSError * __autoreleasing *)anError;

- (void)startReceiving;
- (void)reset;
- (BOOL)waitConnected;

@end

NS_ASSUME_NONNULL_END
