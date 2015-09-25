//
//  DeviceTreadmill.m
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceTreadmill.h"
#import "DeviceTreadmillCommandMap.h"

@implementation DeviceTreadmill

#pragma mark
#pragma mark 初始化
- (void)initializeDeviceWithHardware:(HardwareBase *)hardware
{
    [super initializeDeviceWithHardware:hardware];
}

- (void)dealloc
{

}

#pragma mark
#pragma mark 函数: 命令
//搜索跑步机
- (void)searchThradmill:(onCallBack)handerSearchThreadmill
{
    [self.hardware searchDevice:^(BOOL success) {
        if (success) {
            self.arrSearchedDevice = [self.hardware.arrSearchedDevice copy];
        }
        handerSearchThreadmill(success);
    }];
}

//连接设备
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

//设置体重
- (void)setWeight:(int)nWeight onCallBack:(onCallBack)handerCallBack
{
    [self connectDevice:^(BOOL success) {
        if (success) {
            Byte commandBytes[] = {0, 0, 0, 0, 0, 0, (Byte)nWeight, 0, 0, 0, 0, 0, 0, 0};
            NSData *commandData = [NSData dataWithBytes:commandBytes length:14];
            [self.hardware sendCommand:kThreadmillCommandAddUser withData:commandData response:^(BOOL success, NSData *data) {
                if (success) {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"设置体重成功");
                } else {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"设置体重失败");
                }
                handerCallBack(success);
            }];
        } else {
            handerCallBack(NO);
        }
    }];
}

//擦除数据
- (void)eraseData:(onCallBack)handerEraseData
{
    [self connectDevice:^(BOOL success) {
        if (success) {
            [self.hardware sendCommand:kThreadmillCommandEraseData withData:nil response:^(BOOL success, NSData *data) {
                if (success) {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"清空数据成功");
                } else {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"清空数据失败");
                }
                handerEraseData(success);
            }];
        } else {
            handerEraseData(NO);
        }
    }];
}

//开始初始化设备
- (void)startInitializeDevice:(onCallBack)handerStartInitializeDevice
{
    [self connectDevice:^(BOOL success) {
        if (success) {
            Byte commandBytes[] = {0x01, 0, 0};
            NSData *commandData = [NSData dataWithBytes:commandBytes length:3];
            [self.hardware sendCommand:kThreadmillCommandSetState withData:commandData response:^(BOOL success, NSData *data) {
                if (success) {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"初始化设备成功");
                } else {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"初始化设备失败");
                }
                handerStartInitializeDevice(success);
            }];
        } else {
            handerStartInitializeDevice(NO);
        }
    }];
}

//结束初始化设备
- (void)endInitializeDevice:(onCallBack)handerDndInitializeDevice
{
    [self connectDevice:^(BOOL success) {
        if (success) {
            Byte commandBytes[] = {0x02, 0, 0};
            NSData *commandData = [NSData dataWithBytes:commandBytes length:3];
            [self.hardware sendCommand:kThreadmillCommandSetState withData:commandData response:^(BOOL success, NSData *data) {
                if (success) {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"结束初始化设备成功");
                } else {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"结束初始化设备失败");
                }
                handerDndInitializeDevice(success);
            }];
        } else {
            handerDndInitializeDevice(NO);
        }
    }];
}

//获取运动数据
- (void)getThreadmillData:(onCallBack)handerGetThreadmillData
{
    [self connectDevice:^(BOOL success) {
        if (success) {
            [self.hardware sendCommand:kThreadmillCommandGetData withData:nil response:^(BOOL success, NSData *data) {
                if (success) {
//                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"获取跑步机数据成功");
                    Byte *dataBytes = (Byte*)[data bytes];
                    self.fSpeed = (float)([ArthurByteOperation combineBytesHight:dataBytes[0] andLow:dataBytes[1]])/10.0f;
                    self.fDistance = [ArthurByteOperation combineBytesHight:dataBytes[2] andLow:dataBytes[3]];
                    self.fTotalCal = (float)([ArthurByteOperation combineBytesHight:dataBytes[4] andLow:dataBytes[5]])/10.0f;
                } else {
                    ConditionLog(bInVirtualDeviceDebug, @"%@", @"获取跑步机数据失败");
                }
                handerGetThreadmillData(success);
            }];
        } else {
            handerGetThreadmillData(NO);
        }
    }];
}

@end
