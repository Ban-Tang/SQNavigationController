//
//  SQKitMacro.h
//  SQKit
//
//  Created by roylee on 2017/12/12.
//  Copyright © 2017年 bantang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <pthread.h>

#ifndef SQKitMacro_h
#define SQKitMacro_h

#ifdef __cplusplus
#define SQ_EXTERN_C_BEGIN  extern "C" {
#define SQ_EXTERN_C_END  }
#else
#define SQ_EXTERN_C_BEGIN
#define SQ_EXTERN_C_END
#endif


SQ_EXTERN_C_BEGIN

#ifdef DEBUG
#define NSLog(FORMAT, ...)      fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif


#ifndef SQ_CLAMP // return the clamped value
#define SQ_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef SQ_SWAP // swap two value
#define SQ_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif


#define SQAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)
#define SQCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define SQAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define SQCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)

#define SQAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")
#define SQCAssertMainThread() NSCAssert([NSThread isMainThread], @"This method must be called on the main thread")

/**
 Empty object check.
 */
#define IsEmpty(str)            (str == nil || ![str respondsToSelector:@selector(isEqualToString:)] || [str isEqualToString:@""])
#define IsNull(obj)             (obj == nil || [obj isEqual:[NSNull null]])
#define IsArray(obj)            (obj && [obj isKindOfClass:[NSArray class]] && [obj count])
#define IsDictionary(obj)       (obj && [obj isKindOfClass:[NSDictionary class]] && [obj count])

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
    @strongify(self)
    if (!self) return;
    ...
 }];
 
 */
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif



/**
 Profile time cost.
 @param block    code to benchmark
 @param complete code time cost (millisecond)
 
 Usage:
 SQBenchmark(^{
    // code
 }, ^(double ms) {
    NSLog("time cost: %.2f ms",ms);
 });
 
 */
static inline void SQTimeBenchmark(void (^block)(void), void (^complete)(double ms)) {
    // <QuartzCore/QuartzCore.h> version
    /*
     extern double CACurrentMediaTime (void);
     double begin, end, ms;
     begin = CACurrentMediaTime();
     block();
     end = CACurrentMediaTime();
     ms = (end - begin) * 1000.0;
     complete(ms);
     */
    
    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}


/**
 Whether in main queue/thread.
 */
static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

/**
 Submits a block for asynchronous execution on a main queue and returns immediately.
 */
static inline void dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 Submits a block for execution on a main queue and waits until the block completes.
 */
static inline void dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

/**
 Async run a task on the main therad.
 */
static inline void RunOnMainThread(void (^block)(void)) {
    dispatch_sync_on_main_queue(block);
}

/**
 Initialize a pthread mutex.
 */
static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define SQMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        SQMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        pthread_mutexattr_t attr;
        SQMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        SQMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        SQMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        SQMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef SQMUTEX_ASSERT_ON_ERROR
}


SQ_EXTERN_C_END

#endif /* SQKitMacro_h */
