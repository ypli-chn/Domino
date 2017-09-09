//
//  ContentViewControllerEvents.h
//  DominoDemo
//
//  Created by Yunpeng on 2017/9/5.
//  Copyright © 2017 Yunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const ContentViewControllerStatisticsEvent;

@protocol ContentViewControllerEvents <NSObject>
- (void)contentDidLoadWithArg1:(NSString *)arg1 arg2:(NSInteger)arg2;
- (void)contentDidLoadWithArg:(NSInteger)arg;
- (NSString *)fetchChannelId;
@end
