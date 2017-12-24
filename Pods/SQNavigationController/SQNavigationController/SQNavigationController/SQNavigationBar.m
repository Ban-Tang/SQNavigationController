//
//  SQNavigationBar.m
//  SQNavigationController
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "SQNavigationBar.h"
#import <objc/runtime.h>

#ifndef kNavigationBarHeight
#define kNavigationBarHeight 44
#endif

CGFloat const kBarButtonImageTitleInset = 8;
CGFloat const kBarButtonItemEdgeInset = 8;
CGFloat const kNavigationBarButtonPadding = 8;
CGFloat const kBarButtonItemLineSpacing = 5;

@interface SQNavigationBar ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray <UIView *>*leftViews;
@property (nonatomic, strong) NSMutableArray <UIView *>*rightViews;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *backgroundBarImageView;
@property (nonatomic, strong) UIImageView *shadowImageView;

@end

@implementation SQNavigationBar

+ (SQNavigationBar *)navigationBar {
    SQNavigationBar *navigationBar = [[SQNavigationBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    return navigationBar;
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame = CGRectMake(0, 0, frame.size.width, kNavigationHeight);
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self setupViews];
    }
    return self;
}

- (void)commonInit {
    _leftViews = [NSMutableArray arrayWithCapacity:0];
    _rightViews = [NSMutableArray arrayWithCapacity:0];
    _tintColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1];
    
    // init appearance property here, and they will be changed later.
    _leftBarButtonItemPaddingInset = kNavigationBarButtonPadding;
    _rightBarButtonItemPaddingInset = kNavigationBarButtonPadding;
    _barButtonItemLineSpacing = kBarButtonItemLineSpacing;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.backgroundColor = [UIColor whiteColor];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // title.
    self.titleLabel = [UILabel new];
    _titleLabel.frame = CGRectMake(0, kStatusBarHeight, CGRectGetWidth(self.frame), kNavigationBarHeight);
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleTextAttributes = @{NSFontAttributeName:_titleLabel.font,
                             NSForegroundColorAttributeName:[UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1]};
    
    // line image.
    self.shadowImageView = [[UIImageView alloc] initWithImage:nil];
    _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _shadowImageView.backgroundColor = [UIColor colorWithRed:238.0/ 255 green:238.0/ 255 blue:238.0/ 255 alpha:1];
    
    [self addSubview:_backgroundView];
    [self addSubview:_titleLabel];
    [_backgroundView addSubview:_shadowImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // layout title.
    [self layoutTitleView];
    
    // layout bar button items.
    [self layoutBarButtonItems];
    
    // layout bottom line.
    [self layoutBottomLine];
}

- (void)layoutTitleView {
    CGFloat padding = 8;
    CGFloat left  = CGRectGetMaxX(_leftViews.lastObject.frame) + padding;
    left = MAX(25, left);
    CGFloat right = (_rightViews.firstObject ? CGRectGetMinX(_rightViews.firstObject.frame) : CGRectGetWidth(self.bounds)) - padding;
    right = MIN(CGRectGetWidth(self.frame) - right, 25);
    CGFloat maxW  = CGRectGetWidth(self.bounds) - 2 *MAX(left, right);
    CGRect frame = _titleLabel.frame;
    if (frame.size.width >= maxW && maxW > 0) {
        frame.size.width = maxW;
        frame.origin.x   = left;
    }else {
        // horizontal center.
        frame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame)) / 2;
    }
    _titleLabel.frame = frame;
}

- (void)layoutBarButtonItems {
    // left items.
    [self layoutLeftBarButtonItems];
    
    // right items.
    [self layoutRightBarButtonItems];
}

- (void)layoutLeftBarButtonItems {
    __block CGFloat itemLeft = _leftBarButtonItemPaddingInset;
    __block NSInteger skipIndex = 0;
    [_leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // It is a adjust item (UIBarButtonSystemItemFixedSpace), if the width is not 0.
        if (obj.width != 0) {
            itemLeft += obj.width;
            skipIndex ++;
        }
        // Normal item.
        else {
            UIView *itemView = _leftViews[idx - skipIndex];
            CGRect frame = itemView.frame;
            frame.origin.x = itemLeft + obj.layoutMargin;
            itemView.frame = frame;
            itemLeft = CGRectGetMaxX(frame) + _barButtonItemLineSpacing;
        }
    }];
    
    if (_leftBarButtonItem) {
        UIView *itemView = [_leftViews firstObject];
        CGRect frame = itemView.frame;
        frame.origin.x = itemLeft + _leftBarButtonItem.layoutMargin;
        NSLog(@"left margin is %.f", _leftBarButtonItem.layoutMargin);
        itemView.frame = frame;
    }
}

- (void)layoutRightBarButtonItems {
    __block CGFloat itemRight = CGRectGetWidth(self.bounds) - _rightBarButtonItemPaddingInset;
    __block NSInteger index = _rightViews.count - 1;
    [_rightBarButtonItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // It is a adjust item (UIBarButtonSystemItemFixedSpace), if the width is not 0.
        if (obj.width != 0) {
            itemRight -= obj.width;
        }
        // Normal item.
        else {
            UIView *itemView = _rightViews[index];
            CGRect frame = itemView.frame;
            frame.origin.x = itemRight + obj.layoutMargin - CGRectGetWidth(frame);
            itemView.frame = frame;
            itemRight = CGRectGetMinX(frame) - _barButtonItemLineSpacing;
            index --;
        }
    }];
    
    if (_rightBarButtonItem) {
        UIView *itemView = [_rightViews lastObject];
        CGRect frame = itemView.frame;
        frame.origin.x = itemRight + _rightBarButtonItem.layoutMargin - CGRectGetWidth(frame);
        itemView.frame = frame;
    }
}

- (void)layoutBottomLine {
    CGFloat lineHeight = _shadowImageView.image ? _shadowImageView.image.size.height : 0.5;
    _shadowImageView.frame = CGRectMake(0, CGRectGetHeight(self.bounds), self.bounds.size.width, lineHeight);
}

#pragma mark - Setter

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title ?: @""
                                                                 attributes:_titleTextAttributes];
    CGRect frame = _titleLabel.frame;
    frame.size.width = ceil([title boundingRectWithSize:CGSizeMake(self.bounds.size.width, frame.size.height)
                                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:_titleTextAttributes
                                                context:nil].size.width);
    _titleLabel.frame = frame;
    [self layoutTitleView];
}

- (void)setTitleView:(UIView *)titleView {
    if (_titleView && _titleView != _titleLabel) {
        [_titleView removeFromSuperview];
    }
    _titleView = titleView;
    _titleLabel.hidden = titleView != nil;
    _titleView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, kStatusBarHeight + kNavigationBarHeight / 2);
    [self addSubview:_titleView];
}

- (void)setBackgroundImageView:(UIImageView *)backgroundImageView {
    if (backgroundImageView) {
        if (_backgroundBarImageView) {
            [self insertSubview:backgroundImageView aboveSubview:_backgroundBarImageView];
        }else {
            [self insertSubview:backgroundImageView atIndex:0];
        }
    }else {
        [backgroundImageView removeFromSuperview];
    }
    _backgroundImageView = backgroundImageView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    if (backgroundImage) {
        if (_backgroundBarImageView == nil) {
            _backgroundBarImageView = [[UIImageView alloc] initWithFrame:self.bounds];
            _backgroundBarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_backgroundView insertSubview:_backgroundBarImageView atIndex:0];
        }
        _backgroundBarImageView.image = backgroundImage;
    }
    _backgroundBarImageView.hidden = !backgroundImage;
}

- (void)setShadowImage:(UIImage *)shadowImage {
    if (!shadowImage) {
        _shadowImageView.hidden = YES;
        return;
    }
    _shadowImage = shadowImage;
    _shadowImageView.hidden = NO;
    _shadowImageView.image = shadowImage;
    _shadowImageView.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), shadowImage.size.height);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    _backgroundView.backgroundColor = barTintColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [super setTintColor:tintColor];
    [_leftViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [(UIButton *)obj setTitleColor:_tintColor forState:UIControlStateNormal];
    }];
    [_rightViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [(UIButton *)obj setTitleColor:_tintColor forState:UIControlStateNormal];
    }];
}

- (void)setLeftBarButtonItemPaddingInset:(CGFloat)leftBarButtonItemPaddingInset {
    _leftBarButtonItemPaddingInset = leftBarButtonItemPaddingInset;
    [self layoutLeftBarButtonItems];
}

- (void)setRightBarButtonItemPaddingInset:(CGFloat)rightBarButtonItemPaddingInset {
    _rightBarButtonItemPaddingInset = rightBarButtonItemPaddingInset;
    [self layoutRightBarButtonItems];
}

- (void)setTitleTextAttributes:(NSDictionary<NSString *,id> *)titleTextAttributes {
    _titleTextAttributes = titleTextAttributes;
    if (titleTextAttributes) {
        self.title = _title;
    }
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    _leftBarButtonItems = nil;
    _leftBarButtonItem = leftBarButtonItem;
    UIView *itemView = [self barItemViewFromBarButtonItem:leftBarButtonItem];
    CGRect frame = itemView.frame;
    frame.origin.x = _leftBarButtonItemPaddingInset + leftBarButtonItem.layoutMargin;
    itemView.frame = frame;
    
    [self addSubview:itemView];
    [_leftViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_leftViews removeAllObjects];
    if (itemView) {
        [_leftViews addObject:itemView];
    }
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    _rightBarButtonItems = nil;
    _rightBarButtonItem = rightBarButtonItem;
    UIView *itemView = [self barItemViewFromBarButtonItem:rightBarButtonItem];
    CGRect frame = itemView.frame;
    frame.origin.x = CGRectGetWidth(self.bounds) - _rightBarButtonItemPaddingInset + rightBarButtonItem.layoutMargin - CGRectGetWidth(frame);
    itemView.frame = frame;
    
    [self addSubview:itemView];
    [_rightViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_rightViews removeAllObjects];
    if (itemView) {
        [_rightViews addObject:itemView];
    }
}

- (void)setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    if (_leftBarButtonItems == leftBarButtonItems) {
        return;
    }
    self.leftBarButtonItem = nil;
    _leftBarButtonItems = leftBarButtonItems;
    __block CGFloat left = _leftBarButtonItemPaddingInset;
    
    [_leftViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_leftViews removeAllObjects];
    [_leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // It is a adjust item, if the width is not 0.
        if (obj.width != 0) {
            left += obj.width;
        }
        // Normal item.
        else {
            UIView *itemView = [self barItemViewFromBarButtonItem:obj];
            CGRect frame = itemView.frame;
            frame.origin.x = left + obj.layoutMargin;
            itemView.frame = frame;
            
            [self addSubview:itemView];
            [_leftViews addObject:itemView];
            
            left = CGRectGetMaxX(frame) + _barButtonItemLineSpacing;
        }
    }];
}

- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    if (_rightBarButtonItems == rightBarButtonItems) {
        return;
    }
    self.rightBarButtonItem = nil;
    _rightBarButtonItems = rightBarButtonItems;
    __block CGFloat right = CGRectGetWidth(self.bounds) - _rightBarButtonItemPaddingInset;
    
    [_rightViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_rightViews removeAllObjects];
    [_rightBarButtonItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // It is a adjust item, if the width is not 0.
        if (obj.width != 0) {
            right -= obj.width;
        }
        // Normal item.
        else {
            UIView *itemView = [self barItemViewFromBarButtonItem:obj];
            CGRect frame = itemView.frame;
            frame.origin.x = right + obj.layoutMargin - CGRectGetWidth(frame);
            itemView.frame = frame;
            
            [self addSubview:itemView];
            [_rightViews insertObject:itemView atIndex:0];
            
            right = CGRectGetMinX(frame) - _barButtonItemLineSpacing;
        }
    }];
}

- (UIImageView *)bottomLine {
    return _shadowImageView;
}

#pragma mark - Private

- (UIView *)barItemViewFromBarButtonItem:(UIBarButtonItem *)item {
    if (item.customView) {
        return item.customView;
    }
    if (!item) {
        return nil;
    }
    
    UIButton *itemView = [UIButton buttonWithType:UIButtonTypeCustom];
    itemView.titleLabel.font = [UIFont systemFontOfSize:14];
    if (item.title && item.image) {
        itemView.titleEdgeInsets = UIEdgeInsetsMake(0, item.titleImageInset, 0, 0);
        itemView.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, item.titleImageInset);
    }
    [itemView setTitleColor:_tintColor forState:UIControlStateNormal];
    [itemView setTitle:item.title forState:UIControlStateNormal];
    [itemView setImage:item.image forState:UIControlStateNormal];
    [itemView setImage:item.image forState:UIControlStateHighlighted];
    [itemView sizeToFit];
    CGFloat width = CGRectGetWidth(itemView.frame) + ((item.title && item.image) ? item.titleImageInset : 0 + 2 *item.itemEdgeInset);
    [itemView setFrame:CGRectMake(0, kStatusBarHeight, width, kNavigationBarHeight)];
    [itemView addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
    return itemView;
}

@end




@implementation SQNavigationBar (Alpha)

- (CGFloat)titleAlpha {
    return _titleView ? _titleView.alpha : _titleLabel.alpha;
}

- (void)setTitleAlpha:(CGFloat)alpha {
    [self willChangeValueForKey:@"_titleAlpha"];
    _titleLabel.alpha = alpha;
    _titleView.alpha = alpha;
    [self didChangeValueForKey:@"_titleAlpha"];
}

- (CGFloat)backgroundAlpha {
    return _backgroundView.alpha;
}

- (void)setBackgroundAlpha:(CGFloat)alpha {
    [self willChangeValueForKey:@"_backgroundAlpha"];
    _backgroundView.alpha = alpha;
    [self didChangeValueForKey:@"_backgroundAlpha"];
}

- (CGFloat)barButtonsAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setBarButtonsAlpha:(CGFloat)alpha {
    [self willChangeValueForKey:@"_barButtonsAlpha"];
    objc_setAssociatedObject(self, @selector(barButtonsAlpha), @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    [self didChangeValueForKey:@"_barButtonsAlpha"];
}

- (CGFloat)elementsAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setElementsAlpha:(CGFloat)alpha {
    [self willChangeValueForKey:@"_elementsAlpha"];
    objc_setAssociatedObject(self, @selector(elementsAlpha), @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.titleAlpha = alpha;
    self.barButtonsAlpha = alpha;
    self.backgroundAlpha = alpha;
    [self didChangeValueForKey:@"_elementsAlpha"];
}

@end




@implementation UIBarButtonItem (SQNavigaitonBar)

- (void)setImageName:(NSString *)imageName {
    objc_setAssociatedObject(self, @selector(imageName), imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)imageName {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGFloat)titleImageInset {
    id value = objc_getAssociatedObject(self, _cmd);
    if (value) {
        return [value floatValue];
    }
    return kBarButtonImageTitleInset;
}

- (void)setTitleImageInset:(CGFloat)titleImageInset {
    objc_setAssociatedObject(self, @selector(titleImageInset), @(titleImageInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)layoutMargin {
    id value = objc_getAssociatedObject(self, _cmd);
    if (value) {
        return [value floatValue];
    }
    return 0;
}

- (void)setLayoutMargin:(CGFloat)layoutMargin {
    objc_setAssociatedObject(self, @selector(layoutMargin), @(layoutMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)itemEdgeInset {
    id value = objc_getAssociatedObject(self, _cmd);
    if (value) {
        return [value floatValue];
    }
    return kBarButtonItemEdgeInset;
}

- (void)setItemEdgeInset:(CGFloat)itemEdgeInset {
    objc_setAssociatedObject(self, @selector(itemEdgeInset), @(itemEdgeInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end





@implementation UIViewController (SQNavigaitonBar)

- (SQNavigationBar *)navigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNavigationBar:(SQNavigationBar *)navigationBar {
    objc_setAssociatedObject(self, @selector(navigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isNavigationBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (!animated) {
        objc_setAssociatedObject(self, @selector(isNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.navigationBar.hidden = hidden;
    }else {
        CGFloat top = hidden ? -self.navigationBar.frame.size.height : 0;
        self.navigationBar.hidden = NO;
        
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            CGRect frame = self.navigationBar.frame;
            frame.origin.y = top;
            self.navigationBar.frame = frame;
        } completion:^(BOOL finished) {
            objc_setAssociatedObject(self, @selector(isNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.navigationBar.hidden = hidden;
        }];
    }
}

- (SQNavigationBar *)setupNavigationBar {
    SQNavigationBar *navigationBar = objc_getAssociatedObject(self, _cmd);
    if (navigationBar == nil) {
        navigationBar = [SQNavigationBar navigationBar];
        navigationBar.title = self.title;
        navigationBar.titleView = self.navigationItem.titleView;
        if (self.navigationItem.leftBarButtonItem) {
            navigationBar.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
        }
        if (self.navigationItem.leftBarButtonItems) {
            navigationBar.leftBarButtonItems = self.navigationItem.leftBarButtonItems;
        }
        if (self.navigationItem.rightBarButtonItem) {
            navigationBar.leftBarButtonItem = self.navigationItem.rightBarButtonItem;
        }
        if (self.navigationItem.rightBarButtonItems) {
            navigationBar.leftBarButtonItems = self.navigationItem.rightBarButtonItems;
        }
        navigationBar.hidden = self.isNavigationBarHidden;
        self.navigationBar = navigationBar;
    }
    if (![navigationBar isDescendantOfView:self.view]) {
        [self.view addSubview:navigationBar];
        [navigationBar layoutIfNeeded];
    }
    return navigationBar;
}

@end


