//
//  TalkEventRouter.h
//  Talk
//
//  Created by lichen on 9/29/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TalkConstant.h"

typedef void (^FadeOut)();

@interface TalkEventRouter : NSObject

@property (nonatomic, strong) NSTimer *timerFade;
@property BOOL bInFading;
@property (nonatomic, strong) NSDate *dateFadingStart;

@property (nonatomic, strong) NSMutableArray *arrAllPoints; //所有数据
@property (nonatomic, strong) NSMutableArray *arrPoints;    //暂时记录正在加入的数据
@property (nonatomic, strong) UIColor *colorOfLine;     //暂时数据的颜色
@property (nonatomic, strong) NSNumber *fWidthOfLine;   //暂时数据的宽度

@property (nonatomic, strong) FadeOut handerFadeOut;
- (void)whenFadeOut:(FadeOut)handerFadeOut;

- (void)event:(NSDictionary *)dicEvent;
- (float)opacityNow;
- (NSArray *)allPointData;

@end
