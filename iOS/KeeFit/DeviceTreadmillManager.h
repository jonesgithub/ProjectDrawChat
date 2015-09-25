//
//  DeviceTreadmillManager.h
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceTreadmill.h"
#import "HardwareBluetooth.h"

@interface DeviceTreadmillManager : NSObject

//产生跑步机设备: 主要用于搜索设备
+ (DeviceTreadmill *)createDeviceThreadmill;

//产生跑步机设备: 用于与真实设备通信
+ (DeviceTreadmill *)createDeviceThreadmillWithBroadcastID:(NSString *)strBroadcastID;

@end
