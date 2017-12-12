//
//  UIView+Addition.m
//  SQKit
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "UIView+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

@implementation UIView (Addition)

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (NSData *)snapshotPDF {
    CGRect bounds = self.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 1;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)removeAllSubviews {
    //[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}


- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)visibleAlpha {
    if ([self isKindOfClass:[UIWindow class]]) {
        if (self.hidden) return 0;
        return self.alpha;
    }
    if (!self.window) return 0;
    CGFloat alpha = 1;
    UIView *v = self;
    while (v) {
        if (v.hidden) {
            alpha = 0;
            break;
        }
        alpha *= v.alpha;
        v = v.superview;
    }
    return alpha;
}

- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point toWindow:nil];
        } else {
            return [self convertPoint:point toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point toView:view];
    point = [self convertPoint:point toView:from];
    point = [to convertPoint:point fromWindow:from];
    point = [view convertPoint:point fromView:to];
    return point;
}

- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point fromWindow:nil];
        } else {
            return [self convertPoint:point fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point fromView:view];
    point = [from convertPoint:point fromView:view];
    point = [to convertPoint:point fromWindow:from];
    point = [self convertPoint:point fromView:to];
    return point;
}

- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect toWindow:nil];
        } else {
            return [self convertRect:rect toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!from || !to) return [self convertRect:rect toView:view];
    if (from == to) return [self convertRect:rect toView:view];
    rect = [self convertRect:rect toView:from];
    rect = [to convertRect:rect fromWindow:from];
    rect = [view convertRect:rect fromView:to];
    return rect;
}

- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect fromWindow:nil];
        } else {
            return [self convertRect:rect fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertRect:rect fromView:view];
    rect = [from convertRect:rect fromView:view];
    rect = [to convertRect:rect fromWindow:from];
    rect = [self convertRect:rect fromView:to];
    return rect;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


// return 0 when succeed
static int matrix_invert(__CLPK_integer N, double *matrix) {
    __CLPK_integer error = 0;
    __CLPK_integer pivot_tmp[6 * 6];
    __CLPK_integer *pivot = pivot_tmp;
    double workspace_tmp[6 * 6];
    double *workspace = workspace_tmp;
    bool need_free = false;
    
    if (N > 6) {
        need_free = true;
        pivot = malloc(N * N * sizeof(__CLPK_integer));
        if (!pivot) return -1;
        workspace = malloc(N * sizeof(double));
        if (!workspace) {
            free(pivot);
            return -1;
        }
    }
    
    dgetrf_(&N, &N, matrix, &N, pivot, &error);
    
    if (error == 0) {
        dgetri_(&N, matrix, &N, pivot, workspace, &N, &error);
    }
    
    if (need_free) {
        free(pivot);
        free(workspace);
    }
    return error;
}

CGAffineTransform BTCGAffineTransformGetFromPoints(CGPoint before[3], CGPoint after[3]) {
    if (before == NULL || after == NULL) return CGAffineTransformIdentity;
    
    CGPoint p1, p2, p3, q1, q2, q3;
    p1 = before[0]; p2 = before[1]; p3 = before[2];
    q1 =  after[0]; q2 =  after[1]; q3 =  after[2];
    
    double A[36];
    A[ 0] = p1.x; A[ 1] = p1.y; A[ 2] = 0; A[ 3] = 0; A[ 4] = 1; A[ 5] = 0;
    A[ 6] = 0; A[ 7] = 0; A[ 8] = p1.x; A[ 9] = p1.y; A[10] = 0; A[11] = 1;
    A[12] = p2.x; A[13] = p2.y; A[14] = 0; A[15] = 0; A[16] = 1; A[17] = 0;
    A[18] = 0; A[19] = 0; A[20] = p2.x; A[21] = p2.y; A[22] = 0; A[23] = 1;
    A[24] = p3.x; A[25] = p3.y; A[26] = 0; A[27] = 0; A[28] = 1; A[29] = 0;
    A[30] = 0; A[31] = 0; A[32] = p3.x; A[33] = p3.y; A[34] = 0; A[35] = 1;
    
    int error = matrix_invert(6, A);
    if (error) return CGAffineTransformIdentity;
    
    double B[6];
    B[0] = q1.x; B[1] = q1.y; B[2] = q2.x; B[3] = q2.y; B[4] = q3.x; B[5] = q3.y;
    
    double M[6];
    M[0] = A[ 0] * B[0] + A[ 1] * B[1] + A[ 2] * B[2] + A[ 3] * B[3] + A[ 4] * B[4] + A[ 5] * B[5];
    M[1] = A[ 6] * B[0] + A[ 7] * B[1] + A[ 8] * B[2] + A[ 9] * B[3] + A[10] * B[4] + A[11] * B[5];
    M[2] = A[12] * B[0] + A[13] * B[1] + A[14] * B[2] + A[15] * B[3] + A[16] * B[4] + A[17] * B[5];
    M[3] = A[18] * B[0] + A[19] * B[1] + A[20] * B[2] + A[21] * B[3] + A[22] * B[4] + A[23] * B[5];
    M[4] = A[24] * B[0] + A[25] * B[1] + A[26] * B[2] + A[27] * B[3] + A[28] * B[4] + A[29] * B[5];
    M[5] = A[30] * B[0] + A[31] * B[1] + A[32] * B[2] + A[33] * B[3] + A[34] * B[4] + A[35] * B[5];
    
    CGAffineTransform transform = CGAffineTransformMake(M[0], M[2], M[1], M[3], M[4], M[5]);
    return transform;
}

CGAffineTransform BTCGAffineTransformGetFromViews(UIView *from, UIView *to) {
    if (!from || !to) return CGAffineTransformIdentity;
    
    CGPoint before[3], after[3];
    before[0] = CGPointMake(0, 0);
    before[1] = CGPointMake(0, 1);
    before[2] = CGPointMake(1, 0);
    after[0] = [from convertPoint:before[0] toViewOrWindow:to];
    after[1] = [from convertPoint:before[1] toViewOrWindow:to];
    after[2] = [from convertPoint:before[2] toViewOrWindow:to];
    
    return BTCGAffineTransformGetFromPoints(before, after);
}


@end
