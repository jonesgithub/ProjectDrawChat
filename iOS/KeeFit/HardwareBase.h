//
//  HardwareConnection.h
//  HardwareCommunication
//
//  Created by lichen on 7/14/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDelegate.h"

typedef void (^onCallBack)(BOOL success);

//命令超时时长
#define kSendCommandTimeOutTime 10

@class DeviceSportSleep;
//注: data是纯粹的数据，不包括起始符、功能码、数据长度、校验字
typedef void (^onResponse)(BOOL success, NSData *data);


@interface HardwareBase : NSObject

@property (nonatomic, strong) NSArray *arrSearchedDevice;

//@property (nonatomic, weak) DeviceSportSleep *device;
@property (nonatomic, weak) id<DeviceDelegate> deviceDelegate;

//设置开始命令
//一定要设置
- (void)setStartCommand:(Byte)byteStartCommand;

//发送命令
@property Byte byteCommandType;
@property (nonatomic, strong) NSData *dataCommand;
@property (nonatomic, strong) onResponse handerResponse;
@property (nonatomic, strong) NSTimer *timerSendCommand;
- (void)sendCommand:(Byte)byteCommand withData:(NSData *)data response:(onResponse)handerResponse;
- (void)commandResponsed:(BOOL)success withData:(NSData *)data;
- (void)sendCommandTimeOut;

//搜索设备
- (void)searchDevice:(onCallBack)handerSearchDevice;

//绑定设备
- (void)bindDevice:(onCallBack)handerBindDevice;

//解绑设备
- (void)unbindDevice;

//连接设备
- (void)connectDevice:(onCallBack)handerConnectDevice;

//清理状态
- (void) cleanState;

@end
