//
//  DeviceTreadmill.h
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceBase.h"

@interface DeviceTreadmill : DeviceBase

@property float fSpeed;
@property float fDistance;
@property float fTotalCal;



//搜索设备
- (void)searchThradmill:(onCallBack)handerSearchThreadmill;

//连接
- (void)connectDevice:(onCallBack)handerConnectDevice;

//设置体重
- (void)setWeight:(int)nWeight onCallBack:(onCallBack)handerCallBack;

//擦除数据
- (void)eraseData:(onCallBack)handerEraseData;

//开始初始化设备
- (void)startInitializeDevice:(onCallBack)handerStartInitializeDevice;

//结束初始化设备
- (void)endInitializeDevice:(onCallBack)handerDndInitializeDevice;

//获取运动数据
- (void)getThreadmillData:(onCallBack)handerGetThreadmillData;

@end
