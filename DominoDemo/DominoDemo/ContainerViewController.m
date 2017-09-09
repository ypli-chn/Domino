//
//  ContainerViewController.m
//  DominoDemo
//
//  Created by Yunpeng on 2017/9/5.
//  Copyright © 2017 Yunpeng. All rights reserved.
//

#import "ContainerViewController.h"
#import "Domino.h"
#import "ContentViewControllerEvents.h"

@interface ContainerViewController ()<DominoInterceptor>

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.domino.tracker subscribeSelectorEvent:@selector(contentDidLoadWithArg:) target:self];
}

- (void)contentDidLoadWithArg:(NSInteger)arg {
    NSLog(@"ContainerViewController - contentDidLoad %td",arg);
}

- (void)reformDominoParams:(DominoSelectorEventParams *)params forSelectorEvent:(SEL)selector {
    if (selector == @selector(contentDidLoadWithArg1:arg2:)) {
        NSLog(@"ContainerViewController - reform @selector(contentDidLoadWithArg1:arg2:)");
        params[0] = @"hook!!!";
        params[1] = @(333);
    }
}

@end
