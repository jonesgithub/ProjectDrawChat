//
//  CDUtil.m
//  CodoonSport
//
//  Created by sky on 13-12-5.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//

#import "CDUtil.h"
#import "CDConstants.h"

@implementation CDUtil

#pragma mark 音频相关

//如果设置过声道，就返回那个声道，否则默认返回右声道
+ (int) soundChannelIndex{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *soundChannelNumber = [userDefaults objectForKey:UDK_SoundChannel];
    if (soundChannelNumber) {
        return [soundChannelNumber intValue];
    }else{
        return 1;
    }
}

+ (void) setSoundChannelIndex: (int)channelIndex{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(channelIndex) forKey:UDK_SoundChannel];
    [userDefaults synchronize];
}

+ (int) headSetConnectMode{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *headSetModeNumber = [userDefaults objectForKey:UDK_HeadSetConnectMode];
    if (headSetModeNumber) {
        return [headSetModeNumber intValue];
    }else{
        return 1;
    }
}

+ (void) setHeadSetConnectMode: (int)headSetConnectMode{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(headSetConnectMode) forKey:UDK_HeadSetConnectMode];
    [userDefaults synchronize];
}



@end
