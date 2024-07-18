//
//  UMDeviceMessage.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/16/24.
//

#import "UMDeviceMessage.h"

@interface UMDeviceMessage ()

@property (readonly) NSMutableDictionary *dictionary;

@property (readwrite) NSString *domain;
@property (readwrite) NSString *key;

@end

// This is adapter to mutable dictionary
@implementation UMDeviceMessage

@synthesize dictionary;

+ (UMDeviceMessage *)messageRequestQueryType
{
    return [[UMDeviceMessage alloc] initMessageWithRequest:@"QueryType"];
}

+ (UMDeviceMessage *)messageRequestGetValueForDomain:(NSString *)aDomain key:(NSString *)aKey
{
    UMDeviceMessage *result = [[UMDeviceMessage alloc] initMessageWithRequest:@"GetValue"];
    if (aDomain)
    {
        result.domain = aDomain;
    }
    if (aKey)
    {
        result.key = aKey;
    }
    return result;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithRequest:(NSString *)aType
{
    self = [self init];
    if (self)
    {
        dictionary[@"Request"] = aType;
    }
    return self;
}

- (instancetype)initMessageWithRequest:(NSString *)aType
{
    self = [self initWithRequest:aType];
    if (self)
    {
        dictionary[@"ProtocolVersion"] = @"2";
        dictionary[@"Label"] = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] lastPathComponent];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)aData
{
    self = [super init];
    if (self)
    {
        NSError *error = nil;
        NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:aData options:NSPropertyListImmutable format:NULL
            error:&error];
        if (dict)
        {
            dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
        else
        {
            self = nil;
        }
    }
    return self;
}

#pragma mark -

- (NSString *)request
{
    return dictionary[@"Request"];
}

- (NSString *)type
{
    return dictionary[@"Type"];
}

- (id)value
{
    return dictionary[@"Value"];
}

- (NSString *)error
{
    return dictionary[@"Error"];
}

- (NSString *)domain
{
    return dictionary[@"Domain"];
}

- (void)setDomain:(NSString *)domain
{
    dictionary[@"Domain"] = domain;
}

- (NSString *)key
{
    return dictionary[@"Key"];
}

- (void)setKey:(NSString *)key
{
    dictionary[@"Key"] = key;
}


#pragma mark -

- (NSData *)xmlData
{
    NSError *error = nil;
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:self.dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    return xmlData;
}

@end
