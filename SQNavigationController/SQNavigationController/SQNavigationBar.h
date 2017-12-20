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
/// An addition area for touch, default is 15. [<-15-> IMG_ITEM <-15->]
UIKIT_EXTERN CGFloat const kBarButtonItemEdgeInset;
/// Left or right padding of the edgest item, so the left of the first item in the left bar buttons is 8, and
/// the right of the last item in the right bar bttons is screen width - 8. Default is 8.
UIKIT_EXTERN CGFloat const kNavigationBarButtonPadding;
/// Line spacing between two bar button item. Default is 15.
UIKIT_EXTERN CGFloat const kBarButtonItemLineSpacing;

@interface SQNavigationBar : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, readonly) UIImageView *bottomLine;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIImageView *backgroundImageView; //!< default is nil.
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *shadowImage;
@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *tintColor; //!< color for bar button item title.
@property (nonatomic, copy) NSDictionary <NSString *,id>*titleTextAttributes;
@property (nonatomic, copy) NSArray <UIBarButtonItem *>*leftBarButtonItems;
@property (nonatomic, copy) NSArray <UIBarButtonItem *>*rightBarButtonItems;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end



@interface SQNavigationBar (Alpha)

@property (nonatomic, assign) CGFloat elementAlpa;

- (void)setElementsAlpha:(CGFloat)alpha;

@end




@interface UIBarButtonItem (Extesnion)

@property (nonatomic, strong) NSString *imageName; //!< the name of image, default is nil.
@property (nonatomic, assign) CGFloat titleImageInset;
@property (nonatomic, assign) CGFloat layoutMargin; //!< padding of the edge, adjust for x frame.
@property (nonatomic, assign) CGFloat itemEdgeInset; //!< edge of the item, just like `kBarButtonItemEdgeInset`.

@end



@interface UIViewController (BTNavigaitonBar)

@property (nonatomic, readonly) SQNavigationBar *navigationBar;
@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end


#ifndef iPhoneX
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#endif

#ifndef kStatusBarHeight
#define kStatusBarHeight  (iPhoneX ? 44 : 20)
#endif

#ifndef kNavigationHeight
#define kNavigationHeight (kStatusBarHeight + 44)
#endif

#ifndef kScreenWidth
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#endif

#ifndef kScreenHeight
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#endif
