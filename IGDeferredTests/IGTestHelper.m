//
//  IGTestHelper.m
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGTestHelper.h"

BOOL WaitFor(BOOL (^block)(void))
{
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];
    while(!block() && [[NSProcessInfo processInfo] systemUptime] - start <= 5)
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date]];
    return block();
}

@implementation IGTestHelper

@end
