//
//  UIViewController+SQNavigationBar.m
//  UIViewController-NavigationBar
//
//  Created by roylee on 2017/12/24.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "UIViewController+SQNavigationBar.h"
//#ifdef SQNAVIGATION
#import <SQNavigationController/SQNavigationController.h>
#import <SQNavigationController/SQNavigationBar.h>
//#endif
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, SQNavigaiotnBarElement) {
    SQNavigaiotnBarElementNone,
    SQNavigaiotnBarElementBackground = 1 << 0,
    SQNavigaiotnBarElementTitle = 1 << 1,
    SQNavigaiotnBarElementBarButtons = 1 << 2,
    SQNavigaiotnBarElementAll = (1 << 0) + (1 << 2) + (1 << 3),
};

@implementation UIViewController (SQNavigationBar)

#pragma mark - Bar Elements

#ifdef SQNAVIGATION
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
#else
- (CGFloat)titleAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setTitleAlpha:(CGFloat)titleAlpha {
    UIView *titleView = [self.navigationController.navigationBar valueForKey:@"_titleView"];
    titleView.alpha = titleAlpha;
    objc_setAssociatedObject(self, @selector(titleAlpha), @(titleAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)navigationBarBackgroundAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setNavigationBarBackgroundAlpha:(CGFloat)navigationBarBackgroundAlpha {
    objc_setAssociatedObject(self, @selector(navigationBarBackgroundAlpha), @(navigationBarBackgroundAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setElement:SQNavigaiotnBarElementBackground alpha:navigationBarBackgroundAlpha];
}

- (CGFloat)navigationBarBarButtonsAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setNavigationBarBarButtonsAlpha:(CGFloat)navigationBarBarButtonsAlpha {
    objc_setAssociatedObject(self, @selector(navigationBarBarButtonsAlpha), @(navigationBarBarButtonsAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setElement:SQNavigaiotnBarElementBarButtons alpha:navigationBarBarButtonsAlpha];
}

- (CGFloat)navigationBarElementsAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setNavigationBarElementsAlpha:(CGFloat)navigationBarElementsAlpha {
    objc_setAssociatedObject(self, @selector(navigationBarElementsAlpha), @(navigationBarElementsAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setElement:SQNavigaiotnBarElementAll alpha:navigationBarElementsAlpha];
}

- (void)setElement:(SQNavigaiotnBarElement)element alpha:(CGFloat)alpha {
    if (element == SQNavigaiotnBarElementNone) return;
    
    if (element & SQNavigaiotnBarElementTitle) {
        UIView *titleView = [self valueForKey:@"_titleView"];
        titleView.alpha = alpha;
    }
    
    if (element & SQNavigaiotnBarElementBackground || element & SQNavigaiotnBarElementTitle) {
        // when viewController first load, the titleView maybe nil
        __block NSInteger stopTag = 0;
        [[self.navigationController.navigationBar subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            if (element & SQNavigaiotnBarElementTitle) {
                if ([obj isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {  // tittle view
                    obj.alpha = alpha;
                    if (!(element & SQNavigaiotnBarElementBackground)) {
                        *stop = YES;
                    }
                    stopTag ++;
                }
            }
            if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {  // background view
                obj.alpha = alpha;
                stopTag ++;
            }
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {  // iOS10 after background view
                obj.alpha = alpha;
                stopTag ++;
            }
            if (stopTag == (element & SQNavigaiotnBarElementTitle) ? 2 : 1) {
                *stop = YES;
            }
        }];
    }
    
    if (element & SQNavigaiotnBarElementBarButtons) {
        [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
            view.alpha = alpha;
        }];
        
        [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
            view.alpha = alpha;
        }];
    }
}
#endif




#pragma mark - Property

#ifdef SQNAVIGATION
- (UIImage *)navigationBarBackgroundImage {
    return self.navigationBar.backgroundImage;
}

- (void)setNavigationBarBackgroundImage:(UIImage *)navigationBarBackgroundImage {
    self.navigationBar.backgroundImage = navigationBarBackgroundImage;
}
#else
- (UIImage *)navigationBarBackgroundImage {
    return [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
}

- (void)setNavigationBarBackgroundImage:(UIImage *)navigationBarBackgroundImage {
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
}
#endif



#pragma mark - Bar Buttons

- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image title:(NSString *)title action:(SEL)action margin:(CGFloat)offset {
    if (position == SQBarButtonPositionNone) {
        return;
    }
#ifdef SQNAVIGATION
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
#else
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:action];
    item.title = title;
    UIBarButtonItem *spaceItem = nil;
    if (offset > 0) {
        spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceItem.width = offset;
    }
    
    if (position == SQBarButtonPositionLeft) {
        if (spaceItem) {
            self.navigationItem.leftBarButtonItems = @[item, spaceItem];
        }else {
            self.navigationItem.leftBarButtonItem = item;
        }
    }else {
        if (spaceItem) {
            self.navigationItem.rightBarButtonItems = @[spaceItem, item];
        }else {
            self.navigationItem.rightBarButtonItem = item;
        }
    }
#endif
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
