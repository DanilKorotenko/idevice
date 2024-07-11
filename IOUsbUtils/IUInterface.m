//
//  IUInterface.m
//
//  Created by Danil Korotenko on 7/10/24.
//

#import "IUInterface.h"

@implementation IUInterface

@synthesize numberOfEndpoints;
@synthesize name;

- (instancetype)initWithNumOfEndpoints:(NSUInteger)aNumOfEndpoints name:(NSString *)aName
{
    self = [super init];
    if (self)
    {
        numberOfEndpoints = aNumOfEndpoints;
        name = aName;
    }
    return self;
}

- (NSString *)description
{
    NSDictionary *dictionary =
        @{
            @"name": self.name,
            @"numberOfEndpoints": @(self.numberOfEndpoints)
        };
    return [dictionary description];
}

- (BOOL)isMtpPtp
{
// Comments from https://github.com/libmtp/libmtp/blob/master/src/libusb-glue.c
    /*
    * Loop over the device configurations and interfaces. Nokia MTP-capable
    * handsets (possibly others) typically have the string "MTP" in their
    * MTP interface descriptions, that's how they can be detected, before
    * we try the more esoteric "OS descriptors" (below).
    */
    /*
    * MTP interfaces have three endpoints, two bulk and one
    * interrupt. Don't probe anything else.
    */
    /*
    * Next we search for the MTP substring in the interface name.
    * For example : "RIM MS/MTP" should work.
    */

    return self.numberOfEndpoints == 3 &&
        ([self.name localizedCaseInsensitiveContainsString:@"mtp"] ||
        [self.name localizedCaseInsensitiveContainsString:@"ptp"]);
}

@end
