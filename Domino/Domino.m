//
//  Domino.m
//  Domino
//
//  Created by Yunpeng Li on 2017/8/30.
//  Copyright © 2017 Yunpeng. All rights reserved.
//

#import "Domino.h"
#import <objc/runtime.h>
#include <pthread.h>

#if TARGET_OS_IPHONE || TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
#import <UIKit/UIKit.h>
#define YLResponder UIResponder
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#define YLResponder NSResponder
#endif

/////////////////////////////////////////////////////////////////////////////////////
/// from ReactiveCocoa
/// released under the MIT license
@interface NSInvocation (DominoTypeParsing)
@end
@implementation NSInvocation (DominoTypeParsing)

- (void)domino_setArgument:(id)object atIndex:(NSUInteger)index {
#define PULL_AND_SET(type, selector) \
do { \
type val = [object selector]; \
[self setArgument:&val atIndex:(NSInteger)index]; \
} while (0)
    
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if (argType[0] == 'r') {
        argType++;
    }
    
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        [self setArgument:&object atIndex:(NSInteger)index];
    } else if (strcmp(argType, @encode(char)) == 0) {
        PULL_AND_SET(char, charValue);
    } else if (strcmp(argType, @encode(int)) == 0) {
        PULL_AND_SET(int, intValue);
    } else if (strcmp(argType, @encode(short)) == 0) {
        PULL_AND_SET(short, shortValue);
    } else if (strcmp(argType, @encode(long)) == 0) {
        PULL_AND_SET(long, longValue);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        PULL_AND_SET(long long, longLongValue);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        PULL_AND_SET(unsigned char, unsignedCharValue);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        PULL_AND_SET(unsigned int, unsignedIntValue);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        PULL_AND_SET(unsigned short, unsignedShortValue);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        PULL_AND_SET(unsigned long, unsignedLongValue);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        PULL_AND_SET(unsigned long long, unsignedLongLongValue);
    } else if (strcmp(argType, @encode(float)) == 0) {
        PULL_AND_SET(float, floatValue);
    } else if (strcmp(argType, @encode(double)) == 0) {
        PULL_AND_SET(double, doubleValue);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        PULL_AND_SET(BOOL, boolValue);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        const char *cString = [object UTF8String];
        [self setArgument:&cString atIndex:(NSInteger)index];
        [self retainArguments];
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        [self setArgument:&object atIndex:(NSInteger)index];
    } else {
        NSCParameterAssert([object isKindOfClass:NSValue.class]);
        
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment([object objCType], &valueSize, NULL);
        
#if DEBUG
        NSUInteger argSize = 0;
        NSGetSizeAndAlignment(argType, &argSize, NULL);
        NSCAssert(valueSize == argSize, @"Value size does not match argument size in -domino_setArgument: %@ atIndex: %lu", object, (unsigned long)index);
#endif
        
        unsigned char valueBytes[valueSize];
        [object getValue:valueBytes];
        
        [self setArgument:valueBytes atIndex:(NSInteger)index];
    }
    
#undef PULL_AND_SET
}

- (id)domino_argumentAtIndex:(NSUInteger)index {
#define WRAP_AND_RETURN(type) \
do { \
type val = 0; \
[self getArgument:&val atIndex:(NSInteger)index]; \
return @(val); \
} while (0)
    
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if (argType[0] == 'r') {
        argType++;
    }
    
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id returnObj;
        [self getArgument:&returnObj atIndex:(NSInteger)index];
        return returnObj;
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [self getArgument:valueBytes atIndex:(NSInteger)index];
        
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    
    return nil;
    
#undef WRAP_AND_RETURN
}
@end

/////////////////////////////////////////////////////////////////////////////////////

#define DominoEventActionKeyTarget @"DominoEventActionKeyTarget"
#define DominoEventActionKeyAction @"DominoEventActionKeyAction"

#define dispatch_excute_block_on_main_thread(block)             \
do {                                                        \
    if ([NSThread isMainThread]) {                          \
        block();                                            \
    } else {                                                \
        dispatch_async(dispatch_get_main_queue(), block);    \
    }                                                       \
} while(0)

static void dispatch_excute_block_by_mode(DominoTriggerMode mode, dispatch_block_t block) {
    switch (mode) {
        case DominoTriggerModeMainThread:
            dispatch_excute_block_on_main_thread(block);
            break;
        case DominoTriggerModeBackground:
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
            break;
        case DominoTriggerModeCurrentThread:
            block();
            break;
        default:
            dispatch_excute_block_on_main_thread(block);
            break;
    }
}


BOOL DominoProtocolContainSelector(Protocol *protocol, SEL selector) {
    return (protocol_getMethodDescription(protocol, selector, YES, YES).name
            || protocol_getMethodDescription(protocol, selector, NO, YES).name
            || protocol_getMethodDescription(protocol, selector, NO, NO).name
            || protocol_getMethodDescription(protocol, selector, YES, YES).name);
}



static pthread_mutex_t domino_global_mutex;

static NSInvocation *CopyInvocationFrom(NSInvocation *invocation) {
    NSInvocation *result = [invocation copy];
    result.selector = invocation.selector;
    for (NSInteger index=2; index<invocation.methodSignature.numberOfArguments; index++) {
        NSUInteger valueSize = 0;
        const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:index];
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        char argument[valueSize];
        [invocation getArgument:&argument atIndex:index];
        [result setArgument:&argument atIndex:index];
    }
    
    return result;
}

static NSInteger DominoInvocationParamsOffset = 2;
@interface DominoSelectorEventParams ()
@property (nonatomic, weak) NSInvocation *rawInvocation;
@property (nonatomic, strong) NSInvocation *invocation;
@property (nonatomic, assign, getter=isUpdate) BOOL update;
@end

@implementation DominoSelectorEventParams

- (id)paramAtIndex:(NSUInteger)idx {
    NSInteger paramIndex = idx + DominoInvocationParamsOffset;
    if (self.invocation.methodSignature.numberOfArguments < paramIndex) {
#if DEBUG
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:[NSString stringWithFormat:@"[DominoSelectorEventParams argumentAtIndex]: index (%td) out of bounds [0, %td]",idx,self.invocation.methodSignature.numberOfArguments - DominoInvocationParamsOffset - 1] userInfo:nil];
#else
        return nil;
#endif
    }
    return [self.rawInvocation domino_argumentAtIndex:paramIndex];
}

- (void)setParam:(id)param atIndex:(NSUInteger)idx {
    NSInteger paramIndex = idx + DominoInvocationParamsOffset;
    if (paramIndex >= self.invocation.methodSignature.numberOfArguments) {
#if DEBUG
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:[NSString stringWithFormat:@"[DominoSelectorEventParams setArgument:atIndex:]: index (%td) out of bounds [0, %td]",idx,self.invocation.methodSignature.numberOfArguments - DominoInvocationParamsOffset - 1] userInfo:nil];
#else
        return;
#endif
    }
    [self.invocation domino_setArgument:param atIndex:paramIndex];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self paramAtIndex:idx];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    [self setParam:obj atIndex:idx];
}

- (NSInvocation *)invocation {
    if (_invocation == nil) {
        _invocation = CopyInvocationFrom(self.rawInvocation);
        self.update = YES;
    }
    return _invocation;
}

- (NSUInteger)count {
    return self.invocation.methodSignature.numberOfArguments - DominoInvocationParamsOffset;
}

@end


#pragma mark - DominoEvent
/*********************************************************
 *                  DominoEvent
 *********************************************************/
@interface DominoEvent : NSObject<NSCopying>
@property (nonatomic, weak) NSObject *source;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableSet<Domino *> *dispatchedNodes;

@property (nonatomic, assign) BOOL shouldStop;
@end

@implementation DominoEvent

- (NSMutableSet<Domino *> *)dispatchedNodes {
    if (_dispatchedNodes == nil) {
        _dispatchedNodes = [[NSMutableSet alloc] init];
    }
    return _dispatchedNodes;
}

- (id)copyWithZone:(NSZone *)zone {
    DominoEvent *event = [[[self class] allocWithZone:zone] init];
    event.source = self.source;
    event.name = self.name;
    event.dispatchedNodes = self.dispatchedNodes;
    event.shouldStop = self.shouldStop;
    return event;
}


@end

@interface DominoSimpleEvent : DominoEvent
@property (nonatomic, copy) NSDictionary *params;
@end

@implementation DominoSimpleEvent
- (id)copyWithZone:(NSZone *)zone {
    DominoSimpleEvent *event = [super copyWithZone:zone];
    event.params = self.params;
    return event;
}

- (void)dealloc {
    if (self.source.domino.debugMode) {
        NSLog(@"[Domino][Event:%@][Source:%@]dealloc",self.name, self.source);
    }
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"Instance:%@ \nEvent:%@ \nParams:%@", self.source, self.name, self.params];
}
@end

@interface DominoSelectorEvent : DominoEvent
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSMethodSignature *methodSignature;
@property (nonatomic, strong) NSInvocation *invocation;
@end

@implementation DominoSelectorEvent

- (id)copyWithZone:(NSZone *)zone {
    DominoSelectorEvent *event = [super copyWithZone:zone];
    event.selector = self.selector;
    event.methodSignature = self.methodSignature;
    event.invocation = self.invocation;
    return event;
}

- (NSString *)name {
    return NSStringFromSelector(self.selector);
}
@end


@interface Domino()
- (void)routerEvent:(DominoEvent *)event;
@end


@interface DominoEventTracker() {
    pthread_mutex_t _mutex;
}
@property (nonatomic, weak) NSObject *host;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *eventHandlers;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *eventTargetActions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *eventSelectorTargets;

@end

@implementation DominoEventTracker
- (instancetype)initWithHost:(NSObject *)host {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_mutex, NULL);
        self.host = host;
        
        _eventHandlers = [[NSMutableDictionary alloc] init];
        _eventTargetActions = [[NSMutableDictionary alloc] init];
        _eventSelectorTargets = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (Domino *)domino {
    return self.host.domino;
}

- (void)subscribeEvent:(NSString *)event handler:(DominoEventHandler)handler {
    if (![event isKindOfClass:[NSString class]]
        || event.length == 0) {
        return;
    }

    pthread_mutex_lock(&_mutex);
    NSMutableArray *handlers = self.eventHandlers[event];
    if (handlers == nil) {
        handlers = [[NSMutableArray alloc] init];
        self.eventHandlers[event] = handlers;
    }
    
    if (handler) {
        [handlers addObject:[handler copy]];
    }
    pthread_mutex_unlock(&_mutex);
}

- (void)subscribeEvent:(NSString *)event target:(id)target action:(SEL)action {
    NSString *actionString = NSStringFromSelector(action);
    if (![event isKindOfClass:[NSString class]]
        || event.length == 0
        || actionString.length == 0) {
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    NSMutableArray *actions = self.eventTargetActions[event];
    if (actions == nil) {
        actions = [[NSMutableArray alloc] init];
        self.eventTargetActions[event] = actions;
    }
    
    // avoid retain cycle
    NSMapTable *actionInfo = [NSMapTable strongToWeakObjectsMapTable];
    [actionInfo setObject:target forKey:DominoEventActionKeyTarget];
    [actionInfo setObject:actionString forKey:DominoEventActionKeyAction];
    [actions addObject:actionInfo];
    
    pthread_mutex_unlock(&_mutex);
}

- (void)subscribeSelectorEvent:(SEL)event target:(id)target {
    if (event == NULL
        || target == nil) {
        return;
    }
    pthread_mutex_lock(&_mutex);
    NSString *key = NSStringFromSelector(event);
    NSMutableArray *targets = self.eventSelectorTargets[key];
    if (targets == nil) {
        targets = [[NSMutableArray alloc] init];
        self.eventSelectorTargets[key] = targets;
    }
    
    [targets addObject:target];
    pthread_mutex_unlock(&_mutex);
}

- (void)unsubscribeEvent:(NSString *)event {
    if (![event isKindOfClass:[NSString class]]
        || event.length == 0) {
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    [(NSMutableArray *)self.eventHandlers[event] removeAllObjects];
    [(NSMutableArray *)self.eventTargetActions[event] removeAllObjects];
    pthread_mutex_unlock(&_mutex);
}

- (void)unsubscribeSelectorEvent:(SEL)event {
    if (event == NULL) {
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    NSString *eventString = NSStringFromSelector(event);
    [(NSMutableArray *)self.eventSelectorTargets[eventString] removeAllObjects];
    pthread_mutex_unlock(&_mutex);
}

- (void)clearAllSubscribers {
    pthread_mutex_lock(&_mutex);
    [self.eventHandlers removeAllObjects];
    [self.eventTargetActions removeAllObjects];
    [self.eventSelectorTargets removeAllObjects];
    pthread_mutex_unlock(&_mutex);
}

- (DominoEvent *)handleEvent:(DominoEvent *)event {
    if([event isKindOfClass:[DominoSimpleEvent class]]) {
        return [self handleSimpleEvent:(DominoSimpleEvent *)event];
    } else if([event isKindOfClass:[DominoSelectorEvent class]]) {
        return [self handleSelectorEvent:(DominoSelectorEvent *)event];
    }
    return nil;
}

- (DominoEvent *)handleSimpleEvent:(DominoSimpleEvent *)event {
    if(event.source.domino.debugMode || self.host.domino.debugMode) {
        NSLog(@"[Domino][Event:%@][Source:%@] handled by %@ ",event.name, event.source, self.host);
    }
    
    
    if ([self.host conformsToProtocol:@protocol(DominoInterceptor)]
        && [self.host respondsToSelector:@selector(reformDominoParams:forEvent:)]) {
        NSMutableDictionary *newParams = [event.params mutableCopy];
        [((id<DominoInterceptor>)self.host) reformDominoParams:newParams forEvent:event.name];
        if (![event.params isEqualToDictionary:newParams]) {
            if ((event.source.domino.debugMode || self.host.domino.debugMode)) {
                NSLog(@"[Domino][Event:%@][Source:%@] reformed params from %@ -> %@ by %@",event.name, event.source, event.params, newParams, self.host);
            }
            event = [event copy];
            event.params = [newParams copy];
        }
    }
    
    [self.eventHandlers[event.name] enumerateObjectsUsingBlock:^(DominoEventHandler handler, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_excute_block_by_mode(Domino.triggerMode,^{
            handler(event.params);
        });
    }];
    
    [self.eventTargetActions[event.name] enumerateObjectsUsingBlock:^(NSMapTable *actionInfo, NSUInteger idx, BOOL * _Nonnull stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id target = [actionInfo objectForKey:DominoEventActionKeyTarget];
        SEL selector = NSSelectorFromString([actionInfo objectForKey:DominoEventActionKeyAction]);
#if !DEBUG
        if (!selector || ![target respondsToSelector:selector]) { return; }
#else
        dispatch_excute_block_by_mode(Domino.triggerMode,^{
            [target performSelector:selector withObject:event.params];
        });
#endif
    
#pragma clang diagnostic pop
    }];
    
    if ([self.host conformsToProtocol:@protocol(DominoInterceptor)]
        && [self.host respondsToSelector:@selector(shouldInterceptDominoEvent:)]
        && [((id<DominoInterceptor>)self.host) shouldInterceptDominoEvent:event.name]) {
        if(event.source.domino.debugMode || self.host.domino.debugMode) {
            NSLog(@"[Domino][Event:%@][Source:%@] intercepted by %@ ",event.name, event.source, self.host);
        }
        return nil;
    }
    
    return event;
}

- (DominoEvent *)handleSelectorEvent:(DominoSelectorEvent *)event {
    if(event.source.domino.debugMode || self.host.domino.debugMode) {
        NSLog(@"[Domino][Event:%@][Source:%@] handled by %@ ",NSStringFromSelector(event.selector), event.source, self.host);
    }
    
    DominoSelectorEvent *oldEvent = event;
    if (event.invocation != nil
        && [self.host conformsToProtocol:@protocol(DominoInterceptor)]
        && [self.host respondsToSelector:@selector(reformDominoParams:forSelectorEvent:)]) {
        
        DominoSelectorEventParams *params = [[DominoSelectorEventParams alloc] init];
        params.rawInvocation = event.invocation;
        [((id<DominoInterceptor>)self.host) reformDominoParams:params forSelectorEvent:event.selector];
        if (params.isUpdate) {
            if ((event.source.domino.debugMode || self.host.domino.debugMode)) {
                NSLog(@"[Domino][Event:%@][Source:%@] reformed params by %@",NSStringFromSelector(event.selector), event.source, self.host);
            }
            
            event = [oldEvent copy];
            event.invocation = params.invocation;
        }
    }
    
    NSString *key = NSStringFromSelector(event.selector);
    for (id target in self.eventSelectorTargets[key]) {
        @autoreleasepool {
            if (event.invocation != nil) {
#if !DEBUG
                if (![target respondsToSelector:event.selector]) { continue; }
#endif
                @try {
                    BOOL hasReturnValue = event.methodSignature.methodReturnLength > 0;
                    DominoTriggerMode triggerMode = hasReturnValue?DominoTriggerModeCurrentThread:Domino.triggerMode;
                    
                    dispatch_excute_block_by_mode(triggerMode,^{
                        [event.invocation invokeWithTarget:target];
                    });
                    
                    if(hasReturnValue) {
                        event.shouldStop = YES;
                        if (event != oldEvent) {
                            const char *returnType = event.invocation.methodSignature.methodReturnType;
                            NSUInteger valueSize = 0;
                            NSGetSizeAndAlignment(returnType, &valueSize, NULL);
                            unsigned char valueBytes[valueSize];
                            [event.invocation getReturnValue:valueBytes];
                            [oldEvent.invocation setReturnValue:&valueBytes];
                            oldEvent.shouldStop = YES;
                        }
                        return nil;
                    }
                } @catch (NSException *exception) {
                    if (event != oldEvent) {
                        NSLog(@"[Demino] %@ - @selector(reformDominoSelectorEventParams:target:) reform invocation<%@> params ERROR!!!",event.invocation, target);
                    }
#if DEBUG
                    @throw exception;
#else
                    /// terminate it to prevent subsequent accidents
                    return nil;
#endif
                } @finally {
                    
                }
                
            } else {
                
                // fetch Signature
                NSMethodSignature *signature = [target methodSignatureForSelector:event.selector];
                if (signature != nil) {
                    event.methodSignature = signature;
                    return nil;
                } else {
#if DEBUG
                    NSString *reason = [NSString stringWithFormat:@"-[%@ %@]: unrecognized selector sent to instance %p",
                                        NSStringFromClass([target class]), key , target];
                    @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:reason userInfo:nil];
#endif
                }
            }
        }
    }
    
    if ([self.host conformsToProtocol:@protocol(DominoInterceptor)]
        && [self.host respondsToSelector:@selector(shouldInterceptDominoSelectorEvent:)]
        && [((id<DominoInterceptor>)self.host) shouldInterceptDominoSelectorEvent:event.selector]) {
        if(event.source.domino.debugMode || self.host.domino.debugMode) {
            NSLog(@"[Domino][Event:%@][Source:%@] intercepted by %@ ",NSStringFromSelector(event.selector), event.source, self.host);
        }
        return nil;
    }
    
    return event;
}

@end




/*********************************************************
 *                  DominoEventTrigger
 *********************************************************/
@interface DominoEventTrigger() {
    DominoSelectorEvent *_currentSelectorEvent;
    pthread_mutex_t _mutex;
}
@property (nonatomic, weak) NSObject *host;
@property (nonatomic, copy) NSSet *targets;
@end

@implementation DominoEventTrigger
- (instancetype)initWithHost:(NSObject *)host {
    self.host = host;
    pthread_mutex_init(&_mutex, NULL);
    return self;
}

- (Domino *)domino {
    return self.host.domino;
}

- (void)postEvent:(NSString *)eventName params:(NSDictionary *)params {
    if (![eventName isKindOfClass:[NSString class]]
        || eventName.length == 0
        || (params != nil && ![params isKindOfClass:[NSDictionary class]])) {
        return;
    }
    
    DominoSimpleEvent *event = [[DominoSimpleEvent alloc] init];
    event.source = self.host;
    event.name = eventName;
    event.params = params;
    [self.host.domino routerEvent:event];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    pthread_mutex_lock(&_mutex);
    if (aSelector == @selector(postEvent:params:)) {
        return [self methodSignatureForSelector:aSelector];
    }

    _currentSelectorEvent = [[DominoSelectorEvent alloc] init];
    _currentSelectorEvent.source = self.host;
    _currentSelectorEvent.selector = aSelector;
    [self.host.domino routerEvent:_currentSelectorEvent];
    return _currentSelectorEvent.methodSignature?:[NSMethodSignature signatureWithObjCTypes:@encode(void)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (_currentSelectorEvent == nil
        && anInvocation.selector == @selector(postEvent:params:)) {
        [anInvocation invoke];
        pthread_mutex_unlock(&_mutex);
        return;
    }
    
    if (_currentSelectorEvent == nil
        || _currentSelectorEvent.methodSignature == nil) {
        pthread_mutex_unlock(&_mutex);
        return;
    }
    
    _currentSelectorEvent.invocation = anInvocation;
    [_currentSelectorEvent.dispatchedNodes removeAllObjects];
    [self.host.domino routerEvent:_currentSelectorEvent];
    _currentSelectorEvent = nil;
    pthread_mutex_unlock(&_mutex);
}

@end


/*********************************************************
 *                      Domino
 *********************************************************/
@interface Domino() {
    pthread_mutex_t _mutex;
}

@property (nonatomic, weak) NSObject *host;
@property (nonatomic, strong) NSHashTable *routingTable;
@property (nonatomic, strong) DominoEventTrigger *trigger;
@property (nonatomic, strong) DominoEventTracker *tracker;
@end

@implementation Domino
- (instancetype)initWithHost:(NSObject *)host {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_mutex, NULL);
        self.host = host;
        _trigger = [[DominoEventTrigger alloc] initWithHost:host];
        _tracker = [[DominoEventTracker alloc] initWithHost:host];
    }
    return self;
}

- (Domino *)domino {
    return self;
}

#pragma mark Public API
- (void)mountAtDomino:(Domino *)predomino {
    if (predomino == nil) { return; }
    pthread_mutex_lock(&_mutex);
    [self.routingTable addObject:predomino];
    pthread_mutex_unlock(&_mutex);
}

- (void)unmountFromPredomino:(Domino *)predomino {
    if (predomino == nil) { return; }
    pthread_mutex_lock(&_mutex);
    [self.routingTable removeObject:predomino];
    pthread_mutex_unlock(&_mutex);
}

- (void)unmountFromAllPredominoes {
    pthread_mutex_lock(&_mutex);
    [self.routingTable removeAllObjects];
    pthread_mutex_unlock(&_mutex);
}

#pragma mark Private
- (void)routerEvent:(DominoEvent *)event {
    if ([event.dispatchedNodes containsObject:self] || event.shouldStop) { return; }
    [event.dispatchedNodes addObject:self];

    pthread_mutex_lock(&_mutex);
    event = [self.tracker handleEvent:event];
    pthread_mutex_unlock(&_mutex);
    if(event != nil) {
#ifdef YLResponder
        if ([self.host isKindOfClass:[YLResponder class]]) {
            [[(YLResponder *)self.host nextResponder].domino routerEvent:event];
        }
#endif
        for (Domino *nextNode in self.routingTable) {
            [nextNode routerEvent:event];
        }
    }
}


#pragma mark Getter & Setter
- (NSHashTable *)routingTable {
    pthread_mutex_lock(&_mutex);
    if (_routingTable == nil) {
        _routingTable = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory capacity:1];
    }
    pthread_mutex_unlock(&_mutex);
    return _routingTable;
}

static DominoTriggerMode _triggerMode = DominoTriggerModeMainThread;
+ (void)setTriggerMode:(DominoTriggerMode)triggerMode {
    pthread_mutex_lock(&domino_global_mutex);
    _triggerMode = triggerMode;
    pthread_mutex_unlock(&domino_global_mutex);
}

+ (DominoTriggerMode)triggerMode {
    return _triggerMode;
}

- (BOOL)debugMode {
#if DEBUG
    return _debugMode;
#else
    return NO;
#endif
}
@end


#pragma mark - NSObject
@implementation NSObject (Domino)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&domino_global_mutex, NULL);
    });
}

- (Domino *)domino {
    Domino *domino = objc_getAssociatedObject(self, _cmd);
    pthread_mutex_lock(&domino_global_mutex);
    if(domino == nil) {
        domino = [[Domino alloc] initWithHost:self];
        objc_setAssociatedObject(self, _cmd, domino, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    pthread_mutex_unlock(&domino_global_mutex);
    return domino;
}
@end
