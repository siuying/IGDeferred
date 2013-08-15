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
    __block BOOL callback3 = NO;
    __block BOOL callbackNofity = NO;

    XCTAssert([deferred isRunning], @"should be running");
    [self performSelector:@selector(completed:) withObject:deferred afterDelay:1.0];
    [self performSelector:@selector(notify:) withObject:deferred afterDelay:0.2];

    deferred.progress(^(id obj){
        callbackNofity = YES;
    });
    deferred.done(^(id obj){
        callback1 = YES;
    });
    deferred.then(^(id obj){
        callback2 = YES;
    }, nil, nil);
    deferred.always(^(id obj){
        callback3 = YES;
        XCTAssert(![deferred isRunning], @"should not be running");
        XCTAssert([deferred isResolved], @"should be resolved");
    });

    WaitFor(^{ return (BOOL) (callback1 == YES && callback2 == YES && callback3 == YES); });
}

- (void)testFailCallback
{
    IGDeferred* deferred = [[IGDeferred alloc] init];
    __block BOOL callback1 = NO;
    __block BOOL callback2 = NO;
    __block BOOL callback3 = NO;

    XCTAssert([deferred isRunning], @"should be running");
    [self performSelector:@selector(failure:) withObject:deferred afterDelay:1.0];

    deferred.fail(^(id obj){
        callback1 = YES;
    });
    deferred.then(nil, nil, ^(id obj){
        callback2 = YES;
    });
    deferred.always(^(id obj){
        callback3 = YES;
        XCTAssert(![deferred isRunning], @"should not be running");
        XCTAssert([deferred isRejected], @"should be rejected");
    });

    WaitFor(^{ return (BOOL) (callback1 == YES && callback2 == YES && callback3 == YES); });
}

-(void) completed:(IGDeferred*)deferred
{
    deferred.resolve(self);
}

-(void) failure:(IGDeferred*)deferred
{
    deferred.reject(self);
}

-(void) notify:(IGDeferred*)deferred
{
    deferred.notifyWith(@1);
}

@end
