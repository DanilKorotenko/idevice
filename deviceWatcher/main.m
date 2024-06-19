//
//  main.m
//  deviceWatcher
//
//  Created by Danil Korotenko on 6/18/24.
//

#import <Foundation/Foundation.h>
#import "IOUSBController.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hello, device Watcher!");
        [[IOUSBController sharedController] startWatchingWithBlock:
            ^(IOUSBDevice * _Nonnull aDevice)
            {
                NSLog(@"device added: %@", aDevice);
                if (aDevice.supportsIPhoneOS)
                {
                    [aDevice eject];
                }
            }];

        dispatch_main();
    }
    return 0;
}
