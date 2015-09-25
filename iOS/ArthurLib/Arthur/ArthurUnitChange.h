//
//  ArthurUnitChange.h
//  KeeFit
//
//  Created by lichen on 5/29/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kKg2LbRatio 2.2046226
#define kFeet2Cm 30.48

@interface ArthurUnitChange : NSObject

//千克与磅的转换
+ (float)kg2lb:(float)fkg;
+ (float)lb2kg:(float)flb;
//厘米与英尺的转换
+ (float)cm2feet:(float)fcm;
+ (float)feet2cm:(float)ffeet;


@end
