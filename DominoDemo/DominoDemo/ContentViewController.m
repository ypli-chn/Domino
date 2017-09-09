//
//  ContentViewController.m
//  DominoDemo
//
//  Created by Yunpeng on 2017/9/5.
//  Copyright © 2017 Yunpeng. All rights reserved.
//

#import "ContentViewController.h"
#import "Domino.h"
#import "ContentViewControllerEvents.h"

@DominoSelectorEvents(ContentViewControllerEvents);
@interface ContentViewController ()

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)buttonDidClick:(UIButton *)sender {
    NSString *channelId = [self.domino.trigger fetchChannelId];
    NSLog(@"ChannelId:%@",channelId);
}


- (IBAction)button2DidClick:(UIButton *)sender {
    [self.domino.trigger contentDidLoadWithArg1:@"arg1" arg2:222];
    [self.domino.trigger contentDidLoadWithArg:111];
}


- (IBAction)button3DidClick:(UIButton *)sender {
    [self.domino.trigger postEvent:ContentViewControllerStatisticsEvent params:@{@"msg":@"test"}];
}


@end
