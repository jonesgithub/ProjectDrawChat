//
//  CDKFUIDevice.m
//  KeeFit
//
//  Created by lichen on 6/27/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "CDKFUIDevice.h"

@implementation CDKFUIDevice

#pragma mark
#pragma mark 单体
static CDKFUIDevice * instance = nil;
+(CDKFUIDevice *) Instance
{
    @synchronized(self) {
        if(nil == instance){
            [self new];
        }
    }
    return instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if(instance == nil){
            instance = [super allocWithZone:zone];
            [instance initSingleton];
            return instance;
        }
    }
    return nil;
}

//必须实现该方法
- (void)initSingleton
{
    self.dicDeviceType = [ArthurApp plistWithFileName:@"DeviceType"];
    self.dicDeviceName = [ArthurApp plistWithFileName:@"DeviceName"];
    self.dicDeviceDescription = [ArthurApp plistWithFileName:@"DeviceDescription"];
    self.dicDeviceImagePrefix = [ArthurApp plistWithFileName:@"DeviceImagePrefix"];
}

//以文字描述的设备类型
- (NSString *)deviceType:(NSString *)strTypeID
{
    NSString *strDeviceType = self.dicDeviceType[strTypeID];
    AssertClass(strDeviceType, NSString);
    return strDeviceType;
}

- (NSString *)deviceDescription:(NSString *)strTypeID
{
    NSString *strDeviceType = [self deviceType:strTypeID];
    NSString *strDeviceDescriptino = self.dicDeviceDescription[strDeviceType];
    AssertClass(strDeviceDescriptino, NSString);
    return strDeviceDescriptino;
}

//国际化的设备名称
- (NSString *)deviceName:(NSString *)strTypeID
{
    NSString *strDeviceType = [self deviceType:strTypeID];
    NSString *strDeviceName = self.dicDeviceName[strDeviceType];
    AssertClass(strDeviceName, NSString);
    return strDeviceName;
}

//设备图片
- (UIImage *)deviceImage:(NSString *)strTypeID withSuffix:(NSString *)strSuffix
{
    //图形前缀
    NSString *strDeviceType = self.dicDeviceType[strTypeID];
    AssertClass(strDeviceType, NSString);
    NSString *strDeviceImagePrefix = self.dicDeviceImagePrefix[strDeviceType];
    AssertClass(strDeviceImagePrefix, NSString);
    
    NSString *strImagePath = [strDeviceImagePrefix stringByAppendingString:strSuffix];
    UIImage *image = [UIImage imageNamed:strImagePath];
    AssertClass(image, UIImage);
    return image;
}


@end
