//
//  SQAppearanceProxy.m
//  SQNavigationController
//
//  Created by roylee on 2017/12/21.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import "SQAppearanceProxy.h"

static inline NSMutableDictionary *SQAppearanceClasses() {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *classes;
    dispatch_once(&onceToken, ^{
        classes = [NSMutableDictionary dictionaryWithCapacity:0];
    });
    return classes;
}


@interface SQAppearanceProxy ()

@property (nonatomic, strong) Class mainClass;
@property (nonatomic, strong) NSMutableDictionary *invocations;

@end


@implementation SQAppearanceProxy

// this method return the same object instance for each different class
+ (id)appearanceForClass:(Class)klass {
    NSString *className = NSStringFromClass(klass);
    SQAppearanceProxy *proxy = SQAppearanceClasses()[className];
    if (!proxy) {
        proxy = [self proxyWithClass:klass];
        SQAppearanceClasses()[className] = proxy;
    }
    return proxy;
}

+ (instancetype)proxyWithClass:(Class)klass {
    SQAppearanceProxy *proxy = [SQAppearanceProxy alloc];
    proxy.mainClass = klass;
    return proxy;
}

- (NSMutableDictionary *)invocations {
    if (_invocations == nil) {
        _invocations = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _invocations;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation; {
    [anInvocation setTarget:nil];
    
    [anInvocation retainArguments];
    
    // add the invocation to the dic for selector key.
    [self.invocations setObject:anInvocation forKey:NSStringFromSelector(anInvocation.selector)];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.mainClass instanceMethodSignatureForSelector:aSelector];
}

- (void)startForwarding:(id)sender {
    for (NSInvocation *invocation in [self.invocations allValues]) {
        [invocation setTarget:sender];
        [invocation invoke];
    }
}

@end



@implementation NSObject (SQAppearance)

- (void)sq_setupAppearance {
    SQAppearanceProxy *proxy = [SQAppearanceProxy appearanceForClass:[self class]];
    [proxy startForwarding:self];
}

@end

