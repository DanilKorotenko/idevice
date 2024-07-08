//
//  main.m
//  usbmuxDeviceInfo
//
//  Created by Danil Korotenko on 7/4/24.
//

#import <Foundation/Foundation.h>
#import "UsbMuxController.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hello, Usbmux!");
        NSArray *devices = [UsbMuxController sharedInstance].devices;

        NSLog(@"devices: %@", devices);

//        dispatch_main();
    }
    return 0;
}
