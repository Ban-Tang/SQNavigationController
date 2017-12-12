//
//  NSObject+UIAlert.h
//  SQKit
//
//  Created by roylee on 2017/12/11.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSInteger const kActionSheetCancelButtonIndex;

/**
 Easy methods to show system alert view.
 */
@interface NSObject (Alert)<UIAlertViewDelegate, UIActionSheetDelegate>

/**
 Show an alert view with the config.
 */
- (id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
                delegate:(UIViewController *)delegate
        completionHandle:(void(^)(NSUInteger buttonIndex, id alertView))handle
            buttonTitles:(NSString *)titles,...;

/**
 Show system action sheet.
 After iOS 8, the sheet is `UIAlertController`, otherwise is `UIActionSheet`.
 
 The cancel index will be set -1. So any touch if the index more than 0 is usefull.
 */
- (id)showActionSheetFrom:(__weak UIViewController *)controller
                withTitle:(NSString *)title
             buttonTitles:(NSArray *)buttonTitles
         destructiveTitle:(NSString *)destructiveTitle
              cancelTitle:(NSString *)cancelTitle
          didDismissBlock:(void (^)(id sheet, NSInteger index))block;

@end
