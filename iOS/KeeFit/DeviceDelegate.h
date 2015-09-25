//
//  DeviceDelegate.h
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DeviceDelegate <NSObject>

//设备连接断开
- (void)deviceDisconnected;

@end
