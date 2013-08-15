//
//  IGDeferred.h
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IGDeferredBlock)(void);
typedef void (^IGDeferredCallback)(id obj);

/**
 IGDeferred - A chainable defer object that can register multiple callbacks into callback queues, 
 invoke callback queues, and relay the success or failure state of any sync or async function.
 */
@interface IGDeferred : NSObject

@property (nonatomic, assign, readonly, getter = isRunning) BOOL running;
@property (nonatomic, assign, readonly, getter = isResolved) BOOL resolved;
@property (nonatomic, assign, readonly, getter = isRejected) BOOL rejected;
@property (nonatomic, strong) id value;

@property (nonatomic, readonly) IGDeferred* (^always)(IGDeferredCallback block);
@property (nonatomic, readonly) IGDeferred* (^done)(IGDeferredCallback block);
@property (nonatomic, readonly) IGDeferred* (^fail)(IGDeferredCallback block);

-(id) initWithBlock:(IGDeferredBlock)deferredBlock;

/**
 Add handlers to be called when the Deferred object is either resolved or rejected.
 */
-(IGDeferred* (^)(IGDeferredCallback block)) always;

/**
 Add handlers to be called when the Deferred object is resolved.
 */
-(IGDeferred* (^)(IGDeferredCallback block)) done;

/**
 Add handlers to be called when the Deferred object is rejected.
 */
-(IGDeferred* (^)(IGDeferredCallback block)) fail;

@end