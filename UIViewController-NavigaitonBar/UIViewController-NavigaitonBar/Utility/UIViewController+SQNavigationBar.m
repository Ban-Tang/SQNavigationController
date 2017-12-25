//
//  UIViewController+SQNavigationBar.m
//  UIViewController-NavigationBar
//
//  Created by roylee on 2017/12/24.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "UIViewController+SQNavigationBar.h"
#import <SQNavigationController/SQNavigationController.h>
#import <SQNavigationController/SQNavigationBar.h>

@implementation UIViewController (SQNavigationBar)

#pragma mark - Bar Elements

- (CGFloat)titleAlpha {
    return self.navigationBar.titleAlpha;
}

- (void)setTitleAlpha:(CGFloat)titleAlpha {
    self.navigationBar.titleAlpha = titleAlpha;
}

- (CGFloat)navigationBarBackgroundAlpha {
    return self.navigationBar.backgroundAlpha;
}

- (void)setNavigationBarBackgroundAlpha:(CGFloat)navigationBarBackgroundAlpha {
    self.navigationBar.backgroundAlpha = navigationBarBackgroundAlpha;
}

- (CGFloat)navigationBarBarButtonsAlpha {
    return self.navigationBar.barButtonsAlpha;
}

- (void)setNavigationBarBarButtonsAlpha:(CGFloat)navigationBarBarButtonsAlpha {
    self.navigationBar.barButtonsAlpha = navigationBarBarButtonsAlpha;
}

- (CGFloat)navigationBarElementsAlpha {
    return self.navigationBar.elementsAlpha;
}

- (void)setNavigationBarElementsAlpha:(CGFloat)navigationBarElementsAlpha {
    self.navigationBar.elementsAlpha = navigationBarElementsAlpha;
}

#pragma mark - Bar Buttons

- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image title:(NSString *)title action:(SEL)action margin:(CGFloat)offset {
    if (position == SQBarButtonPositionNone) {
        return;
    }
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem new];
    barButtonItem.image = image;
    barButtonItem.title = title;
    barButtonItem.action = action;
    
    if (position == SQBarButtonPositionLeft) {
        barButtonItem.layoutMargin = offset;
        self.navigationBar.leftBarButtonItem = barButtonItem;
    }else {
        barButtonItem.layoutMargin = -offset;
        self.navigationBar.rightBarButtonItem = barButtonItem;
    }
}

- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image action:(SEL)action margin:(CGFloat)offset {
    [self setBarButtonAtPosition:position withImage:image title:nil action:action margin:offset];
}

- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withTitle:(NSString *)title action:(SEL)action margin:(CGFloat)offset {
    [self setBarButtonAtPosition:position withImage:nil title:title action:action margin:offset];
}

- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image title:(NSString *)title action:(SEL)action {
    [self setBarButtonAtPosition:position withImage:image title:title action:action margin:0];
}

- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image action:(SEL)action {
    [self setBarButtonAtPosition:position withImage:image title:nil action:action];
}

- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withTitle:(NSString *)title action:(SEL)action {
    [self setBarButtonAtPosition:position withImage:nil title:title action:action];
}

@end
