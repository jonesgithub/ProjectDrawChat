//
//  ArthurApp.h
//  KeeFit
//
//  Created by lichen on 6/22/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArthurApp : NSObject

//应用程序版本、名字、bundle
+ (NSString *)appVersion;
+ (NSString *)appName;
+ (NSString *)appBundleVersion;

+ (float)systmeVersion;

//获取属性列表
+ (NSMutableDictionary *)plistWithFileName:(NSString *)strFileName;

@end
