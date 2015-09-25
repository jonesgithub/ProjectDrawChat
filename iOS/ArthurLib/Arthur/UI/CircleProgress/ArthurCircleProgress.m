//
//  ArthurCircleProgress.m
//  KeeFit
//
//  Created by lichen on 6/21/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//


//弧形进度条

#import "ArthurCircleProgress.h"
#include <math.h>

@implementation ArthurCircleProgress

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.nPregressInHundred = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //弧线背景
    float fBackgroundWith = 10.0;
    [[MNLib hexStringToColor:@"#302f30"] setStroke];
    CGContextSetLineWidth(context, fBackgroundWith);//线的宽度  s
    //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度   
    // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。  
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.height/2-fBackgroundWith/2, 0, 2*M_PI, 0); //添加一个圆  
    CGContextDrawPath(context, kCGPathStroke); //绘制路径  

    //运动量
    float fProgress = (float)self.nPregressInHundred * M_PI * 2 / 100.0;
    float fProgressWith = 4;
    float fProgressRadius = self.frame.size.width/2 - fProgressWith/2 - fProgressWith/2 - 1;
    [[MNLib hexStringToColor:@"#3cf0cd"] setStroke];
    CGContextSetLineWidth(context, fProgressWith);
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, fProgressRadius, M_PI/2, M_PI/2 + fProgress, 0); //添加一个圆  
    CGContextDrawPath(context, kCGPathStroke); //绘制路径  
}

- (void)setProgress:(int)nPercentInHundred
{
    self.nPregressInHundred = nPercentInHundred;
    [self setNeedsDisplay];
}


@end
