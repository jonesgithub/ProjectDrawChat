//
//  DeviceSportSleep.m
//  KeeFit
//
//  Created by lichen on 5/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceSportSleep.h"
#import "DataAnalyze.h"
#import "GTMBase64.h"

@implementation DeviceSportSleep

//初始化设备状态
- (void)initializeDeviceWithHardware:(HardwareBase *)hardware
{
    [super initializeDeviceWithHardware:hardware];
    
    self.bDeviceConected = [[NSNumber alloc] initWithBool:NO];
    
    self.dateOfSyn = nil;
    self.nDataSynPercent = [[NSNumber alloc] initWithInt:0];
    self.nBatteryPercent = [[NSNumber alloc] initWithInt:0];
    
    self.strSynEncryptData = nil;
    self.nSynTotalCal = 0;
    self.nSynTotalStep = 0;
    self.nSynTotalDistance = 0; 
    
    self.nBatteryPercent = [[NSNumber alloc] initWithInt:0];    //电量初始化为0

    //设备状态
    self.bDeviceBinded = [MNLib getObjByKey:kDeviceBinded];
    self.nDeviceType = [MNLib getObjByKey:kDeviceType];
    self.strDeviceVersion = [MNLib getObjByKey:kDeviceVersion];
    self.strDeviceId = [MNLib getObjByKey:kDeviceID];
    
    //非正在绑定设备
    self.bInBindDevice = [[NSNumber alloc] initWithBool:NO];
    self.bInSynData = [[NSNumber alloc] initWithBool:NO];
    
    //程序进入后台
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(applicationWillResignActive) 
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    //程序进入前台
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(applicationDidBecomeActive) 
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark 基础命令
//连接命令
- (void)baseConnect:(onCallBack)handerBaseConnect
{
    [self.hardware sendCommand:kCommandConnect withData:nil response:^(BOOL success, NSData *data) {
        handerBaseConnect(success);
    }];
}

//类型与版本号
- (void)baseTypeAndVersion:(onCallBack)handerTypeAndVersion
{
    [self.hardware sendCommand:kCommandTypeAndVersion withData:nil response:^(BOOL success, NSData *data) {
        if (success) {            
            Byte *dataBytes = (Byte*)[data bytes];
            self.nDeviceType = [[NSNumber alloc] initWithInt:(int)dataBytes[0]];
            self.strDeviceVersion = [NSString stringWithFormat:@"%d.%d", (int)dataBytes[1],(int)dataBytes[2]];
        }
        handerTypeAndVersion(success);
    }];
}

//读取设备ID
- (void)baseReadDeviceID:(onCallBack)handerReadDeviceID
{
    [self.hardware sendCommand:kCommandTypeAndVersion withData:nil response:^(BOOL success, NSData *data) {
        if (success) {
            NSString * dataStr = [MNLib dataToHexString:data];
            //第一个byte是类型
            //后面的为DeviceID
            self.strDeviceId = [dataStr substringFromIndex:2];
        }
        handerReadDeviceID(success);
    }];
}

//绑定设备
- (void)baseBindDevice:(onCallBack)handerBindDevice
{
    [self.hardware sendCommand:kCommandBindDevice withData:nil response:^(BOOL success, NSData *data) {
        handerBindDevice(success);
    }];
}

//骑行实时数据
- (void)baseRidingRealTimeData:(onCallBack)handerRidingRealTimeData
{
    [self.hardware sendCommand:kCommandTypeAndVersion withData:nil response:^(BOOL success, NSData *data) {
        if (success) {
            Byte *dataBytes = (Byte*)[data bytes];
            float speed = [ArthurByteOperation combineBytesHight:dataBytes[0] andLow:dataBytes[1]]/10.0f;
            float cadence = [ArthurByteOperation combineBytesHight:dataBytes[2] andLow:dataBytes[3]]/10.0f;
            int circle = [ArthurByteOperation combineBytesHight:dataBytes[4] andLow:dataBytes[5]];
            self.fRidingSpeed = [[NSNumber alloc] initWithFloat:speed];
            self.fRidingCadence = [[NSNumber alloc] initWithFloat:cadence];
            self.nRidingCircle = [[NSNumber alloc] initWithInt:circle];
        }
        handerRidingRealTimeData(success);
    }];
}

//获取数据帧数
- (void)baseDataFrameCount:(onCallBack)handerDataFrameCount
{
    [self.hardware sendCommand:kCommandDataFrameCount withData:nil response:^(BOOL success, NSData *data) {
        if (success) {
            Byte *dataBytes = (Byte*)[data bytes];
            self.nDataFrameCount = [ArthurByteOperation combineBytesHight:dataBytes[1] andLow:dataBytes[2]];
            ConditionLog(bInVirtualDeviceDebug, @"数据帧数: %d", self.nDataFrameCount);
            self.nDataFrameIndex = 0;   //设置获取起始帧
            //下面初始化用16是因为可能为16byte，或者12byte，用最大
            self.dataSportSleepBuffer = [[NSMutableData alloc] initWithCapacity:self.nDataFrameCount*16];   
        }
        handerDataFrameCount(success);
    }];
}

 //获取某一帧
- (void)baseGetDataFrame:(onCallBack)handerGetDataFrame
{
    ConditionLog(bInVirtualDeviceDebug, @"开始获取数据帧:%d", self.nDataFrameIndex);
    NSArray *btArray = [ArthurByteOperation spliteBytes:self.nDataFrameIndex];
    Byte dataBytes[] = {[btArray[0] intValue], [btArray[1] intValue]};
    NSData *data = [NSData dataWithBytes:dataBytes length:2];
    [self.hardware sendCommand:kCommandDataFrameCount withData:data response:^(BOOL success, NSData *data) {
        if (success) {
            AssertClass(self.dataSportSleepBuffer, NSMutableData);
            [self.dataSportSleepBuffer appendData:data];
            self.nDataFrameIndex++; //index移一步
        } else {
            ConditionLog(bInVirtualDeviceDebug, @"获取数据帧: %d 失败", self.nDataFrameIndex);
        }
        handerGetDataFrame(success);
    }];
}

//擦除数据
- (void)baseEraseData:(onCallBack)handerEraseData
{
    [self.hardware sendCommand:kCommandEraseData withData:nil response:^(BOOL success, NSData *data) {
        handerEraseData(success);
    }];
}

//读取电量
- (void)baseReadBattery:(onCallBack)handerReadBattery;
{
    [self.hardware sendCommand:kCommandReadBattery withData:nil response:^(BOOL success, NSData *data) {
        if (success) {            
            Byte *dataBytes = (Byte*)[data bytes];
            self.nBatteryPercent = [[NSNumber alloc] initWithInt:(int)dataBytes[12]];
        }
        handerReadBattery(success);
    }];
}

//设置用户相关信息
- (void)baseSetUserInfo:(CDKFUserSetting *)userSetting response:(onCallBack)handerSetUserInfo
{
    int height = [userSetting.nHeightOfMetric intValue];
    int weight = [userSetting.nWeightOfKg intValue];
    int age = [userSetting.nAge intValue];
    int gender = [userSetting.bMale boolValue] ? 1: 0;
    int walkStepLength = (int)((float)[userSetting.nHeightOfMetric intValue] * 0.39);
    int runStepLenght = (int)((float)[userSetting.nHeightOfMetric intValue] * 0.39 * 1.2);
    int diameter = [userSetting.nDiameter intValue];    //骑行圈径
    int goalType = 1;    //0: Cals 1: step 2 distance
    int goal = [userSetting.nTarget intValue];
    NSArray *arrGoalBytes = [ArthurByteOperation spliteBytes:goal];
    
    Byte commandBytes[] = {(Byte)height, (Byte)weight, (Byte)age, (Byte)gender, (Byte)walkStepLength, (Byte)runStepLenght, (Byte)0, (Byte)diameter, (Byte)goalType, (Byte)[arrGoalBytes[0] intValue], (Byte)[arrGoalBytes[1] intValue], 0x02, 0x0a, 0x00};
    //后三位
    //0x02: 产品处于绑定状态
    //0x0a: 数据保存密度为10分钟
    //0x00: 保留字段
    NSData *commandData = [NSData dataWithBytes:commandBytes length:14];
    
    [self.hardware sendCommand:kCommandSetUserInfo withData:commandData response:^(BOOL success, NSData *data) {
        if (success) {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"设置用户信息成功");
        } else {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"设置用户信息失败");
        }
        handerSetUserInfo(success);
    }];
}

- (void)baseSetAlarmActivity:(CDKFUserSetting *)userSetting response:(onCallBack)handerSetAlarmActivity
{
    Byte bOn = {0x7f};
    Byte bOff = {0x00};
    
    //把星期天放在前面换成放到最后面
    NSMutableArray *arrActivityRepeat = [[NSMutableArray alloc] init];
    for (int j = 1; j < 7; j++) {
        [arrActivityRepeat addObject:userSetting.arrActivityDaysRepeat[j]];
    }
    [arrActivityRepeat addObject:userSetting.arrActivityDaysRepeat[0]];
    
    NSMutableArray *arrAlarmRepeat = [[NSMutableArray alloc] init];
    for (int j = 1; j < 7; j++) {
        [arrAlarmRepeat addObject:userSetting.arrAlarmDaysRepeat[j]];
    }
    [arrAlarmRepeat addObject:userSetting.arrAlarmDaysRepeat[0]];
    
    //准备command的byte
    int activityStart = [userSetting.nActivityStartTime intValue] / 100;
    int activityEnd = [userSetting.nActivityEndTime intValue] / 100;
    int alarmHour = [userSetting.nAlarmTimeInt intValue] / 100;
    int alarmMinute = [userSetting.nAlarmTimeInt intValue] % 100;
    
    Byte byteActivityStart = BCD_X(activityStart);
    Byte byteActivityEnd = BCD_X(activityEnd);
    Byte activityInterval = (Byte)([userSetting.nActivityInterval intValue]);
    Byte byteActivityDayRepeat = [ArthurByteOperation arrayToByte:[arrActivityRepeat boolToNumber]];
    Byte byteActivityOn = [userSetting.bActivityOn boolValue]  ?  bOn: bOff;
    
    Byte byteAlarmHour =BCD_X(alarmHour);
    Byte byteAlarmMinute =BCD_X(alarmMinute);
    Byte byteAlarmHead = (Byte)[userSetting.nAlarmHeadMinute intValue];
    Byte byteAlarmDayRepeat = [ArthurByteOperation arrayToByte:[arrAlarmRepeat boolToNumber]];
    Byte byteAlarmHeadOn = [userSetting.bALarmHeadOn boolValue] ? bOn: bOff;
    Byte byteAlarmOn = [userSetting.bAlarmOn boolValue] ?  bOn: bOff;
    
    Byte commandBytes[] = {
        byteActivityStart, 
        byteActivityEnd, 
        activityInterval,
        byteActivityDayRepeat,
        byteActivityOn,
        byteAlarmHour,
        byteAlarmMinute,
        byteAlarmHead,
        byteAlarmDayRepeat,
        byteAlarmHeadOn,
        byteAlarmOn,
        0,  //报警指示
        0   //电量百分比
    };
    NSData *commandData = [NSData dataWithBytes:commandBytes length:13];
    [self.hardware sendCommand:kCommandSetAlarmActivity withData:commandData response:^(BOOL success, NSData *data) {
        if (success) {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"设置闹钟与活动提醒成功");
        } else {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"设置闹钟与活动提醒失败");
        }
        handerSetAlarmActivity(success);
    }];
}

//同步时间
- (void)baseSynTime:(onCallBack)handerSynTime
{
    NSData *synTimeCommandData = [self timeCommandData];
    [self.hardware sendCommand:kCommandSynTime withData:synTimeCommandData response:^(BOOL success, NSData *data) {
        if (success) {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"同步时间成功");
        } else {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"同步时间失败");
        }
        handerSynTime(success);
    }];
}

#pragma mark
#pragma mark 综合命令
//循环获取数据帧
- (void)getDataCycle
{
    [self baseGetDataFrame:^(BOOL success) {
        if (success) {
            self.nDataSynPercent = [[NSNumber alloc] initWithInt:(self.nDataFrameIndex *100 ) / self.nDataFrameCount];  //数据同步进度
            if (self.nDataFrameIndex < self.nDataFrameCount) {
                [self getDataCycle];
            } else {
                [self sportSleepDataAnalyze];
                ConditionLog(bInVirtualDeviceDebug, @"%@", @"数据处理完成");
                onCallBack handerGetSportSleepData = CopyAndClearHander(self.handerGetSportSleepData);
                handerGetSportSleepData(YES);
            }
        } else {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"获取数据失败");
            onCallBack handerGetSportSleepData = CopyAndClearHander(self.handerGetSportSleepData);
            handerGetSportSleepData(NO);
        }
    }];
}

- (void)sportSleepDataAnalyze
{
    DataAnalyze *dataAnalyze = [[DataAnalyze alloc] init];
    NSDictionary *resultData = [dataAnalyze extandsToitems:[dataAnalyze executeData:[self.dataSportSleepBuffer copy] withLength:6]];
    self.dictSports = [resultData[KEYSPORT] copy];
    self.dictSleeps = [resultData[KEYSLEEP] copy];
    self.strSynEncryptData = [GTMBase64 stringByEncodingData:resultData[KEYRAWDATA]];
    self.nSynTotalCal = [resultData[kAllCal] intValue];
    self.nSynTotalStep= [resultData[kAllStep] intValue];
    self.nSynTotalDistance = [resultData[kAllDistance] intValue];
}

//获取运动与睡眠数据
- (void)getSportSleepData:(onCallBack)handerGetSportSleepData
{
    [self baseDataFrameCount:^(BOOL success) {
        if (success) {
            AssertEmptyHander(self.handerGetSportSleepData) = handerGetSportSleepData;
            [self getDataCycle];
        } else {
            handerGetSportSleepData(NO);
        }
    }];
}

- (void)bindDevice:(onBindDevice)handerBindDevice
{
    ConditionLog(bInVirtualDeviceDebug, @"%@", @"开始绑定");
    [self.hardware bindDevice:^(BOOL success) {
        if (success) {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"硬件绑定成功");
            [MNLib delay2:2 doSomething:^{
                [self baseTypeAndVersion:^(BOOL success) {
                    if (success) {
                        ConditionLog(bInVirtualDeviceDebug, @"%@", @"硬件绑定成功，获取设备类型成功");
                        [self baseReadDeviceID:^(BOOL success) {
                            if (success) {
                                ConditionLog(bInVirtualDeviceDebug, @"%@", @"硬件绑定成功，获取设备类型成功，获取ID成功");
                                //设备状态
                                self.bDeviceBinded = NumberYES;
                                //存deviceID、TypeVersion、type
                                [MNLib setObject:self.nDeviceType key:kDeviceType];
                                [MNLib setObject:self.strDeviceVersion key:kDeviceVersion];
                                [MNLib setObject:self.strDeviceId key:kDeviceID];
                                //肯定已连接好了噻
                                self.bDeviceConected = NumberYES;
                            } else {
                                ConditionLog(bInVirtualDeviceDebug, @"%@", @"硬件绑定成功，获取设备类型成功，获取ID失败");
                            }
                            handerBindDevice(success);
                        }];
                    } else {
                        ConditionLog(bInVirtualDeviceDebug, @"%@", @"硬件绑定成功，但获取设备类型失败");
                        handerBindDevice(NO);
                    }
                }];
            }];
        } else {
            ConditionLog(bInVirtualDeviceDebug, @"%@", @"绑定失败，硬件绑定失败");
            handerBindDevice(NO);
        }
    }];
}

- (void)unbindDevice
{
    //清本地状态
    self.bDeviceBinded = NumberNO;
    self.bDeviceConected = NumberNO;
    
    //请保存状态
    [MNLib setObject:NumberNO key:kDeviceBinded];
    [MNLib setObject:nil key:kDeviceType];
    [MNLib setObject:nil key:kDeviceVersion];
    [MNLib setObject:nil key:kDeviceID];
    
    //设置活动状态
    self.bInBindDevice = NumberNO;
    self.bInSynData = NumberNO;
    self.bInTranslateData = NumberNO;
    
    //硬件底层解绑设备
    [self.hardware unbindDevice];
}

- (void)cancelBindDevice
{
    NSLog(@"%@", @"虚拟设备子类未实现cancelBindDevice函数");
}

//同步
- (void)syn:(onCallBack)handerSyn
{
    if (![self.bDeviceBinded boolValue]) {
        NSLog(@"%@", @"程序错误: 设备未绑定，你就想同步数据?");
        return;
    }
    
    if ([self.bInSynData boolValue]) {
        NSLog(@"%@", @"正在同步数据，不能再进来了");
        handerSyn(NO);
        return;
    }
    
    self.bInSynData = NumberYES;
    
    self.synBlockChian = [[ArthurBlockChain2 alloc] init];
    
    [self.synBlockChian chainBreak:^{
        handerSyn(NO);
    }];
    [self.synBlockChian chainDone:^{
        handerSyn(YES);
    //TODO: 暂不清理数据
//        [self baseEraseData:^(BOOL success) {
//            
//        }];
    }];
    
    __weak typeof(self) weakSelf = self;
    
    //连接设备
    [self.synBlockChian addBlock:^(ArthurBlockChain2 *blockChain) {
        [weakSelf connectDevice:^(BOOL success) {
            [blockChain StepNext:success];
        }];
    }];
    //测试连接的设备是否是已绑定的设备: 考虑是否放放硬件中去？
    [self.synBlockChian addBlock:^(ArthurBlockChain2 *blockChain) {
        NSString *strBindedDeviceID = [MNLib getObjByKey:kDeviceID];
        [weakSelf baseReadDeviceID:^(BOOL success) {
            if (success) {
                if ([strBindedDeviceID isEqualToString:weakSelf.strDeviceId]) {
                    [blockChain StepNext:YES];
                    NSLog(@"%@", @"连接的设备就是已绑定的设备");
                } else {
                    NSLog(@"%@", @"连接的设备非已绑定的设备");
                    [blockChain StepNext:NO];
                }
            } else {
                NSLog(@"%@", @"读取设备ID失败");
                [blockChain StepNext:NO];
            }
        }];
    }];
    //电量
    [self.synBlockChian addBlock:^(ArthurBlockChain2 *blockChain) {
        [weakSelf baseReadBattery:^(BOOL success) {
            [blockChain StepNext:success];
        }];
    }];
    //用户设置
    [self.synBlockChian addBlock:^(ArthurBlockChain2 *blockChain) {
        [weakSelf updateUserSetting:^(BOOL success) {
            [blockChain StepNext:success];
        }];
    }];
    //同步数据
    [self.synBlockChian addBlock:^(ArthurBlockChain2 *blockChain) {
        weakSelf.dateOfSyn = [NSDate date]; //同步时间
        [weakSelf getSportSleepData:^(BOOL success) {
            [blockChain StepNext:success];
        }];
    }];
    //同步设备时间
    [self.synBlockChian addBlock:^(ArthurBlockChain2 *blockChain) {
        [weakSelf baseSynTime:^(BOOL success) {
            [blockChain StepNext:success];
        }];
    }];
    
    //开始执行chian
    [self.synBlockChian start];
}

//连接设备
- (void)connectDevice:(onCallBack)handerConnectDevice
{
    if ([self.bDeviceConected boolValue]) {
        handerConnectDevice(YES);
    } else {
        if (![self.bDeviceBinded boolValue]) {
            NSLog(@"%@", @"程序错误: 设备未绑定，你就想连接?");
            handerConnectDevice(NO);
        } else {
            [self.hardware connectDevice:^(BOOL success) {
                if (success) {
                    NSLog(@"%@", @"连接设备成功");
                    self.bDeviceConected = NumberYES;
                } else {
                    NSLog(@"%@", @"连接设备失败");
                }
                handerConnectDevice(success);
            }];
        }
    }
}

//设置骑行圈径
- (void)setDiameter:(int)nDiameter onCallBack:(onCallBack)handerSetDiameter
{
    CDKFUserSetting *userSetting = [[CDKFUserSetting Instance] copy];
    userSetting.nDiameter = [[NSNumber alloc] initWithInt:nDiameter];
    [self saveSetting:userSetting onCallBack:^(BOOL success) {
        if (success) {
            [CDKFUserSetting saveSettingToUserDefault:userSetting];
            NSLog(@"%@", @"设置骑行圈径成功");
        } else {
            NSLog(@"%@", @"设置骑行圈径失败");
        }
        handerSetDiameter(success);
    }];
}

//保存设置
- (void)saveSetting:(CDKFUserSetting *)userSetting onCallBack:(onCallBack)handerCallBack
{
    [self baseSetUserInfo:userSetting response:^(BOOL success) {
        if (success) {
            [self baseSetAlarmActivity:userSetting response:^(BOOL success) {
                handerCallBack(success);
            }];
        } else {
            handerCallBack(NO);
        }
    }];
}

//内部使用: 同步用户设置
- (void)updateUserSetting:(onCallBack)handerSynUserSetting
{  
    //下面为什么要用copy: 因为保存设置的过程中，用户可能还在更改
    CDKFUserSetting *userSetting = [[CDKFUserSetting Instance] copy];
    [self saveSetting:userSetting onCallBack:^(BOOL success) {
        if (success) {
            [CDKFUserSetting saveSettingToUserDefault:userSetting];
            NSLog(@"%@", @"设置用户信息成功");
        }
        handerSynUserSetting(success);
    }];
}

#pragma mark
#pragma mark 事件响应
//这样的动作应该在外层操作
- (void)applicationWillResignActive
{
    //TODO: 要不要回应相应操作?
//    [self.HardwareBase cleanState];
}

//程序进入活动状态
- (void)applicationDidBecomeActive
{
//    if ([self.bDeviceBinded boolValue]) {
//        [self syn:^(BOOL success) {
//            //TODO: 去存数据
//            if (success) {
//                NSLog(@"%@", @"同步成功");
//            } else {
//                NSLog(@"%@", @"同步失败");
//            }
//        }];
//    }
}

#pragma mark
#pragma mark Helper
- (NSData *) timeCommandData{
    NSDateComponents *dateComponents = [self dateComponentsFromDate :[NSDate date]];
    int weekDay = (int)dateComponents.weekday;
    if (weekDay == 1) {
        weekDay = 6;
    }else{
        weekDay = weekDay - 2;
    }
    Byte bytes[] = {BCD_X(dateComponents.year%100), BCD_X(dateComponents.month), BCD_X(dateComponents.day), BCD_X(dateComponents.hour), BCD_X(dateComponents.minute), BCD_X(dateComponents.second), weekDay};
    return [NSData dataWithBytes:bytes length:7];
}

- (NSDateComponents *)dateComponentsFromDate: (NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekCalendarUnit|
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    return comps;
}

@end
