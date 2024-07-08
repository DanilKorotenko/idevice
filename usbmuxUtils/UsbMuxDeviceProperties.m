//
//  UsbMuxDeviceProperties.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/8/24.
//

#import "UsbMuxDeviceProperties.h"

@interface UsbMuxDeviceProperties ()

@property (readonly) NSDictionary *dictionary;

@end

@implementation UsbMuxDeviceProperties

@synthesize dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)aDictionary
{
    self = [super init];
    if (self)
    {
        dictionary = aDictionary;
    }
    return self;
}

@end
