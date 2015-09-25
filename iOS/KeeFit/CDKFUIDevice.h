//
//  CDKFUIDevice.h
//  KeeFit
//
//  Created by lichen on 6/27/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDeviceImageSuffixDescription @"_描述.png"    //用于My Device中的描述
#define kDeviceImageSuffixIndication @"_指示.png"      //用于主界面，指示已绑定设备
#define kDeviceImageSuffixSearching @"_搜索.png"      //用于搜索界面，找到设备时显示的图

@interface CDKFUIDevice : NSObject


+ (CDKFUIDevice *) Instance; 
+ (id)allocWithZone:(NSZone *)zone;
- (void)initSingleton;

//与上面的plist一一对应
@property (nonatomic, strong) NSMutableDictionary *dicDeviceType;
@property (nonatomic, strong) NSMutableDictionary *dicDeviceName;
@property (nonatomic, strong) NSMutableDictionary *dicDeviceDescription;
@property (nonatomic, strong) NSMutableDictionary *dicDeviceImagePrefix;

//以文字描述的设备类型
- (NSString *)deviceType:(NSString *)strTypeID;
//国际化的设备名称
- (NSString *)deviceName:(NSString *)strTypeID;
//国际化的设备描述
- (NSString *)deviceDescription:(NSString *)strTypeID;
//设备的各种图片
- (UIImage *)deviceImage:(NSString *)strTypeID withSuffix:(NSString *)strSuffix;

@end
