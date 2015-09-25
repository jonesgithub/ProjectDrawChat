//
//  TalkRootView.m
//  Talk
//
//  Created by lichen on 9/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "TalkRootView.h"
#import <QuartzCore/QuartzCore.h>  

//#define PI 3.14159265358979323846

@implementation TalkRootView

- (id)initWithFrame:(CGRect)frame  
{  
    self = [super initWithFrame:frame];  
    if (self) {
//        //初始化数据源
//        self.talkEventRouterLocal = [[TalkEventRouter alloc] init];
//        self.talkEventRouterRemote = [[TalkEventRouter alloc] init];
//        
//        float fFreshInterval = 1.0 / kFreshCountInSecond;
//        self.timerFreshView = [NSTimer scheduledTimerWithTimeInterval:fFreshInterval target:self selector:@selector(freshView) userInfo:nil repeats:YES];
    }  
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];  
    if (self) {
        //初始化数据源
        self.talkEventRouterLocal = [[TalkEventRouter alloc] init];
        self.talkEventRouterRemote = [[TalkEventRouter alloc] init];
        
        float fFreshInterval = 1.0 / kFreshCountInSecond;
        self.timerFreshView = [NSTimer scheduledTimerWithTimeInterval:fFreshInterval target:self selector:@selector(freshView) userInfo:nil repeats:YES];
    }  
    return self;
}

- (void)freshView
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawLinesInContext:context withDataSource:self.talkEventRouterLocal];
    [self drawLinesInContext:context withDataSource:self.talkEventRouterRemote];
}

- (void)drawLinesInContext:(CGContextRef)context withDataSource:(TalkEventRouter *)talkEventRouter
{
    NSArray *arrAllData = [talkEventRouter allPointData];
    float fOpacity = [talkEventRouter opacityNow];
    for (NSDictionary *dictData in arrAllData) {
        [self drawLinesInContext:context withData:dictData withOpacity:fOpacity];
    }
}

- (void)drawLinesInContext:(CGContextRef)context withData:(NSDictionary *)dictData withOpacity:(float)fOpacity
{
    UIColor *color = [UIColor colorFromHexString:[dictData objectForKey:kDrawColor]];
    NSNumber *fWidthOfLoine = [dictData objectForKey:kDrawWidth];
    NSArray *arrPoints = [dictData objectForKey:kDataPoints];
    [self drawLinesInContext:context withPoints:arrPoints withOpacity:fOpacity color:color width:fWidthOfLoine];
}

- (void)drawLinesInContext:(CGContextRef)context withPoints:(NSArray *)arrPoints withOpacity:(float)fOpacity color:(UIColor *)color width:(NSNumber *)fWidthOfLine
{
    //设置线宽
    CGContextSetLineWidth(context, [fWidthOfLine floatValue]);
    //设置颜色
    UIColor *lineColor = [color colorWithAlphaComponent:fOpacity];
    [lineColor setStroke];
    [lineColor setFill];
    
    int nCount = [arrPoints count];
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    //画各连线
    if (nCount == 4) {
        CGPoint aPoints[nCount/2];//坐标点
        for (int nIndex = 0; nIndex < nCount/2; nIndex++) {
            aPoints[nIndex] = CGPointMake([arrPoints[nIndex*2] floatValue], [arrPoints[nIndex*2+1] floatValue]);    //添加坐标点
        }
        CGContextAddLines(context, aPoints, nCount/2);//添加线
        CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径 
    } else if (nCount > 4){
        CGContextMoveToPoint(context, [arrPoints[0] floatValue], [arrPoints[1] floatValue]); 
        
        for (int nIndex = 1; nIndex < nCount/2 -1; nIndex++) {
            CGContextAddQuadCurveToPoint(
                                         context, 
                                         [arrPoints[nIndex*2] floatValue], 
                                         [arrPoints[nIndex*2+1] floatValue], 
                                         ([arrPoints[nIndex*2] floatValue] + [arrPoints[nIndex*2+2] floatValue]) / 2, 
                                         ([arrPoints[nIndex*2+1] floatValue] + [arrPoints[nIndex*2+3] floatValue]) / 2
                                         ); 
        }
        CGContextStrokePath(context);
    }
}



@end
