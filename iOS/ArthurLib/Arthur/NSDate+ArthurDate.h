//
//  NSDate+ArthurDate.h
//  NSDateDemo
//
//  Created by lichen on 5/19/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ArthurDate)

+ (NSString *)currentDateWithFull;
+ (NSString *)currentDateWithYMD;
+ (NSString *)currentDateWithHMS;
+ (NSString *)currentDateWithFormat:(NSString *)strFormat;
+ (NSString *)stringWithDate:(NSDate *)date withFormat:(NSString *)strFormat;

- (NSString *)stringWithFull;
- (NSString *)stringWithYMD;
- (NSString *)stringWithHMS;

//时间转成long: 2014-03-08 => 20140308
+ (long long)longWithString:(NSString *)strDate;
//long转成时间: 20140308 => 2014-03-08
+ (NSString *)stringWithLong:(long long)llnDate;

+ (NSDate *)dateFromFull:(NSString *)strFull;
+ (NSDate *)dateFromYMD:(NSString *)strYMD;

//计算两个日期相差天数
- (int)theDayCountFromDate:(NSDate *)dateOfFrom;

//获取星期几
- (int)getWeekDay;
//获取第多少日
- (NSString *)getDay;
//获取年月
- (NSString *)stringWithYM;

//是否比另一个日期大
- (BOOL)greaterThanDate:(NSDate *)date;

- (NSDate *)dateAddDays:(int)nDays;
+ (NSString *)stringWithYMD:(NSString *)strDate addDays:(int)days;
+ (NSString *)currentDateByYMDAddDays:(int)days;

//年月日时分秒获取
- (int)theYear;
- (int)theMonth;
- (int)theDay;
- (int)theHour;
- (int)theMinute;
- (int)theSecond;

@end
