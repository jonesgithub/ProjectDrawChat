//
//  TalkEventRouter.m
//  Talk
//
//  Created by lichen on 9/29/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "TalkEventRouter.h"

@implementation TalkEventRouter

- (id)init
{  
    self = [super init];  
    if (self) { 
        self.bInFading = NO;
    }  
    return self;
}

#pragma mark
#pragma mark 函数: 外部接口
//所有事件的处理
- (void)event:(NSDictionary *)dicEvent
{
    if (dicEvent == nil) {
        NSLog(@"%@", @"程序错误，数据为空");
        return;
    }
    
    NSString *strEventType = [dicEvent objectForKey:kEventType];
    
    //开始
    if ([strEventType isEqualToString:kEventTypeTouchBegin]) {
        [self closeFadeTimer];
        self.arrPoints = [[NSMutableArray alloc] init];
        [self addPoint:dicEvent];
        self.fWidthOfLine = [dicEvent objectForKey:kDrawWidth];
        self.colorOfLine = [dicEvent objectForKey:kDrawColor];
    }
    
    //中间
    if ([strEventType isEqualToString:kEventTypeTouchMiddle]) {
        [self addPoint:dicEvent];
    }
    
    //结束
    if ([strEventType isEqualToString:kEventTypeTouchEnd]) {
        [self addPoint:dicEvent];
        if (self.arrAllPoints == nil) {
            self.arrAllPoints = [[NSMutableArray alloc] init];
        }
        //记录数据
        NSDictionary *dictAddObject = @{
                                        kDataPoints: [self.arrPoints copy], 
                                        kDrawColor: self.colorOfLine,
                                        kDrawWidth: self.fWidthOfLine
                                        };
        [self.arrAllPoints addObject:dictAddObject];
        self.arrPoints = nil;
        [self startFadeTimer];
    }
    
    //删除
    if ([strEventType isEqualToString:kEventTypeDelete]) {
        self.arrAllPoints = nil;
        self.arrPoints = nil;
        [self closeFadeTimer];
    }
}

- (float)opacityNow
{
    if (self.bInFading) {
        double fFadingTime = [[NSDate date] timeIntervalSinceDate:self.dateFadingStart];
        if (fFadingTime > kFadingTime) {
            //通知fadeout了
            if (self.handerFadeOut) {
                self.handerFadeOut();
            }
            return 0;
        } else {
            return 1.0 - fFadingTime/kFadingTime;
        }
    } else {
        return 1.0;
    }
}

- (NSArray *)allPointData
{
    if (self.arrPoints == nil) {
        return [self.arrAllPoints copy];
    } else {
        NSMutableArray *arrData = [self.arrAllPoints mutableCopy];
        if (arrData == nil) {
            arrData = [[NSMutableArray alloc] init];
        }
        //TODO
        NSDictionary *dictAddObject = @{
                                        kDataPoints: [self.arrPoints copy], 
                                        kDrawColor: self.colorOfLine,
                                        kDrawWidth: self.fWidthOfLine
                                        };
        [arrData addObject:dictAddObject];
        return [arrData copy];
    }
}

//添加回调，收到fadeout事件
- (void)whenFadeOut:(FadeOut)handerFadeOut
{
    self.handerFadeOut = handerFadeOut;
}

#pragma mark
#pragma mark 函数: 辅助函数
- (void)addPoint:(NSDictionary *)dictEvent
{
    [self.arrPoints addObject:[dictEvent objectForKey:kPointX]];
    [self.arrPoints addObject:[dictEvent objectForKey:kPointY]];
}

- (void)startFadeTimer
{
    self.timerFade = [NSTimer scheduledTimerWithTimeInterval:kStartFadeTime target:self selector:@selector(stratFade) userInfo:nil repeats:NO];
}

- (void)stratFade
{
    self.bInFading = YES;
    self.dateFadingStart = [NSDate date];
}

- (void)closeFadeTimer
{
    [self.timerFade invalidate];
    self.timerFade = nil;
    self.bInFading = NO;
    self.dateFadingStart = nil;
}

@end
