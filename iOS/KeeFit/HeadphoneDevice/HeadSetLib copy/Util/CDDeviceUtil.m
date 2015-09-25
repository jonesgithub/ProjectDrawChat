//
//  CDDeviceUtil.m
//  CodoonSport
//
//  Created by lian on 13-12-25.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//

#import "CDDeviceUtil.h"
//#import "CDDateUtil.h"
//#import "CDAccountDBManager.h"
//#import "DBDeviceConfigureManager.h"
//#import "CDAccountManager.h"

#define BCD_X(x) ((x/10)*16+(x%10))

@implementation CDDeviceUtil

+ (Byte) validByteOfByteArray: (NSData *)bytesData{
    Byte *bytes = (Byte *)[bytesData bytes];
    Byte validByte = 0x00;
    for (int i = 0; i < bytesData.length; i++) {
        Byte commandByte = bytes[i];
        validByte += commandByte;
    }
    return validByte;
}

+ (NSData *) appendDataWithValidByte: (NSData *)data{
    Byte validByte = [self validByteOfByteArray:data];
    NSData *validData = [NSData dataWithBytes:&validByte length:1];
    NSMutableData *mutableData = [NSMutableData dataWithData:data];
    [mutableData appendData:validData];
    return [NSData dataWithData:mutableData];
}

+ (NSData *) timeCommandData{
//    NSDateComponents *dateComponents = [CDDateUtil dateComponentsFromDate :[NSDate date]];
//    int weekDay = dateComponents.weekday;
//    if (weekDay == 1) {
//        weekDay = 6;
//    }else{
//        weekDay = weekDay - 2;
//    }
//    Byte bytes[] = {0xAA, 0x0a, 0x07, BCD_X(dateComponents.year%100), BCD_X(dateComponents.month), BCD_X(dateComponents.day), BCD_X(dateComponents.hour), BCD_X(dateComponents.minute), BCD_X(dateComponents.second), weekDay};
//    return [NSData dataWithBytes:bytes length:10];
    return nil;
}

+ (NSData *) blTimeCommandData{
//    NSDateComponents *dateComponents = [CDDateUtil dateComponentsFromDate :[NSDate date]];
//    Byte bytes[] = {0xAA, 0x0a, 0x06, BCD_X(dateComponents.year%100), BCD_X(dateComponents.month), BCD_X(dateComponents.day), BCD_X(dateComponents.hour), BCD_X(dateComponents.minute), BCD_X(dateComponents.second)};
//    return [NSData dataWithBytes:bytes length:9];
    return nil;
}

+ (NSData *) userInfoCommandData{
//    CDAccount *currentUser = [CDAccountManager currentUser];
//    int height = currentUser.height;
//    int weight = currentUser.weight;
//    int gender = currentUser.gender;
//    
//    int goalTypeLocal = currentUser.weekGoalType;
//    int goalValueLocal = currentUser.weekGoalValue/7.0;
//    
//    int goalTypeForDevice = -1;
//    //步数
//    if (goalTypeLocal == GoalTypeSteps) {
//        goalTypeForDevice = 1;
//    }else if(goalTypeLocal == GoalTypeMeters){ //米数
//        goalTypeForDevice = 2;
//    }else { //卡路里
//        goalTypeForDevice = 0;
//    }
//    
//    int goalValueHigh = goalValueLocal / 256;
//    int goalValueLow = goalValueLocal % 256;
//    
//    int strideLength = (int)(height * 0.39);
//    int runStrideLength = (int)(height * 0.39 * 1.2);
//    
//    
//    //    Byte *bytes = (Byte *)[data bytes];
//    
//    Byte bytesForDevice[] = {0xAA, 0x05, 0x0e, height, weight, 0x00, gender, strideLength, runStrideLength, strideLength, 0x00, goalTypeForDevice, goalValueHigh, goalValueLow, 0x02, 0x0a, 0x0a};
//    return [NSData dataWithBytes:bytesForDevice length:17];
    return nil;
}

+ (NSData *) ringInfoCommandData{
//    NSDictionary *sportsRemindDictionary = [DBDeviceConfigureManager deviceConfigureDictionaryOfConfigueCategory:DeviceConfigueCategoryRemind];
//    NSDictionary *noopsycheClockDictionary = [DBDeviceConfigureManager deviceConfigureDictionaryOfConfigueCategory:DeviceConfigueCategoryAlarm];
//    
//    //活动提醒提取
//    int alertStartHour = BCD_X([sportsRemindDictionary[@"start_time"] intValue]);
//    int alertStopHour = BCD_X([sportsRemindDictionary[@"stop_time"] intValue]);
//    int space_minutes = [sportsRemindDictionary[@"space_time"] intValue];
//    
//    int isAlert;
//    if ([sportsRemindDictionary[@"remindSwitch"] intValue] > 0) {
//        isAlert = 0x7f;
//    }else{
//        isAlert = 0x00;
//    }
//    
//    NSArray *alertDaysArray = sportsRemindDictionary[@"week_day_array"];
//    
//    Byte alertDaysMaskByte = 0;
//    
//    for(int i = 0; i < 7; i++){
//        if ([alertDaysArray[i] intValue] == 1) {
//            alertDaysMaskByte |= (0x01 << i);
//        }
//    }
//    
//    //智能闹钟提取
//    NSString *wake_time_str = noopsycheClockDictionary[@"start_time"];
//    int wakeHour = BCD_X([[wake_time_str componentsSeparatedByString:@":"][0] intValue]);
//    int wakeMinute = BCD_X([[wake_time_str componentsSeparatedByString:@":"][1] intValue]);
//    
//    int wake_region = [noopsycheClockDictionary[@"awaken_time"] intValue];
//    
//    int isClockOn;
//    if ([noopsycheClockDictionary[@"block_Switch"] intValue] > 0) {
//        isClockOn = 0x7f;
//    }else{
//        isClockOn = 0x00;
//    }
//    
//    NSArray *clockDaysArray = noopsycheClockDictionary[@"week_day_array"];
//    
//    Byte clockDaysMaskByte = 0;
//    
//    for(int i = 0; i < 7; i++){
//        if ([clockDaysArray[i] intValue] == 1) {
//            clockDaysMaskByte |= (0x01 << i);
//        }
//    }
//    
//    int isWakeRegionValid;
//    if (wake_region == 0) {
//        isWakeRegionValid = 0x00;
//    }else{
//        isWakeRegionValid = 0x7f;
//    }
//    
//    Byte bytesForDevice[] = {0xAA, 0x06, 0x0d, (Byte)alertStartHour, (Byte)alertStopHour, space_minutes, alertDaysMaskByte, isAlert, wakeHour, wakeMinute, wake_region, clockDaysMaskByte, isWakeRegionValid, isClockOn, 0x00, 0x00};
//    return [NSData dataWithBytes:bytesForDevice length:16];
    
    return nil;
}

+ (NSString *) generateDeviceIDFromData: (NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *productId = [NSString stringWithFormat:@"%d-%d-%d-%d-%d-%d-%d-%d", bytes[0], (bytes[1]<<8) + bytes[2], (bytes[3]<<8) + bytes[4], (bytes[5]<<8) + bytes[6], bytes[7], (bytes[8] << 8) + bytes[9], (bytes[10]<<8) + bytes[11], bytes[12]];
    return productId;
}

+ (NSString *) generateDeviceHardVersionFromData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hardVersion = [NSString stringWithFormat:@"%d.%d", bytes[1], bytes[2]];
    return hardVersion;
}

@end
