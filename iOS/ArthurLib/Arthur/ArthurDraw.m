//
//  ArthurDraw.m
//  DrawDemo
//
//  Created by lichen on 5/15/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//
    
#import "ArthurDraw.h"

@implementation ArthurDraw

#define kDrawTypePath 0
#define kDrawTypeClosePath 1
#define kDrawTypeFillPath 2

+ (void)drawPathInContext:(CGContextRef)context withPoints:(NSArray *)points strokeColor:(UIColor *)strokeColor
{
    [ArthurDraw drawInContext:context withPoints:points color:strokeColor type:kDrawTypePath];
}

+ (void)drawPathInContext:(CGContextRef)context withPoints:(NSArray *)points strokeColor:(UIColor *)strokeColor width:(float)fWidth
{
    int length = (int)[points count];
    if (length%2 != 0) {
        NSLog(@"%@", @"length wrong!");
        return;
    }
    if (length < 4) {
        NSLog(@"%@", @"length less");
        return;
    }
    
    UIBezierPath *startPath = [UIBezierPath bezierPath];
    [startPath moveToPoint:CGPointMake([points[0] floatValue], [points[1] floatValue])];
    for (int index = 1; index < length/2; index++) {
        [startPath addLineToPoint:CGPointMake([points[index*2] floatValue], [points[index*2+1] floatValue])];
    }
    //    保存context状态
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, fWidth);
    [strokeColor setStroke];
    [startPath stroke];
    
    //    恢复context状态
    CGContextRestoreGState(context);
}

+ (void)drawClosePathInContext:(CGContextRef)context withPoints:(NSArray *)points strokeColor:(UIColor *)strokeColor
{
    [ArthurDraw drawInContext:context withPoints:points color:strokeColor type:kDrawTypeClosePath];
}

+ (void)drawFillPathInContext:(CGContextRef)context withPoints:(NSArray *)points fillColor:(UIColor *)fillColor
{
    [ArthurDraw drawInContext:context withPoints:points color:fillColor type:kDrawTypeFillPath];
}

+ (void)drawInContext:(CGContextRef)context withPoints:(NSArray *)points color:(UIColor *)color type:(int)drawType
{
    int length = (int)[points count];
    if (length%2 != 0) {
        NSLog(@"%@", @"length wrong!");
        return;
    }
    if (length < 4) {
        NSLog(@"%@", @"length less");
        return;
    }
    
    UIBezierPath *startPath = [UIBezierPath bezierPath];
    [startPath moveToPoint:CGPointMake([points[0] floatValue], [points[1] floatValue])];
    for (int index = 1; index < length/2; index++) {
        [startPath addLineToPoint:CGPointMake([points[index*2] floatValue], [points[index*2+1] floatValue])];
    }
    //    非简单的线，封闭
    if (drawType != kDrawTypePath) {
        [startPath closePath];
    }
    
    //    保存context状态
    CGContextSaveGState(context);
    
    //    是否fill
    if (drawType == kDrawTypeFillPath) {
        [color setFill];
        [startPath fill];
    } else{
        [color setStroke];
        [startPath stroke];
    }
    
    //    恢复context状态
    CGContextRestoreGState(context);
}

@end
