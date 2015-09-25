//
//  CDKFDeviceManager.h
//  KeeFit
//
//  Created by lichen on 6/18/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceSportSleep.h"
#import "HardwareBluetooth.h"
//#import "CDKFHeadphoneDevice.h"

//绑定的设备类型
#define kDataManagerBindedDeviceType                       @"kDataManagerBindedDeviceType"
#define kDataManagerBindedDeviceTypeBluetooth       @"kDataManagerBindedDeviceTypeBluetooth"
#define kDataManagerBindedDeviceTypeHeadphone     @"kDataManagerBindedDeviceTypeHeadphones"

//绑定设备ID与Version
#define kDataManagerBindedDeviceId          @"kDataManagerBindedDeviceId"
#define kDataManagerBindedDeviceVersion @"kDataManagerBindedDeviceVersion"


//typedef void (^onCallBack)(BOOL success);

@interface CDKFDeviceManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *dicDeviceMap;              //设备名列表
@property (nonatomic, strong) NSMutableDictionary *dicDeviceImageMap;    //设备图片列表
@property (nonatomic, strong) NSMutableDictionary *dicDeviceBindedImageMap;    //绑定页面显示的图的列表

@property (nonatomic, strong) NSNumber *bInBindDevice;          //是否正在绑定
@property (nonatomic, strong) NSNumber *bDeviceBinded;          //是否已经绑定设备

@property (nonatomic, strong) NSString *strBinedDeviceType;               //已绑定设备类型

//已绑定的设备
@property (nonatomic, strong) DeviceSportSleep *bindedDevice;

//单体方法
+ (CDKFDeviceManager *) Instance;
+ (id)allocWithZone:(NSZone *)zone;

//获取已链接的设备
+ (DeviceSportSleep *) theBindedDevice;

//初始化状态
- (void)initializeState;

//绑定\解除绑定
- (void)bindDevice:(onCallBack)handerBindDevice;
//取消绑定
- (void)cancelBindDevice;
//解除绑定
- (void)unbindDevice;

//绑定设备的类型ID
- (NSString *)bindedDeviceTypeID;

//定时同步
@property (nonatomic, strong) NSTimer *timerOfCircleSynDeviceData;
- (void)circleSynDeviceData;

@end
