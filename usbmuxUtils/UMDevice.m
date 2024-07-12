//
//  UsbMuxDeviceInfo.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/5/24.
//

#import "UMDevice.h"
#import "UMConnection.h"

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

@end

@implementation UMDevice

@synthesize deviceInfoDictionary;
@synthesize properties;
@synthesize connection;
@synthesize allValues;

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

- (NSDictionary *)allValues
{
    if (allValues == nil)
    {
        UMConnection *connection = self.connection;
        while (!connection)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
            connection = self.connection;
        }
        NSUInteger tag = 0;
        NSError *error = nil;
        if ([connection sendGetValuePacket:&tag domain:nil key:nil error:&error])
        {
            UMPacket *packet = nil;
            if ([connection receive_packet:&packet])
            {
                NSLog(@"packet: %@", packet);
            }

        }
    }
    return allValues;
}



#pragma mark -

- (UMConnection *)connection
{
    if (connection == nil)
    {
        connection = [UMConnection startWithDelegate:self];
        [connection waitConnected];
        NSUInteger tag = 0;
        NSError *error = nil;

        if ([connection sendConnectPacket:&tag deviceId:self.deviceID error:&error])
        {
            UMPacket *packet = nil;
            if (![connection receive_packet:&packet])
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

- (void)connectionCanceled:(nonnull UMConnection *)aConnection
{
    connection = nil;
}

- (void)didConnect:(nonnull UMConnection *)aConnection
{

}

- (void)log:(nonnull NSString *)aLogMessage
{
    NSLog(@"%@", aLogMessage);
}

- (void)stringReceived:(nonnull NSString *)aStringReceived
{ 

}

@end
