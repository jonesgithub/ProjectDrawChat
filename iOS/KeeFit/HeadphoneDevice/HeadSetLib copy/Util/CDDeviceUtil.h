//
//  CDDeviceUtil.h
//  CodoonSport
//
//  Created by lian on 13-12-25.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDeviceUtil : NSObject

+ (NSData *) appendDataWithValidByte: (NSData *)data;
+ (NSData *) timeCommandData;
+ (NSData *) blTimeCommandData;
+ (NSData *) userInfoCommandData;
+ (NSData *) ringInfoCommandData;
+ (NSString *) generateDeviceIDFromData: (NSData *)data;
+ (NSString *) generateDeviceHardVersionFromData:(NSData *)data;

@end
