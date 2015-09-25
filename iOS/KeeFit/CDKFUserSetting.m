//
//  CDKFUserSetting.m
//  KeeFit
//
//  Created by lichen on 5/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "CDKFUserSetting.h"

//#define kProfileDefaultHeightOfInch 5.90
//#define kProfileDefaultHeightOfPound 14

#define kWeekRepeatAllNo @[@(NO), @(NO), @(NO), @(NO), @(NO), @(NO), @(NO)]

@implementation CDKFUserSetting

- (void)defaultValues
{
    self.bMale = [[NSNumber alloc] initWithBool:YES];
    
    //默认公制
    self.bByMetric = [[NSNumber alloc] initWithBool:YES];
    
    self.nHeightOfMetric = [[NSNumber alloc] initWithInt:kProfileDefaultHeightOfMetric];
    self.fHeightOfInch = [[NSNumber alloc] initWithFloat:[ArthurUnitChange cm2feet:kProfileDefaultHeightOfMetric]];
    
//    self.bWeightByKg = [[NSNumber alloc] initWithBool:YES];
    self.nWeightOfKg = [[NSNumber alloc] initWithInt:kProfileDefaultWeightOfKg];
    self.nWeightOfPound = [[NSNumber alloc] initWithFloat:(int)[ArthurUnitChange kg2lb:kProfileDefaultWeightOfKg]];
    
    self.nAge = [[NSNumber alloc] initWithInt:kProfileDefaultAge];
    
    self.nTarget = [[NSNumber alloc] initWithInt:kTargetDefaultValue];
    
    //智能闹钟
    self.bAlarmOn = [[NSNumber alloc] initWithBool:NO];                     //闹钟总开关
    self.nAlarmTimeInt = [[NSNumber alloc] initWithInt:800];                //闹钟时间: 8:20 => 820表示
    self.arrAlarmDaysRepeat = kWeekRepeatAllNo;                                 //闹钟每天(一周内)重复情况: BOOL表示:
    self.bALarmHeadOn = [[NSNumber alloc] initWithBool:YES];         //闹钟提前量开关: 界面无设置
    self.nAlarmHeadMinute = [[NSNumber alloc] initWithInt:10];             //闹钟提前量: 注意只byte大小有效: 默认不提前
    
    //活动提醒
    self.bActivityOn = [[NSNumber alloc] initWithBool:NO];                //活动提醒总开关: 默认关
    self.nActivityStartTime = [[NSNumber alloc] initWithInt:900];            //活动提醒开始时间: 早上九点开始
    self.nActivityEndTime = [[NSNumber alloc] initWithInt:1800];           //活动提醒结束时间: 下午六点结束
    self.arrActivityDaysRepeat = kWeekRepeatAllNo;                            //活动提配每天(一周内)重复情况: 默认无
    self.nActivityInterval = [[NSNumber alloc] initWithInt:30];              //活动提醒间隔: 默认为30分钟
}


static CDKFUserSetting * instance = nil;
+(CDKFUserSetting *) Instance
{
    @synchronized(self) {
        if(nil == instance){
            [self getSettingFromUserDefault];
        }
    }
    return instance;
}

#pragma mark
#pragma mark 函数: 从user default中取出setting，若无，则设默认
+ (void)getSettingFromUserDefault
{
    instance = (CDKFUserSetting *)[MNLib getObjWithNSDataFormatByKey:kUserSetting];
    if (!instance) {
        instance = [[self class] new];
        [instance defaultValues];
        //存一个在默认里面
        [MNLib setObjectWithNSDataFormat:instance key:kUserSetting];
    }
}

#pragma mark
#pragma mark 函数: 保存、取消setting
+ (void)saveSettingToUserDefault
{
    [MNLib setObjectWithNSDataFormat:[self Instance] key:kUserSetting];
}

+ (void)saveSettingToUserDefault:(CDKFUserSetting *)userSetting
{
    [MNLib setObjectWithNSDataFormat:userSetting key:kUserSetting];
}

//保存setting
+ (void)saveSetting:(onCallBack)handerCallBack
{
    if ([[CDKFDeviceManager Instance].bDeviceBinded boolValue]) {
        if ([[CDKFDeviceManager theBindedDevice].bInSynData boolValue]) {
            [MNLib showTitle:ArthurLocal(@"The device is uploading data, please set later.") message:nil buttonName:ArthurLocal(@"OK")];
            handerCallBack(NO);
        } else {
            [[CDKFDeviceManager theBindedDevice] saveSetting:[self Instance] onCallBack:^(BOOL success) {
                if (success) {
                    [self saveSettingToUserDefault];
                    [MNLib showTitle:ArthurLocal(@"Save successfully") message:nil delayTime:0.8 completion:^{
                        handerCallBack(success);
                    }];
                } else {
                    //查看为什么没有设置成功: 可能是未连接
                    if (![[CDKFDeviceManager theBindedDevice].bDeviceConected boolValue]) {
                        [MNLib showTitle:ArthurLocal(@"The device is not connected") message:nil delayTime:0.8 completion:^{
                            handerCallBack(success);
                        }];
                    } else {
                        [MNLib showTitle:ArthurLocal(@"Saving fails") message:nil delayTime:0.8 completion:^{
                            handerCallBack(success);
                        }];
                    }
                }
            }];
        }
    } else {
        [MNLib showTitle:nil message:ArthurLocal(@"No device is binded, So you can't set") delayTime:1.0 completion:^{
            handerCallBack(NO);
        }];
    }
}

//        if ([[CDKFDeviceManager theBindedDevice].bDeviceConected boolValue]) {
//            
//            
//        } else {
//            [MNLib showTitle:ArthurLocal(@"The device is not connected") message:nil delayTime:0.8 completion:^{
//                handerCallBack(NO);
//            }];
//        }


//取消setting: 从新重user default中取出数据
+ (void)cancelSetting
{
    [self getSettingFromUserDefault];
}

@end
