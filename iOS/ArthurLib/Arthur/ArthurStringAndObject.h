//
//  ArthurStringAndObject.h
//  ArthurLib
//
//  Created by lichen on 5/20/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArthurStringAndObject : NSObject

/**
 *	@brief	把obj转成NSString: 先NSData，再Base64
 *
 *	@param 	obj 	需要转化的obj
 *
 *	@return	返回转化成的NSString
 */
+ (NSString *)encodeFromObject:(id)obj;

/**
 *	@brief	作用与encodeFromObject相反
 *
 *	@param 	str 	str description
 *
 *	@return	return value description
 */
+ (id)decodeFromString:(NSString *)str;


@end
