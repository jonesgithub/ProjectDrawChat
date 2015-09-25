//
//  ArthurApp.m
//  KeeFit
//
//  Created by lichen on 6/22/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurApp.h"

@implementation ArthurApp


+ (NSString *)appVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)appBundleVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleVersion"];
}

//获取属性列表
+ (NSMutableDictionary *)plistWithFileName:(NSString *)strFileName
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:strFileName ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    AssertClass(data, NSMutableDictionary);
    return data;
}

//系统版本号
+ (float)systmeVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end
