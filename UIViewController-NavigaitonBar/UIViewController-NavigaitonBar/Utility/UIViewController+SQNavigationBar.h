//
//  UIViewController+SQNavigationBar.h
//  UIViewController-NavigationBar
//
//  Created by roylee on 2017/12/24.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SQNavigationBar)

#pragma mark - Elements Alpha
///=============================================================================
/// @name Elements Alpha
///=============================================================================

/// Title view or just the title of the navigaiton bar.
@property (nonatomic, assign) CGFloat titleAlpha;

/// Just background view without title, bar buttons.
@property (nonatomic, assign) CGFloat navigationBarBackgroundAlpha;

/// Alpha of the right and left bar buttons.
@property (nonatomic, assign) CGFloat navigationBarBarButtonsAlpha;

/// All the elements in the navigaiton bar (title, background, bar buttons).
@property (nonatomic, assign) CGFloat navigationBarElementsAlpha;


#pragma mark - Bar Buttons
///=============================================================================
/// @name Bar Buttons
///=============================================================================



@end
