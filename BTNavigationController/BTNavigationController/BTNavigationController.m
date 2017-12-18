//
//  BTNavigationController.m
//  BTNavigationController
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "BTNavigationController.h"
#import <objc/runtime.h>

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



@interface BTNavigationController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *fullScreenPopGestureRecognizer;
@property (nonatomic, strong) BTFullscreenPopGestureRecognizerDelegate *popGestureRecognizerDelegate;

@end

@implementation BTNavigationController

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
    self.navigationBarHidden = YES;
    
    if (@available(iOS 11.0, *)) {
        BOOL iPhoneX = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO);
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(-(iPhoneX ? 44 : 20), 0, 0, 0);
    }
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
    BTNavigationController *navigationController = (BTNavigationController *)self.navigationController;
    if (!navigationController) {
        return;
    }
    NSAssert([navigationController isKindOfClass:[BTNavigationController class]], @"The navigationController of self must be class of `BTNavigationController`.");
    [gestureRecoginzer requireGestureRecognizerToFail:navigationController.fullScreenPopGestureRecognizer];
}

@end
