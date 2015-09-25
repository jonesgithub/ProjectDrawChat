//
//  HeadSetCommunicationUtil.h
//  CodoonSport
//
//  Created by sky on 12-6-29.
//  Copyright (c) 2012年 codoon.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICommunication.h"

@protocol HeadSetCommunicationUtilDelegate <NSObject>

@optional
- (void)hasCompleteRate: (float)completeRate;

@end


@interface HeadSetCommunicationUtil : NSObject <ICommunication>

@property (assign, atomic) id<HeadSetCommunicationUtilDelegate> delegate;
@property (assign, atomic) int isNowCancelOrTimeout; // 是否取消或者超时，是的话就不用再往设备发送命令了  0: 一切正常 1:取消 2: 超时
@property (assign, nonatomic) BOOL isAllowSound;


+ (void) backToMonitorCommunication;
+ (void) cancelMonitorCommunication;
+ (HeadSetCommunicationUtil *)sharedHeadSetCommunicationUtil;

- (void) cancelConnection;
- (void) cancelMission;

- (void) connectionComplete: (NSData *)data;

- (void) connectDevice: (SEL) callback byTarget: (id)target;
- (void) obtainConnection: (SEL) callback byTarget: (id)target; //获取连接
- (void) obtainDataFrameCount: (SEL) callback byTarget: (id)target; //获取数据的帧数

- (void) obtainSportsData: (SEL) callback byTarget: (id)target; //获取数据

- (void) obtainDeviceID: (SEL) callback byTarget: (id)target; //获取设备id

- (void) obtainTypeAndVersion: (SEL) callback byTarget: (id)target; //获取设备固件版本号

- (void) obtainDeviceInfo: (SEL) callback byTarget: (id)target; //获取设备信息，电量。

- (BOOL) isDeviceConnected;

// 跟isDeviceConnected的区别在于这是随便什么东西，只要是带耳麦的耳机插着就行。
- (BOOL) isHeadSetOutPlugIn;

- (BOOL) isDeviceBond;

- (BOOL) isNowHandelingMission; //询问是否现在正在处理一个任务

//获取用户信息，和下方的有所区别
- (void) obtainDeviceUserInfo: (SEL) callback byTarget: (id)target;

//更新用户信息
- (void) updateDeviceUserInfoWithBytes: (Byte *)bytes withCallback:(SEL) callback byTarget: (id)target;
- (void) setUserInfo: (SEL) callback byTarget: (id)target;

- (void) setAlertAlarmInfo: (SEL) callback byTarget: (id)target;
//更新手环用户信息
- (void) updateRingUserInfoWithBytes: (Byte *)bytes withCallback:(SEL) callback byTarget: (id)target;

//清除运动数据
- (void) clearSportsData: (SEL) callback byTarget: (id)target;

//获取设备时间
- (void) obtainDeviceTime: (SEL) callback byTarget: (id) target;

//更新设备时间
- (void) updateDeviceDateTime: (Byte *)bytes withCallback: (SEL) callback byTarget: (id)target;

@end
