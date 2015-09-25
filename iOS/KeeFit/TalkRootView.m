//
//  TalkRootView.m
//  Talk
//
//  Created by lichen on 9/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "TalkRootView.h"
#import <QuartzCore/QuartzCore.h>  
#define PI 3.14159265358979323846

#define kCircleWidth 5

@implementation TalkRootView

- (id)initWithFrame:(CGRect)frame  
{  
    self = [super initWithFrame:frame];  
    if (self) {  
        
    }  
    return self;  
}

- (void)sectionEnds
{
    if (self.arrAllPoints == nil) {
        self.arrAllPoints = [[NSMutableArray alloc] init];
    }
    [self.arrAllPoints addObject:[self.arrPoints copy]];
    self.arrPoints = [[NSMutableArray alloc] init];
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBStrokeColor(context, 0, 1,1,1.0);//画笔线的颜色
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(context, kCircleWidth*2);//线的宽度 
    
    //画各组线
    if (self.arrAllPoints != nil) {
        for (int nIndex = 0; nIndex < [self.arrAllPoints count]; nIndex++) {
            NSArray *arrPoints = [self.arrAllPoints objectAtIndex:nIndex];
            [self drawLines:context withPoints:arrPoints];
        }
    }
    
    //画当前的线
    [self drawLines:context withPoints:self.arrPoints];
}

- (void)drawLines:(CGContextRef)context withPoints:(NSArray *)arrPoints
{
    int nCount = [arrPoints count];
    for (int nIndex = 0; nIndex < [arrPoints count]/2; nIndex++) {
        float x = [arrPoints[nIndex*2] floatValue];
        float y = [arrPoints[nIndex*2 + 1] floatValue];
        CGContextAddArc(context, x, y, kCircleWidth, 0, 2*PI, 0); //添加一个圆  
        CGContextDrawPath(context, kCGPathFill);//绘制填充
    }
    
    if (nCount >= 4) {
        for (int nIndex = 0; nIndex < nCount/2 - 1; nIndex++) {
            CGPoint aPoints[2];//坐标点
            aPoints[0] = CGPointMake([arrPoints[nIndex*2] floatValue], [arrPoints[nIndex*2+1] floatValue]);//坐标1  
            aPoints[1] = CGPointMake([arrPoints[nIndex*2+2] floatValue], [arrPoints[nIndex*2+3] floatValue]);//坐标2
            CGContextAddLines(context, aPoints, 2);//添加线
            CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径 
        }
    }
}

@end
