//
//  main.m
//  ICDeviceInfo
//
//  Created by Danil Korotenko on 7/9/24.
//

#import <Foundation/Foundation.h>

#import "ICController.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSArray *devices = [ICController sharedInstance].devices;
        NSLog(@"Devices: %@", devices);
        dispatch_main();
    }
    return 0;
}
