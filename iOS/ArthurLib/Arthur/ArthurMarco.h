//
//  ArthurMarco.h
//  KeeFit
//
//  Created by lichen on 6/4/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>



//在Debug状态下才输出
//#ifdef DEBUG
//A better version of NSLog
#define NSLog(format, ...) do {\
fprintf(stderr, "<%s : %d> %s\n",\
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],\
__LINE__, __func__);\
NSString *newFormat = [NSString stringWithFormat:@"\n%@", format];\
(NSLog)((newFormat), ##__VA_ARGS__);\
fprintf(stderr, "\n");\
} while (0)

#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)
#define NSLogError() NSLog(@"%@", @"error")

//条件Log: 只有当condition满足时才log
#define ConditionLog(condition, format, ...) \
if (condition) {\
    NSLog(format, ##__VA_ARGS__);\
}

//#else
//
//#define NSLog(...)
//#define NSLogRect(rect)
//#define NSLogSize(size)
//#define NSLogPoint(point)
//#define NSLogError()
//
//#endif



//RGB
#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]



//断言
//应在对象类型强制转换前进行判断，以发现错误
#define AssertClass(obj, className) \
if ((obj) == nil) { NSLog(@"类型%@变量为空", [className class]);}\
NSAssert(((obj) != nil), @"数据为空");\
if (![(obj) isKindOfClass:[className class]]) { NSLog(@"非 %@ 类型", [className class]);}\
NSAssert([(obj) isKindOfClass:[className class]], @"类型错误");


//国际化宏
#define ArthurLocal(x) NSLocalizedString(x, @"国际化错误")


//NSNumber YES/NO
#define NumberYES [[NSNumber alloc] initWithBool:YES]
#define NumberNO [[NSNumber alloc] initWithBool:NO]

//返回回调、检查回调不为空、清空回调
//#define CopyAndClearHander(x) x; NSAssert(nil != x, @"回调为空"); x=nil;
#define CopyAndClearHander(x) x; if (nil == x) {\
    NSLog(@"%@", @"回调为空");\
}\
x=nil;
//设置的回调应为空
//#define AssertEmptyHander(x) NSAssert(nil == x, @"回调应为空"); x
#define AssertEmptyHander(x) if(nil != x) {\
NSLog(@"%@", @"回调不为空");\
}\
x


#pragma mark
#pragma mark 系统兼容的宏
//系统是否>7.0
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)


@interface ArthurMarco : NSObject

@end
