//
//  HeadsetBindingEngine.h
//  CodoonSport
//
//  Created by sky on 13-10-25.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//

//绑定引擎
//完成绑定动作

#import <Foundation/Foundation.h>

typedef void (^onCallBack)(BOOL success);
typedef void (^onGetDeviceID)(BOOL success, NSString *strDeviceId);
typedef void (^onBindDevice)(BOOL success, NSString *strDeviceId, NSString *strDeviceVersion);

@interface HeadsetBindingEngine : NSObject

@property (nonatomic, strong) NSNumber *bDeviceConnected;

//连接设备
@property (nonatomic, strong) onCallBack handerConnectDevice;
- (void)connectDevice:(onCallBack)handerConnectDevice;

//获取DeviceID
@property (nonatomic, strong) onGetDeviceID handerGetDeviceID;
- (void)getDeviceID:(onGetDeviceID)handerGetDeviceID;

//绑定设备
@property (nonatomic, strong) onBindDevice handerBindDevice;
- (void) bindDevice:(onBindDevice)handerBindDevice;

//连接指定设备
@property (nonatomic, strong) onCallBack handerConnectDirectDevice;
- (void)connectDeviceWithDeviceID:(NSString *)strDeviceID onCallBack:(onCallBack)handerConnectDirectDevice;





@end
