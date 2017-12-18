//
//  BTNavigationBar.m
//  BTNavigationController
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "BTNavigationBar.h"
#import <objc/runtime.h>

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

CGFloat const kBarButtonImageTitleInset = 8;
CGFloat const kBarButtonItemEdgeInset = 15;
CGFloat const kNavigationBarButtonPadding = 10;
CGFloat const kBarButtonItemLineSpacing = 15;

@interface BTNavigationBar ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray <UIView *>*leftViews;
@property (nonatomic, strong) NSMutableArray <UIView *>*rightViews;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *backgroundBarImageView;
@property (nonatomic, strong) UIImageView *shadowImageView;

@end

@implementation BTNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    frame = CGRectMake(0, 0, frame.size.width, kNavigationHeight);
    self = [super initWithFrame:frame];
    if (self) {
        _leftViews = [NSMutableArray arrayWithCapacity:0];
        _rightViews = [NSMutableArray arrayWithCapacity:0];
        _tintColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1];
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // title.
    self.titleLabel = [UILabel new];
    _titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 44);
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleTextAttributes = @{NSFontAttributeName:_titleLabel.font,
                             NSForegroundColorAttributeName:[UIColor blackColor]};
    
    // line image.
    self.shadowImageView = [[UIImageView alloc] initWithImage:nil];
    _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _shadowImageView.backgroundColor = [UIColor colorWithRed:238.0/ 255 green:238.0/ 255 blue:238.0/ 255 alpha:1];
    _shadowImageView.frame = CGRectMake(0, CGRectGetMaxX(self.frame), CGRectGetWidth(self.frame), _shadowImageView.image ? _shadowImageView.image.size.height : 0.5);
    
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
}

- (void)layoutTitleView {
    CGFloat padding = 8;
    CGFloat left  = CGRectGetMaxX(_leftViews.lastObject.frame) + padding;
    left = MAX(25, left);
    CGFloat right = (_rightViews.firstObject ? CGRectGetMinX(_rightViews.firstObject.frame) : kScreenWidth) - padding;
    right = MIN(CGRectGetWidth(self.frame) - right, 25);
    CGFloat maxW  = kScreenWidth - 2 *MAX(left, right);
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
    __block CGFloat itemLeft = kNavigationBarButtonPadding;
    __block NSInteger skipIndex = 0;
    [_leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // It is a adjust item, if the width is not 0.
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
            itemLeft = CGRectGetMaxX(frame) + kBarButtonItemLineSpacing;
        }
    }];
    
    // right items.
    __block CGFloat itemRight = CGRectGetWidth(self.bounds) - kNavigationBarButtonPadding;
    __block NSInteger index = _rightViews.count - 1;
    [_rightBarButtonItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // It is a adjust item, if the width is not 0.
        if (obj.width != 0) {
            itemRight -= obj.width;
        }
        // Normal item.
        else {
            UIView *itemView = _rightViews[index];
            CGRect frame = itemView.frame;
            frame.origin.x = itemRight + obj.layoutMargin - CGRectGetWidth(frame);
            itemView.frame = frame;
            itemRight = CGRectGetMinX(frame) - kBarButtonItemLineSpacing;
            index --;
        }
    }];
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
    _titleView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, kStatusBarHeight + ceil((kNavigationHeight - kStatusBarHeight)/2));
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
    _shadowImageView.frame = CGRectMake(0, kNavigationHeight - shadowImage.size.height, CGRectGetWidth(self.bounds), shadowImage.size.height);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    _backgroundView.backgroundColor = barTintColor;
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
    frame.origin.x = kNavigationBarButtonPadding + leftBarButtonItem.layoutMargin;
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
    frame.origin.x = CGRectGetWidth(self.bounds) - kNavigationBarButtonPadding + rightBarButtonItem.layoutMargin - CGRectGetWidth(frame);
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
    __block CGFloat left = kNavigationBarButtonPadding;
    
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
            
            left = CGRectGetMaxX(frame) + kBarButtonItemLineSpacing;
        }
    }];
}

- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    if (_rightBarButtonItems == rightBarButtonItems) {
        return;
    }
    self.rightBarButtonItem = nil;
    _rightBarButtonItems = rightBarButtonItems;
    __block CGFloat right = CGRectGetWidth(self.bounds) - kNavigationBarButtonPadding;
    
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
            
            right = CGRectGetMinX(frame) - kBarButtonItemLineSpacing;
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
    [itemView setFrame:CGRectMake(0, kStatusBarHeight, width, kNavigationHeight - kStatusBarHeight)];
    [itemView addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
    return itemView;
}

@end




@implementation BTNavigationBar (Alpha)

- (void)setElementAlpa:(CGFloat)elementAlpa {
    [self willChangeValueForKey:@"_elementAlpa"];
    objc_setAssociatedObject(self, @selector(elementAlpa), @(elementAlpa), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"_elementAlpa"];
}

- (CGFloat)elementAlpa {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setElementsAlpha:(CGFloat)alpha {
    self.elementAlpa = alpha;
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];
    
    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha = alpha;
}

@end




@implementation UIBarButtonItem (Extesnion)

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
