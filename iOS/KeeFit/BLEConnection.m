//
//  BLEConnection.m
//  SportsPlugin
//
//  Created by LiMing on 14-5-14.
//  Copyright (c) 2014年 codoon. All rights reserved.
//

#import "BLEConnection.h"
@interface BLEConnection()<CBPeripheralDelegate>

//@property (nonatomic, strong) CBService *service;
//@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, copy) MessageHandler dataEvent;
@property (nonatomic, assign) int waitCount;
@property (nonatomic, strong) NSTimer *dataTimer;

@end

@implementation BLEConnection

#pragma mark
#pragma mark 初始化
//为什么初始化的时候这么多参数？
//防止后面漏掉相应设置
-(id) initWithPeripheral:(CBPeripheral *)peripheral 
serviceCharacteristicUUID:(NSDictionary *)dicServiceCharacteristic
             broadcastId:(NSString*)broadcastId 
                delegate:(id<BLEDevice>)delegate 
{
    self = [super init];
    if (self) {
        //初始化参数
        self.bCheckAllCharacteristic = NO;
        self.dicServiceCharacteristic = [dicServiceCharacteristic copy];
//        self.dictService = [[NSMutableDictionary alloc] init];
        self.dictCharacteristic = [[NSMutableDictionary alloc] init];
        
        //
        self.dicServiceCharacteristicNotificationed = [[NSMutableDictionary alloc] init];
        
        //保存参数
        self.peripheral = peripheral;
        self.broadcastId = broadcastId;
        self.delegate = delegate;
        
        //设置信道通信代理
        self.peripheral.delegate = self;
    }
    return self;
}

#pragma mark
#pragma mark 函数: 发现所有服务
-(void) findAllServiceCharacteristics
{
    //开始搜索characteristics
    NSMutableArray *arrServiceUUID = [[NSMutableArray alloc] init];
    for (NSString *strServiceUUID in [self.dicServiceCharacteristic allKeys]) {
        [arrServiceUUID addObject:[CBUUID UUIDWithString:strServiceUUID]];
    }
    [self.peripheral discoverServices:arrServiceUUID];
    
//    ConditionLog(bInBluetoothDebug, @"开始发现broadcastID为: %@ 的所有服务", self.broadcastId);
}

#pragma mark
#pragma mark CBPeripheralDelegate代理
//已发现服务
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error 
{
    if (error != nil) {
        ConditionLog(bInBluetoothDebug, @"didDiscoverServices error %@", error.description);
        return;
    }
    
    for (CBService *service in aPeripheral.services) {
        ConditionLog(bInBluetoothDebug, @"发现服务: %@", service.UUID);
        [self.peripheral discoverCharacteristics:nil forService:service];   //发现service的所有characteristic
    }
}

//已发现服务的Characteristics
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        ConditionLog(bInBluetoothDebug, @"查找服务的characteristic时失败\ndidDiscoverCharacteristicsForService error%@", error.description);
        return;
    }
    
    if (self.bCheckAllCharacteristic) {
        NSLog(@"%@", @"忽略characteristics");
        return;
    }
    
    //检测是否要查找的service
//    NSArray *arrCharacteristic = self.dicServiceCharacteristic[service.UUID.UUIDString];
//    if (arrCharacteristic) {
//        for (CBCharacteristic *characteristic in service.characteristics) {
//            if ([arrCharacteristic containsObject:characteristic.UUID.UUIDString]) {
//                NSString *strCharacteristicsKey = [service.UUID.UUIDString stringByAppendingString:characteristic.UUID.UUIDString];
//                [self.dictCharacteristic setObject:characteristic forKey:strCharacteristicsKey];
//            }
//        }
//    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        ConditionLog(bInBluetoothDebug, @"找到service: %@ 的characteristics: %@", service.UUID.UUIDString, characteristic.UUID.UUIDString);
        NSString *strCharacteristicsKey = [service.UUID.UUIDString stringByAppendingString:characteristic.UUID.UUIDString];
        [self.dictCharacteristic setObject:characteristic forKey:strCharacteristicsKey];
        
        //所有都notify一下
//        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
    
    //检测是否已经连接好
    [self checkLinkDone];
}

//检测是否已经完成连接
- (void)checkLinkDone
{
    BOOL bCheck = YES;
    
    for (NSString *strService in [self.dicServiceCharacteristic allKeys]) {
        NSArray *arrCharacteristics = self.dicServiceCharacteristic[strService];
        for (NSString *strCharacteristics in arrCharacteristics) {
            NSString *strServiceCharacteristicsKey = [strService stringByAppendingString:strCharacteristics];
            if (![self.dictCharacteristic objectForKey:strServiceCharacteristicsKey]) {
                bCheck = NO;
                break;
            }
        }
        if (!bCheck) {
            break;
        }
    }
    
    if (bCheck) {
        self.bCheckAllCharacteristic = YES;
        NSLog(@"查找到broadcastID为: %@ 的所有服务", self.broadcastId);
        [self.delegate connected:self]; //通知连接好了
    }
}

#pragma mark
#pragma mark 数据交互: 发送notification/数据
//notification交互数据
- (void)notificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler
{
    NSString *strCharacteristicsKey = [strService stringByAppendingString:strCharacteristics];
    CBCharacteristic *characteristic = self.dictCharacteristic[strCharacteristicsKey];
    if (characteristic) {
        [self communicatePrepareWithHander:handler waitForService:strService waitForCharacteristics:strCharacteristics];
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        [self.dicServiceCharacteristicNotificationed setValue:NumberYES forKey:strCharacteristicsKey];
        NSLog(@"对service:%@ characteristics:%@ 发送notification了", strService, strCharacteristics);
    } else {
        NSLog(@"%@", @"程序错误: 要发送的notificaiton没有找到相应的service与characteristics组成的服务");
        handler(NO, nil);
    }
}

//关闭notification
- (void)closeNotificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics
{
    NSString *strCharacteristicsKey = [strService stringByAppendingString:strCharacteristics];
    CBCharacteristic *characteristic = self.dictCharacteristic[strCharacteristicsKey];
    if (characteristic) {
        [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
        [self.dicServiceCharacteristicNotificationed setValue:NumberNO forKey:strCharacteristicsKey];
        NSLog(@"对service:%@ characteristics:%@ notification关闭了", strService, strCharacteristics);
    } else {
        NSLog(@"%@", @"程序错误: 准备关闭notificaiton，但未找到相应的service与characteristics");
    }
}

- (void)readValueForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler
{
    NSString *strCharacteristicsKey = [strService stringByAppendingString:strCharacteristics];
    CBCharacteristic *characteristic = self.dictCharacteristic[strCharacteristicsKey];
    if (characteristic) {
        [self communicatePrepareWithHander:handler waitForService:strService waitForCharacteristics:strCharacteristics];
        [self.peripheral readValueForCharacteristic:characteristic];
        //        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        NSLog(@"对service:%@ characteristics:%@ 发送notification了", strService, strCharacteristics);
    } else {
        NSLog(@"%@", @"程序错误: 要发送的notificaiton没有找到相应的service与characteristics组成的服务");
        handler(NO, nil);
    }
}

//发送命令
-(void) sendCommand:(NSData*)command 
         forService:(NSString *)strService 
 forCharacteristics:(NSString *)strCharacteristics 
     waitForService:(NSString *)strWaitForService 
waitForCharacteristics:(NSString *)strWaitForCharacteristics 
               when:(MessageHandler)handler
{
    NSString *strCharacteristicsKey = [strService stringByAppendingString:strCharacteristics];
    CBCharacteristic *characteristic = self.dictCharacteristic[strCharacteristicsKey];
    if (characteristic) {
        [self checkNotificationWithService:strWaitForService withCharacteristics:strWaitForCharacteristics when:^(BOOL success) {
            if (success) {
                [self communicatePrepareWithHander:handler waitForService:strWaitForService waitForCharacteristics:strWaitForCharacteristics];
                if ([strService isEqualToString:strWaitForService] && [strCharacteristics isEqualToString:strWaitForCharacteristics]) {
                    //发与收的service与characteristics相等，就等待回复
                    [self.peripheral writeValue:command forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                } else {
                    //发与收的service与characteristics不相等，就不等待回复
                    [self.peripheral writeValue:command forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                }
                NSLog(@"对service:%@ characteristics:%@ 发送command:\n%@", strService, strCharacteristics, [ArthurHexOperation NSDataToHexString:command]);
            } else {
                NSLog(@"%@", @"对要接收的characteritics notification检测失败");
                handler(NO, nil);
            }
        }];
    }
}

- (void)checkNotificationWithService:(NSString *)strService withCharacteristics:(NSString *)strCharacteristics when:(onCallBack)handerCheckNotification
{
    NSString *strWaitCharacteristicsKey = [strService stringByAppendingString:strCharacteristics];
    id bNotificationed = [self.dicServiceCharacteristicNotificationed objectForKey:strWaitCharacteristicsKey];
    //已经有了，直接发
    if (bNotificationed && [bNotificationed boolValue]) {
        handerCheckNotification(YES);
    } else {
        [self notificaitonForService:strService characteristics:strCharacteristics when:^(BOOL success, NSData *data) {
            handerCheckNotification(success);
        }];
    }
}

- (void)communicatePrepareWithHander:(MessageHandler)handler waitForService:(NSString *)strService waitForCharacteristics:(NSString *)strCharacteristics
{
    self.strWaitService = strService;
    self.strWaitCharacteristics = strCharacteristics;
    
    self.dataEvent = handler;
    [MNLib destroyTimer:self.dataTimer];
    self.dataTimer = [NSTimer 
                      scheduledTimerWithTimeInterval:kBaseCommandTimeOutTime 
                      target:self 
                      selector:@selector(communicateTimeout:) 
                      userInfo:self.peripheral 
                      repeats:NO];
}

//通信超时
-(void) communicateTimeout:(NSTimer*)theTimer
{
    [MNLib destroyTimer:self.dataTimer];
    //取消销毁，回调可能被重复用到
//    MessageHandler dataEvent = CopyAndClearHander(self.dataEvent);
    MessageHandler dataEvent = self.dataEvent;
    NSLog(@"%@", @"基础链接的通信中，命令超时");
    if (dataEvent) {
        dataEvent(NO, nil);
    } else {
        NSLog(@"%@", @"无回调处理");
    }
}

#pragma mark
#pragma mark 数据交互: 收到notification/数据
- (void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        ConditionLog(bInBluetoothDebug, @"%@", @"didUpdateValueForCharacteristic 错误");
    }
    [self communicateResponseForCharacteristic:characteristic error:error];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        ConditionLog(bInBluetoothDebug, @"%@", @"didUpdateValueForCharacteristic 错误");
    }
    [self communicateResponseForCharacteristic:characteristic error:error];
}

- (void)communicateResponseForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //验证service与characteristics
    if (![characteristic.service.UUID.UUIDString isEqualToString:self.strWaitService] ||
        ![characteristic.UUID.UUIDString isEqualToString:self.strWaitCharacteristics]) {
        NSLog(@"%@", @"来临的service/characteristics与收到的不一致");
        NSLog(@"等待: service:%@, characteristics:%@, \n来临: service:%@, 来临characteristics:%@", 
              self.strWaitService, 
              self.strWaitCharacteristics, 
              characteristic.service.UUID.UUIDString,
              characteristic.UUID.UUIDString);
        return;
    }
    
    [MNLib destroyTimer:self.dataTimer];
    //不注销处理回调，因为可能被重复利用到
//    MessageHandler dataEvent = CopyAndClearHander(self.dataEvent);
    MessageHandler dataEvent = self.dataEvent;
    if (error) {
        ConditionLog(bInBluetoothDebug, @"通信错误，错误原因(error):\n%@", error.description);
        dataEvent(NO, nil);
    } else {
        if (dataEvent) {
            dataEvent(YES, characteristic.value);
        } else {
            NSLog(@"%@", @"无回调处理");
        }
    }
}

#pragma mark
#pragma mark 函数: close/equal
-(void) close:(CBCentralManager*)manager
{
    ConditionLog(bInBluetoothDebug, @"release peripheral %@", self.broadcastId);
    @try {
        [manager cancelPeripheralConnection:self.peripheral];
    }
    @catch (NSException *exception) {
        ConditionLog(bInBluetoothDebug, @"error in close:%@", exception);
    }
    @finally {
        self.peripheral = nil;
    }
    [MNLib destroyTimer:self.dataTimer];
    self.dataEvent = nil;
    
    //清理service与characteristics
    self.bCheckAllCharacteristic = NO;
    self.dictCharacteristic = [[NSMutableDictionary alloc] init];
    self.dicServiceCharacteristicNotificationed = [[NSMutableDictionary alloc] init];
//    self.dictService = [[NSMutableDictionary alloc] init];
    
//    self.service = nil;
//    self.characteristic = nil;
}

//是否为某一通道
-(BOOL) isEqualPeripheral:(CBPeripheral *)peripheral
{
    if([peripheral isEqual:self.peripheral]){
        return YES;
    } else {
        return NO;
    }
}

@end
