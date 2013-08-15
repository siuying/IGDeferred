//
//  IGMultiDeferred.m
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGMultiDeferred.h"

@interface IGMultiDeferred ()
@property (nonatomic, assign, getter = isRunning) BOOL running;
@property (nonatomic, assign, getter = isResolved) BOOL resolved;
@property (nonatomic, assign, getter = isRejected) BOOL rejected;
@end

@implementation IGMultiDeferred

-(id) init {
    self = [super init];
    if (self) {
        self.running = NO;
    }
    return self;
}

-(void) addDeferred:(IGDeferred*)deferred
{
    
    [self.deferreds addObject:deferred];

    if ([deferred isRejected]) {
        self.reject([self rejectedValues]);
    }

    [deferred addObserver:self
               forKeyPath:@"running"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
}

-(IGMultiDeferred* (^)(IGDeferred*)) add
{
    return ^IGMultiDeferred* (IGDeferred* deferred) {
        [self addDeferred:deferred];
        return self;
    };
}

-(void) dealloc
{
    [self.deferreds enumerateObjectsUsingBlock:^(IGDeferred* defer, NSUInteger idx, BOOL *stop) {
        [defer removeObserver:self forKeyPath:@"running" context:nil];
    }];
}

-(BOOL) allResolved
{
    __block BOOL resolved = YES;
    [self.deferreds enumerateObjectsUsingBlock:^(IGDeferred* defer, NSUInteger idx, BOOL *stop) {
        if (!defer.resolved) {
            resolved = NO;
            *stop = YES;
        }
    }];
    return resolved;
}

-(BOOL) anyRejected
{
    __block BOOL rejected = NO;
    [self.deferreds enumerateObjectsUsingBlock:^(IGDeferred* defer, NSUInteger idx, BOOL *stop) {
        if (defer.reject) {
            rejected = YES;
            *stop = YES;
        }
    }];
    return rejected;
}

-(NSArray*) resovledValues
{
    NSMutableArray* resolvedValues = [NSMutableArray array];
    [self.deferreds enumerateObjectsUsingBlock:^(IGDeferred* defer, NSUInteger idx, BOOL *stop) {
        if (defer.resolved) {
            [resolvedValues addObject:defer.value];
        }
    }];
    return resolvedValues;
}

-(NSArray*) rejectedValues
{
    NSMutableArray* rejectedValues = [NSMutableArray array];
    [self.deferreds enumerateObjectsUsingBlock:^(IGDeferred* defer, NSUInteger idx, BOOL *stop) {
        if (defer.rejected) {
            [rejectedValues addObject:defer.value];
        }
    }];
    return rejectedValues;
}

#pragma makr - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)contex {
    if (!self.running) {
        return;
    }

    if ([self allResolved]) {
        self.running = NO;
        self.resolved = YES;
        self.resolve([self resovledValues]);
    } else if ([self anyRejected]) {
        self.running = NO;
        self.rejected = YES;
        self.reject([self rejectedValues]);
    }
}

@end
