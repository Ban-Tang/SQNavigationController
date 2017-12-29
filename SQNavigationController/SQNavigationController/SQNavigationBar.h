//
//  SQNavigationBar.h
//  SQNavigationController
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Inset between the image icon of title, when the bar button has both title and image.
/// Default is 8. [IMG <-inst-> TEXT]
UIKIT_EXTERN CGFloat const kBarButtonImageTitleInset;
/// An addition area for touch, default is 8. [<-8-> IMG_ITEM <-8->]
UIKIT_EXTERN CGFloat const kBarButtonItemEdgeInset;
/// Left or right padding of the edgest item, so the left of the first item in the left bar buttons is 8, and
/// the right of the last item in the right bar bttons is screen width - 8. Default is 8.
UIKIT_EXTERN CGFloat const kNavigationBarButtonPadding;
/// Line spacing between two bar button item. Default is 5.
UIKIT_EXTERN CGFloat const kBarButtonItemLineSpacing;

@interface SQNavigationBar : UIView

@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, readonly) UIImageView *bottomLine;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIImageView *backgroundImageView; //!< default is nil.

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray <UIBarButtonItem *>*leftBarButtonItems;
@property (nonatomic, copy) NSArray <UIBarButtonItem *>*rightBarButtonItems;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

#pragma mark - Appearance Property
///=============================================================================
/// @name Appearance Property
///=============================================================================

/// Custom config the title attributes.
@property (nonatomic, copy) NSDictionary <NSString *,id>*titleTextAttributes UI_APPEARANCE_SELECTOR;

/// An image for back ground.
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

/// Shadow image at the bottom fo this navigation bar, the top of this image is at
/// the bottom of this navigaiton bar.
@property (nonatomic, strong) UIImage *shadowImage UI_APPEARANCE_SELECTOR;

/// Just is background corlor the bar.
@property (nonatomic, strong) UIColor *barTintColor UI_APPEARANCE_SELECTOR;

/// Color for bar button text element in this navigation bar.
@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;

/// Inset padding for the first bar button item of left buttons, or the last button of right
/// buttons.
///
/// If the value is more than 0, the first button will be moved to inside with the value
/// distance.
/// eg.
///    [<-default padding->[BUTTON]                                        [BUTTON]<-default padding->]
///
///    add a inset: left inset = 8, right inset = 8.
///
///    [<-default padding-><-left inset->[BUTTON]           [BUTTON]<-right inset-><-default padding->]
///
@property (nonatomic, assign) CGFloat leftBarButtonItemPaddingInset UI_APPEARANCE_SELECTOR;

/// Same as `leftBarButtonItemPaddingInset` above.
@property (nonatomic, assign) CGFloat rightBarButtonItemPaddingInset UI_APPEARANCE_SELECTOR;

/// Line spacing between two bar button, default is kBarButtonItemLineSpacing.
@property (nonatomic, assign) CGFloat barButtonItemLineSpacing UI_APPEARANCE_SELECTOR;

@end




/// Methods for config the alpha of navigation bar, KVO available.
@interface SQNavigationBar (Alpha)

@property (nonatomic, assign) CGFloat titleAlpha;
@property (nonatomic, assign) CGFloat backgroundAlpha;
@property (nonatomic, assign) CGFloat barButtonsAlpha;
@property (nonatomic, assign) CGFloat elementsAlpha;

@end




/// Addition for UIBarButtonItem.
@interface UIBarButtonItem (SQNavigaitonBar)

/// Inset between icon image and title.
@property (nonatomic, assign) CGFloat titleImageInset;
/// padding of the edge, adjust for horizontal frame.
@property (nonatomic, assign) CGFloat layoutMargin;
/// edge of the item, just like `kBarButtonItemEdgeInset`.
@property (nonatomic, assign) CGFloat itemEdgeInset;

@end




@interface UIViewController (SQNavigaitonBar)

@property (nonatomic, readonly) SQNavigationBar *navigationBar;
@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

- (SQNavigationBar *)setupNavigationBar;

@end

