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

@end
