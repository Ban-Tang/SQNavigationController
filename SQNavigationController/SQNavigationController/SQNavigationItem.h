//
//  SQNavigationItem.h
//  SQNavigationController
//
//  Created by roylee on 2017/12/20.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <UIKit/UIKit.h>

/// A private custom navigation item for intercepting, to config the custom
/// navigaiton bar in its view controller.
@interface SQNavigationItem : UINavigationItem

@property (nonatomic, weak) UIViewController *viewController;

@end



@interface UIViewController (SQNavigationItem)

- (void)replaceNavigationItem;

@end
