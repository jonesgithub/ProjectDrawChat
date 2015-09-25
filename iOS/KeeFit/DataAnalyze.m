//
//  DataAnalyze.m
//  HardwareCommunication
//
//  Created by lichen on 7/15/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "DataAnalyze.h"

@implementation DataAnalyze

//length是数据的单位长度
-(NSArray*) executeData:(NSData*)data withLength:(int)length{
    self.dataBuffer = data;
    
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:145];
    int totalCount = (int)[data length];
    int state = 0;
    for (int idx=0; idx<totalCount-length; idx+=length) {
        NSData *frameData = [data subdataWithRange:NSMakeRange(idx, length)];
        NSDictionary *frameDict = [self executeFrameData:frameData withState:state];
        if ([[frameDict objectForKey:KEYTYPE] intValue]==DATAHEADERFRMAE ) {
            state = DATATIMEFRAME;
            continue;
        }
        if ([[frameDict objectForKey:KEYTYPE] intValue]==SLEEPHEADER ) {    //TODO: 无sleep header的返回
            state = SLEEPTIMEFRAME;
            continue;
        }
        if ([[frameDict objectForKey:KEYTYPE] intValue]==DATATIMEFRAME ) {
            state = DATAFRAME;
        }
        if ([[frameDict objectForKey:KEYTYPE] intValue]==SLEEPTIMEFRAME ) {
            state = SLEEPDATA;
        }
        [frames addObject:frameDict];
    }
    return [frames copy];
}

-(NSDictionary*)executeFrameData:(NSData*)frame withState:(int)state{
    Byte headerBytes[] = {0xfe,0xfe,0xfe,0xfe,0xfe,0xfe};
    if ([[NSData dataWithBytes:headerBytes length:6] isEqualToData:frame]) {
        //        change @"type" to KEYTYPE by lichen at 2016.05.16
        return @{KEYTYPE:@(DATAHEADERFRMAE)};
    }
    Byte sleepBytes[] = {0xfd,0xfd,0xfd,0xfd,0xfd,0xfd};
    if ([[NSData dataWithBytes:sleepBytes length:6] isEqualToData:frame]) {
        //        change by lichen at 2014.05.20
        //        return @{KEYTYPE:@(DATAHEADERFRMAE)};
        return @{KEYTYPE:@(SLEEPHEADER)};
    }
    if (state == DATATIMEFRAME || state == SLEEPTIMEFRAME) {
        Byte *bytes = (Byte*)[frame bytes];
        int year = 2000 + BCD_Y(bytes[1]);
        int month = BCD_Y(bytes[2]);
        int day = BCD_Y(bytes[3]);
        int hour = BCD_Y(bytes[4]);
        int minute = BCD_Y(bytes[5]);
        return @{KEYTYPE:@(state), KEYYEAR:@(year), KEYMONTH:@(month), KEYDAY:@(day), KEYHOUR:@(hour), KEYMINUTE:@(minute), KEYSECOND:@(0)};
    }
    if (state == DATAFRAME) {
        Byte *bytes = (Byte*)[frame bytes];
        int steps = [ArthurByteOperation combineBytesHight:bytes[0] andLow:bytes[1]];
        int cal = [ArthurByteOperation combineBytesHight:bytes[2] andLow:bytes[3]];
        int dis = [ArthurByteOperation combineBytesHight:bytes[4] andLow:bytes[5]];
        return @{KEYTYPE:@(DATAFRAME), KEYSTEPS:@(steps), KEYKCAL:@(cal), KEYDIS:@(dis)};
    }
    if (state == SLEEPDATA) {
        Byte *bytes = (Byte*)[frame bytes];
        int v1 = [ArthurByteOperation combineBytesHight:bytes[0] andLow:bytes[1]];
        int v2 = [ArthurByteOperation combineBytesHight:bytes[2] andLow:bytes[3]];
        int v3 = [ArthurByteOperation combineBytesHight:bytes[4] andLow:bytes[5]];
        return @{KEYTYPE:@(SLEEPDATA), KEYDATA: @[@(v1),@(v2),@(v3)]};
    }
    return @{};
}


-(NSDictionary*) extandsToitems:(NSArray*)frames{
    int state = -1;
    NSDate *baseDate;
    NSMutableDictionary *dayItems = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sleepItems = [[NSMutableDictionary alloc] init];
    int totalCal = 0;
    int totalStep = 0;
    int totalDis = 0;
    int idxOffset = 0;
    for (NSDictionary *frame in frames) {
        int frameType = [[frame objectForKey:KEYTYPE] intValue];
        if (frameType==DATATIMEFRAME) {
            state = DATAFRAME;
            baseDate = [self makeDate:frame];
            idxOffset = 0;
            continue;
        }
        if (frameType==SLEEPTIMEFRAME) {
            state = SLEEPDATA;
            baseDate = [self makeDate:frame];
            idxOffset = 0;
            continue;
        }
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        //        当前时间 = 开始一种活动的基础时间 + index
        NSDate *currentDate = [baseDate dateByAddingTimeInterval:idxOffset*600];
        NSString *dateString = [formatter stringFromDate:currentDate];
        //        以10分钟为单位来算index，运动记录10分钟为单位，睡眠为200秒为单位，即10/3分钟
        int itemFrameIdx = [self makeIdex:currentDate];
        //        NSLog(@"data idx %@", @(itemFrameIdx));
        if (frameType==DATAFRAME) {
            NSDictionary *dayitem = [dayItems objectForKey:dateString];
            if (dayitem) {
                NSMutableDictionary *tempData = [dayitem mutableCopy];
                NSMutableArray *steps = [[dayitem objectForKey:KEYSTEPS] mutableCopy];
                NSMutableArray *kcals = [[dayitem objectForKey:KEYKCAL] mutableCopy];
                NSMutableArray *dis = [[dayitem objectForKey:KEYDIS] mutableCopy];
                //                为什么相加?
                //                steps[itemFrameIdx] = @([[frame objectForKey:KEYSTEPS] intValue]+[steps[itemFrameIdx] intValue]);
                //                kcals[itemFrameIdx]= @([[frame objectForKey:KEYKCAL] intValue] + [kcals[itemFrameIdx] intValue]);
                //                dis[itemFrameIdx]= @([[frame objectForKey:KEYDIS] intValue] + [dis[itemFrameIdx] intValue]);
                //改成直接设值
                steps[itemFrameIdx] = @([[frame objectForKey:KEYSTEPS] intValue]);
                kcals[itemFrameIdx]= @([[frame objectForKey:KEYKCAL] intValue]);
                dis[itemFrameIdx]= @([[frame objectForKey:KEYDIS] intValue]);
                
                totalStep+=[steps[itemFrameIdx] intValue];
                totalCal+=[kcals[itemFrameIdx] intValue];
                totalDis+= [dis[itemFrameIdx] intValue];
                [tempData setValue:steps forKey:KEYSTEPS];
                [tempData setValue:kcals forKey:KEYKCAL];
                [tempData setValue:dis forKey:KEYDIS];
                [dayItems setValue:[tempData copy] forKeyPath:dateString];
            }else{
                NSMutableArray *steps = [[NSMutableArray alloc] initWithArray:[self newDayitem]];
                NSMutableArray *kcals = [[NSMutableArray alloc] initWithArray:[self newDayitem]];
                NSMutableArray *dis = [[NSMutableArray alloc] initWithArray:[self newDayitem]];
                steps[itemFrameIdx]=[frame objectForKey:KEYSTEPS];
                kcals[itemFrameIdx]=[frame objectForKey:KEYKCAL];
                dis[itemFrameIdx]=[frame objectForKey:KEYDIS];
                dayitem = @{
                            KEYSTEPS: steps,
                            KEYKCAL: kcals,
                            KEYDIS:dis
                            };
                [dayItems setValue:dayitem forKeyPath:dateString];
            }
            idxOffset++;
        }
        if (frameType==SLEEPDATA) {
            NSArray *sleepitem = [sleepItems objectForKey:dateString];
            NSArray *data = [frame objectForKey:KEYDATA];
            //            TODO: if里面内容抽出相同内容
            if (sleepitem) {
                NSMutableArray *dataArray = [sleepitem mutableCopy];
                dataArray[itemFrameIdx*3] = data[0];
                dataArray[itemFrameIdx*3+1] = data[1];
                dataArray[itemFrameIdx*3+2] = data[2];
                //                fix a bug by lichen at 2014.05.16
                //                [sleepitem setValue:[dataArray copy] forKeyPath:dateString];
                [sleepItems setValue:[dataArray copy] forKeyPath:dateString];
            }else{
                NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:[self newSleepitem]];
                dataArray[itemFrameIdx*3] = data[0];
                dataArray[itemFrameIdx*3+1] = data[1];
                dataArray[itemFrameIdx*3+2] = data[2];
                //                fix a bug by lichen at 2014.05.16
                //                [sleepitem setValue:[dataArray copy] forKeyPath:dateString];
                [sleepItems setValue:[dataArray copy] forKeyPath:dateString];
            }
            idxOffset++;
        }
    }
    NSLog(@"step %d cal %d dis %d", totalStep, totalCal, totalDis);
    //    有临时原始数据，加密后带上
    if (self.dataBuffer) {
        //        NSLog(@"buffer :%@", self.dataBuffer);
        return @{
                 kAllStep:@(totalStep), 
                 kAllCal:@(totalCal), 
                 kAllDistance:@(totalDis), 
                 KEYSPORT:dayItems, 
                 KEYSLEEP:sleepItems, 
                 KEYRAWDATA:[self encryptData]};
    } else {
        return @{
                 kAllStep:@(totalStep), 
                 kAllCal:@(totalCal), 
                 kAllDistance:@(totalDis), 
                 KEYSPORT:dayItems, 
                 KEYSLEEP:sleepItems, 
                 KEYRAWDATA:[[NSData alloc] init]};
    }
}

-(NSArray*) newDayitem{
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:144];
    for (int i=0; i<144; i++) {
        [dataArray addObject:@(-1)];
    }
    return [dataArray copy];
}

-(NSArray*) newSleepitem{
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:144*3];
    for (int i=0; i<144*3; i++) {
        [dataArray addObject:@(-1)];
    }
    return [dataArray copy];
}

-(NSDate*) makeDate:(NSDictionary*)frame{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:[[frame objectForKey:KEYYEAR] intValue]];
    [components setMonth:[[frame objectForKey:KEYMONTH] intValue]];
    [components setDay:[[frame objectForKey:KEYDAY] intValue]];
    [components setHour:[[frame objectForKey:KEYHOUR] intValue]];
    [components setMinute:[[frame objectForKey:KEYMINUTE] intValue]];
    [components setSecond:[[frame objectForKey:KEYSECOND] intValue]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3600*8]];
    return [calendar dateFromComponents:components];
}


- (NSDateComponents *)dateComponentsFromDate: (NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekCalendarUnit|
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    return comps;
}

//根据时间来算出该内容落在哪个区间(index)，每个区间10分钟，一天一共144个
-(int) makeIdex:(NSDate*)currentDate{
    NSDateComponents *comps = [self dateComponentsFromDate:currentDate];
    return (int)(comps.hour*60+comps.minute)/10;
}



//加密数据
-(NSData*) encryptData{
    //    TODO: 把加密串抽出去
    Byte password[] = {0x54, 0x91, 0x28, 0x15, 0x57, 0x26};
    NSMutableData *encryptedData = [[NSMutableData alloc] initWithCapacity:[self.dataBuffer length]];
    for (int start=0; start<[self.dataBuffer length]-6; start+=6) {
        Byte *bytes = (Byte*)[[self.dataBuffer subdataWithRange:NSMakeRange(start, 6)] bytes];
        bytes[0] = bytes[0]^password[0];
        bytes[1] = bytes[1]^password[1];
        bytes[2] = bytes[2]^password[2];
        bytes[3] = bytes[3]^password[3];
        bytes[4] = bytes[4]^password[4];
        bytes[5] = bytes[5]^password[5];
        [encryptedData appendBytes:bytes length:6];
    }
    return [encryptedData copy];
}

@end
