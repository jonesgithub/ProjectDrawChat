//
//  HardwareBluetooth.m
//  BLETest
//
//  Created by LiMing on 14-3-13.
//  Copyright (c) 2014年 DEV. All rights reserved.
//

#import "HardwareBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ArthurHexOperation.h"

@interface HardwareBluetooth() <CBCentralManagerDelegate, BLEDevice>

@property (nonatomic, strong) CBCentralManager *cbmanger;

//蓝牙过滤
@property BOOL bHasSetBluetoothFilter;
@property (nonatomic, strong) NSArray *arrFilterDeviceNames;
@property (nonatomic, strong) NSArray *arrFilterBroadcastIDs;   //broadcast id过滤
@property (nonatomic, strong) NSDictionary *dicServiceCharacteristic;   //所有服务

//所有尝试连接的设备
@property (nonatomic, strong) NSMutableArray *connectedDevices;

@property (nonatomic, assign) BOOL directConnect;
@property (nonatomic, strong) BLEConnection *connection;

@property (nonatomic, assign) BOOL closed;

//搜索状态
@property (nonatomic, strong) NSNumber *bInScanDevice;
@property BOOL bWaitScan;

@end

@implementation HardwareBluetooth

#pragma mark
#pragma mark 初始化
- (id) init
{
    self = [super init];
    
    self.bHasSetBluetoothFilter = NO;
    
    self.bWaitScan = NO;
    _connectedDevices = [[NSMutableArray alloc] init];
    _connected = NO;
    _directConnect = NO;
    _closed = YES;
    self.bInScanDevice = NumberNO;
    _connected = [[NSNumber alloc] initWithBool:NO];
    
    return self;
}

- (void)dealloc
{
    [self cleanState];
}

-(void) cleanState
{
    //停止搜索
    [self stopSearchDevice];
    
    //表示已关闭
    self.closed = YES;
    
    //清除使用连接
    [self.connection close:self.cbmanger];
    self.connection = nil;
    self.connected = NumberNO;
    
    //去掉所有连接
    [self.connectedDevices removeAllObjects];
    self.cbmanger = nil;
    
    //直连与搜索区分
    self.directConnect = NO;
    self.broadcastId = nil;
    
    //去掉peripheral identify
    self.strPeripheralUUID = nil;
}


#pragma mark
#pragma mark CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"%@", @"有连接过来");
    
    if (self.closed) {
        ConditionLog(bInBluetoothDebug, @"%@", @"已关闭，忽略新来的连接");
        return;
    }
    
    BLEConnection *conn = nil;
    for (BLEConnection *connd in _connectedDevices) {
        if ([connd isEqualPeripheral:peripheral]) {
            conn = connd;
        }
    }
    if (conn==nil) {
        ConditionLog(bInBluetoothDebug, @"%@", @"连接成功但是找不到对应的conn");
        return;
    }
    
    [MNLib delay2:0.5 doSomething:^{
        //开始发现服务
        [conn findAllServiceCharacteristics];
    }];
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if (_closed) {
        ConditionLog(bInBluetoothDebug, @"%@", @"已关闭，忽略断掉的连接");
        return;
    }
    
    BLEConnection *conn = nil;
    int idx = 0;
    int connIdx = 0;
    for (BLEConnection *connd in _connectedDevices) {
        if ([connd isEqualPeripheral:peripheral]) {
            conn = connd;
            connIdx = idx;
        }
        idx++;
    }
    
    if (conn==nil) {
        ConditionLog(bInBluetoothDebug, @"%@", @"连接断开，且这个连接未存储");
        return;
    } else {
        if (conn == self.connection) {
            ConditionLog(bInBluetoothDebug, @"%@", @"设备的连接断开");
            self.connection = nil;
            //设备连接断开
            NSAssert(self.deviceDelegate != nil, @"设备代理应存在");
            [self.deviceDelegate deviceDisconnected];
        } else {
            ConditionLog(bInBluetoothDebug, @"%@", @"非设备的连接断开");
        }
        [conn close:self.cbmanger];
        [_connectedDevices removeObjectAtIndex:connIdx];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (self.closed) {
        ConditionLog(bInBluetoothDebug, @"%@", @"已关闭，忽略现在发现的信道");
        return;
    }
    
    if (![self.bInScanDevice boolValue]) {
        ConditionLog(bInBluetoothDebug, @"%@", @"不处于搜索状态，忽略现在发现的信道");
        return;
    }
    
    if (self.connected) {
        ConditionLog(bInBluetoothDebug, @"%@", @"已连接，忽略发现的通道");
        return;
    }
    
//    NSLog(@"设备名: %@", peripheral.name);
    
    //device name过滤
    if (self.arrFilterDeviceNames && [self.arrFilterDeviceNames count] != 0) {
        if (![self.arrFilterDeviceNames containsObject:peripheral.name]){
//            NSLog(@"%@", @"device name过滤失败");
            return;
        }
    }
    
    NSString *strBroadcastID = [MNLib dataToHexString:advertisementData[@"kCBAdvDataManufacturerData"]];
    
    //去掉broadcast的过滤
//    if (strBroadcastID == nil || [strBroadcastID isEqual:@""]) {
//        ConditionLog(bInBluetoothDebug, @"%@", @"发现的信道无设备broadcastID，忽略");
//        return;
//    }
    
//    //忽略codoon等
//    NSArray *arrIgnoreDeviceNames = @[@"CSL", @"codoon", @"CBL", @"ZTECBL"];
//    if ([arrIgnoreDeviceNames containsObject:peripheral.name]) {
//        return;
//    }
    
    for (BLEConnection *conn in self.connectedDevices) {
        if ([conn isEqualPeripheral:peripheral]) {
            ConditionLog(bInBluetoothDebug, @"设备 %@ 已经在连接中，忽略", strBroadcastID);
            return;
        }
    }
    
    ConditionLog(bInBluetoothDebug, @"搜索到信道，设备名: %@, broadcastID: %@, RSSI: %@", peripheral.name, strBroadcastID, RSSI);
    
    //broadcast过滤
    if (self.arrFilterBroadcastIDs && [self.arrFilterBroadcastIDs count] != 0) {
        if (![self.arrFilterBroadcastIDs containsObject:strBroadcastID]){
            NSLog(@"%@", @"broadcast id过滤失败");
            return;
        }
    }
    
    NSLog(@"开始连接设备，broadcastID为：%@", strBroadcastID);
//    [self.cbmanger stopScan]; //停止搜索
    BLEConnection *conn = [[BLEConnection alloc] 
                           initWithPeripheral:peripheral 
                           serviceCharacteristicUUID:self.dicServiceCharacteristic
                           broadcastId:strBroadcastID
                           delegate:self];
    [self.connectedDevices addObject:conn];
    [self.cbmanger connectPeripheral:peripheral options:nil]; //开始连接设备
}

- (void)tryConnectDevice
{
    //为保险起见，外部不一定会stopScan
//    [self stopScan];
    
    //排序: 信息强度更高的放在前面
    [_connectedDevices sortUsingComparator:^NSComparisonResult(BLEConnection *obj1, BLEConnection *obj2) {
        if ([obj1.RSSI intValue] < [obj2.RSSI intValue]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    ConditionLog(bInBluetoothDebug, @"连接信号最好的前%d个", kConnectBestSignalCount);
    for (int i = 0; i < kConnectBestSignalCount; i++) {
        if (i < [self.connectedDevices count]) {
            BLEConnection *conn = [self.connectedDevices objectAtIndex:i];
            [self.cbmanger connectPeripheral:conn.peripheral options:nil];
            NSLog(@"RSSI: %@", conn.RSSI);
        }
    }
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (_closed) {
        return;
    }
    
    BLEConnection *connection;
    int idx = 0;
    int connIdx = 0;
    for (BLEConnection *conn in self.connectedDevices) {
        if ([conn isEqualPeripheral:peripheral]) {
            connection = conn;
            connIdx = idx;
        }
        idx++;
    }
    if (connection==nil) {
        NSLog(@"%@", @"找不到连接的设备，忽略之");
        return;
    }else{
        [connection close:self.cbmanger];
    }

    NSLog(@"didFailToConnectPeripheral:%@ with error:%@", connection.broadcastId, [error description]);
    [_connectedDevices removeObjectAtIndex:connIdx];
    
    //连接断开
    if ([self.connected boolValue]) {
        //如果是当前连接状态就重连一下
        [self.cbmanger connectPeripheral:peripheral options:nil];
    }
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"%@", @"收到早就连接好的设备了");
    for (CBPeripheral *peripheral in peripherals) {
        if (self.closed) {
            ConditionLog(bInBluetoothDebug, @"%@", @"已关闭，忽略现在发现的信道");
            return;
        }
        
        if (![self.bInScanDevice boolValue]) {
            ConditionLog(bInBluetoothDebug, @"%@", @"不处于搜索状态，忽略现在发现的信道");
            return;
        }
        
        if (self.connected) {
            ConditionLog(bInBluetoothDebug, @"%@", @"已连接，忽略发现的通道");
            return;
        }
        
        for (BLEConnection *conn in self.connectedDevices) {
            if ([conn isEqualPeripheral:peripheral]) {
                ConditionLog(bInBluetoothDebug, @"%@", @"设备已经在连接中，忽略");
                return;
            }
        }
        
        ConditionLog(bInBluetoothDebug, @"找到已经连接的信道，设备名: %@, RSSI: %@", peripheral.name, peripheral.RSSI);
        
        if (self.arrFilterDeviceNames && [self.arrFilterDeviceNames count] != 0) {
            if (![self.arrFilterDeviceNames containsObject:peripheral.name]){
                NSLog(@"%@", @"device name过滤失败");
                return;
            }
        }
        
        //    [self.cbmanger stopScan]; //停止搜索
        BLEConnection *conn = [[BLEConnection alloc] 
                               initWithPeripheral:peripheral
                               serviceCharacteristicUUID:self.dicServiceCharacteristic
                               broadcastId:[self.arrFilterBroadcastIDs objectAtIndex:0]
                               delegate:self];
        [self.connectedDevices addObject:conn];
        [self.cbmanger connectPeripheral:peripheral options:nil];   //开始连接设备
    }
}

- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"%@", @"didRetrievePeripherals");
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"蓝牙状态改变，状态码: %d", (int)central.state);
    if (central.state == CBCentralManagerStateUnsupported) {
        [MNLib showTitle:ArthurLocal(@"The divice does not support bluetooth4.0") message:nil buttonName:ArthurLocal(@"OK")];
    }
    
    //没电
    if ((int)central.state == CBCentralManagerStatePoweredOff) {
        [MNLib showTitle:ArthurLocal(@"bluetooth is power off, you can open it") message:nil buttonName:ArthurLocal(@"OK")];
        if (self.handerSearchDevice) {
            NSLog(@"%@", @"蓝牙关闭，连接或者绑定就直接做超时处理");
            //要不要打开呢？
//            [self searchDeviceTimeout];
        }
    }
    
    if ((int)central.state == CBCentralManagerStatePoweredOn) {
        if (self.bWaitScan) {
            [self scan];
        }
    } else {
        ConditionLog(bInBluetoothDebug, @"%@", @"蓝牙状态非PoweredOn，断开连接");
        if (self.self.deviceDelegate) {
            [self.deviceDelegate deviceDisconnected];
        } else {
            NSLog(@"%@", @"设备代理应存在");
        }
    }
}

#pragma mark
#pragma mark BLEDevice协议
-(void) connected:(id)conn
{
    if ([self.connected boolValue]) {
        ConditionLog(bInBluetoothDebug, @"%@", @"已经连接好，新来确认好服务的连接忽略");
        return;
    }
    
    self.connected = NumberYES;  //表示已经连接上
    self.connection = conn;             //设置能够通信连接
    self.strPeripheralUUID =  ((BLEConnection *)conn).peripheral.identifier.UUIDString;
    
    //停止搜索
    [self stopSearchDevice];
    
    //连接好
    onCallBack handerSearchDevice = CopyAndClearHander(self.handerSearchDevice);
    if (handerSearchDevice) {
        handerSearchDevice(YES);
    }
}

#pragma mark
#pragma mark 外部调用
//设置蓝牙过滤条件
- (void)setBluetoothFilterWithDeviceName:(NSArray *)arrDeviceNames 
                            broadcastIDs:(NSArray *)arrBroadcastIDs 
                  serviceCharacteristics:(NSDictionary *)dictServiceCharacteristics 
                      peripheralUUIDString:(NSString *)strPeripheralUUID
{
    self.arrFilterBroadcastIDs = [arrBroadcastIDs copy];
    self.arrFilterDeviceNames = [arrDeviceNames copy];
    self.dicServiceCharacteristic = [dictServiceCharacteristics copy];
    self.strPeripheralUUID = strPeripheralUUID;
    self.bHasSetBluetoothFilter = YES;
}

- (void) serachDeviceWithTimeout:(int)nTimeoutInSecond onCallBack:(onCallBack)handerSearchDevice
{
    NSAssert(self.bHasSetBluetoothFilter, @"必须先设置好蓝牙过滤条件, 调用函数: setScanRangeWithNames");
    
    //检测是否正在搜索状态
    if ([self.bInScanDevice boolValue]) {
        NSLog(@"%@", @"正在搜索，不能再搜索");
        handerSearchDevice(NO);
        return;
    }
    
    //先清除状态
    [self stopSearchDevice];
    
    //开始正在搜索
    self.bInScanDevice = NumberYES;
    
    //加定时器
    if (nTimeoutInSecond <= 0) {
        nTimeoutInSecond = kMaxSearchDeviceTimeInSeconds;
    }
    self.timerSearchDevice = [NSTimer 
                              scheduledTimerWithTimeInterval:nTimeoutInSecond 
                              target:self 
                              selector:@selector(searchDeviceTimeout) 
                              userInfo:nil 
                              repeats:NO];
    
    //新开蓝牙
    self.cbmanger = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.connected = NO;    //未连接
    self.closed = NO;   //非关闭
    
    AssertEmptyHander(self.handerSearchDevice) = handerSearchDevice;
    
    if (self.cbmanger.state == CBCentralManagerStatePoweredOn) {
        [self scan];
    } else {
        self.bWaitScan = YES;
    }
}

-(void)stopSearchDevice
{
    [MNLib destroyTimer:self.timerSearchDevice];
    self.bInScanDevice = NumberNO;
    if (self.cbmanger) {
        [self.cbmanger stopScan];
    }
}

- (void)searchDeviceTimeout
{
    [self stopSearchDevice];
    onCallBack handerSearchDevice = CopyAndClearHander(self.handerSearchDevice);
    if (handerSearchDevice) {
        handerSearchDevice(NO);
    }
}

- (void)scan
{
    self.bWaitScan = NO;
    self.bInScanDevice = NumberYES; //开始处于搜索状态
    
    //有peripheral的uuid
    if (self.strPeripheralUUID) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.strPeripheralUUID];
        NSArray *peripherals = [self.cbmanger retrievePeripheralsWithIdentifiers:@[uuid]];
        
        for(CBPeripheral *peripheral in peripherals){
            BLEConnection *conn = [[BLEConnection alloc] 
                                   initWithPeripheral:peripheral 
                                   serviceCharacteristicUUID:self.dicServiceCharacteristic
                                   broadcastId:nil
                                   delegate:self];
            [self.connectedDevices addObject:conn];
            [self.cbmanger connectPeripheral:peripheral options:nil]; //开始连接设备
        }
    } else {
        //扫描新的
        [self.cbmanger scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO }];
        //查找已连接好的
//        [self.cbmanger retrieveConnectedPeripheralsWithServices:nil];
    }
}

- (void)notificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler
{ 
    if (self.connected) {
        [self.connection notificaitonForService:strService characteristics:strCharacteristics when:handler];
    } else {
        NSLog(@"%@", @"未连接，不能发notificaiton");
        handler(NO, nil);
    }
}

- (void)closeNotificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics
{
    if (self.connected) {
        [self.connection closeNotificaitonForService:strService characteristics:strCharacteristics];
    } else {
        NSLog(@"%@", @"未连接，不能关notification");
    }
}

-(void) readValueForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler
{
    if (self.connected) {
        [self.connection readValueForService:strService characteristics:strCharacteristics when:handler];
    } else {
        NSLog(@"%@", @"未连接，不能从characteristics中read value");
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
    if (self.connected) {
        [self.connection sendCommand:command forService:strService forCharacteristics:strCharacteristics waitForService:strWaitForService waitForCharacteristics:strWaitForCharacteristics when:handler];
    } else {
        NSLog(@"%@", @"未连接，不能发command");
        handler(NO, nil);
    }
}


@end
