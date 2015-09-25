//
//  NSDate+ArthurDate.m
//  NSDateDemo
//
//  Created by lichen on 5/19/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "NSDate+ArthurDate.h"

@implementation NSDate (ArthurDate)

+ (NSString *)currentDateWithYMD
{
    return [self currentDateWithFormat:@"yyyy-MM-dd"];
}

+ (NSString *)currentDateWithHMS
{
    return [self currentDateWithFormat:@"HH:mm:ss"];
}

+ (NSString *)currentDateWithFull
{
    return [self currentDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *)currentDateWithFormat:(NSString *)strFormat
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:strFormat];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    return dateString;
}

@end
