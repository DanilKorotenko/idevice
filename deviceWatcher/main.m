//
//  main.m
//  deviceWatcher
//
//  Created by Danil Korotenko on 6/18/24.
//

#import <Foundation/Foundation.h>
#import "IUController.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hello, device Watcher!");
        [[IUController sharedController] startWatchingWithBlock:
            ^(IUDevice * _Nonnull aDevice)
            {
                NSLog(@"device added: %@", aDevice);
                if (aDevice.isIPhone)
                {
                    [aDevice eject];
                }
            }];

        dispatch_main();
    }
    return 0;
}
