# Domino

[English](./README.md)

Domino为Objective-C提供了一种多层级对象的通信机制。



## 为什么使用Domino？

当我们实现复杂UI的时候，很容易形成一种多层级的对象关系，如下图

![relationships](images/relationships.png)

随着ContentViewController业务的增长，ContentViewController/ContainerViewController/RootViewController的delegate会变得越来越大。很多时候，ContainerViewController/RootViewController可能并不关心其中的方法，只是承担传递事件的责任，但是这些实现又是和自身没有关系的。Domino就是为了解决这个问题。



Domino在对象之间创建了一条事件链，就像系统的Responder Chain一样。

##### 使用场景:

- 父VC包含子VC，子VC又包含其他子VC，依次
- 从VC中将部分功能拆分出独立对象，但很多事件仍然需要VC知道
- delegate(如UIScrollDelegate)中的事件需要被多方知晓

##### vs Delegate:

- 避免多层级之间的delegate只用作转发而变得臃肿
- delegate只能实现一对一通信，但有些事件需要被多方知晓
- 无视命名域，也就是说，事件是可以直接跨过组件传递的，只需要将需要公开的事件单独定义成头文件为外界引用即可

##### vs Notification:

- 很多时候当有多个实例的时候Notification并不适合

- 只有上级才能接收下级的事件，也就是说比Notification更加严格，便于管理

  ​



## 示例

**沿着系统的Respnder Chain有一条默认的事件链。** 这也就是如果相关的对象都在同一条Respnder Chain上的话，你就不需要做任何配置。

如果不在一条响应链上，可以通过以下方式将某个对象挂到链上

```objective-c
[dddManager.domino mountAtDomino:contentVC.domino]
```

也可以通过`unmountFromPredomino:`来实现解绑。这个链并不会导致循环引用，所以不需要在dealloc的时候调用`unmount`方法。



Domino事件分为 `SimpleEvent` and `SelectorEvent`两种.**无论哪种事件，都只能从下向上传递。**

#### SimpleEvent:

就像`NSNotification`一样，使用`NSString`作为事件名，使用`NSDictionary`作为参数。

#### SelectorEvent:

看起来更像delegate，通过定义协议来规定事件，每个方法都是一个SelectorEvent，这样调用和传参更加容易和规范，**所以在大多数情况下，推荐使用SelectorEvent。**

对于有返回值的SelectorEvent来说，会像责任链模式一样，一旦有任意一个对象处理了这个Event就不会继续传递了。

对于无返回值的SelectorEvent来说，就像Notification一样告诉其所有的上级。

建议为对应的VC单独新建一个文件来声明事件：

```objective-c
// ContentViewControllerEvents.h

/// SimpleEvent
extern NSString * const ContentViewControllerStatisticsEvent;

/// SelectorEvent
@protocol ContentViewControllerEvents <NSObject>
@optional
- (void)contentDidLoadWithArg1:(NSString *)arg1 arg2:(NSInteger)arg2;
- (void)contentDidLoadWithArg:(NSInteger)arg;
- (NSString *)fetchChannelId;
@end
```


发送事件：

```objc
#import "Domino.h"
#import "ContentViewControllerEvents.h"

@DominoSelectorEvents(ContentViewControllerEvents); // declare events would be posted
@interface ContentViewController ()

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // ...
    
    // post SelectorEvent
  	[self.domino.trigger contentDidLoadWithArg:12];
  
    // post NormalEvent
    [self.domino.trigger postEvent:ContentViewControllerStatisticsEvent params:@{@"msg":@"did load"}];
  	
}
@end
```


监听事件：

```objective-c
#import "Domino.h"
#import "ContentViewControllerEvents.h"

@interface ContainerViewController () // <ContentViewControllerEvents> NOT neccessary
@end
@implementation ContainerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // 注册监听SelectorEvent
    [self.domino.tracker subscribeSelectorEvent:@selector(contentDidLoadWithArg:) target:self];
  
    // 注册监听NormalEvent
    [self.domino.tracker subscribeEvent:ContentViewControllerStatisticsEvent handler:^(NSDictionary *params) {
        NSLog(@"[%@]%@",ContentViewControllerStatisticsEvent, params);
    }];
}

- (void)contentDidLoadWithArg:(NSInteger)arg {
    NSLog(@"ContainerViewController - contentDidLoad %td",arg);
}
@end
```
修改事件参数：

```objective-c
@interface ContainerViewController ()<DominoInterceptor> // !!! declare IS neccessary !!!
@end
@implementation ContainerViewController
- (void)reformDominoParams:(DominoSelectorEventParams *)params forSelectorEvent:(SEL)selector {
    if (selector == @selector(contentDidLoadWithArg1:arg2:)) {
        NSLog(@"ContainerViewController - reform @selector(contentDidLoadWithArg1:arg2:)");
        params[0] = @"hook!!!"; // index from 0
        params[1] = @(333); // Don't worry about type
    }
}
@end
```
当你需要打断事件链的时候，你可以通过 `BOOL DominoProtocolContainSelector(Protocol *protocol, SEL selector);` 来判断一个selector是否属于一个protocol。这样就可以在必要的时候避免所有非公开的事件向外传递。

#### 线程:

Domino除 `DominoSelectorEventParams`之外都是线程安全的. 考虑到大多使用场景都是UI事件, **所以所有订阅默认都是在主线程调用的。** 

当然，你也可以选择其他模式

```ob
typedef NS_ENUM(NSInteger, DominoTriggerMode) {
    DominoTriggerModeMainThread,  // default
    DominoTriggerModeBackground,
    DominoTriggerModeCurrentThread,
};
```

可以通过 `[Domino setTriggerMode:DominoTriggerModeBackground]`来修改Domino的Mode。值得注意的是， Mode并**不**影响带有返回值的SelectorEvent，带有返回值的SelectorEvent的处理总是在发起该事件的线程中进行。



## 安装

如果使用 Cocoapods的话，将`pod 'Domino', '~> 1.0.0'` 加到你的Podfile文件里即可。

你也可以直接把 `Domino.h/m` 这两个文件直接拖到你的工程里面。

## License

Domino is released under the MIT license. See [LICENSE](./LICENSE) for details.