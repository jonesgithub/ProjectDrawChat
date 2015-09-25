//
//  CDKFUserSetting.h
//  KeeFit
//
//  Created by lichen on 5/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArthurSerialBase.h"

typedef void (^onCallBack)(BOOL success);

//设置的一些预定义量
#define kProfileDefaultHeightOfMetric 180       //默认身高180cm
#define kProfileMaxHeightOfMetric 300           //默认最大身高300cm
#define kProfileDefaultWeightOfKg 70                //默认体重70Kg
#define kProfileMaxWeightOfKg 1000               //默认最大体重200Kg
#define kProfileDefaultAge 20                  //默认年龄20
#define kProfileMaxAge 150                      //最大年龄150
#define kTargetDefaultValue 10000       //默认target

//目标设置范围
#define kTargetRangeMin 1000
#define kTargetRangeMax 100000

//身高、体重、年龄设置
//#define kProfileHeigthMaxInCm 300
//#define kProfileWeightMaxInKg 1000
//#define kProfileAgeMax 150

//User Default中key
#define kUserSetting @"kUserSetting"

@interface CDKFUserSetting : ArthurSerialBase

//男女
@property (nonatomic, strong) NSNumber *bMale;

//公制或英制
@property (nonatomic, strong) NSNumber *bByMetric;

//身高
@property (nonatomic, strong) NSNumber *nHeightOfMetric;
@property (nonatomic, strong) NSNumber *fHeightOfInch;

//体重
@property (nonatomic, strong) NSNumber *nWeightOfKg;
@property (nonatomic, strong) NSNumber *nWeightOfPound;

//年龄
@property (nonatomic, strong) NSNumber *nAge;

//目标: 目前只做步数
@property (nonatomic, strong) NSNumber *nTarget;

//智能闹钟
@property (nonatomic, strong) NSNumber *bAlarmOn;                  //闹钟总开关
@property (nonatomic, strong) NSNumber *nAlarmTimeInt;          //闹钟时间: 8:20 => 820表示
@property (nonatomic, strong) NSArray *arrAlarmDaysRepeat;     //闹钟每天(一周内)重复情况: BOOL表示
@property (nonatomic, strong) NSNumber *bALarmHeadOn;         //闹钟提前量开关
@property (nonatomic, strong) NSNumber *nAlarmHeadMinute;    //闹钟提前量: 注意只byte大小有效

//活动提醒
@property (nonatomic, strong) NSNumber *bActivityOn;                //活动提醒总开关
@property (nonatomic, strong) NSNumber *nActivityStartTime;     //活动提醒开始时间
@property (nonatomic, strong) NSNumber *nActivityEndTime;       //活动提醒结束时间
@property (nonatomic, strong) NSArray *arrActivityDaysRepeat;    //活动提配每天(一周内)重复情况
@property (nonatomic, strong) NSNumber *nActivityInterval;          //活动提醒间隔

//骑行
@property (nonatomic, strong) NSNumber *nDiameter;

+(CDKFUserSetting *) Instance;

+ (void)saveSettingToUserDefault;
+ (void)saveSettingToUserDefault:(CDKFUserSetting *)userSetting;
+ (void)saveSetting:(onCallBack)handerCallBack;
+ (void)cancelSetting;

@end
