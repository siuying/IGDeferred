//
//  IGViewController.m
//  IGDeferred
//
//  Created by Chong Francis on 13年8月15日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGViewController.h"
#import "IGDeferred.h"

@interface IGViewController ()
@end

@implementation IGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.deferred = [[IGDeferred alloc] init];

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.deferred.resolve(nil);
    });

    self.deferred.done(^(id obj){
        NSLog(@"done");
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
