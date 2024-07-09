//
//  main.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/4/24.
//

#import <Foundation/Foundation.h>
#import "UMController.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hello, Usbmux!");
        NSArray *devices = [UMController sharedInstance].devices;

        NSLog(@"devices: %@", devices);

//        dispatch_main();
    }
    return 0;
}
