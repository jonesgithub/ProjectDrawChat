//
//  HeadsetBindingEngine.m
//  CodoonSport
//
//  Created by sky on 13-10-25.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//

#import "HeadsetBindingEngine.h"
#import "HeadSetCommunicationUtil.h"
#import "CDConstants.h"
#import <MediaPlayer/MediaPlayer.h>


@implementation HeadsetBindingEngine

- (id) init{
    self = [super init];
    if (self) {
        //初始化为未链接
        self.bDeviceConnected = [[NSNumber alloc] initWithBool:NO];
        //监听是否绑定失败
        [[NSNotificationCenter defaultCenter] 
         addObserver:self
         selector:@selector(connectDeviceSuccess)
         name:AudioConnectionSuccessNotification
         object:nil];
        //监听是否绑定成功
        [[NSNotificationCenter defaultCenter] 
         addObserver:self 
         selector:@selector(connectDeviceFail) 
         name:AudioConnectionFailNotification 
         object:nil];
    }
    
    return self;
}

#pragma mark
#pragma mark 析构
- (void) dealloc{
    //去掉监听Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //去掉监听耳机
    [HeadSetCommunicationUtil cancelMonitorCommunication];
}

#pragma mark
#pragma mark 函数: 连接设备
//连接设备
- (void)connectDevice:(onCallBack)handerConnectDevice
{
    if ([self.bDeviceConnected boolValue]) {
        handerConnectDevice(YES);
    }
    self.handerConnectDevice = handerConnectDevice;
    
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {
        [[MPMusicPlayerController iPodMusicPlayer] pause];
    }
    //iphone5全音量会出现乱波，影响通讯成功率
    [[MPMusicPlayerController iPodMusicPlayer] setVolume:15.0/16.0];
    
    //开始连接设备
    HeadSetCommunicationUtil *headSetCommunicationUtil = [HeadSetCommunicationUtil sharedHeadSetCommunicationUtil];
    [HeadSetCommunicationUtil backToMonitorCommunication];
    [headSetCommunicationUtil obtainConnection:@selector(connectionComplete:) byTarget:headSetCommunicationUtil];
}

- (void)connectDeviceFail
{
    NSAssert(self.handerConnectDevice, @"连接回调不能为空!");
    self.handerConnectDevice(NO);
}

- (void)connectDeviceSuccess
{
    NSAssert(self.handerConnectDevice, @"连接回调不能为空!");
    self.bDeviceConnected = [[NSNumber alloc] initWithBool:YES];
    self.handerConnectDevice(YES);
}

#pragma mark
#pragma mark 函数: 获取设备ID
//获取DeviceID
- (void)getDeviceID:(onGetDeviceID)handerGetDeviceID
{
    self.handerGetDeviceID = handerGetDeviceID;
    [[HeadSetCommunicationUtil sharedHeadSetCommunicationUtil] obtainDeviceID:@selector(deviceIDGotten:) byTarget:self];
}

- (void) deviceIDGotten: (NSData *)data
{
    NSAssert(self.handerGetDeviceID, @"获取设备ID回调不能为空!");
    if (nil == data) {
        self.handerGetDeviceID(NO, nil);
    } else {
        //TODO: 分析得到Device ID
        self.handerGetDeviceID(YES, @"Device ID");
    }
}

#pragma mark
#pragma mark 函数: 绑定设备
- (void) bindDevice:(onBindDevice)handerBindDevice{
    self.handerBindDevice = handerBindDevice;
    [self connectDevice:^(BOOL success) {
        NSAssert(self.handerBindDevice, @"获取设备ID回调不能为空!");
        if (success) {
            [self getDeviceID:^(BOOL success, NSString *strDeviceId) {
                
            }];
        } else {
            self.handerBindDevice(NO);
        }
    }];
}

#pragma mark
#pragma mark 函数: 连接指定设备
- (void)connectDeviceWithDeviceID:(NSString *)strDeviceID onCallBack:(onCallBack)handerConnectDirectDevice
{
    self.handerConnectDirectDevice = handerConnectDirectDevice;
    [self connectDevice:^(BOOL success) {
        //TODO: 获取设备ID
    }];
}

@end
