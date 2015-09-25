//
//  ArthurUnitChange.m
//  KeeFit
//
//  Created by lichen on 5/29/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurUnitChange.h"

@implementation ArthurUnitChange

//千克与磅的转换
+ (float)kg2lb:(float)fkg
{
    return fkg * kKg2LbRatio;
}

+ (float)lb2kg:(float)flb
{
    return flb / kKg2LbRatio;
}

//厘米与英尺的转换
+ (float)cm2feet:(float)fcm
{
    return fcm / kFeet2Cm;
}

+ (float)feet2cm:(float)ffeet
{
    return ffeet * kFeet2Cm;
}


@end
