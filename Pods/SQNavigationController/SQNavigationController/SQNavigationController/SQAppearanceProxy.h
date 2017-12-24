//
//  SQAppearanceProxy.h
//  SQNavigationController
//
//  Created by roylee on 2017/12/21.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQAppearanceProxy : NSProxy

+ (id)appearanceForClass:(Class)klass;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end


@interface NSObject (SQAppearance)
- (void)sq_setupAppearance;
@end
