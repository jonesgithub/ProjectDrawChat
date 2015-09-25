//
//  ArthurDraw.h
//  DrawDemo
//
//  Created by lichen on 5/15/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArthurDraw : NSObject

+ (void)drawPathInContext:(CGContextRef)context withPoints:(NSArray *)points strokeColor:(UIColor *)strokeColor;
+ (void)drawClosePathInContext:(CGContextRef)context withPoints:(NSArray *)points strokeColor:(UIColor *)strokeColor;
+ (void)drawFillPathInContext:(CGContextRef)context withPoints:(NSArray *)points fillColor:(UIColor *)fillColor;

+ (void)drawPathInContext:(CGContextRef)context withPoints:(NSArray *)points strokeColor:(UIColor *)strokeColor width:(float)fWidth;

@end
