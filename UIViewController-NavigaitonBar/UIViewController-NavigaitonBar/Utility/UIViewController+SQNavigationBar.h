//
//  UIViewController+SQNavigationBar.h
//  UIViewController-NavigationBar
//
//  Created by roylee on 2017/12/24.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SQBarButtonPosition) {
    SQBarButtonPositionNone,
    SQBarButtonPositionLeft,
    SQBarButtonPositionRight
};

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

/// Add bar button for navigaiton bar.
///
/// @param position     Indicate left or right bar button
/// @param image        The image for the button
/// @param title        Title of the bar button, if both have image & title, the title will be
///                     at the right of the image.
/// @param action       A custom action when click the bar button.
/// @param offset       Layout offset for this bar button, if the value is more than 0, the bar button
///                     will be adjust to center of its navigaiton bar.
- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image title:(NSString *)title action:(SEL)action margin:(CGFloat)offset;

/// Same as above.
- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image action:(SEL)action margin:(CGFloat)offset;

/// Same as above.
- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withTitle:(NSString *)title action:(SEL)action margin:(CGFloat)offset;

/// Same as above, the default `offset` is 0.
- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image title:(NSString *)title action:(SEL)action;

/// Same as above.
- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withImage:(UIImage *)image action:(SEL)action;

/// Same as above.
- (void)setBarButtonAtPosition:(SQBarButtonPosition)position withTitle:(NSString *)title action:(SEL)action;

@end
