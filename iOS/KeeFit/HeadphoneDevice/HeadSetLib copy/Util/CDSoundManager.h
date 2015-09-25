//
//  CDSoundManager.h
//  CodoonSport
//
//  Created by andy on 14-1-14.
//  Copyright (c) 2014年 codoon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDSoundManager : NSObject

+ (CDSoundManager *)defaultManager;

- (void)stopSound;

- (void)speakReady;
- (void)speakCancel;
- (void)speakContinue;
- (void)speakSportFinishTarget;
- (void)speakFinishForDefaultSport;
- (void)speakFailForPlanSport;
- (void)speakFinishAllPlanSport:(BOOL)yesOrNo;
- (void)speakWithSportType:(int)type withKm:(int)km withTime:(int)time withAverage:(float)averagefloat;
- (void)speakPlanDetail:(int)numberOfIndex contextDic:(NSDictionary *)speakDic countNumber:(int)countNumber;

- (void)speakMessage;
- (void)speakHeartRateWarning;

@end
