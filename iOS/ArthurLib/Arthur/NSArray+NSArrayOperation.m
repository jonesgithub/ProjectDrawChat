//
//  NSArray+NSArrayOperation.m
//  KeeFit
//
//  Created by lichen on 5/20/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "NSArray+NSArrayOperation.h"

@implementation NSArray (NSArrayOperation)

+ (NSArray *)getBiggerFrom:(NSArray *)array1 withArray:(NSArray *)array2
{
    if ([array1 count] != [array2 count]) {
        NSLog(@"%@", @"数组不一样大");
        return nil;
    } else {
        NSMutableArray *arrayReturn = [[NSMutableArray alloc] initWithCapacity:[array1 count]];
        for (int index = 0; index < [array1 count]; index++) {
            if ([array1[index] intValue] > [array2[index] intValue]) {
                [arrayReturn addObject:array1[index]];
            } else {
                [arrayReturn addObject:array2[index]];
            }
        }
        return [NSArray arrayWithArray:arrayReturn];
    }
}

+ (NSArray *)getSumFromWithOutNegative:(NSArray *)array1 withArray:(NSArray *)array2
{
    if ([array1 count] != [array2 count]) {
        NSLog(@"%@", @"数组不一样大");
        return nil;
    } else {
        NSMutableArray *arrayReturn = [[NSMutableArray alloc] initWithCapacity:[array1 count]];
        for (int index = 0; index < [array1 count]; index++) {
            
            if ([array1[index] intValue] < 0) {
                if ([array2[index] intValue] < 0) {
                    [arrayReturn addObject:array1[index]];  //两都都为-1
                } else {
                    [arrayReturn addObject:array2[index]];  //array2为正
                }
            } else {
                if ([array2[index] intValue] < 0) {             //Array1为正，Array2为-1
                    [arrayReturn addObject:array1[index]];
                } else {                    
                    NSNumber *sumOfAll = [[NSNumber alloc] initWithInt:[array1[index] intValue] + [array2[index] intValue]]; //两者都为正
                    [arrayReturn addObject:sumOfAll];
                }
            }
        }
        return [NSArray arrayWithArray:arrayReturn];
    }
}

//TODO: 检查类型
- (int)sum
{
    return [[self valueForKeyPath:@"@sum.self"] intValue];
}

- (int)sumOfNoNegal
{
    int nSum = 0;
    for (id obj in self) {
        int value = [obj intValue];
        if (value >= 0) {
            nSum += value;
        }
    }
    return nSum;
}

- (NSArray *)splitBy:(int)nSplitValue
{
    //在原有数组最末加一个分割号，使得算法简单
    //不用在最后去判断
    NSMutableArray *arrToSplited = [self mutableCopy];
    [arrToSplited addObject:@(nSplitValue)];
    
    NSMutableArray *arrRecords = [[NSMutableArray alloc] init];

    int nLength = (int)[arrToSplited count];
    int nIndex = 0;
    NSString *strState = @"NO";
    NSMutableDictionary *dicSplited = nil;
    NSMutableArray *arrSplitedData= nil;
    
    while (nIndex < nLength) {
        if ([strState isEqualToString:@"NO"]) {
            if ([[arrToSplited objectAtIndex:nIndex] intValue] == nSplitValue) {
                //无数据，遇到分割
                //无动作
            } else {
                //无数据，遇到数据: new, 改状态
                dicSplited = [[NSMutableDictionary alloc] init];
                arrSplitedData = [[NSMutableArray alloc] init];
                dicSplited[kSplitStartIndex] = @(nIndex);
                [arrSplitedData addObject:[arrToSplited objectAtIndex:nIndex]];
                strState = @"YES";
            }
        } else {
            if ([[arrToSplited objectAtIndex:nIndex] intValue] == nSplitValue) {
                //有数据，遇到分割: 存数据，清空缓存，改状态
                dicSplited[kSplitData] = [arrSplitedData copy];
                dicSplited[kSplitEndIndex] = @(nIndex -1);
                [arrRecords addObject:[dicSplited copy]];
                dicSplited = nil;
                arrSplitedData = nil;
                strState = @"NO";
            } else {
                //有数据，遇到数据: 添加记录
                [arrSplitedData addObject:[arrToSplited objectAtIndex:nIndex]];
            }
        }
        
        nIndex++;
    }
    
    return [arrRecords copy];
}

+ (NSArray *)arrayWith:(int)nValue repeatCount:(int)nCount
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int nIndex = 0; nIndex < nCount; nIndex++) {
        [arr addObject:@(nValue)];
    }
    return [arr copy];
}

- (NSArray *)boolToNumber
{
    NSMutableArray *arrReturn = [[NSMutableArray alloc] init];
    for (NSNumber *value in self) {
        AssertClass(value, NSNumber);
        NSNumber *convertedValue = [[NSNumber alloc] initWithInt:[value boolValue] ? 1: 0];
        [arrReturn addObject:convertedValue];
    }
    return [arrReturn copy];
}

//数组是否含用字符串的元素
- (BOOL)hasString:(NSString *)strToFind
{
    for (NSString *strElement in self) {
        if ([strElement isEqualToString:strToFind]) {
            return YES;
        }
    }
    return NO;
}

@end
