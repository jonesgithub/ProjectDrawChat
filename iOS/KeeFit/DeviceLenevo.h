//
//  DeviceLenevo.h
//  LenovoBand
//
//  Created by lichen on 9/11/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceBase.h"
#import "HardwareBluetooth.h"

@interface DeviceLenevo : DeviceBase

#define kPeripheralUUIDString @"kPeripheralUUIDString"

@property (nonatomic, strong) HardwareBluetooth *hardwareBluetooth;

#define kSleepStartTime @"kSleepStartTime"
#define kSleepEndTime @"kSleepEndTime"
#define kSleepData @"kSleepData"
#define kSleepTypeDeep 0
#define kSleepTypeLight 1
#define kSleepTypeWake 2

@property (nonatomic, strong) NSMutableArray *arrAllSleepData;
@property (nonatomic, strong) NSMutableArray *arrSleepData;
@property (nonatomic, strong) NSString *strStartTime;
@property (nonatomic, strong) NSString *strEndTime;

@property int nCurrentSleepPacketCount;
@property int nPacketSectionIndex;


#define kRunStartTime @"kRunStartTime"
#define kRunEndTime @"kRunEndTime"
#define kRunSpeedData @"kRunSpeedData"
#define kRunHeartRateData @"kRunHeartRateData"
#define kRunCalories @"kRunCalories"
#define kRunSteps @"kRunSteps"
#define kRunDistance @"kRunDistance"

@property (nonatomic, strong) NSMutableArray *arrAllRunData;
@property (nonatomic, strong) NSMutableArray *arrRunData;
@property (nonatomic, strong) NSMutableArray *arrHeartRateData;
@property (nonatomic, strong) NSString *strRunStartTime;
@property (nonatomic, strong) NSString *strRunEndTime;
@property int nRunSpeedDataCount;
@property int nRunSectionSteps;
@property int nRunSectionDistance;
@property int nRunSecitonCalories;
@property int nCurrentRunPacketCount;

@property int nRunSpeedPacketCount;
@property int nRunHeartPacketCount;

+ (DeviceLenevo *)createDeviceLenvo;
//搜索设备
- (void)serachDevice:(onCallBack)handerSearchDevice;
//电量
- (void)getBattery:(onCallBack)handerGetBattery;
//心率
- (void)getHeartRate:(onCallBack)handerGetHeartRate;
//关心率
- (void)closeGetHeartRate;
//连接
- (void)connectDevice:(onCallBack)handerConnectDevice;
//设置
- (void)watchSetting:(onCallBack)handerWatchSetting;
//所有运动数据
- (void)getAllRunData:(onCallBack)handerGetAllRunData;
//清理数据
- (void)clearData:(onCallBack)handerClearData;
//获取所有睡眠数据
- (void)getAllSleepData:(onCallBack)handerGetAllRunData;
@end
