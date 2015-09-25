//
//  DataAnalyze.h
//  HardwareCommunication
//
//  Created by lichen on 7/15/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BCD_X(x) ((x/10)*16+(x%10))
#define BCD_Y(y) ((y/16)*10+(y%16))
#define DATAHEADERFRMAE 0
#define DATATIMEFRAME 1
#define DATAFRAME 2
#define SLEEPHEADER 3
#define SLEEPTIMEFRAME 4
#define SLEEPDATA 5
#define KEYYEAR @"year"
#define KEYMONTH @"month"
#define KEYDAY @"day"
#define KEYHOUR @"hour"
#define KEYMINUTE @"minute"
#define KEYSECOND @"second"
#define KEYSTEPS @"steps"
#define KEYKCAL @"kcal"
#define KEYDIS @"dis"
#define KEYTYPE @"type"
#define KEYDATA @"data"
#define KEYSPORT @"sport"
#define KEYSLEEP @"sleep"
#define KEYRAWDATA @"rawdata"
#define kAllStep @"kAllStep"
#define kAllCal @"kAllCal"
#define kAllDistance @"kAllDistance"


@interface DataAnalyze : NSObject

@property (nonatomic, strong) NSData *dataBuffer;
-(NSArray*) executeData:(NSData*)data withLength:(int)length;
-(NSDictionary*) extandsToitems:(NSArray*)frames;

@end
