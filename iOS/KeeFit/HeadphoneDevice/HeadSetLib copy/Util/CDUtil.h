//
//  CDUtil.h
//  CodoonSport
//
//  Created by sky on 13-12-5.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDUtil : NSObject

#pragma mark 音频相关

+ (int) soundChannelIndex;

+ (void) setSoundChannelIndex: (int)channelIndex;

+ (int) headSetConnectMode;

+ (void) setHeadSetConnectMode: (int)headSetConnectMode;

@end
