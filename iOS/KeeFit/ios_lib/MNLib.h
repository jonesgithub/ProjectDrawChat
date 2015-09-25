//
//  MNLib.h
//  地图新闻
//
//  Created by lichen on 4/11/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VoidBlock)();

@interface MNLib : NSObject

+(void)showTitle:(NSString *)strTitle message:(NSString *)strMessage buttonName:(NSString *)strButtonName;
+(BOOL)dictionary:(NSDictionary *)dict hasKeys:(NSArray *)array;

+(void)showTitle:(NSString *)strTitle message:(NSString *)strMessage delayTime:(float)delayTime completion:(VoidBlock)completion;


/**
 *	@brief	延迟delayTime的时候再做某事
 *
 *	@param 	delayTime 	延迟时间
 *	@param 	something 	需要做的事的块
 */
+ (void)delay:(float)delayTime doSomething:(VoidBlock)something;

/**
 *	@brief	两个同样大小的数组，取同index大的数
 *
 *	@param 	array1 	数组1
 *	@param 	array2 	数组2
 *
 *	@return	更大的数组
 */
+ (NSArray *)getBiggerFrom:(NSArray *)array1 withArray:(NSArray *)array2;



@end
