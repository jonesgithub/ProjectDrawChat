//
//  NSDate+ArthurDate.m
//  NSDateDemo
//
//  Created by lichen on 5/19/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "NSDate+ArthurDate.h"

#define kDateYMD @"yyyy-MM-dd"
#define kDateFull @"yyyy-MM-dd HH:mm:ss"
#define kDateHMS @"HH:mm:ss"
#define kDateM @"MM"
#define kDateD @"dd"
#define kDateYM @"yyyyMM"

@implementation NSDate (ArthurDate)

+ (NSString *)currentDateWithYMD
{
    return [self currentDateWithFormat:kDateYMD];
}

+ (NSString *)currentDateWithHMS
{
    return [self currentDateWithFormat:kDateHMS];
}

+ (NSString *)currentDateWithFull
{
    return [self currentDateWithFormat:kDateFull];
}

+ (NSString *)currentDateWithFormat:(NSString *)strFormat
{
    NSDate *currentDate = [NSDate date];
    return [NSDate stringWithDate:currentDate withFormat:strFormat];
}

+ (NSString *)stringWithDate:(NSDate *)date withFormat:(NSString *)strFormat
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:strFormat];
    return [formatter stringFromDate:date];
}

- (NSString *)stringWithFull
{
    return [NSDate stringWithDate:self withFormat:kDateFull];
}

- (NSString *)stringWithYMD
{
    return [NSDate stringWithDate:self withFormat:kDateYMD];
}

- (NSString *)stringWithHMS
{
    return [NSDate stringWithDate:self withFormat:kDateHMS];
}

+ (long long)longWithString:(NSString *)strDate
{
    NSString *strFirst = [strDate stringByReplacingOccurrencesOfString: @"-" withString:@""];
    NSString *strSecond = [strFirst stringByReplacingOccurrencesOfString: @":" withString:@""];
    NSString *strPure = [strSecond stringByReplacingOccurrencesOfString: @" " withString:@""];
    return (long long)[strPure longLongValue];
}

+ (NSString *)stringWithLong:(long long)llnDate
{
    return [NSString stringWithFormat:@"%04lld-%02lld-%02lld", llnDate/10000, (llnDate%10000)/100, llnDate%100];
}

+ (NSDate *)dateFromFull:(NSString *)strFull
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateFull];
    return [formatter dateFromString:strFull];
}

+ (NSDate *)dateFromYMD:(NSString *)strYMD
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateYMD];
    return [formatter dateFromString:strYMD];
}

- (int)theDayCountFromDate:(NSDate *)dateOfFrom
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlag = NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlag fromDate:dateOfFrom toDate:self options:0];
    return (int)[components day] + 1;
}

- (int)getWeekDay
{
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:self];
    return (int)[componets weekday];
}

- (NSString *)getDay
{
    return [[self class] stringWithDate:self withFormat:kDateD];
}

- (NSString *)stringWithYM
{
     return [[self class] stringWithDate:self withFormat:kDateYM];
}

- (BOOL)greaterThanDate:(NSDate *)date
{
    if ([self compare:date] == NSOrderedDescending) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDate *)dateAddDays:(int)nDays
{
    NSTimeInterval  interval = 24*60*60*nDays; //1:天数
    return [NSDate dateWithTimeInterval:interval sinceDate:self];
}

+ (NSString *)stringWithYMD:(NSString *)strDate addDays:(int)days
{
    NSDate *date = [NSDate dateFromYMD:strDate];
    NSDate *otheDate = [date dateAddDays:days];
    return [otheDate stringWithYMD];
}

+ (NSString *)currentDateByYMDAddDays:(int)days
{
    NSDate *date = [NSDate date];
    NSDate *otheDate = [date dateAddDays:days];
    return [otheDate stringWithYMD];
}

- (NSDateComponents *)dateComponentsFromDate: (NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekCalendarUnit|
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    return comps;
}

////同步时间的命令
//- (NSData *) timeCommandData{
//    NSDateComponents *dateComponents = [self dateComponentsFromDate :[NSDate date]];
//    int weekDay = (int)dateComponents.weekday;
//    if (weekDay == 1) {
//        weekDay = 6;
//    }else{
//        weekDay = weekDay - 2;
//    }
//    Byte bytes[] = {0xAA, 0x0a, 0x07, BCD_X(dateComponents.year%100), BCD_X(dateComponents.month), BCD_X(dateComponents.day), BCD_X(dateComponents.hour), BCD_X(dateComponents.minute), BCD_X(dateComponents.second), weekDay};
//    return [NSData dataWithBytes:bytes length:10];
//}

- (int)theYear
{
    NSDateComponents *dateComponents = [self dateComponentsFromDate: self];
    return dateComponents.year;
}

- (int)theMonth
{
    NSDateComponents *dateComponents = [self dateComponentsFromDate: self];
    return dateComponents.month;
}

- (int)theDay
{
    NSDateComponents *dateComponents = [self dateComponentsFromDate: self];
    return dateComponents.day;
}

- (int)theHour
{
    NSDateComponents *dateComponents = [self dateComponentsFromDate: self];
    return dateComponents.hour;
}

- (int)theMinute
{
    NSDateComponents *dateComponents = [self dateComponentsFromDate: self];
    return dateComponents.minute;
}

- (int)theSecond
{
    NSDateComponents *dateComponents = [self dateComponentsFromDate: self];
    return dateComponents.second;
}


@end
