//
//  DeviceWeight.m
//  Weight
//
//  Created by lichen on 9/2/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceWeight.h"
#import "ArthurHexOperation.h"

@implementation DeviceWeight

#pragma mark
#pragma mark 生成器
+ (DeviceWeight *)createDeviceWeight
{
    //初始化蓝牙硬件
    HardwareBluetooth *bluetoothHardware = [[HardwareBluetooth alloc] init];
    
    //蓝牙连接参数
//    NSArray *arrDeviceNames = @[@"COD_WXC"];
//    [bluetoothHardware setScanRangeWithNames:arrDeviceNames Service:@"180F" characteristics:@"2A19"];
//    [bluetoothHardware setStartCommand:0x68];
    
    DeviceWeight *deviceWeight = [[DeviceWeight alloc] init];
    
    [deviceWeight initializeDeviceWithHardware:bluetoothHardware];
    
    return deviceWeight;
}

#pragma mark
#pragma mark 函数: 内部辅助函数
- (void)searchDevice:(onCallBack)handerSearchDevice
{
    [self.hardware searchDevice:^(BOOL success) {
        if (success) {
            self.arrSearchedDevice = [self.hardware.arrSearchedDevice copy];
        }
        handerSearchDevice(success);
    }];
}

- (void)connectDevice:(onCallBack)handerConnectDevice
{
    if ([self.bDeviceConected boolValue]) {
        handerConnectDevice(YES);
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


#pragma mark
#pragma mark 外部分接口
- (void)searchAndConnectDevice:(onCallBack)handerSearchAndConnectDevice
{
    NSLog(@"%@", @"开始搜索");
    [self searchDevice:^(BOOL success) {
        if (success) {
            NSLog(@"%@", @"搜索到");
            //用搜索到的第一个，连接
            NSString *strBroadcastID = self.arrSearchedDevice[0];
            HardwareBluetooth *bluetoothHardware = (HardwareBluetooth *)self.hardware;
            [bluetoothHardware setBroadcastId:strBroadcastID];
            
            NSLog(@"%@", @"开始连接");
            [self connectDevice:^(BOOL success) {
                if (success) {
                    NSLog(@"%@", @"连接成功");
                } else {
                    NSLog(@"%@", @"连接失败");
                }
                handerSearchAndConnectDevice(success);
            }];
        } else {
            NSLog(@"%@", @"未搜索到");
            handerSearchAndConnectDevice(NO);
        }
    }];
}

- (void)bodyStateWithGender:(BOOL)bBoy heightInCM:(int)nHeight age:(int)nAge onCallBack:(onCallBack)handerBodyState
{
    //数据验证
    if (nHeight < 50 || nHeight > 255) {
        NSLog(@"%@", @"身高超过50到255cm的限制");
        handerBodyState(NO);
        return;
    }
    if (nAge < 5 || nAge > 120) {
        NSLog(@"%@", @"年龄超过5到120的限制");
        handerBodyState(NO);
        return;
    }
    
    [self connectDevice:^(BOOL success) {
        if (success) {
            Byte commandBytes[] = {
                0,  //组号
                (Byte)bBoy,  //性别: 1男; 0 女
                0,  //运动员级别: 0 表示为普通 =1 表示为业余 =2 表示为专业
                (Byte)nHeight,  //身高: 50-255CM
                (Byte)nAge,  //年龄: 5-120 岁
                1,  //单位: 01 表示 KG; 02 表示 LB; 04 表示 ST:LB
                0, 0, 0, 0, 0, 0, 0, 0};    //后八位保留
            NSData *commandData = [NSData dataWithBytes:commandBytes length:14];
            [self.hardware sendCommand:kWeightCommandData withData:commandData response:^(BOOL success, NSData *data) {
                if (success) {
                    //打印出来
                    NSString *strData = [ArthurHexOperation NSDataToHexString:data];
                    NSLog(@"获取到的数据:\n%@\n", strData);
                    
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"获取身体数据成功");                    
                    Byte *dataBytes = (Byte*)[data bytes];
                    
                    //TODO: 0x31与0x33都可能是错误的
                    //判断方式应改进: 用长度加内容更好
                    //FD 31 00 00 00 00 00 31
                    //FD 33 00 00 00 00 00 33
                    if ([data length] == 8) {
                        handerBodyState(NO);
                    } else {
                        self.fWeightInKG = (float)([ArthurByteOperation combineBytesHight:dataBytes[4] andLow:dataBytes[5]]) / 10.0f;
                        self.fFatPercent = (float)([ArthurByteOperation combineBytesHight:dataBytes[6] andLow:dataBytes[7]]) / 10.0f;
                        self.fSkeletonPercent = (int)(dataBytes[8]) / 10.0f / self.fWeightInKG;
                        self.fMusclePercent = (float)([ArthurByteOperation combineBytesHight:dataBytes[9] andLow:dataBytes[10]]) / 10.0f;
                        self.nFatLevel = (int)(dataBytes[11]);
                        self.fWaterPercent = (float)([ArthurByteOperation combineBytesHight:dataBytes[12] andLow:dataBytes[13]]) / 10.0f;
                        self.nCalories = [ArthurByteOperation combineBytesHight:dataBytes[14] andLow:dataBytes[15]];
                        
                        handerBodyState(YES);
                    }
                } else {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"获取身体数据失败");
                    handerBodyState(NO);
                }
                
            }];
        } else {
            NSLog(@"%@", @"设备未连接");
            handerBodyState(NO);
        }
    }];
}

@end
