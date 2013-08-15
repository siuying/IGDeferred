//
//  IGTestHelper.h
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL WaitFor(BOOL (^block)(void));

@interface IGTestHelper : NSObject

@end
