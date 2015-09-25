//
//  HardwareConnection.m
//  HardwareCommunication
//
//  Created by lichen on 7/14/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "HardwareBase.h"

@interface HardwareBase()

//命令开始byte
@property Byte byteStartCommand;
@property BOOL bHasSetByteStartCommand;

@end



@implementation HardwareBase

#pragma mark
#pragma mark 初始化
- (id)init
{
    self = [super init];
    self.bHasSetByteStartCommand = NO;
    self.deviceDelegate = nil;
    return self;
}

- (void)dealloc
{
    self.deviceDelegate = nil;
}

//设置命令开始byte
- (void)setStartCommand:(Byte)byteStartCommand
{
    self.byteStartCommand = byteStartCommand;
    self.bHasSetByteStartCommand = YES;
}

#pragma mark
#pragma mark 发送命令
//发送命令，子类需继承
- (void)sendCommand:(Byte)byteCommandType withData:(NSData *)data response:(onResponse)handerResponse
{
    //保存command类型、生成command内容
    self.byteCommandType = byteCommandType;
    self.dataCommand = [self combineCommand:byteCommandType andData:data];
    
    //保存回调
    AssertEmptyHander(self.handerResponse) = handerResponse;
    
    //超时定时器
    self.timerSendCommand = [NSTimer 
                             scheduledTimerWithTimeInterval: kSendCommandTimeOutTime
                             target:self 
                             selector:@selector(sendCommandTimeOut) 
                             userInfo:nil 
                             repeats:NO];
}

//子类直接调用即可
- (void)commandResponsed:(BOOL)success withData:(NSData *)data
{
    [MNLib destroyTimer:self.timerSendCommand];
    onResponse handerResponse = CopyAndClearHander(self.handerResponse);
    
    Byte *dataArray = (Byte*)[data bytes];
    //验证功能码: 规则为0x01 => 0x81
    Byte byteResponseFunction = dataArray[1];
    if ((int)(self.byteCommandType) + 8*16 != (int)byteResponseFunction){
        NSLog(@"功能码不一致: 发送%x，收到%x", self.byteCommandType, byteResponseFunction);
        handerResponse(NO, nil);
    } else {
        //验证CheckSum
        int nDataLength = (int)dataArray[2];
        Byte checkSum = dataArray[3 + nDataLength];
        NSData *dataWithOutCheckSum = [data subdataWithRange:NSMakeRange(0, 3+nDataLength)];
        Byte checkSumCalculated = [ArthurByteOperation checkSumOfData:dataWithOutCheckSum];
        if (checkSum != checkSumCalculated) {
            NSLog(@"%@", @"校验和不对，收到的数据为:\n %@", [MNLib dataToHexString:data]);
            handerResponse(NO, nil);
        } else {
            //截取纯数据，并执行回调
            NSData *pureData = [data subdataWithRange:NSMakeRange(3, nDataLength)];
            if (handerResponse) {
                handerResponse(YES, pureData);
            } else {
                NSLog(@"%@", @"无回调处理");
            }
        }
    }
}

- (void)sendCommandTimeOut
{
    onResponse handerResponse = CopyAndClearHander(self.handerResponse);
    [MNLib destroyTimer:self.timerSendCommand];
    if (handerResponse) {
        handerResponse(NO, nil);
    } else {
        NSLog(@"%@", @"回调为空");
    }
}

#pragma mark
#pragma mark 硬件相关操作，子类需继承
//搜索设备
- (void)searchDevice:(onCallBack)handerSearchDevice
{
    NSLog(@"%@", @"子类未现该函数");
}

//绑定设备
- (void)bindDevice:(onCallBack)handerBindDevice
{
    NSLog(@"%@", @"子类未现该函数");
}

//解绑设备
- (void)unbindDevice
{
    NSLog(@"%@", @"子类未现该函数");
}

//连接设备
- (void)connectDevice:(onCallBack)handerConnectDevice
{
    NSLog(@"%@", @"子类未现该函数");
}

//清理状态
- (void)cleanState
{
    NSLog(@"%@", @"子类未现该函数");
}

#pragma mark
#pragma mark Helper
//组合出命令: 功能码 + 数据
- (NSData *)combineCommand:(Byte)byteCommand andData:(NSData *)data
{
    NSAssert(self.bHasSetByteStartCommand, @"未设置命令开始byte");
    
    NSMutableData *dataCommand = [[NSMutableData alloc] init];
    //起始符
    Byte startByte[] = {self.byteStartCommand};
    [dataCommand appendBytes:startByte length:1];
    //功能码
    Byte commandByte[] = {byteCommand};
    [dataCommand appendBytes:commandByte length:1];
    //数据长度
    int nDataLength = [data length];
    Byte lengthByte[] = {(Byte)nDataLength};
    [dataCommand appendBytes:lengthByte length:1];
    //数据
    [dataCommand appendData:data];
    //校验和
    return [ArthurByteOperation addCheckSum:[dataCommand copy]];
}

@end
