//
//  IGDeferred.h
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^IGDeferredBlock)(BOOL* succeed);
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

@property (nonatomic, copy, readonly) IGDeferred* (^reject)(id obj);
@property (nonatomic, copy, readonly) IGDeferred* (^resolve)(id obj);
@property (nonatomic, copy, readonly) IGDeferred* (^notifyWith)(id obj);

@property (nonatomic, copy, readonly) IGDeferred* (^progress)(IGDeferredCallback block);
@property (nonatomic, copy, readonly) IGDeferred* (^always)(IGDeferredCallback block);
@property (nonatomic, copy, readonly) IGDeferred* (^done)(IGDeferredCallback block);
@property (nonatomic, copy, readonly) IGDeferred* (^fail)(IGDeferredCallback block);
@property (nonatomic, copy, readonly) IGDeferred* (^then)(IGDeferredCallback resolvedBlock, IGDeferredCallback rejectedBlock, IGDeferredCallback progressBlock);

+(instancetype) deferredWithBlock:(IGDeferredBlock)deferredBlock usingQueue:(NSOperationQueue*)queue;

/**
  Reject a Deferred object and call any failCallbacks with the given argument.
 */
-(IGDeferred* (^)(id obj)) reject;

/**
Resolve a Deferred object and call any doneCallbacks with the given argument.
 */
-(IGDeferred* (^)(id obj)) resolve;

/**
 Call the progressCallbacks on a Deferred object with the given argument.
 
 @note When deferred.notifyWith is called, any progressCallbacks added by deferred.progress are called in the order they were added. Each callback is passed the arg from the .notifyWith(). Any calls to .notifyWith() after a Deferred is resolved or rejected (or any progressCallbacks added after that) are ignored.
 */
-(IGDeferred* (^)(id obj)) notifyWith;

/**
 Add handlers to be called when the Deferred object generates progress notifications.
 */
-(IGDeferred* (^)(IGDeferredCallback block)) progress;

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

/**
 Add handlers to be called when the Deferred object is resolved, rejected, or notify progress.
 */
-(IGDeferred* (^)(IGDeferredCallback resolvedBlock, IGDeferredCallback rejectedBlock, IGDeferredCallback progressBlock)) then;

@end