//
//  CDKFDeviceManager.m
//  KeeFit
//
//  Created by lichen on 6/18/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "CDKFDeviceManager.h"

@implementation CDKFDeviceManager

#pragma mark
#pragma mark 单体方法

static CDKFDeviceManager * instance = nil;
+(CDKFDeviceManager *) Instance
{
    @synchronized(self) {
        if(nil == instance){
            [self new];
            [instance initializeState];
        }
    }
    return instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if(instance == nil){
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

//获取已链接的设备
+ (DeviceSportSleep *)theBindedDevice
{
    CDKFDeviceManager *deviceManager = [self Instance];
    if ([deviceManager.bDeviceBinded boolValue]) {
        if (deviceManager.bindedDevice) {
            return deviceManager.bindedDevice;
        } else {
            if ([deviceManager.strBinedDeviceType isEqualToString:kDataManagerBindedDeviceTypeBluetooth]) {
                HardwareBase *HardwareBase = [[HardwareBluetooth alloc] init];
                deviceManager.bindedDevice = [[DeviceSportSleep alloc] init];
                [deviceManager.bindedDevice initializeDeviceWithHardware:HardwareBase];
                return deviceManager.bindedDevice;
            }
            NSLog(@"%@", @"未知类型");
            return nil;
        }
    } else {
        NSLog(@"%@", @"程序错误，未连接设备时想获取已连接设备");
        return nil;
    }
}

#pragma mark
#pragma mark 初始化设备管理状态: 是否已经绑定、监听程序状态
- (void)initializeState
{
    //是否已绑定
    self.strBinedDeviceType = [MNLib getValueByKey:kDataManagerBindedDeviceType];
    if (nil == self.strBinedDeviceType) {
        self.bDeviceBinded = [[NSNumber alloc] initWithBool:NO];
    } else {
        self.bDeviceBinded = [[NSNumber alloc] initWithBool:YES];
    }
    
    //是否处于绑定过程中
    self.bInBindDevice = [[NSNumber alloc] initWithBool:NO];
    
    //程序进入后台
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(applicationWillResignActive) 
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    //程序进入前台
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(applicationDidBecomeActive) 
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark 函数: 绑定、解除绑定
//绑定入口: 先耳机，后蓝牙
- (void)bindDevice:(onCallBack)handerBindDevice
{
    [self bindDeviceBluetooth:^(BOOL success) {
        if (success) {
            NSLog(@"%@", @"绑定蓝牙成功");
        } else {
            NSLog(@"%@", @"绑定蓝牙失败");
        }
        handerBindDevice(success);
    }];
    
//    //绑定耳机
//    [self bindDeviceHeadset:^(BOOL success) {
//        if (success) {
//            NSLog(@"%@", @"绑定耳机成功");
//            handerBindDevice(YES);
//        } else {
//            //绑定蓝牙
//            [self bindDeviceBluetooth:^(BOOL success) {
//                if (success) {
//                    NSLog(@"%@", @"绑定蓝牙成功");
//                } else {
//                    NSLog(@"%@", @"绑定蓝牙失败");
//                }
//                handerBindDevice(success);
//            }];
//        }
//    }];
}

- (void)cancelBindDevice
{
    //TODO: todo
    NSLog(@"%@", @"程序错误:cancelBindDevice还未完成就在使用");
}

//绑定: 只绑定蓝牙
- (void)bindDeviceBluetooth:(onCallBack)handerBindDevice
{
    if ([self.bInBindDevice boolValue]) {
        NSLog(@"%@", @"Warning: 正在绑定，你还要绑定?");
        return;
    }
    
    //正在绑定
    self.bInBindDevice = [[NSNumber alloc] initWithBool:YES];
    
    //构造一个蓝牙设备
    HardwareBase *HardwareBase = [[HardwareBluetooth alloc] init];
    DeviceSportSleep *virtualDevice = [[DeviceSportSleep alloc] init];
    [virtualDevice initializeDeviceWithHardware:HardwareBase];
    
    [virtualDevice bindDevice:^(BOOL success) {
        if (success) {
            self.bindedDevice = virtualDevice;
            [MNLib setValue:kDataManagerBindedDeviceTypeBluetooth key:kDataManagerBindedDeviceType];
            self.strBinedDeviceType = kDataManagerBindedDeviceTypeBluetooth;
            self.bDeviceBinded = [[NSNumber alloc] initWithBool:YES];
            NSLog(@"%@", @"DeviceManager处绑定成功");
        } else {
            NSLog(@"%@", @"DeviceManager处绑定失败");
        }
        
        //结束绑定
        self.bInBindDevice = NumberNO;
        //处理回调
        handerBindDevice(success);
    }];
}

//绑定: 只绑定耳机
- (void)bindDeviceHeadset:(onCallBack)handerBindDevice
{
    
}

//解除绑定
- (void)unbindDevice
{
    [self.bindedDevice unbindDevice];
    self.bindedDevice = nil;
}

#pragma mark
#pragma mark 函数: 设备类型ID
- (NSString *)bindedDeviceTypeID
{
    return [[self bindedDevice].nDeviceType stringValue];
}

#pragma mark
#pragma mark 函数: 定时同步
- (void)circleSynDeviceData
{
    [self.bindedDevice syn:^(BOOL success) {}];
}

#pragma mark
#pragma mark 事件响应
//程序失去活动状态
- (void)applicationWillResignActive
{
//    [MNLib destroyTimer:self.timerOfCircleSynDeviceData];
}

//程序进入活动状态
- (void)applicationDidBecomeActive
{
//    //定时同步数据
//    self.timerOfCircleSynDeviceData = [NSTimer 
//                           scheduledTimerWithTimeInterval:kCircleSynDataIntervalInMinute * 60
//                           target:self 
//                           selector:@selector(circleSynDeviceData) 
//                           userInfo:nil 
//                           repeats:YES];
}

@end
