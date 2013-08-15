//
//  IGMultiDeferred.h
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGDeferred.h"

@interface IGMultiDeferred : IGDeferred

@property (nonatomic, strong) NSMutableArray* deferreds;

-(void) addDeferred:(IGDeferred*)deferred;

-(IGMultiDeferred* (^)(IGDeferred* deferred)) add;

@end
