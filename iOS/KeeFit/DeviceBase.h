//
//  DeviceBase.h
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDelegate.h"

typedef void (^onCallBack)(BOOL success);

@interface DeviceBase : NSObject <DeviceDelegate>

@property (nonatomic, strong) NSNumber *bDeviceConected;   //设备是否正处于连接状态
@property (nonatomic, strong) HardwareBase *hardware;  //硬件: 可能是蓝牙，可能是音频
@property (nonatomic, strong) NSArray *arrSearchedDevice;   //搜索到的设备

- (void)initializeDeviceWithHardware:(HardwareBase *)hardware;

@end
