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

/*
all values
{
    BasebandCertId = 165673526;
    BasebandKeyHashInformation =     {
        AKeyStatus = 64;
        SKeyStatus = 2;
    };
    BasebandSerialNumber = {length = 12, bytes = 0x31c68969bd5b094700000000};
    BasebandVersion = "6.00.00";
    BoardId = 14;
    BuildVersion = 21F90;
    CPUArchitecture = arm64e;
    ChipID = 32800;
    DeviceClass = iPhone;
    DeviceColor = 1;
    DeviceName = "Danil\U2019s iPhone";
    DieID = 3971513824444462;
    HardwareModel = D321AP;
    HasSiDP = 1;
    HumanReadableProductVersionString = "17.5.1";
    PartitionType = "GUID_partition_scheme";
    ProductName = "iPhone OS";
    ProductType = "iPhone11,2";
    ProductVersion = "17.5.1";
    ProductionSOC = 1;
    ProtocolVersion = 2;
    SupportedDeviceFamilies =     (
        1
    );
    TelephonyCapability = 1;
    UniqueChipID = 3971513824444462;
    UniqueDeviceID = "00008020-000E1C121EBA002E";
    WiFiAddress = "a4:d9:31:60:54:33";
}
*/

@interface UMDevice ()

@property (readonly) NSDictionary *deviceInfoDictionary;
@property (readonly) UMConnection *connection;
@property (readonly) BOOL isConnected;
@property (readonly) NSDictionary *allValues;

@end

@implementation UMDevice

@synthesize deviceInfoDictionary;
@synthesize properties;
@synthesize connection;
@synthesize allValues;
@synthesize isConnected;
@synthesize daemonName;
@synthesize serialNumber;

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
                daemonName = message.type;
            }
        }
    }
    return daemonName;
}

- (NSDictionary *)allValues
{
    if (allValues == nil)
    {
        if (self.isConnected)
        {
            if ([self.connection serviceSend:[UMDeviceMessage messageRequestGetValueForDomain:nil key:nil].xmlData])
            {
                UMDeviceMessage *message = nil;
                [self.connection serviceReceiveMessage:&message];
                allValues = message.value;
            }
        }
    }
    return allValues;
}

- (NSString *)deviceName
{
    return self.allValues[@"DeviceName"];
}

- (NSString *)serialNumber
{
    if (serialNumber == nil)
    {
        if (self.isConnected)
        {
            if ([self.connection serviceSend:[UMDeviceMessage messageRequestGetValueForDomain:nil key:@"SerialNumber"].xmlData])
            {
                UMDeviceMessage *message = nil;
                [self.connection serviceReceiveMessage:&message];
                serialNumber = message.value;
            }
        }
    }
    return serialNumber;
}

#pragma mark -

- (UMConnection *)connection
{
    if (connection == nil)
    {
        connection = [UMConnection startNewConnection];

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
