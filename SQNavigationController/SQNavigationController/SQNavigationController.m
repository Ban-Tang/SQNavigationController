//
//  SQNavigationController.m
//  SQNavigationController
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "SQNavigationController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "SQNavigationItem.h"

/// Simple method wihtout object swizzle for layout methods.
static inline void SQSwizzleMethodUsingBlock(Class class, SEL originalSelector, BOOL shouldReturn, void(^block)(id receiver, id result)) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    
    // Preserve any existing implementation.
    void (*originalInvocation)(id, SEL) = NULL;
    if (originalMethod != NULL) {
        originalInvocation = (__typeof__(originalInvocation))method_getImplementation(originalMethod);
    }
    
    // Set a common call back block.
    id(^invokeBlock)(id receiver, id obj1) = ^id(id receiver, id obj1) {
        id result = nil;
        if (originalInvocation != NULL) {
            if (shouldReturn) {
                id (*originalInvocation1)(id, SEL) = (id (*)(id, SEL))originalInvocation;
                result = originalInvocation1(receiver, originalSelector);
                block(receiver, result);
            }else {
                originalInvocation(receiver, originalSelector);
                block(receiver, nil);
            }
        }else {
            [receiver doesNotRecognizeSelector:originalSelector];
        }
        return result;
    };
    
    // Set up a new invocation.
    id newInvocation = NULL;
    if (shouldReturn) {
        newInvocation = ^id(id receiver) {
            return invokeBlock(receiver, nil);
        };
    }else {
        newInvocation = ^(id receiver) {
            invokeBlock(receiver, nil);
        };
    }
    
    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    class_replaceMethod(class, originalSelector, imp_implementationWithBlock(newInvocation), typeEncoding);
}



@interface BTFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation BTFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // Ignore when the `interactivePopDisabled` is YES
    if (self.navigationController.interactivePopDisabled) {
        return NO;
    }
    
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.interactivePopDisabled) {
        return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end




@interface SQNavigationControllerProxy : NSObject<UINavigationControllerDelegate> {
    __weak id _delegate;
}
@end

@implementation SQNavigationControllerProxy

- (instancetype)initWithDelegate:(id<UINavigationControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_delegate respondsToSelector:aSelector] || [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    // Keep it lightweight: access the ivar directly
    if ([_delegate respondsToSelector:selector]) {
        return _delegate;
    }
    return [super forwardingTargetForSelector:selector];
}

// handling unimplemented methods and nil target/interceptor
// https://github.com/Flipboard/FLAnimatedImage/blob/76a31aefc645cc09463a62d42c02954a30434d7d/FLAnimatedImage/FLAnimatedImage.m#L786-L807
- (void)forwardInvocation:(NSInvocation *)invocation {
    // Fallback for when target is nil. Don't do anything, just return 0/NULL/nil.
    // The method signature we've received to get here is just a dummy to keep `doesNotRecognizeSelector:` from firing.
    // We can't really handle struct return types here because we don't know the length.
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    // We only get here if `forwardingTargetForSelector:` returns nil.
    // In that case, our weak target has been reclaimed. Return a dummy method signature to keep `doesNotRecognizeSelector:` from firing.
    // We'll emulate the Obj-c messaging nil behavior by setting the return value to nil in `forwardInvocation:`, but we'll assume that the return value is `sizeof(void *)`.
    // Other libraries handle this situation by making use of a global method signature cache, but that seems heavier than necessary and has issues as well.
    // See https://www.mikeash.com/pyblog/friday-qa-2010-02-26-futures.html and https://github.com/steipete/PSTDelegateProxy/issues/1 for examples of using a method signature cache.
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSAssert(![viewController isKindOfClass:[UITableViewController class]], @"SQNavigationController does not support UITableViewController.");
    
    // Disable scroll view inset adjust.
    viewController.edgesForExtendedLayout = UIRectEdgeNone;
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    
    // Add a back button if need.
    SQNavigationBar *navigationBar = viewController.navigationBar;
    if (navigationController.viewControllers.count > 1) {
        SQNavigationItem *navigationItem = (SQNavigationItem *)viewController.navigationItem;
        if (!navigationItem.hidesBackButton) {
            navigationBar.leftBarButtonItem = navigationItem.backBarButtonItem;
        }
    }
    
    // Add the custom navigation bar.
    if (![viewController.navigationBar isDescendantOfView:viewController.view]) {
        [viewController.view addSubview:viewController.navigationBar];
    }
    
    if ([_delegate respondsToSelector:_cmd]) {
        [_delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

@end





@interface UIViewController (SQNavigationControllerSwizzle)
+ (void)swizzleMethods;
@end



@interface SQNavigationController ()<UIGestureRecognizerDelegate>
    
@property (nonatomic, strong) SQNavigationControllerProxy *proxy;
@property (nonatomic, strong) UIPanGestureRecognizer *fullScreenPopGestureRecognizer;
@property (nonatomic, strong) BTFullscreenPopGestureRecognizerDelegate *popGestureRecognizerDelegate;
@property (nonatomic, strong) NSMapTable *hiddenNavigationBarMap;
@property (nonatomic, strong) UIViewController *lastestViewControllerCalledNavigationController;

@end

@implementation SQNavigationController

/// Not use `+ load` if can use `+ initialize`.
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController swizzleMethods];
    });
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self.viewControllers.firstObject replaceNavigationItem];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.viewControllers.firstObject replaceNavigationItem];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the system edge gesture target
    id target = self.interactivePopGestureRecognizer.delegate;
    
    // Create the full screen gesture recognizer delegate.
    self.popGestureRecognizerDelegate = [[BTFullscreenPopGestureRecognizerDelegate alloc] init];
    _popGestureRecognizerDelegate.navigationController = self;
    
    // Create new pan gesture recognizer. "handleNavigationTransition:" is system gesture action.
    self.fullScreenPopGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    _fullScreenPopGestureRecognizer.delegate = _popGestureRecognizerDelegate;
    
    // Add the full screen gesture recognizer.
    [self.view addGestureRecognizer:_fullScreenPopGestureRecognizer];
    
    // Disable system interactive gesture recognizer.
    self.interactivePopGestureRecognizer.enabled = NO;
    
    // Default hidden the navigation bar.
    if (!_useSystemNavigationBar) {
        [super setNavigationBarHidden:YES animated:NO];
    }
    
    // Reset delegate to proxy.
    self.proxy = [[SQNavigationControllerProxy alloc] initWithDelegate:nil];
    super.delegate = _proxy;
    
    if (@available(iOS 11.0, *)) {
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(-(iPhoneX ? 44 : 20), 0, 0, 0);
    }
}

#pragma mark - Override

// Intercept the delegate methods.
- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    // The delegate caches whether the delegate responds to some of the delegate
    // methods, so we need to force it to re-evaluate if the delegate responds to them
    super.delegate = nil;
    
    self.proxy = [[SQNavigationControllerProxy alloc] initWithDelegate:delegate];
    super.delegate = self.proxy;
}

// Override the method to handle the navigation bar of current viewcontroller.
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    if (_useSystemNavigationBar) {
        [super setNavigationBarHidden:navigationBarHidden];
    }else {
        [self.lastestViewControllerCalledNavigationController setNavigationBarHidden:navigationBarHidden];
    }
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (_useSystemNavigationBar) {
        [super setNavigationBarHidden:hidden animated:animated];
    }else {
        [self.lastestViewControllerCalledNavigationController setNavigationBarHidden:hidden animated:animated];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Replace the navigationItem of this viewController.
    [viewController replaceNavigationItem];
    
    // Push the view controller.
    [super pushViewController:viewController animated:animated];
    
    // Add the custom navigation bar after push action.
    [viewController.view addSubview:viewController.navigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end



@implementation UIViewController (FullScreenPopGestureRecognizer)

- (BOOL)interactivePopDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setInteractivePopDisabled:(BOOL)interactivePopDisabled {
    objc_setAssociatedObject(self, @selector(interactivePopDisabled), @(interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)interactivePopMaxAllowedInitialDistanceToLeftEdge {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setInteractivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)interactivePopMaxAllowedInitialDistanceToLeftEdge {
    objc_setAssociatedObject(self, @selector(interactivePopMaxAllowedInitialDistanceToLeftEdge), @(interactivePopMaxAllowedInitialDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)requireFullScreenPopGestureRecognizerFromScrollView:(UIScrollView *)scrollView {
    [self requireFullScreenPopGestureRecognizerFailed:scrollView.panGestureRecognizer];
}

- (void)requireFullScreenPopGestureRecognizerFailed:(UIGestureRecognizer *)gestureRecoginzer {
    SQNavigationController *navigationController = (SQNavigationController *)self.navigationController;
    if (!navigationController) {
        return;
    }
    NSAssert([navigationController isKindOfClass:[SQNavigationController class]], @"The navigationController of self must be class of `SQNavigationController`.");
    [gestureRecoginzer requireGestureRecognizerToFail:navigationController.fullScreenPopGestureRecognizer];
}

@end





@implementation UIViewController (SQNavigationControllerSwizzle)

+ (void)swizzleMethods {
    // swizzle layout for change the layer of navigation bar.
    SQSwizzleMethodUsingBlock([self class], @selector(viewWillLayoutSubviews), NO, ^(id receiver, id result) {
        if (receiver) {
            [receiver sq_viewWillLayoutSubviews];
        }
    });
    
    // swizzle `navigationController` to add refence the current view controller receiver.
    SQSwizzleMethodUsingBlock([self class], @selector(navigationController), YES, ^(id receiver, id result) {
        if ([result isKindOfClass:[SQNavigationController class]]) {
            [result setLastestViewControllerCalledNavigationController:receiver];
        }
    });
}

static inline NSArray <Class>*SQNavigationBarBlackList() {
    static dispatch_once_t onceToken;
    static NSArray <Class>*blackList;
    dispatch_once(&onceToken, ^{
        blackList = @[[UINavigationController class],
                      [UITableViewController class],
                      [UITabBarController class],
                      ];
    });
    return blackList;
}

- (void)sq_viewWillLayoutSubviews {
    for (Class c in SQNavigationBarBlackList()) {
        if ([self isKindOfClass:c]) return;
    }
    
    BOOL navigationBarHiddenByChildViewController = NO;
    for (UIViewController *childVC in self.childViewControllers) {
        if (!childVC.isNavigationBarHidden) {
            navigationBarHiddenByChildViewController = YES;
            break;
        }
    }
    
    navigationBarHiddenByChildViewController |= self.navigationBarHidden;
    self.navigationBarHidden = navigationBarHiddenByChildViewController;
    
    [self.view bringSubviewToFront:self.navigationBar];
}

@end










