#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEConnection.h"
#import "HardwareBase.h"

//绑定或者直连超时
#define kBindOrDirectConnectTimeOutTime 30
//搜索设备的时间
#define kMaxSearchDeviceTimeInSeconds 120   //两分钟

//绑定设备时，搜索时间
#define kBindDeviceSearchTime 3
//连接信号强度最强的几个
#define kConnectBestSignalCount 3

@interface HardwareBluetooth: HardwareBase

//状态
@property (nonatomic, strong) NSString *broadcastId;
@property (nonatomic, strong) NSString *strDeviceID;
@property (nonatomic, strong) NSString *strPeripheralUUID;
@property (nonatomic, strong) NSNumber *connected;

//设置蓝牙过滤条件
- (void)setBluetoothFilterWithDeviceName:(NSArray *)arrDeviceNames 
                            broadcastIDs:(NSArray *)arrBroadcastIDs 
                  serviceCharacteristics:(NSDictionary *)dictServiceCharacteristics 
                    peripheralUUIDString:(NSString *)strPeripheralUUID;

//搜索设备
@property (nonatomic, strong) onCallBack handerSearchDevice;
@property (nonatomic, strong) NSTimer *timerSearchDevice;
-(void) serachDeviceWithTimeout:(int)nTimeoutInSecond onCallBack:(onCallBack)handerSearchDevice;
-(void) stopSearchDevice;

//发送notification
- (void)notificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler;
//关闭notification
- (void)closeNotificaitonForService:(NSString *)strService characteristics:(NSString *)strCharacteristics;
//读characteristics中的数据
- (void)readValueForService:(NSString *)strService characteristics:(NSString *)strCharacteristics when:(MessageHandler)handler;
//发送command
-(void) sendCommand:(NSData*)command 
         forService:(NSString *)strService 
 forCharacteristics:(NSString *)strCharacteristics 
     waitForService:(NSString *)strWaitForService 
waitForCharacteristics:(NSString *)strWaitForCharacteristics 
               when:(MessageHandler)handler;

@end


