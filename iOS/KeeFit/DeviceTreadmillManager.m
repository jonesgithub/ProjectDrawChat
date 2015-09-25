//
//  DeviceTreadmillManager.m
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceTreadmillManager.h"


@implementation DeviceTreadmillManager

+ (DeviceTreadmill *)createDeviceThreadmillWithBroadcastID:(NSString *)strBroadcastID
{
    //初始化蓝牙硬件
    HardwareBluetooth *bluetoothHardware = [[HardwareBluetooth alloc] init];
    
    //蓝牙连接参数
//    NSArray *arrDeviceNames = @[@"COD_PBJ"];
//    [bluetoothHardware setScanRangeWithNames:arrDeviceNames Service:@"180F" characteristics:@"2A19"];
//    [bluetoothHardware setBroadcastId:strBroadcastID];
//    [bluetoothHardware setStartCommand:0x68];
    
    DeviceTreadmill *treadmill = [[DeviceTreadmill alloc] init];
    
    [treadmill initializeDeviceWithHardware:bluetoothHardware];
    
    return treadmill;
}

+ (DeviceTreadmill *)createDeviceThreadmill
{
    //初始化蓝牙硬件
    HardwareBluetooth *bluetoothHardware = [[HardwareBluetooth alloc] init];
    
//    //蓝牙连接参数
//    NSArray *arrDeviceNames = @[@"COD_PBJ"];
//    [bluetoothHardware setScanRangeWithNames:arrDeviceNames Service:@"180F" characteristics:@"2A19"];
//    [bluetoothHardware setStartCommand:0x68];
    
    DeviceTreadmill *treadmill = [[DeviceTreadmill alloc] init];
    
    [treadmill initializeDeviceWithHardware:bluetoothHardware];
    
    return treadmill;
}

@end
