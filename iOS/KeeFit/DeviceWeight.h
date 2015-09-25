//
//  DeviceWeight.h
//  Weight
//
//  Created by lichen on 9/2/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceBase.h"
#import "DeviceWeightCommandMap.h"
#import "HardwareBluetooth.h"

@interface DeviceWeight : DeviceBase

@property float fWeightInKG;    //体重: Kg
@property float fFatPercent;       //脂肪百分比
@property float fSkeletonPercent;   //骨骼百分比
@property float fMusclePercent;     //肌肉百分比
@property float fWaterPercent;       //水分百分比
@property int nCalories;                  //热量含量
@property int nFatLevel;                //脂肪等级

//生成
+ (DeviceWeight *)createDeviceWeight;
//搜索与连接
- (void)searchAndConnectDevice:(onCallBack)handerSearchAndConnectDevice;
//获取数据
- (void)bodyStateWithGender:(BOOL)bBoy heightInCM:(int)nHeight age:(int)nAge onCallBack:(onCallBack)handerBodyState;

@end
