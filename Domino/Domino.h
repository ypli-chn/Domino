//
//  Domino.h
//  Domino
//
//  Created by Yunpeng Li on 2017/8/30.
//  Copyright © 2017 Yunpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DominoTriggerMode) {
    DominoTriggerModeMainThread,  // default
    DominoTriggerModeBackground,
    DominoTriggerModeCurrentThread,
};

@interface DominoSelectorEventParams : NSObject
@property (nonatomic, assign, readonly) NSUInteger count;
/// index from 0
- (id)paramAtIndex:(NSUInteger)idx;
- (void)setParam:(id)param atIndex:(NSUInteger)idx;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end


@protocol DominoInterceptor <NSObject>
@optional
/// used to modify parameters of events delivered by this node
- (void)reformDominoParams:(NSMutableDictionary *)params forEvent:(NSString *)event;
- (void)reformDominoParams:(DominoSelectorEventParams *)params forSelectorEvent:(SEL)selector;

/// used to interrupt the chain. The event won't deliver to next node if return YES
- (BOOL)shouldInterceptDominoEvent:(NSString *)event;
- (BOOL)shouldInterceptDominoSelectorEvent:(SEL)selector;
@end


@class DominoEventTrigger, DominoEventTracker;
@interface Domino : NSObject
@property (class, nonatomic, assign) DominoTriggerMode triggerMode;

@property (nonatomic, readonly) DominoEventTrigger *trigger;
@property (nonatomic, readonly) DominoEventTracker *tracker;

- (void)mountAtDomino:(Domino *)predomino;
- (void)unmountFromPredomino:(Domino *)predomino;
- (void)unmountFromAllPredominoes;

/// Debug Mode
/// only available in DEBUG
/// will print all events triggered and delivered by this node
@property (nonatomic, assign) BOOL debugMode;
@end


BOOL DominoProtocolContainSelector(Protocol *protocol, SEL selector);

#define DominoSelectorEvents(...) interface DominoEventTrigger()<__VA_ARGS__> @end

@interface DominoEventTrigger : NSProxy
- (void)postEvent:(NSString *)event params:(NSDictionary * _Nullable)params;
@end


typedef void (^DominoEventHandler)(NSDictionary * _Nullable params);
@interface DominoEventTracker : NSObject
/// add subscriber
- (void)subscribeEvent:(NSString *)event handler:(DominoEventHandler)handler;
- (void)subscribeEvent:(NSString *)event target:(id)target action:(SEL)action;
- (void)subscribeSelectorEvent:(SEL)event target:(id)target;

/// delete subscriber
- (void)unsubscribeEvent:(NSString *)event;
- (void)unsubscribeSelectorEvent:(SEL)event;

- (void)clearAllSubscribers;
@end


@interface NSObject (Domino)
@property (nonatomic, readonly) Domino *domino;
@end

NS_ASSUME_NONNULL_END
