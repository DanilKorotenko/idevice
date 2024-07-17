//
//  UsbMuxDeviceInfo.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UMDevice.h"
#import "UMConnection.h"
#import "UMDeviceMessage.h"

/*
Printing description of ((__NSDictionaryM *)0x0000600002f44940):
{
    DeviceID = 19;
    MessageType = Attached;
    Properties =     {
        ConnectionSpeed = 480000000;
        ConnectionType = USB;
        DeviceID = 19;
        LocationID = 17895424;
        ProductID = 4776;
        SerialNumber = "00008020-000E1C121EBA002E";
        USBSerialNumber = 00008020000E1C121EBA002E;
    };
}
*/
@interface UMDevice ()

@property (readonly) NSDictionary *deviceInfoDictionary;
@property (readonly) UMConnection *connection;
@property (readonly) BOOL isConnected;

@end

@implementation UMDevice

@synthesize deviceInfoDictionary;
@synthesize properties;
@synthesize connection;
//@synthesize allValues;
@synthesize isConnected;
@synthesize daemonName;

- (instancetype)initWithDeviceInfoDictionary:(NSDictionary *)aDeviceInfoDictionary
{
    self = [super init];
    if (self)
    {
        deviceInfoDictionary = aDeviceInfoDictionary;
    }
    return self;
}

- (NSString *)description
{
    return [deviceInfoDictionary description];
}

#pragma mark -

- (NSInteger)deviceID
{
    return [(NSNumber *)self.deviceInfoDictionary[@"DeviceID"] integerValue];
}

- (UMDeviceMessageType)messageType
{
//    NSString *messageTypeString = self.deviceInfoDictionary[@"MessageType"];
//    if ([messageTypeString isEqualToString:@"Attached"])
//    {
        return UMDeviceMessageTypeAttached;
//    }
}

- (UMDeviceProperties *)properties
{
    if (properties == nil)
    {
        properties = [[UMDeviceProperties alloc] initWithDictionary:self.deviceInfoDictionary[@"Properties"]];
    }
    return properties;
}

#pragma mark -

- (NSString *)daemonName
{
    if (daemonName == nil)
    {
        if (self.isConnected)
        {
            if ([self.connection serviceSend:[UMDeviceMessage messageRequestQueryType].xmlData])
            {
                UMDeviceMessage *message = nil;
                [self.connection serviceReceiveMessage:&message];
                NSLog(@"Message: %@", message);
            }
        }
    }
    return daemonName;
}

//- (NSDictionary *)allValues
//{
//    if (allValues == nil)
//    {
//        UMConnection *connection = self.connection;
//    }
//    return allValues;
//}

#pragma mark -

- (UMConnection *)connection
{
    if (connection == nil)
    {
        connection = [[UMConnection alloc] init];

        NSUInteger tag = 0;
        NSError *error = nil;

        if (connection != nil && [connection sendUsbMuxConnectPacket:&tag deviceId:self.deviceID error:&error])
        {
            UMPacket *packet = nil;
            if (![connection receiveUsbMuxPacket:&packet])
            {
                connection = nil;
            }
            else if (packet.result != UsbmuxdResultOK)
            {
                connection = nil;
            }
        }
    }
    return connection;
}

- (BOOL)connect
{
    return self.connection != nil;
}

- (BOOL)isConnected
{
    if (!isConnected)
    {
        isConnected = [self connect];
    }
    return isConnected;
}

@end
