//
//  SQNavigationItem.m
//  SQNavigationController
//
//  Created by roylee on 2017/12/20.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "SQNavigationItem.h"
#import "SQNavigationBar.h"

@implementation SQNavigationItem

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    _viewController.navigationBar.title = title;
}

- (void)setTitleView:(UIView *)titleView {
    [super setTitleView:titleView];
    _viewController.navigationBar.titleView = titleView;
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [super setLeftBarButtonItem:leftBarButtonItem];
    _viewController.navigationBar.leftBarButtonItem = leftBarButtonItem;
}

- (void)setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    [super setLeftBarButtonItems:leftBarButtonItems];
    _viewController.navigationBar.leftBarButtonItems = leftBarButtonItems;
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    [super setRightBarButtonItem:rightBarButtonItem];
    _viewController.navigationBar.rightBarButtonItem = rightBarButtonItem;
}

- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    [super setRightBarButtonItems:rightBarButtonItems];
    _viewController.navigationBar.rightBarButtonItems = rightBarButtonItems;
}

@end




@implementation UIViewController (SQNavigationItem)

// Replace the system navigationItem to custom.
- (void)replaceNavigationItem {
    if ([self.navigationItem isKindOfClass:[SQNavigationItem class]]) {
        return;
    }
    SQNavigationItem *navigationItem = [[SQNavigationItem alloc] initWithTitle:self.title];
    navigationItem.viewController = self;
    [self setValue:navigationItem forKey:@"navigationItem"];
}

@end

