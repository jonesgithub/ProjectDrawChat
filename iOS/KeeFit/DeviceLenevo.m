//
//  DeviceLenevo.m
//  LenovoBand
//
//  Created by lichen on 9/11/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceLenevo.h"
#import "ArthurHexOperation.h"

@implementation DeviceLenevo

#pragma mark
#pragma mark 生成器
+ (DeviceLenevo *)createDeviceLenvo
{
    //生成蓝牙硬件
    HardwareBluetooth *hardwareLluetooth = [[HardwareBluetooth alloc] init];
    //设置过滤参数
//    NSArray *arrDeviceNames = @[@"LERUNNER 21DA"];
    NSArray *arrDeviceNames = @[@"Smartband 023B"];
    NSArray *arrBroadcastIDs = @[];
    NSDictionary *dictServiceCharacteristics = @{
                                                 @"1500": @[@"1520", @"1530"],
                                                 @"1600": @[@"1620", @"1650"],
                                                 @"1802": @[@"2A06"],
                                                 @"1803": @[@"2A06"],
                                                 @"1804": @[@"2A07"],
                                                 @"180A": @[@"2A29", @"2A24", @"2A23"],
                                                 @"180D": @[@"2A37", @"2A38"],  //前面一个是心率
                                                 @"180F": @[@"2A19"]
                                                 };
    
    NSString *strPeripheralUUIDString = [MNLib getObjByKey:kPeripheralUUIDString];
    
    [hardwareLluetooth setBluetoothFilterWithDeviceName:arrDeviceNames 
                                           broadcastIDs:arrBroadcastIDs 
                                 serviceCharacteristics:dictServiceCharacteristics 
                                   peripheralUUIDString:strPeripheralUUIDString];
    
    //生成本类
    DeviceLenevo *deviceLevno = [[DeviceLenevo alloc] init];
    deviceLevno.hardwareBluetooth = hardwareLluetooth;
    hardwareLluetooth.deviceDelegate = deviceLevno;
    return deviceLevno;
}

#pragma mark
#pragma mark 清理
- (void)dealloc
{
    [self.hardwareBluetooth cleanState];
    self.hardwareBluetooth = nil;
}

#pragma mark
#pragma mark 函数: 外部接口
- (void)serachDevice:(onCallBack)handerSearchDevice
{
    [self.hardwareBluetooth serachDeviceWithTimeout:60 onCallBack:^(BOOL success) {
        if (success) {
            [MNLib setObject:self.hardwareBluetooth.strPeripheralUUID key:kPeripheralUUIDString];
        }
        handerSearchDevice(success);
    }];
}

- (void)getBattery:(onCallBack)handerGetBattery
{
    [self.hardwareBluetooth readValueForService:@"180F" characteristics:@"2A19" when:^(BOOL success, NSData *data) {
        if (success) {
            NSLog(@"%@", @"获取电量成功");
            NSString *strData = [ArthurHexOperation NSDataToHexString:data];
            NSLog(@"电量Hex数据: %@", [strData capitalizedString]);
        } else {
            NSLog(@"%@", @"获取电量失败");
        }
        handerGetBattery(success);
    }];
}

- (void)getHeartRate:(onCallBack)handerGetHeartRate
{
    [self.hardwareBluetooth notificaitonForService:@"180D" characteristics:@"2A37" when:^(BOOL success, NSData *data) {
        if (success) {
            NSString *strData = [ArthurHexOperation NSDataToHexString:data];
            NSLog(@"心率Hex数据: %@", [strData capitalizedString]);
        } else {
            NSLog(@"%@", @"获取心率失败");
        }
        handerGetHeartRate(success);
    }];
}

- (void)closeGetHeartRate
{
    [self.hardwareBluetooth closeNotificaitonForService:@"180D" characteristics:@"2A37"];
}

- (void)connectDevice:(onCallBack)handerConnectDevice
{
    ArthurByteOperation *byteOperation = [[ArthurByteOperation alloc] init];
    [byteOperation addByte:0xEE withCount:2];
    [byteOperation addByte:0x00 withCount:18];
    [self commmunicateWithData:[byteOperation wholeData] when:^(BOOL success, NSData *data) {
        if (success) {
            [MNLib printData:data dataName:@"连接收到:\n"];
        } else {
            NSLog(@"%@", @"连接失败");
        }
        handerConnectDevice(success);
    }];
}

- (void)watchSetting:(onCallBack)handerWatchSetting
{
    ArthurByteOperation *byteOperation = [[ArthurByteOperation alloc] init];
    [byteOperation addStringValue:@"SET"];
    NSDate *nowDate = [NSDate date];
    [byteOperation addByte:(Byte)([nowDate theYear] % 100)];   //14年
    [byteOperation addByte:(Byte)[nowDate theMonth]];   //9月
    [byteOperation addByte:(Byte)[nowDate theDay]];   //22日
    [byteOperation addByte:(Byte)[nowDate theHour]];   //时
    [byteOperation addByte:(Byte)[nowDate theMinute]];   //分
    [byteOperation addByte:(Byte)[nowDate theSecond]];   //秒
    [byteOperation addByte:(Byte)1];   //24小时制
    [byteOperation addByte:0x0A];   //Display
    [byteOperation addByte:0x00];   //单位: mile
    [byteOperation addByte:0x00];   //00=Female, 01=Male
    [byteOperation addByte:(Byte)26];   //年龄: 26
    [byteOperation addByte:(Byte)158];   //身高
    [byteOperation addByte:(Byte)60];   //体重: 60Kg
    [byteOperation addByte:0x00];   //这一位文档与体重联在一起，有点疑问
    [byteOperation addByte:0x00];   //Idle time: 00=off 01=on
    [byteOperation addByte:0x00];   //Packet 00
    [byteOperation addByte:0xFF];   //Head
    
    NSData *dataCommand = [byteOperation wholeData];
    [self commmunicateWithData:dataCommand when:^(BOOL success, NSData *data) {
        if (success) {
            if ([dataCommand isEqualToData:data]) {
                NSLog(@"%@", @"设置1成功");
                handerWatchSetting(YES);
            } else {
                NSLog(@"%@", @"设置1失败: 发与收的设置不一致");
                handerWatchSetting(NO);
            }
        } else {
            NSLog(@"%@", @"设置1失败");
            handerWatchSetting(NO);
        }
    }];
}

- (void)getAllRunData:(onCallBack)handerGetAllRunData
{
    //清理空间
    self.arrAllRunData = [[NSMutableArray alloc] init];
    
    NSData *getAllRunData = [ArthurHexOperation hexToNSData:@"52 55 4E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FB"];
    
    static int nRunNumber = 0;
    static int nPacketInnerIndex = -1;
    static int nRunCount = 0;
    static int nHeartRateCount = 0;
    
    [self commmunicateWithData:getAllRunData when:^(BOOL success, NSData *data) {
        if (success) {
            //测试是否结束
            ArthurByteOperation *endData = [[ArthurByteOperation alloc] init];
            [endData addByte:0xFF withCount:20];
            if ([data isEqualToData:[endData wholeData]]) {
                NSLog(@"%@", @"运动数据结束");
                handerGetAllRunData(YES);
                return;
            }
            
            //是否无数据
            NSData *noData = [ArthurHexOperation hexToNSData:@"52 55 4E FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 01 FB"];
            if ([data isEqualToData:noData]) {
                NSLog(@"%@", @"无数据");
                handerGetAllRunData(YES);
                return;
            }
            
            //分段
            Byte *dataArray = (Byte*)[data bytes];
            int nCurrentRunNumber = (int)dataArray[17];
            if (nCurrentRunNumber != nRunNumber) {
                //打印前面一个段的内容
                fprintf(stderr, "总速度个数: %d，总心率个数: %d\n\n", nRunCount, nHeartRateCount);
                
                nRunNumber = nCurrentRunNumber;
                nPacketInnerIndex = 0;
                nRunCount = 0;
                nHeartRateCount = 0;
                
                
//                fprintf(stderr, "\n");
            } else {
                nPacketInnerIndex++;
            }
            
            if (nPacketInnerIndex == 0) {
                [self processFirstPacket:data]; //开始时间、结束时间
//                return;
            } else if (nPacketInnerIndex == 1) {
                [self processSecondPacket:data];    //运动时长、休息时长、休息次数、步数、距离
//                return;
            } else if (nPacketInnerIndex == 2) {
                [self processThirdPacket:data];     //平均速度、心率
                //开始准备数据
                self.arrRunData = [[NSMutableArray alloc] init];
                self.arrHeartRateData = [[NSMutableArray alloc] init];
//                return;
            } else {
                if (dataArray[16] == 0) {
                    nRunCount += [self processFourthPacket:data];    //各段速度
                } else if (dataArray[16] == 1) {    
                    nHeartRateCount += [self processFivethPacket:data];    //各段心率
                } else {
                    NSLog(@"%@", @"数据解析程序出错");
                    handerGetAllRunData(NO);
                    return;
                }
                
                //最后一个数据都解析完了
                if (nPacketInnerIndex == (self.nRunSpeedPacketCount + self.nRunHeartPacketCount + 2)) {
                    //存数据
                    //有数据时才存
                    if (self.nRunSpeedDataCount != 0) {
                        [self.arrAllRunData addObject:@{
                                                        kRunStartTime: self.strRunStartTime,
                                                        kRunEndTime: self.strRunEndTime,
                                                        kRunSpeedData: [self.arrRunData copy],
                                                        kRunHeartRateData: [self.arrHeartRateData copy],
                                                        kRunCalories: @(self.nRunSecitonCalories),
                                                        kRunSteps: @(self.nRunSectionSteps),
                                                        kRunDistance: @(self.nRunSectionDistance)}];
                    }
                }
            } 
            
            NSString *strData = [ArthurHexOperation NSDataToHexString:data];
            fprintf(stderr, "%s\n",[strData UTF8String]);
        } else {
            NSLog(@"%@", @"get all run data fails");
            handerGetAllRunData(NO);
            return;
        }
    }];
}

- (void)getAllSleepData:(onCallBack)handerGetAllSleepData
{
    self.arrAllSleepData = [[NSMutableArray alloc] init];
    NSData *getAllSleepData = [ArthurHexOperation hexToNSData:@"53 4C 45 45 50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FC"];
    
//    static int nSleepNumber = 0;
    self.nPacketSectionIndex = -1;
    static int nSleepPacketInnerIndex = 0;
//    static int nSleepCount = 0;
    
    [self commmunicateWithData:getAllSleepData when:^(BOOL success, NSData *data) {
        if (success) {
            //测试是否结束
            ArthurByteOperation *endData = [[ArthurByteOperation alloc] init];
            [endData addByte:0xFF withCount:20];
            if ([data isEqualToData:[endData wholeData]]) {
                NSLog(@"%@", @"睡眠数据结束");
                handerGetAllSleepData(YES);
                return;
            }
            
            //是否无数据
            NSData *noData = [ArthurHexOperation hexToNSData:@"44 41 49 4C 59 YY MM DD FF FF FF FF FF FF FF FF FF FF FF FA"];
            if ([data isEqualToData:noData]) {
                NSLog(@"%@", @"无数据");
                handerGetAllSleepData(YES);
                return;
            }
            
            //分段
//            Byte *dataArray = (Byte*)[data bytes];
            
            if (nSleepPacketInnerIndex == 0) {
                [self processSleepFirstPacket:data];
            } else if (nSleepPacketInnerIndex == 1) {
                [self processSleepSecondPacket:data];
                self.nPacketSectionIndex++; //开始进入下一组
                self.arrSleepData = [[NSMutableArray alloc] init];
            } else {
                [self processSleepOtherPacket:data];
            }
            
            //获取完数据了
            if (nSleepPacketInnerIndex == self.nCurrentSleepPacketCount+1) {
                nSleepPacketInnerIndex = 0;
                //存数据
                NSDictionary *dicSleep = @{
                                           kSleepStartTime: self.strStartTime, 
                                           kSleepEndTime: self.strEndTime,
                                           kSleepData: [self.arrSleepData copy]};
                [self.arrAllSleepData addObject:dicSleep];
                
            } else {
                nSleepPacketInnerIndex++;
            }
            
            
            
//            NSString *strData = [ArthurHexOperation NSDataToHexString:data];
//            fprintf(stderr, "%s\n",[strData UTF8String]);
        } else {
            NSLog(@"%@", @"get all run data fails");
            handerGetAllSleepData(NO);
            return;
        }
    }];
}



- (void)clearData:(onCallBack)handerClearData
{    
    NSData *deleteData = [ArthurHexOperation hexToNSData:@"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FD"];
    [self commmunicateWithData:deleteData when:^(BOOL success, NSData *data) {
        if (success && [data isEqualToData:deleteData]) {
            NSLog(@"%@", @"清理数据成功");
            handerClearData(YES);
        } else {
            handerClearData(NO);
        }
    }];
}


#pragma mark
#pragma mark 函数: 处理运动数据
- (void)processFirstPacket:(NSData *)data
{
    Byte *dataArray = (Byte*)[data bytes];
    NSString *strStart = [NSString stringWithFormat:@"%02d.%02d.%02d %02d:%02d:%02d", 
                          (int)dataArray[5],
                          (int)dataArray[4],
                          (int)dataArray[3],
                          (int)dataArray[2],
                          (int)dataArray[1],
                          (int)dataArray[0]];
    NSString *strEnd = [NSString stringWithFormat:@"%02d.%02d.%02d %02d:%02d:%02d", 
                          (int)dataArray[11],
                          (int)dataArray[10],
                          (int)dataArray[9],
                          (int)dataArray[8],
                          (int)dataArray[7],
                          (int)dataArray[6]];
    
    fprintf(stderr, "%s => %s\n", [strStart UTF8String], [strEnd UTF8String]);
    
    NSDate *dateStart = [NSDate dateFromFull:[@"20" stringByAppendingString:strStart]];
    NSDate *dateEnd = [NSDate dateFromFull:[@"20" stringByAppendingString:strEnd]];
    NSTimeInterval timeDiff = [dateEnd timeIntervalSinceDate:dateStart];
    self.nRunSpeedDataCount = timeDiff / 60;  //一分钟一个数据，一共有多少个数据
    
    fprintf(stderr, "一共有%d个运动数据\n", self.nRunSpeedDataCount);
    
    self.strRunStartTime = strStart;
    self.strRunEndTime = strEnd;
}

- (void)processSecondPacket:(NSData *)data
{
    Byte *dataArray = (Byte*)[data bytes];
    NSString *strExerciseTime = [NSString stringWithFormat:@"%02d:%02d:%02d:%02d", 
                          (int)dataArray[0],
                          (int)dataArray[1],
                          (int)dataArray[2],
                          (int)dataArray[3]];
    NSString *strRestTime = [NSString stringWithFormat:@"%02d:%02d:%02d:%02d", 
                             (int)dataArray[4],
                             (int)dataArray[5],
                             (int)dataArray[6],
                             (int)dataArray[7]];
    int nRestTime = (int)dataArray[8];  //休息次数
    int nStep = [ArthurByteOperation totalNumber:[data subdataWithRange:NSMakeRange(9, 4)] normalEnd:YES]; //休息步数
    int nDistance = [ArthurByteOperation totalNumber:[data subdataWithRange:NSMakeRange(13, 4)] normalEnd:YES];  //距离
    self.nRunSectionSteps = nStep;
    self.nRunSectionDistance = nDistance;
    fprintf(stderr, "运动: %s 休息: %s, 休息次数: %d, 步数: %d，距离: %d\n", 
            [strExerciseTime UTF8String], 
            [strRestTime UTF8String],
            nRestTime,
            nStep,
            nDistance);
}

- (void)processThirdPacket:(NSData *)data
{
    Byte *dataArray = (Byte*)[data bytes];
    int nCalories = [ArthurByteOperation totalNumber:[data subdataWithRange:NSMakeRange(0, 4)] normalEnd:YES]; //卡路里
    self.nRunSecitonCalories = nCalories;
    int nAveragySpeed = [ArthurByteOperation totalNumber:[data subdataWithRange:NSMakeRange(4, 2)] normalEnd:YES]; //平均速度
    int nMaxSpeed = [ArthurByteOperation totalNumber:[data subdataWithRange:NSMakeRange(6, 2)] normalEnd:YES]; //最大速度
    int nDataPacketNumber = (int)dataArray[8];  //?
    int nDataPacketForTime = (int)dataArray[9]; //?
    int nMaxHeartRate = (int)dataArray[10]; //最大心率f
    int nAverageHeartRate = (int)dataArray[11];     //平均心率
    NSString *strZoneTime = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)dataArray[12], (int)dataArray[13], (int)dataArray[14]];
    int nHeartRatePacket = (int)dataArray[15];
    int nHeartRatePacketForTime = (int)dataArray[16];
    
    fprintf(stderr, "卡路里: %d 平均速度: %d, 最大速度: %d, 数据包数: %d, 数据包时间: %d，最大心率: %d，平均心率: %d，时区: %s，心率包数: %d，心率时间单位: %d\n", 
            nCalories, 
            nAveragySpeed,
            nMaxSpeed,
            nDataPacketNumber,
            nDataPacketForTime,
            nMaxHeartRate,
            nAverageHeartRate, 
            [strZoneTime UTF8String], 
            nHeartRatePacket,
            nHeartRatePacketForTime);
    
    self.nRunSpeedPacketCount = nDataPacketNumber;
    self.nRunHeartPacketCount = nHeartRatePacket;
}

- (int)processFourthPacket:(NSData *)data
{
    int nCount = 0;
    Byte *dataArray = (Byte*)[data bytes];
    for (int nIndex = 0 ; nIndex < 16; nIndex++) {
        //        if (dataArray[nIndex] != 0x1A) {    //0x1A: 速度非空标识
        if ([self.arrRunData count] < self.nRunSpeedDataCount) {
            nCount++;
            [self.arrRunData addObject:@((int)dataArray[nIndex])];
        } else {
            break;
        }
    }
    return nCount;
}

- (int)processFivethPacket:(NSData *)data
{
    int nCount = 0;
    Byte *dataArray = (Byte*)[data bytes];
    for (int nIndex = 0 ; nIndex < 16; nIndex++) {
        if (dataArray[nIndex] != 0xFF) {    //0xFF: 心率非空标识
            nCount++;
            [self.arrHeartRateData addObject:@((int)dataArray[nIndex])];
        } else {
            break;
        }
    }
    return nCount;
}

#pragma mark
#pragma mark 函数: 处理睡眠数据
- (void)processSleepFirstPacket:(NSData *)data
{
    Byte *dataArray = (Byte*)[data bytes];
    
    NSString *strStart = [NSString stringWithFormat:@"%02d.%02d.%02d %02d:%02d", 
                          (int)dataArray[4],
                          (int)dataArray[3],
                          (int)dataArray[2],
                          (int)dataArray[1],
                          (int)dataArray[0]];
    NSString *strEnd = [NSString stringWithFormat:@"%02d.%02d.%02d %02d:%02d", 
                        (int)dataArray[9],
                        (int)dataArray[8],
                        (int)dataArray[7],
                        (int)dataArray[6],
                        (int)dataArray[5]];
    self.strStartTime = strStart;
    self.strEndTime = strEnd;
    
    self.nCurrentSleepPacketCount = 256 * (int)(dataArray[12]) + (int)(dataArray[11]);
    int nSleepUnitTime = (int)dataArray[13];
    
    fprintf(stderr, "时间: %s => %s\n包个数:%d \n睡眠时间单位%d分钟\n", 
            [strStart UTF8String], 
            [strEnd UTF8String], 
            self.nCurrentSleepPacketCount,
            nSleepUnitTime);
}

- (void)processSleepSecondPacket:(NSData *)data
{
    
}

- (void)processSleepOtherPacket:(NSData *)data
{
    Byte *dataArray = (Byte*)[data bytes];
    for (int nIndex = 0; nIndex < 16; nIndex++) {
        if (dataArray[nIndex] != 0x1A) {
            [self.arrSleepData addObject:@((int)dataArray[nIndex])];
        }
    }
}

#pragma mark
#pragma mark 函数: 基础通信功能
- (void)commmunicateWithData:(NSData *)data when:(MessageHandler)handler
{
    if ([data length] != 20) {
        NSLog(@"%@", @"程序错误: 发送的数据长度不为20");
        handler(NO, nil);
        return;
    }
    
    [self.hardwareBluetooth sendCommand:data 
                             forService:@"1500" 
                     forCharacteristics:@"1530"
                         waitForService:@"1500"
                 waitForCharacteristics:@"1520" when:handler];
}

@end
