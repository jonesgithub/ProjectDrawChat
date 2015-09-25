//
//  BLEConnection.h
//  SportsPlugin
//
//  Created by LiMing on 14-5-14.
//  Copyright (c) 2014年 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


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

//是否打印Debug信息开关
#define bInBluetoothDebug YES
#define kBaseCommandTimeOutTime 60

/**
 *  内部使用的用来当消息到达时候的回调函数定义
 *
 *  @param success 是否成功;
 *  @param data    返回的数据
 */
typedef void (^MessageHandler)(BOOL success, NSData *data);

@protocol BLEDevice <NSObject>
-(void) connected:(id)conn;
@end


@interface BLEConnection : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic,copy) NSString *broadcastId;
//@property (nonatomic, strong) CBUUID *serviceUUID;
//@property (nonatomic, strong) CBUUID *characteristicUUID;

@property (nonatomic, strong) NSString *strWaitService;
@property (nonatomic, strong) NSString *strWaitCharacteristics;

@property BOOL bCheckAllCharacteristic;
@property (nonatomic, strong) NSDictionary *dicServiceCharacteristic;
@property (nonatomic, strong) NSDictionary *dicServiceCharacteristicNotificationed;     //对于接收的，是否已经notificatin开启了
//@property (nonatomic, strong) NSMutableDictionary *dictService;
@property (nonatomic, strong) NSMutableDictionary *dictCharacteristic;
    
//@property (nonatomic, assign) BOOL directConnect;
@property (nonatomic, strong) id<BLEDevice> delegate;
@property (nonatomic, strong) NSNumber *RSSI;

//-(id) initWith:(CBPeripheral *)peripheral andBroadcastId:(NSString*)broadcastId;

-(id) initWithPeripheral:(CBPeripheral *)peripheral serviceCharacteristicUUID:(NSDictionary *)dicServiceCharacteristic broadcastId:(NSString*)broadcastId delegate:(id<BLEDevice>)delegate;
-(void) findAllServiceCharacteristics;

//打开notification，使蓝牙设备发出数据
-(void) notificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler;
//关闭notification
- (void)closeNotificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics;
//读服务
-(void) readValueForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler;
//发命令交互
-(void) sendCommand:(NSData*)command forService:(NSString *)strService forCharacteristics:(NSString *)strCharacteristics waitForService:(NSString *)strWaitForService waitForCharacteristics:(NSString *)strWaitForCharacteristics when:(MessageHandler)handler;

-(void) close:(CBCentralManager*)manager;
-(BOOL) isEqualPeripheral:(CBPeripheral *)peripheral;

@end
