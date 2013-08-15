//
//  IGMultiDeferred.m
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IGMultiDeferred.h"
#import "IGDeferred.h"
#import "IGTestHelper.h"

@interface IGMultiDeferredTests : XCTestCase

@end

@implementation IGMultiDeferredTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testMultiDeferredAllResolved
{
    __block BOOL callback1 = NO;
    IGMultiDeferred* multiDeferred = [[IGMultiDeferred alloc] init];
    multiDeferred.done(^(id obj){
        callback1 = YES;
    });
    
    IGDeferred* deferred1 = [[IGDeferred alloc] init];
    IGDeferred* deferred2 = [[IGDeferred alloc] init];
    IGDeferred* deferred3 = [[IGDeferred alloc] init];
    multiDeferred
    .add(deferred1)
    .add(deferred2)
    .add(deferred3);
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        deferred1.resolve(nil);
    });
    
    double delayInSeconds2 = 1.5;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        deferred2.resolve(nil);
    });
    
    double delayInSeconds3 = 1.3;
    dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds3 * NSEC_PER_SEC));
    dispatch_after(popTime3, dispatch_get_main_queue(), ^(void){
        deferred3.resolve(nil);
    });
    
    WaitFor(^{ return (BOOL) (callback1 == YES);});
}

- (void)testMultiDeferredAnyRejected
{
    __block BOOL callback1 = NO;
    IGMultiDeferred* multiDeferred = [[IGMultiDeferred alloc] init];
    multiDeferred.fail(^(id obj){
        callback1 = YES;
    });
    
    IGDeferred* deferred1 = [[IGDeferred alloc] init];
    IGDeferred* deferred2 = [[IGDeferred alloc] init];
    IGDeferred* deferred3 = [[IGDeferred alloc] init];
    multiDeferred
    .add(deferred1)
    .add(deferred2)
    .add(deferred3);
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        deferred1.resolve(nil);
    });
    
    double delayInSeconds2 = 1.5;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        deferred2.reject(nil);
    });
    
    double delayInSeconds3 = 1.3;
    dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds3 * NSEC_PER_SEC));
    dispatch_after(popTime3, dispatch_get_main_queue(), ^(void){
        deferred3.resolve(nil);
    });
    
    WaitFor(^{ return (BOOL) (callback1 == YES);});
}

- (void)testMultiDeferredAddWhenRejected
{
    __block BOOL callback1 = NO;
    IGMultiDeferred* multiDeferred = [[IGMultiDeferred alloc] init];
    multiDeferred.fail(^(id obj){
        callback1 = YES;
    });
    
    IGDeferred* deferred1 = [[IGDeferred alloc] init];
    IGDeferred* deferred2 = [[IGDeferred alloc] init];
    deferred2.reject(nil);
    multiDeferred
        .add(deferred1)
        .add(deferred2);
    
    XCTAssert(multiDeferred.rejected, @"should be failed immediately");
    XCTAssert(callback1, @"should be failed immediately");
}

@end
