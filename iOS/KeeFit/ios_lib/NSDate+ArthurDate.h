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

@end
