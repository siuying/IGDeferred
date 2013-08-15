//
//  IGDeferredTests.m
//  IGDeferredTests
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IGDeferred.h"

BOOL WaitFor(BOOL (^block)(void))
{
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];
    while(!block() && [[NSProcessInfo processInfo] systemUptime] - start <= 5)
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date]];
    return block();
}

@interface IGDeferredTests : XCTestCase

@end

@implementation IGDeferredTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDoneCallback
{
    __block IGDeferred* deferred = [[IGDeferred alloc] init];
    __block BOOL callback1 = NO;
    __block BOOL callback2 = NO;
    
    [self performSelector:@selector(completed:) withObject:deferred afterDelay:2.0];

    deferred.done(^(id obj){
        callback1 = YES;
    });
    deferred.then(^(id obj){
        callback2 = YES;
    }, nil, nil);
    
    WaitFor(^{ return (BOOL) (callback1 == YES && callback2 == YES); });
}

- (void)testFailCallback
{
    IGDeferred* deferred = [[IGDeferred alloc] init];
    __block BOOL callback1 = NO;
    __block BOOL callback2 = NO;
    
    [self performSelector:@selector(failure:) withObject:deferred afterDelay:2.0];
    
    deferred.fail(^(id obj){
        callback1 = YES;
    });
    deferred.then(nil, nil, ^(id obj){
        callback2 = YES;
    });
    
    WaitFor(^{ return (BOOL) (callback1 == YES && callback2 == YES); });
}

-(void) completed:(IGDeferred*)deferred
{
    deferred.resolve(self);
}

-(void) failure:(IGDeferred*)deferred
{
    deferred.reject(self);
}
@end
