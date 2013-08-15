//
//  IGDeferred.m
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGDeferred.h"

@interface IGDeferred ()

@property (nonatomic, strong) NSMutableArray* progressQueues;
@property (nonatomic, strong) NSMutableArray* alwaysQueues;
@property (nonatomic, strong) NSMutableArray* doneQueues;
@property (nonatomic, strong) NSMutableArray* failQueues;

@end

@implementation IGDeferred

-(id) init {
    self = [super init];
    if (self) {
        self.progressQueues = [NSMutableArray array];
        self.alwaysQueues = [NSMutableArray array];
        self.doneQueues = [NSMutableArray array];
        self.failQueues = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Chainable methods

-(IGDeferred* (^)(id obj)) reject
{
    if (!self.isRunning) {
        [NSException raise:@"IGDeferredException"
                    format:@"Deferred is not running, you can only reject or resolve a Deferred object once."];
    }
    
    return ^IGDeferred* (id obj) {
        _rejected = YES;
        
        [[self.failQueues copy] enumerateObjectsUsingBlock:^(IGDeferredCallback block, NSUInteger idx, BOOL *stop) {
            block(obj);
        }];
        
        [[self.alwaysQueues copy] enumerateObjectsUsingBlock:^(IGDeferredCallback block, NSUInteger idx, BOOL *stop) {
            block(obj);
        }];
        
        return self;
    };
}

-(IGDeferred* (^)(id obj)) resolve
{
    if (!self.isRunning) {
        [NSException raise:@"IGDeferredException"
                    format:@"Deferred is not running, you can only reject or resolve a Deferred object once."];
    }

    return ^IGDeferred* (id obj) {
        _resolved = YES;
        
        [[self.doneQueues copy] enumerateObjectsUsingBlock:^(IGDeferredCallback block, NSUInteger idx, BOOL *stop) {
            block(obj);
        }];

        [[self.alwaysQueues copy] enumerateObjectsUsingBlock:^(IGDeferredCallback block, NSUInteger idx, BOOL *stop) {
            block(obj);
        }];

        return self;
    };
}

-(IGDeferred* (^)(id obj)) notifyWith
{
    return ^IGDeferred* (id obj) {
        if (self.isRunning) {
            [[self.progressQueues copy] enumerateObjectsUsingBlock:^(IGDeferredCallback block, NSUInteger idx, BOOL *stop) {
                block(obj);
            }];
        }
        return self;
    };
}

-(IGDeferred* (^)(IGDeferredCallback block)) progress
{
    return ^IGDeferred* (IGDeferredCallback block){
        [self.progressQueues addObject:block];
        return self;
    };
}

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

-(IGDeferred* (^)(IGDeferredCallback resolvedBlock, IGDeferredCallback rejectedBlock, IGDeferredCallback progressBlock)) then {
    return ^IGDeferred* (IGDeferredCallback resolvedBlock, IGDeferredCallback rejectedBlock, IGDeferredCallback progressBlock){
        if (resolvedBlock) {
            [self.doneQueues addObject:resolvedBlock];
        }
        
        if (rejectedBlock) {
            [self.failQueues addObject:rejectedBlock];
        }
        
        if (progressBlock) {
            [self.progressQueues addObject:progressBlock];
        }

        return self;
    };
}

#pragma mark - 

-(BOOL) isRunning
{
    return !_resolved && !_rejected;
}

@end
