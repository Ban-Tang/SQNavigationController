//
//  SQNavigationController.h
//  SQNavigationController
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQNavigationController : UINavigationController

/// A full screen pan gesturerecognizer instead of the system's interactivePopGestureRecognizer.
@property (nonatomic, readonly) UIPanGestureRecognizer *fullScreenPopGestureRecognizer;

/// Whether the full screen gesture recognizer is effect. Default is NO, means it is effect.
///
/// If is YES, the property `interactivePopDisabled` of viewcontroller will not effect. It
/// is whole effect of the navigation controller.
@property (nonatomic, assign) BOOL interactivePopDisabled;

/// Indicate whether use system `UINavigationBar` or not. If not every view controller
/// will be added a custom navigation bar.
/// 
/// Default is NO.
@property (nonatomic, assign) BOOL useSystemNavigationBar;


#pragma mark - Appearance Property
///=============================================================================
/// @name Appearance Property
///=============================================================================

/// Custom the back bar button for the navigation bar. It support uiappearance.
///
/// This back bar button item will be effect when the top view controller has no back button
@property (nonatomic, strong) UIBarButtonItem *globalBackBarButtonItem UI_APPEARANCE_SELECTOR;

@end



@interface UIViewController (FullScreenPopGestureRecognizer)

/// Whether the full screen gesture recognizer is effect. Default is NO, means it is effect.
@property (nonatomic, assign) BOOL interactivePopDisabled;

/// This property indicate the max edge distance from left when allow the gesture effect.
/// Default is 0, which means allow full screen pop gesture.
@property (nonatomic, assign) CGFloat interactivePopMaxAllowedInitialDistanceToLeftEdge;

/// Add a require condition from a gesture of scrollview. The pan gesture of scrollview will
/// effect only when the `fullScreenPopGestureRecognizer` of the navigation controller failed.
- (void)requireFullScreenPopGestureRecognizerFromScrollView:(UIScrollView *)scrollView;

/// Add a require condition from a gesture. The gesture will effect only when the
/// `fullScreenPopGestureRecognizer` of the navigation controller failed.
- (void)requireFullScreenPopGestureRecognizerFailed:(UIGestureRecognizer *)gestureRecoginzer;

@end




