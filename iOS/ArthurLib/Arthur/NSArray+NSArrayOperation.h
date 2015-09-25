//
//  NSArray+NSArrayOperation.h
//  KeeFit
//
//  Created by lichen on 5/20/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSplitStartIndex @"kSplitStartIndex"
#define kSplitEndIndex @"kSplitEndIndex"
#define kSplitData  @"kSplitData"

@interface NSArray (NSArrayOperation)

/**
 *	@brief	两个同样大小的数组，取同index大的数
 *
 *	@param 	array1 	数组1
 *	@param 	array2 	数组2
 *
 *	@return	更大的数组
 */
+ (NSArray *)getBiggerFrom:(NSArray *)array1 withArray:(NSArray *)array2;
+ (NSArray *)getSumFromWithOutNegative:(NSArray *)array1 withArray:(NSArray *)array2;

- (int)sum;


/**
 *	@brief	只算不小于0的和
 *
 *	@return	返回和不小于0的和
 */
- (int)sumOfNoNegal;

//用值nSplitValue分割数组
- (NSArray *)splitBy:(int)nSplitValue;

//生成一个定长大小数组
+ (NSArray *)arrayWith:(int)nValue repeatCount:(int)nCount;

//每一个元素都是NSNumber的BOOL值，将其变成NSNumber的int，YES为1，NO为0
- (NSArray *)boolToNumber;

//数组是否含用字符串的元素
- (BOOL)hasString:(NSString *)strToFind;

@end
