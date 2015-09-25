//
//  ArthurByteOperation.m
//  HardwareCommunication
//
//  Created by lichen on 7/14/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurByteOperation.h"

@implementation ArthurByteOperation

#pragma mark
#pragma mark 函数: 类方法
//对数据加上校验和
+ (NSData*)addCheckSum:(NSData*)data
{
    Byte checkSum = [self checkSumOfData:data];
    
    NSMutableData *resultData = [NSMutableData dataWithData:data];
    Byte checkSumBytes[] = {checkSum};
    [resultData appendBytes:checkSumBytes length:1];
    
    return [resultData copy];
}

//算一个Data的check sum
+ (Byte)checkSumOfData:(NSData*)data
{
    Byte checkSum = 0;
    
    Byte *commandBytes = (Byte*)[data bytes];
    for (int idx=0;  idx<[data length]; idx++) {
        checkSum+=commandBytes[idx];
    }
    
    return checkSum;
}

//把高低Byte组合成Int
+ (int)combineBytesHight:(Byte)hight andLow:(Byte)low
{
    return (int)(hight*256+low);
}

//把整数分拆成高低Byte
+ (NSArray*)spliteBytes:(int)number{
    NSData *data = [NSData dataWithBytes:&number length:sizeof(number)];
    Byte *dataArray = (Byte*)[data bytes];
    Byte hight = dataArray[1];
    Byte low = dataArray[0];
    return @[[NSNumber numberWithInt:hight],[NSNumber numberWithInt:low]];
}

+ (Byte) arrayToByte:(NSArray*)switchArray
{
    Byte alertDaysMaskByte = 0;
    for(int i = 0; i < 7; i++){
        if ([switchArray[i] intValue] == 1) {
            alertDaysMaskByte |= (0x01 << i);
        }
    }
    return alertDaysMaskByte;
}

+ (int)totalNumber:(NSData *)data normalEnd:(BOOL)bNormalEnd
{
    int nTotal = 0;
    int nUnit = 256;
    Byte *dataArray = (Byte*)[data bytes];
    
    if (bNormalEnd) {
        for (int nIndex = [data length] - 1; nIndex >= 0; nIndex--) {
            nTotal = nTotal * nUnit;
            nTotal += (int)dataArray[nIndex];
        }
    } else {
        for (int nIndex = 0; nIndex < [data length]; nIndex++) {
            nTotal = nTotal * nUnit;
            nTotal += (int)dataArray[nIndex];
        }
    }
    
    return nTotal;
}

#pragma mark
#pragma mark 函数: 内容操作
- (id)init
{
    self = [super init];
    if (self) {
        self.data = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)addByte:(Byte)byteToAdd withCount:(int)nCount
{
    for (int nIndex = 0; nIndex < nCount; nIndex++) {
        [self addByte:byteToAdd];
    }
}

- (void)addByte:(Byte)byteToAdd
{
    Byte byteArray[] = {byteToAdd};
    [self.data appendBytes:byteArray length:1];
}

- (void)addStringValue:(NSString *)strData
{
    NSData *data = [strData dataUsingEncoding:NSUTF8StringEncoding];
    [self.data appendData:data];
}

- (NSData *)wholeData
{
    return [self.data copy];
}

@end
