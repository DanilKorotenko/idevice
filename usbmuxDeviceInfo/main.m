//
//  main.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/4/24.
//

#import <Foundation/Foundation.h>
#import "UMController.h"
#import "UMDevice.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hello, Usbmux!");
        NSArray *devices = [UMController sharedInstance].devices;

        NSLog(@"devices: %@", devices);

        UMDevice *device = [devices objectAtIndex:0];

        NSLog(@"%@", device.allValues);

//        dispatch_main();
    }
    return 0;
}
