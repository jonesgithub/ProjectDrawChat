//
//  DeviceBase.m
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DeviceBase.h"

@implementation DeviceBase

- (void)initializeDeviceWithHardware:(HardwareBase *)hardware
{
    self.hardware = hardware;
    self.hardware.deviceDelegate = self;
}

- (void)dealloc
{
    [self.hardware cleanState];
    self.hardware.deviceDelegate = nil;
    self.hardware = nil;
}

#pragma mark
#pragma mark DeviceDelegate
//设备连接断开
- (void)deviceDisconnected
{
    self.bDeviceConected = NumberNO;
}

@end
