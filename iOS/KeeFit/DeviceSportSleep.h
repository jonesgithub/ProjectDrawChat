//
//  DeviceSportSleep.h
//  KeeFit
//
//  Created by lichen on 5/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDKFUserSetting.h"
#import "HardwareBase.h"
#import "DeviceSportSleepCommandMap.h"
#import "ArthurBlockChain2.h"
#import "DeviceBase.h"

//是否打印Debug信息开关
#define bInVirtualDeviceDebug YES

//设备状态
#define kDeviceBinded @"kDeviceBinded"
#define kDeviceType @"kDeviceType"
#define kDeviceVersion @"kDeviceVersion"
#define kDeviceID @"kDeviceID"

typedef void (^onBindDevice)(BOOL success);
//typedef void (^onCallBack)(BOOL success);


@interface DeviceSportSleep: DeviceBase

@property (nonatomic, strong) NSNumber *bDeviceBinded;       //是否已绑定设备: 用于其它观察
@property (nonatomic, strong) NSNumber *bInBindDevice;       //是否正在绑定设备
@property (nonatomic, strong) NSNumber *bInSynData;            //是否正在同步数据(包括连接、获取数据、存设置)
@property (nonatomic, strong) NSNumber *bInTranslateData;   //正在传输数据
@property (nonatomic, strong) NSDate *dateOfSyn;                    //同步时间
@property (nonatomic, strong) NSNumber *nDataSynPercent;    //数据同步百分比

@property (strong, nonatomic) NSNumber *nBatteryPercent;      //电量
@property (nonatomic, strong) NSString *strSynEncryptData;     //同步数据，加密成字符串: base64
@property int nSynTotalCal;                                                           //本次同步中总的卡路里
@property int nSynTotalStep;                                                          //本次同步中总的步数  
@property int nSynTotalDistance;                                                   //本次同步中总的距离
@property (nonatomic, strong) NSDictionary *dictSports;             //运动数据
@property (nonatomic, strong) NSDictionary *dictSleeps;             //睡眠数据

//设备硬件相差数据
@property (nonatomic, strong) NSNumber *nDeviceType;          //设备类型
@property (nonatomic, strong) NSString *strDeviceVersion;       //设备版本号
@property (nonatomic, strong) NSString *strDeviceId;                //设备id

//获取数据
@property (nonatomic, strong) NSMutableData *dataSportSleepBuffer;
@property int nDataFrameCount;    //帧数
@property int nDataFrameIndex;    //正在获取第几条数据


//骑行相关
@property (nonatomic, strong) NSNumber *fRidingSpeed;           //速度
@property (nonatomic, strong) NSNumber *fRidingCadence;       //踏频
@property (nonatomic, strong) NSNumber *nRidingCircle;          //圈数

#pragma mark
#pragma mark 基础命令
- (void)baseConnect:(onCallBack)handerBaseConnect;    //连接命令
- (void)baseTypeAndVersion:(onCallBack)handerTypeAndVersion;    //类型与版本号
- (void)baseReadDeviceID:(onCallBack)handerReadDeviceID;     //读取设备ID
- (void)baseBindDevice:(onCallBack)handerBindDevice;    //绑定设备
- (void)baseRidingRealTimeData:(onCallBack)handerRidingRealTimeData;    //骑行实时数据
- (void)baseDataFrameCount:(onCallBack)handerDataFrameCount;    //获取数据帧数
- (void)baseGetDataFrame:(onCallBack)handerGetDataFrame;    //获取某一帧
- (void)baseEraseData:(onCallBack)handerEraseData;      //擦除数据
- (void)baseReadBattery:(onCallBack)handerReadBattery;  //读取电量
- (void)baseSetUserInfo:(CDKFUserSetting *)userSetting response:(onCallBack)handerSetUserInfo;  //设置用户相关信息
- (void)baseSetAlarmActivity:(CDKFUserSetting *)userSetting response:(onCallBack)handerSetAlarmActivity;  //设置闹钟、活动提醒信息
- (void)baseSynTime:(onCallBack)handerSynTime;  //同步时间

#pragma mark
#pragma mark 综合命令
@property (nonatomic, strong) onCallBack handerGetSportSleepData;
- (void)getSportSleepData:(onCallBack)handerGetSportSleepData;  //获取运动与睡眠数据

- (void)connectDevice:(onCallBack)handerConnectDevice;           //连接设备
- (void)initializeDeviceWithHardware:(HardwareBase *)HardwareBase;    //初始化设备状态
- (void)bindDevice:(onBindDevice)handerBindDevice;                  //绑定设备
- (void)cancelBindDevice;                                                                //取消绑定
- (void)unbindDevice;                                                                       //解绑设备

@property (nonatomic, strong) ArthurBlockChain2 *synBlockChian;
- (void)syn:(onCallBack)handerSyn;                                                  //同步

//设置骑行圈径
- (void)setDiameter:(int)nDiameter onCallBack:(onCallBack)handerSetDiameter;

- (void)saveSetting:(CDKFUserSetting *)userSetting onCallBack:(onCallBack)handerCallBack;                    //保存用户设置

@end
