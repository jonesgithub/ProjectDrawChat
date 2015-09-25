//
//  ArthurByteOperation.h
//  HardwareCommunication
//
//  Created by lichen on 7/14/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArthurByteOperation : NSObject

#pragma mark
#pragma mark 组装方法
@property (nonatomic, strong) NSMutableData *data;
- (void)addByte:(Byte)byteToAdd withCount:(int)nCount;
- (void)addByte:(Byte)byteToAdd;
- (void)addStringValue:(NSString *)strData;
- (NSData *)wholeData;

#pragma mark
#pragma mark 类方法
//对数据加上校验和
+ (NSData*)addCheckSum:(NSData*)data;

//获取校验和
+ (Byte)checkSumOfData:(NSData*)data;

//把高低Byte组合成Int
+ (int)combineBytesHight:(Byte)hight andLow:(Byte)low;

//把整数分拆成高低Byte
+ (NSArray*)spliteBytes:(int)number;

//Array变Byte，值1对应 1，其它对应0
+ (Byte)arrayToByte:(NSArray*)switchArray;

//组装内容
+ (int)totalNumber:(NSData *)data normalEnd:(BOOL)bNormalEnd;
@end
