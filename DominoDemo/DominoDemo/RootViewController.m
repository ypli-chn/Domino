//
//  RootViewController.m
//  DominoDemo
//
//  Created by Yunpeng on 2017/9/5.
//  Copyright © 2017 Yunpeng. All rights reserved.
//

#import "RootViewController.h"
#import "Domino.h"
#import "ContentViewController.h"
#import "ContentViewControllerEvents.h"
@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.domino.tracker subscribeSelectorEvent:@selector(contentDidLoadWithArg:) target:self];
    [self.domino.tracker subscribeSelectorEvent:@selector(contentDidLoadWithArg1:arg2:) target:self];
    [self.domino.tracker subscribeSelectorEvent:@selector(fetchChannelId) target:self];
    
    [self.domino.tracker subscribeEvent:ContentViewControllerStatisticsEvent handler:^(NSDictionary *params) {
        NSLog(@"[%@]%@",ContentViewControllerStatisticsEvent,params);
    }];
}


- (void)contentDidLoadWithArg1:(NSString *)arg1 arg2:(NSInteger)arg2 {
    NSLog(@"RootViewController - contentDidLoad arg1 = <%@>, arg2 = <%td>", arg1, arg2);
}

- (void)contentDidLoadWithArg:(NSInteger)arg {
    NSLog(@"RootViewController - contentDidLoad %td",arg);
}

- (NSString *)fetchChannelId {
    return @"2";
}

@end
