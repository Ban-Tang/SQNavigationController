//
//  NSObject+UIAlert.m
//  SQKit
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "NSObject+Alert.h"
#import <objc/runtime.h>

NSInteger const kActionSheetCancelButtonIndex = -1;

@implementation NSObject (Alert)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
                delegate:(UIViewController *)delegate
        completionHandle:(void(^)(NSUInteger buttonIndex, id alertView))handle
            buttonTitles:(NSString *)titles,... {
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if (titles != nil) {
            
            id eachObject;
            va_list argumentList;
            NSUInteger index = 0;
            
            // ①.添加第一个按钮的action
            __block void(^blockHandle)(NSUInteger buttonIndex, id alertView) = handle;
            UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:titles style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // 获取下标
                NSNumber * indexObj = objc_getAssociatedObject(action, "cancel action");
                NSUInteger currentIndex = [indexObj integerValue];
                if (blockHandle) {
                    blockHandle(currentIndex,alert);
                }
                // 管理内存，设置nil，防止循环引用
                blockHandle = nil;
            }];
            
            objc_setAssociatedObject(actionCancel, "cancel action", [NSNumber numberWithInteger:index], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            [alert addAction:actionCancel];
            index ++;
            
            // ②.创建参数列表
            va_start(argumentList, titles);
            
            // 获取参数，并执行操作
            while ((eachObject = va_arg(argumentList, id))) {
                // 添加action
                UIAlertAction * action = [UIAlertAction actionWithTitle:eachObject style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    // 获取下标
                    NSNumber * indexObj = objc_getAssociatedObject(action, "action");
                    NSUInteger currentIndex = [indexObj integerValue];
                    if (blockHandle) {
                        blockHandle(currentIndex,alert);
                    }
                    blockHandle = nil;
                }];
                
                objc_setAssociatedObject(action, "action", [NSNumber numberWithInteger:index], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                [alert addAction:action];
                index ++;
            }
            va_end(argumentList);
        }
        if (nil == delegate) {
            delegate = [UIApplication sharedApplication].keyWindow.rootViewController;
        }
        if ([delegate isKindOfClass:[UIViewController class]]) {
            [delegate presentViewController:alert animated:YES completion:nil];
        }
        
        return alert;
    }
    else */{
        objc_setAssociatedObject(self, "blockCallback", handle, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:nil];
        
        if (titles) {
            [alert addButtonWithTitle:titles];
        }
        
        id eachObject;
        va_list argumentList;
        
        va_start(argumentList, titles);
        while ((eachObject = va_arg(argumentList, id))) {
            [alert addButtonWithTitle:eachObject];
        }
        va_end(argumentList);
        
        alert.cancelButtonIndex = 0;
        [alert show];
        return alert;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^block)(NSUInteger buttonIndex, UIAlertView *alertView) = objc_getAssociatedObject(self, "blockCallback");
    if (block) {
        block(buttonIndex, alertView);
    }
    objc_setAssociatedObject(self, "blockCallback", nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (id)showActionSheetFrom:(__weak UIViewController *)controller
                withTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles
         destructiveTitle:(NSString *)destructiveTitle
              cancelTitle:(NSString *)cancelTitle
         didDismissBlock:(void (^)(id sheet, NSInteger index))block {
    NSAssert([controller isKindOfClass:[UIViewController class]], @"The controller must be kind of class `UIViewController`.");
    id sheet = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        NSInteger index = 0;
        for (int i  = 0; i < buttonTitles.count; i ++) {
            index = i;
            UIAlertAction *n_action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (block) {
                    block(alert, index);
                }
            }];
            [alert addAction:n_action];
        }
        if (destructiveTitle.length > 0) {
            index ++;
            UIAlertAction *d_action = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                if (block) {
                    block(alert, index);
                }
            }];
            [alert addAction:d_action];
        }
        if (cancelTitle.length > 0) {
            index ++;
            UIAlertAction *c_action = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (block) {
                    block(alert, kActionSheetCancelButtonIndex);
                }
            }];
            [alert addAction:c_action];
        }
        if (!controller) {
            controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        }
        [controller presentViewController:alert animated:YES completion:nil];
        
        sheet = alert;
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:destructiveTitle otherButtonTitles:nil, nil];
        
        for (NSString * titles in buttonTitles) {
            [actionSheet addButtonWithTitle:titles];
        }
        
        objc_setAssociatedObject(actionSheet, "action_sheet_dismiss_block", block, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        UIView *view = controller.view;
        if (!view) {
            view = [UIApplication sharedApplication].keyWindow;
        }
        [actionSheet showInView:controller.view];
        
        sheet = actionSheet;
    }
    return sheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^didDismisssBlock)(UIActionSheet *sheet, NSInteger index) = objc_getAssociatedObject(actionSheet, "action_sheet_dismiss_block");
    if (didDismisssBlock) {
        // In low version, the index start form 1 (UIActionSheet is from 1, cancel index is 0).
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            buttonIndex = kActionSheetCancelButtonIndex;
        }else {
            buttonIndex --;
        }
        didDismisssBlock(actionSheet,buttonIndex);
    }
}

#pragma clang diagnostic pop

@end
