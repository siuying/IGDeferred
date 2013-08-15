//
//  IGDeferred.m
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGDeferred.h"

@interface IGDeferred ()
@property (nonatomic, assign, getter = isRunning) BOOL running;
@property (nonatomic, assign, getter = isResolved) BOOL resolved;
@property (nonatomic, assign, getter = isRejected) BOOL rejected;
@property (nonatomic, strong) NSMutableArray* progressQueues;
@property (nonatomic, strong) NSMutableArray* alwaysQueues;
@property (nonatomic, strong) NSMutableArray* doneQueues;
@property (nonatomic, strong) NSMutableArray* failQueues;

@end

@implementation IGDeferred

-(id) init {
    self = [super init];
    if (self) {
        self.running = YES;
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
    return ^IGDeferred* (id obj) {
        self.rejected = YES;
        self.running = NO;
        self.value = obj;
        
        [[self.failQueues copy] enumerateObjectsUsingBlock:^(IGDeferredCallback block, NSUInteger idx, BOOL *stop) {
            block(self.value);
        }];
        
        [[self.alwaysQueues copy] enumerateObjectsUsingBlock:^(IGDeferredCallback block, NSUInteger idx, BOOL *stop) {
            block(self.value);
        }];
        
        return self;
    };
}

-(IGDeferred* (^)(id obj)) resolve
{
    return ^IGDeferred* (id obj) {
        self.resolved = YES;
        self.running = NO;
        self.value = obj;
        
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

@end
