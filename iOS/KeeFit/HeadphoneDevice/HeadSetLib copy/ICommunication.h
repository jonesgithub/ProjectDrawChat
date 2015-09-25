//
//  ICommunication.h
//  CodoonSport
//
//  Created by sky on 13-10-15.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICommunication <NSObject>

@optional
- (void) connectCommand: (SEL) callback byTarget: (id)target;
- (void) obtainTypeAndVersion: (SEL) callback byTarget: (id)target;
- (void) obtainDeviceID: (SEL) callback byTarget: (id)target;
- (void) obtainUserInfo: (SEL) callback byTarget: (id)target;
- (void) obtainDeviceInfo: (SEL) callback byTarget: (id)target;
- (void) setUserInfo: (SEL) callback byTarget: (id)target;
- (void) setAlertAlarmInfo: (SEL) callback byTarget: (id)target;
- (void) setDeviceTime: (SEL) callback byTarget: (id)target;
- (void) obtainDeviceTime: (SEL) callback byTarget: (id)target;
- (void) obtainSportsData: (SEL) callback byTarget: (id)target;
- (void) clearSportsData: (SEL) callback byTarget: (id)target;

- (BOOL) isDeviceBond;

- (void) cancelConnection;

@end
