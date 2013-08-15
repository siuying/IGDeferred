//
//  IGDeferred.m
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGDeferred.h"

@interface IGDeferred ()
@property (nonatomic, strong) NSArray* deferredBlocks;
@property (nonatomic, strong) NSMutableArray* alwaysQueues;
@property (nonatomic, strong) NSMutableArray* doneQueues;
@property (nonatomic, strong) NSMutableArray* failQueues;
@end

@implementation IGDeferred

-(id) init {
    return [self initWithBlock:nil];
}

-(id) initWithBlock:(IGDeferredBlock)deferredBlock {
    self = [super init];
    if (self) {
        if (deferredBlock) {
            _deferredBlocks = [NSArray arrayWithObject:deferredBlock];
        }
    }
    return self;
}

#pragma mark - Chainable methods

-(IGDeferred* (^)(IGDeferredCallback block)) always
{
    return ^IGDeferred* (IGDeferredCallback block){
        [self.alwaysQueues addObject:block];
        return self;
    };
}

-(IGDeferred* (^)(IGDeferredCallback block)) done
{
    return ^IGDeferred* (IGDeferredCallback block){
        [self.doneQueues addObject:block];
        return self;
    };
}

-(IGDeferred* (^)(IGDeferredCallback block)) fail
{
    return ^IGDeferred* (IGDeferredCallback block){
        [self.failQueues addObject:block];
        return self;
    };
}

#pragma mark - 

-(BOOL) isRunning
{
    return !_resolved && !_rejected;
}

#pragma mark - Lazy getters

-(NSMutableArray*) alwaysQueue {
    if (!_alwaysQueues) {
        _alwaysQueues = [NSMutableArray array];
    }
    return _alwaysQueues;
}

-(NSMutableArray*) doneQueue {
    if (!_doneQueues) {
        _doneQueues = [NSMutableArray array];
    }
    return _doneQueues;
}

-(NSMutableArray*) failQueue {
    if (!_failQueues) {
        _failQueues = [NSMutableArray array];
    }
    return _failQueues;
}

#pragma mark - Private

-(id) __igd_value {
    return _value;
}

@end
