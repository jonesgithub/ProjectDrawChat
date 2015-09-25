//
//  CDSoundManager.m
//  CodoonSport
//
//  Created by andy on 14-1-14.
//  Copyright (c) 2014年 codoon.com. All rights reserved.
//

#import "CDSoundManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CDConstants.h"

@interface CDSoundManager() <AVAudioPlayerDelegate>

@property(nonatomic,strong) AVAudioPlayer *audioPlayer;

@end

@implementation CDSoundManager

+ (CDSoundManager *)defaultManager {
    
    static CDSoundManager *soundManager = nil;
    static dispatch_once_t onceCDSoundManagerToken;
    
    dispatch_once(&onceCDSoundManagerToken, ^{
        
        soundManager = [[CDSoundManager alloc] init];
    });
    
    return soundManager;
}

- (void)dealloc {

    _audioPlayer.delegate = nil;
}

- (BOOL)soundIsOpen {
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:UDK_SportSoundIsOpen] boolValue];
}

- (void)stopSound {

    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
}

//返回是否成功打开声音通道
- (BOOL)initWithSessionProperty {
    
    [self stopSound];
    
    if (![self soundIsOpen]) {return NO;}
    
//    if ([MPMusicPlayerController iPodMusicPlayer].volume > 0.7) {
//
//        [MPMusicPlayerController iPodMusicPlayer].volume = 0.7;
//    }
    
    AudioSessionSetActive(false);//激活audiosession
    AudioSessionInitialize (NULL,NULL,NULL,NULL);//初始化音频
    
    UInt32 sessionCategory =kAudioSessionCategory_MediaPlayback;//设置后台播放
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,sizeof (sessionCategory), &sessionCategory);
    
    UInt32 allowAudioShouldDuck = true;//设置是否与ipod混合(ipod声音变小,应用程序声音变大)
    AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck, sizeof(allowAudioShouldDuck), &allowAudioShouldDuck);
    
    AudioSessionSetActive(true);//激活audiosession
    
    return YES;
}

- (NSData *)soundDataWithSoundName:(NSString *)name {
    
    int soundType = 0;
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d_%@",soundType,name] ofType:@"mp3"]];
}

- (void)startSound:(NSData *)soundData {
    
    [self stopSound];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

#pragma mark - 计划开始了
- (void)speakReady {
    
    if (![self initWithSessionProperty]) {return;}
    [self startSound:[self soundDataWithSoundName:@"计划开始了"]];
}

#pragma mark - 目标还未完成你确定要结束吗
- (void)speakCancel {

    if (![self initWithSessionProperty]) {return;}
    [self startSound:[self soundDataWithSoundName:@"目标还未完成你确定要结束吗"]];
}

#pragma mark - 再来继续计划吧
- (void)speakContinue {

    if (![self initWithSessionProperty]) {return;}
    [self startSound:[self soundDataWithSoundName:@"再来继续计划吧"]];
}

#pragma mark - 你完成了今天的目标
- (void)speakSportFinishTarget {
    
    if (![self initWithSessionProperty]) {return;}
    [self startSound:[self soundDataWithSoundName:@"你完成了今天的目标"]];
}

#pragma mark - 放松一下吧
- (void)speakFinishForDefaultSport {

    if (![self initWithSessionProperty]) {return;}
    [self startSound:[self soundDataWithSoundName:@"放松一下吧"]];
}

#pragma mark - 目标还未完成你确定要结束吗
- (void)speakFailForPlanSport {

    if (![self initWithSessionProperty]) {return;}
    [self startSound:[self soundDataWithSoundName:@"目标还未完成你确定要结束吗"]];
}

#pragma mark - 太棒了你完成了今天的目标
- (void)speakFinishAllPlanSport:(BOOL)yesOrNo {

    if (![self initWithSessionProperty]) {return;}
    if (yesOrNo) {
        [self startSound:[self soundDataWithSoundName:@"太棒了你完成了所有目标运动计划成功"]];
    }else {
        [self startSound:[self soundDataWithSoundName:@"太棒了你完成了今天的目标"]];
    }
}

#pragma mark - 每公里播报
- (void)speakWithSportType:(int)type withKm:(int)km withTime:(int)time withAverage:(float)averagefloat {

    if (![self initWithSessionProperty]) {return;}
    
    int average = (int)averagefloat;
    
    NSMutableData *itemsData = [NSMutableData dataWithCapacity:1];
    
    [itemsData appendData:[self soundDataWithSoundName:@"你已经"]];
    
    switch (type) {
        case 0:
            
            [itemsData appendData:[self soundDataWithSoundName:@"走路"]];
            break;
        case 1:
            [itemsData appendData:[self soundDataWithSoundName:@"跑步"]];
            break;
        case 2:
            [itemsData appendData:[self soundDataWithSoundName:@"骑行"]];
            break;
            
        default:
            [itemsData appendData:[self soundDataWithSoundName:@"运动"]];
            break;
    }
    
    [itemsData appendData:[self numberDataWithString:[NSString stringWithFormat:@"%d",km]]];
    [itemsData appendData:[self soundDataWithSoundName:@"公里"]];
    [itemsData appendData:[self soundDataWithSoundName:@"用时"]];
    
    if (time / 60 > 0) {
        
        [itemsData appendData:[self numberDataWithString:[NSString stringWithFormat:@"%d",time / 60]]];
        [itemsData appendData:[self soundDataWithSoundName:@"分钟"]];
    }
    
    if (time % 60 > 0) {
        
        [itemsData appendData:[self numberDataWithString:[NSString stringWithFormat:@"%d",time % 60]]];
        [itemsData appendData:[self soundDataWithSoundName:@"秒"]];
    }
    
    if (type >= 2) {
        
        [itemsData appendData:[self soundDataWithSoundName:@"平均速度"]];
        [itemsData appendData:[self numberDataWithString:[NSString stringWithFormat:@"%d",average]]];
        
        float aaa;
        float tempnum = modff(averagefloat, &aaa);
        int tempintnum = tempnum * 100;
        
        if (tempintnum > 0) {
            
            [itemsData appendData:[self soundDataWithSoundName:@"点"]];
            [itemsData appendData:[self numberDecimalsDataWithString:[NSString stringWithFormat:@"%d",tempintnum]]];
        }
        
        [itemsData appendData:[self soundDataWithSoundName:@"公里每小时"]];
    }else {
        
        //最近一公里用时 average 分 average秒
        
        [itemsData appendData:[self soundDataWithSoundName:@"最近一公里"]];
        [itemsData appendData:[self soundDataWithSoundName:@"用时"]];
        
        if (average / 60 > 0) {
            
            [itemsData appendData:[self numberDataWithString:[NSString stringWithFormat:@"%d",average / 60]]];
            [itemsData appendData:[self soundDataWithSoundName:@"分钟"]];
        }
        
        if (average % 60 > 0) {
            
            [itemsData appendData:[self numberDataWithString:[NSString stringWithFormat:@"%d",average % 60]]];
            [itemsData appendData:[self soundDataWithSoundName:@"秒"]];
        }
    }
    
    if (km <= 5) {
        
        [itemsData appendData:[self soundDataWithSoundName:@"加油吧"]];
        
    }else {
        [itemsData appendData:[self soundDataWithSoundName:@"太棒了"]];
    }
    
    [self startSound:itemsData];
}

- (NSData *)numberDataWithString:(NSString *)tempNumberStr {
    
    int tempNumberLength = (int)[tempNumberStr length];
    if (tempNumberLength > 7) return nil;
    const char * numberStr =[tempNumberStr UTF8String];
    
    NSMutableData *itemsData = [NSMutableData dataWithCapacity:1];
    
    int i = 0;
    switch (tempNumberLength) {
            
        case 7: {
            
            [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
            [itemsData appendData:[self soundDataWithSoundName:@"100"]];
            i++;
        }
            
        case 6: {
            
            if (![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"0"]) {
                
                if (i != 0 || ![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"1"]) {
                    
                    [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
                }
                [itemsData appendData:[self soundDataWithSoundName:@"10"]];
            }
            i++;
        }
            
        case 5: {
            
            if (![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"0"]) {
                
                if ([[NSString stringWithFormat:@"%c",numberStr[i-1]] isEqualToString:@"0"]) {
                    
                    [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i-1]]]];
                }
                
                [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
            }
            [itemsData appendData:[self soundDataWithSoundName:@"10000"]];
            i++;
        }
            
        case 4: {
            
            if (![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"0"]) {
                
                [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
                [itemsData appendData:[self soundDataWithSoundName:@"1000"]];
            }
            i++;
        }
            
        case 3: {
            
            if (![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"0"]) {
                
                if ([[NSString stringWithFormat:@"%c",numberStr[i-1]] isEqualToString:@"0"]) {
                    
                    [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i-1]]]];
                }
                [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
                [itemsData appendData:[self soundDataWithSoundName:@"100"]];
            }
            i++;
        }
            
        case 2: {
            
            if (![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"0"]) {
                
                if ([[NSString stringWithFormat:@"%c",numberStr[i-1]] isEqualToString:@"0"]) {
                    
                    [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i-1]]]];
                }
                
                if (i != 0 || ![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"1"]) {
                    
                    [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
                }
                [itemsData appendData:[self soundDataWithSoundName:@"10"]];
            }
            i++;
        }
        case 1: {
            
            if (![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"0"]) {
                
                if ([[NSString stringWithFormat:@"%c",numberStr[i-1]] isEqualToString:@"0"]) {
                    
                    [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i-1]]]];
                }
                [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
            }
        }
        default:
            
            break;
    }
    
    return itemsData;
}

- (NSData *)numberDecimalsDataWithString:(NSString *)tempNumberStr {
    
    int tempNumberLength = (int)[tempNumberStr length];
    if (tempNumberLength > 2) return nil;
    const char * numberStr =[tempNumberStr UTF8String];
    
    NSMutableData *itemsData = [NSMutableData dataWithCapacity:1];
    
    int i = 0;
    switch (tempNumberLength) {
            
        case 2: {
            
            [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
            i++;
        }
        case 1: {
            
            if (![[NSString stringWithFormat:@"%c",numberStr[i]] isEqualToString:@"0"]) {
                
                [itemsData appendData:[self soundDataWithSoundName:[NSString stringWithFormat:@"%c",numberStr[i]]]];
            }
        }
        default:
            
            break;
    }
    
    return itemsData;
}

#pragma mark - 计划运动语音播报
- (void)speakPlanDetail:(int)numberOfIndex contextDic:(NSDictionary *)speakDic countNumber:(int)countNumber {

    if (![self initWithSessionProperty]) {return;}
    
    
    NSMutableData *itemsData = [NSMutableData dataWithCapacity:1];
    
    if (numberOfIndex == 0) {
        
        [itemsData appendData:[self soundDataWithSoundName:@"首先"]];
        
    }else {
        
        if (numberOfIndex+1 == countNumber) {
            
            [itemsData appendData:[self soundDataWithSoundName:@"最后"]];
        }else {
            [itemsData appendData:[self soundDataWithSoundName:@"接着"]];
        }
    }
    
    
    if ([[speakDic objectForKey:@"t"] isEqualToString:@"n"]) {
        
        [itemsData appendData:[self soundDataWithSoundName:@"走路"]];
        
    }else if ([[speakDic objectForKey:@"t"] isEqualToString:@"r"]){
        
        [itemsData appendData:[self soundDataWithSoundName:@"跑步"]];
        
    }else if ([[speakDic objectForKey:@"t"] isEqualToString:@"j"]){
        
        [itemsData appendData:[self soundDataWithSoundName:@"快走"]];
        
    }else if ([[speakDic objectForKey:@"t"] isEqualToString:@"s"]){
        
        [itemsData appendData:[self soundDataWithSoundName:@"慢走"]];
        
    }else if ([[speakDic objectForKey:@"t"] isEqualToString:@"c"]){
        
        [itemsData appendData:[self soundDataWithSoundName:@"放松运动"]];
        
    }else if ([[speakDic objectForKey:@"t"] isEqualToString:@"m"]){
        
        [itemsData appendData:[self soundDataWithSoundName:@"慢跑"]];
        
    }else if ([[speakDic objectForKey:@"t"] isEqualToString:@"q"]){
        
        [itemsData appendData:[self soundDataWithSoundName:@"快跑"]];
    }
    
    [itemsData appendData:[self numberDataWithString:[NSString stringWithFormat:@"%@",[speakDic objectForKey:@"d"]]]];
    
    [itemsData appendData:[self soundDataWithSoundName:@"分钟"]];
    
    [self startSound:itemsData];
}


#pragma mark - 消息提示
- (void)speakMessage {

    if (![self initWithSessionProperty]) {return;}
    [self startSound:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"消息提示" ofType:@"mp3"]]];
}

#pragma mark - 心率预警提示
- (void)speakHeartRateWarning {
    
    if (![self initWithSessionProperty]) {return;}
    [self startSound:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"心率提示音" ofType:@"wav"]]];
}


#pragma mark - AVAudioPlayer 代理

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    AudioSessionSetActive(false);
    //CDLog(@"---CDSoundManager FinishPlaying---");
}

@end
