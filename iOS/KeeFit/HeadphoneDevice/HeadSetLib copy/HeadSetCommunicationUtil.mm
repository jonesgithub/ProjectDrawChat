//
//  HeadSetCommunicationUtil.m
//  CodoonSport
//
//  Created by sky on 12-6-29.
//  Copyright (c) 2012年 codoon.com. All rights reserved.
//

#import "HeadSetCommunicationUtil.h"
#import <AudioToolbox/AudioToolbox.h>
#import "HiJackMgr.h"
#import "CDDeviceUtil.h"
#import "CDConstants.h"
#import "CDUtil.h"

#define TIMEOUT 1.1
#define ConnectTimeOut 6
#define MissionTimeOut 8

#define DEBUG_Receive_LOG


enum receive_state {
	StartReceive = 0,
    ControlReceive = 1,
    LengthReceive = 2,
    DataReceive = 3,
    ValidReceive = 4,
    EndReceive = 5
};//获取状态

enum missionState{
    missionEverythingFine = 0,
    missionCancel = 1,
    missionTimeout = 2
};//任务当前的状态，只有在proceed mission的方法里需要判断这个状态

typedef enum{
    MissionIDSportsNone,
    MissionIDSportsData
}MissionID;


@interface HeadSetCommunicationUtil()<HiJackDelegate>

@property (assign, atomic) BOOL isConnected; //是否已经建立连接，一插上设备应该立即建立连接，把这个字段标识为YES.

@property (retain, atomic) NSDictionary *nowHandlingMission; // 当前正在执行的命令，是一个NSDictionary {"commands": [command, command], "callBackString": String of @selector, "target": object, "data": NSData} command 是一个完整的命令(NSArray, 不包括最后校验的那个byte), 每个command都对应下面一个字典,每个command完成后，将data的数据添加到mission的数据里来。
 
@property (retain, atomic) NSMutableDictionary *nowWantedDataAndReceiveState; // 当前需要拿到的数据和它现在所处于的状态,是一个NSDictionary {"wantedLength": int, "state": int, "data": NSData, "currentFetchIndex": int} 即需要接收有效数据的长度，目前接收数据所处的状态，接收到的所有数据的存储(包括起始，控制，长度，有效数据，校验)  currentFetchIndex: 现在获取到有效数据的位数

@property (retain, atomic) HiJackMgr *hijackMgr;

@property (retain, atomic) NSTimer *receiveTimeout;

@property (retain, atomic) NSArray *nowCommand; //当前正在处理的命令

@property (retain, atomic) NSTimer *missionTimeout; //整个mission的超时控制

@property (assign, atomic) SEL mediumSelector; //有的时候需要回调用户提供的方法前执行一些别的命令，如连接命令。如取用户数据。

@property (assign, atomic) int totalCommandsCount;  //在初始化一个任务之前把commandArray的总数赋给这个值，用来追踪任务完成度。


@property (retain, nonatomic) NSData *currentReceiveData;

@property (assign, nonatomic) UInt8 currentControllByte;

@property (assign, nonatomic) MissionID missionID;

//连接尝试次数
@property (assign, nonatomic) int soundIndexConnectTryCount; //曼彻斯特声道的尝试次数
@property (assign, nonatomic) int modeConnectTryCount; //通讯模式的尝试次数 (模式分曼彻斯特和fsk两种)

@property (assign, nonatomic) BOOL hasFailManchester;
@property (assign, nonatomic) BOOL hasFailFSK;

@property (assign, nonatomic) BOOL hasFailSoundIndexOnce;

@end

//------------------------------//

@implementation HeadSetCommunicationUtil

#pragma mark
#pragma mark 类方法: 单体、取消监听、开始监听
static  HeadSetCommunicationUtil *headSetCommunicationUtil = nil;

+ (HeadSetCommunicationUtil *)sharedHeadSetCommunicationUtil {
    @synchronized(self) {
        
        if (!headSetCommunicationUtil) headSetCommunicationUtil = [[HeadSetCommunicationUtil alloc] init];
    } 
    return headSetCommunicationUtil;
}

//取消监听耳机孔，在软件回到前台的时候再继续监听
+ (void) cancelMonitorCommunication{
    [headSetCommunicationUtil.hijackMgr unSetupRemoteIo];
}

+ (void) backToMonitorCommunication{
    headSetCommunicationUtil.isAllowSound = NO;
    [headSetCommunicationUtil.hijackMgr setupRemoteIo];
}

#pragma mark
#pragma mark 初始化
- (id) init {
    self = [super init];
    if (self) {
        self.isNowCancelOrTimeout = NO;
        
        //初始化hijackMgr
        self.hijackMgr = [[HiJackMgr alloc] init];
        [self.hijackMgr setDelegate:self];
        
        self.isAllowSound = YES;
        
        //监听程序失去活动
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)applicationWillResignActive{
    [self .hijackMgr unSetupRemoteIo];
}

#pragma mark
#pragma mark 函数

//设备是否已经链接
- (BOOL) isDeviceConnected{
    return self.isConnected;
}

- (BOOL) isNowHandelingMission{
    return self.nowHandlingMission ? YES: NO;
}

- (void) setMissionStateTimeout{
    self.isNowCancelOrTimeout = missionTimeout;
}

- (void) performCallBack: (BOOL)isTimeout{
    id target = [self.nowHandlingMission objectForKey: @"target"];
    SEL selector = NSSelectorFromString([self.nowHandlingMission objectForKey: @"callBackString"]);
    id object = [self.nowHandlingMission objectForKey: @"data"];
    if (isTimeout) {
        object = nil;
    }
    [self resetState];
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector:selector withObject: object];
#pragma clang diagnostic pop
}

/*把整个通讯模块恢复到初始态， 即可以接受新的任务的一个状态*/
- (void) resetState{

    self.nowHandlingMission = nil;
    
    self.nowWantedDataAndReceiveState = nil;
    
    if ([self.receiveTimeout isValid]) {
        [self.receiveTimeout invalidate];
    }
    
    if ([self.missionTimeout isValid]) {
        [self.missionTimeout invalidate];
    }
    self.nowCommand = nil;
    
    _isNowCancelOrTimeout = NO;
    self.totalCommandsCount = 0;
    
    self.missionID = MissionIDSportsNone;
}


- (void) resetWantedDataAndReceiveState{
   // {"wantedLength": int, "state": int, "data": NSData, "currentFetchIndex": int}
    //printf("resetWantedDataAndReceiveState");
    NSMutableDictionary *temDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"wantedLength", [NSNumber numberWithInt:0], @"state", [NSMutableData data], @"data", [NSNumber numberWithInt:0], @"currentFetchIndex", nil];
    self.nowWantedDataAndReceiveState = temDict;
    
}

- (void) blankWantedDataAndReceiveState{
    self.nowWantedDataAndReceiveState[@"data"] = [NSMutableData data];
}

- (NSData *) dataFromCommandArray: (NSArray *)commandArray{
    NSMutableData *commandData = [NSMutableData data];
    for (int i=0; i < commandArray.count; i++) {
        Byte commandByte = (Byte)[commandArray[i] intValue];
        Byte commandBytes[] = {commandByte};
        [commandData appendBytes:commandBytes length:1];
    }
    return [commandData copy];
}

- (void) sendCommand: (NSArray *)bytesInCommand withTimeOut: (float) timeoutSeconds{
    if (!self.hijackMgr.mute) {
        
        Byte validByte = 0;
        for (int b_i=0; b_i < [bytesInCommand count]; b_i++) {
            validByte += (Byte)[[bytesInCommand objectAtIndex:b_i] intValue];
        }
        
        NSMutableArray *bytesInCommandsAppendValidByte = [NSMutableArray arrayWithArray:bytesInCommand];
        [bytesInCommandsAppendValidByte addObject:[NSNumber numberWithInt:validByte]];
        
        self.nowCommand = bytesInCommand;
        [self resetWantedDataAndReceiveState];

        if (self.hijackMgr.headSetConnectMode == HeadSetConnectManchester) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                for (int b_j=0; b_j<[bytesInCommandsAppendValidByte count]; b_j++) {
                    int isNotSented = 1;
                    int sentedCount = 0;
                    int isMaybe = 0;
                    UInt8 wantSendByte = [[bytesInCommandsAppendValidByte objectAtIndex:b_j] intValue];
                    while (isNotSented) {
                        sentedCount += 1;
                        
                        isNotSented = [self.hijackMgr send: wantSendByte];
                        if (sentedCount >= 1000000) {
    //                        NSLog(@">1000000");
                            isMaybe = 1;
                            break;
                        }
                    }
                    if (b_j == 1) {
                        self.currentControllByte = wantSendByte;
                    }
                    if (isMaybe) {
                        break;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.receiveTimeout = [NSTimer scheduledTimerWithTimeInterval:timeoutSeconds target:self selector:@selector(receiveTimeOut:) userInfo:nil repeats:NO];
                    
                });
                
            });
        }else{
            //fsk通讯
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                NSData *commandData = [self dataFromCommandArray:bytesInCommandsAppendValidByte];
                self.hijackMgr.leadSignCount = 5;
                [self.hijackMgr fskSendData:commandData];
                self.currentControllByte = [bytesInCommandsAppendValidByte[1] intValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.receiveTimeout = [NSTimer scheduledTimerWithTimeInterval:timeoutSeconds target:self selector:@selector(receiveTimeOut:) userInfo:nil repeats:NO];
                    
                });
                
            });
        }
        
    }
    
}

- (void) reSendCommand{
    
    //NSLog(@"resendCommand!");
    
    NSMutableArray *commandArray = [self.nowHandlingMission objectForKey:@"commands"];
    [commandArray insertObject:self.nowCommand atIndex:0];
    //NSLog(@"%@ commandArray", commandArray);
    [self proceedMission];
}


//如果发送一个命令过了一定时间没有反馈，即认为超时，此时应该再发送一遍
- (void) receiveTimeOut: (NSTimer *)timer{
    //NSLog(@"NSTimer expired!");
    //NSLog(@"%@ nowHandlingMission", self.nowHandlingMission);
    //printf("NSTimer expired");
    [self reSendCommand];
}


//任务取消时的处理方法
-(void)missionCancelHanler{
    
//    NSLog(@"missionCancelHanler");
    
    [self resetState];
}


//任务超时的处理方法
- (void)missionTimeoutHanler{
//    NSLog(@"missionTimeoutHanler");
    
    [self performCallBack:YES];
}

//任务完成的处理方法
- (void)completeMission{
    
//    NSLog(@"completeMission");

    [self performCallBack:NO];
}

- (void)defaultMediumCallback{
    ;
}

//这个方法只在传入新的mission的时候，接收一次命令的数据完成的时候, 重发命令的时候 被调用.
- (void) proceedMission{    
    if (!self.isNowCancelOrTimeout) {
        NSMutableArray *commandArray = [self.nowHandlingMission objectForKey:@"commands"];
        //NSLog(@"%@ nowHandlingMission in proceedMission", self.nowHandlingMission);
        //NSLog(@"%@ commandArray in proceedMission,    ", commandArray);
        //NSLog(@"%i, count!!!!!!!!!!", [commandArray count]);
        //如果有人关心完成度的话 告诉他
        float completeRate = 100 - [commandArray count] / (float)self.totalCommandsCount * 100;
        if (self.missionID == MissionIDSportsData) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ObtainSportsDataCompleteNotification object:@(completeRate)];
        }
        //如果还有命令未发送完毕，发送
        if ([commandArray count]) {
            NSArray *command = commandArray[0];
            [commandArray removeObjectAtIndex:0];
            
                
            [self sendCommand:command withTimeOut:TIMEOUT];
            
        }else {
//            NSLog(@"done!");
            //count 为零说明数据已经发送完了而且接收完了，这时可以做收尾工作了。 如果没有设置返回前的回调，直接返回，否则交由返回前的回调处理
            if (self.mediumSelector == @selector(defaultMediumCallback)) {
                [self completeMission];
            }
            else {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:self.mediumSelector withObject:[self.nowHandlingMission objectForKey: @"data"]];
            #pragma clang diagnostic pop
            }
        }
    }else if (self.isNowCancelOrTimeout == missionCancel) {
        [self missionCancelHanler];
    }else if(self.isNowCancelOrTimeout == missionTimeout) {
        [self missionTimeoutHanler];
    }
    
}

//设置接收数据的状态
- (void) setReceiveState: (int)state{
    [self.nowWantedDataAndReceiveState setValue:[NSNumber numberWithInt:state ] forKey:@"state"];
}

//设置欲接收数据的长度
- (void) setReceiveDataLength: (int)length{
    [self.nowWantedDataAndReceiveState setValue:[NSNumber numberWithInt:length ] forKey:@"wantedLength"];
}

//设置接收到有效数据的当前个数
- (void) setReceiveCurrentIndex: (int) index{
    [self.nowWantedDataAndReceiveState setValue:[NSNumber numberWithInt:index ] forKey:@"currentFetchIndex"];
}

//设备返回的结果已经接收完毕
- (void) receiveFinish: (NSData *)receiveData{
    //如果倒计时还在进行，停止它.
    if ([self.receiveTimeout isValid]) {
        [self.receiveTimeout invalidate];
    }
    
//    NSData *receiveData = [self.nowWantedDataAndReceiveState objectForKey:@"data"];
    
    Byte *receiveByte = (Byte *)[receiveData bytes];
    
    Byte validSumByte = 0x00;
    Byte validByte = 0x00;
    
    for (int i = 0; i < [receiveData length]; i++) {
        
        if (i < [receiveData length] - 1) {
            
            validSumByte = validSumByte + receiveByte[i];
        }else {
            
            validByte = receiveByte[i];
        }
    }
    //校验通过
    
    Byte receiveControllByte = receiveByte[1];
    Byte sendControllerByte = [[self.nowCommand objectAtIndex:1] intValue];
    if (receiveControllByte != sendControllerByte + 128) {
        [self reSendCommand];
        return;
        
    }
    
    if (validByte == validSumByte){
        //数据加到mission的data里去 整个bytes数组的前三个byte抛掉. 只要数据主体
        [[self.nowHandlingMission objectForKey:@"data"] appendData:[receiveData  subdataWithRange:NSMakeRange(3, receiveByte[2])]];
        //继续发数据
        [self proceedMission];
    }else {
        //接收收据失败，和超时一样，重发一遍.
        [self reSendCommand];
    }
    
}

//**************************Hijack的代理部分********************


#pragma mark
#pragma mark Hijack的代理部分
- (int) receive:(UInt8)data {
    if (self.hijackMgr.mute) {
        
        printf("mute == yes,data=0x%x\n",data);
        
    }else {
        
        if (self.nowHandlingMission) {
            
            int receiveState = [[self.nowWantedDataAndReceiveState objectForKey:@"state"] intValue];
            
            switch (receiveState) {
                    
                case StartReceive:
                {
#ifdef DEBUG_Receive_LOG
                    printf("-起始-:0x%x ", data);
#endif
//                    if (data == 0x0) {
//                        return 1;
//                    }
                    
                    if (data == 0xaa){
                        [self setReceiveState:ControlReceive];
                        break;
                    }else{
                        return 1;
                    }
                }
                case ControlReceive:
                {
#ifdef DEBUG_Receive_LOG
                    printf("-控制-:0x%x ", data);
#endif
                    
//                    if ([self.receiveTimeout isValid]) {
//                        [self.receiveTimeout invalidate];
//                        self.receiveTimeout = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT target:self selector:@selector(receiveTimeOut:) userInfo:nil repeats:NO];
//                        
//                    }
                    
                    if (data != self.currentControllByte + 0x80) {
                        [self setReceiveState: StartReceive];
                        [self blankWantedDataAndReceiveState];
                        return 1;
                    }
                    
                    [self setReceiveState:LengthReceive];
                    break;
                }
                case LengthReceive:
                {
#ifdef DEBUG_Receive_LOG
                    printf("-长度-:0x%x ", data);
#endif
                    [self setReceiveDataLength:data];  //全局变量控制要接收的数据主体长度
                    if (data == 0x00) 
                        [self setReceiveState:ValidReceive];
                    else 
                        [self setReceiveState:DataReceive];
                    break;
                }
                case DataReceive:
                {
#ifdef DEBUG_Receive_LOG
                    printf("-数据-:0x%x ", data);
#endif
                    
                    int receiveLength = [[self.nowWantedDataAndReceiveState objectForKey:@"wantedLength"] intValue];
                    int currentFetchIndex = [[self.nowWantedDataAndReceiveState objectForKey:@"currentFetchIndex"] intValue];
                    
                    //printf("%d, receiveLength", receiveLength);
                    //printf("%d, currentFetchIndex", currentFetchIndex);

                    if (currentFetchIndex + 1 >= receiveLength) [self setReceiveState:ValidReceive]; //直到把数据快接收完毕后再标志校验状态
                    
                    currentFetchIndex++;
                    [self setReceiveCurrentIndex:currentFetchIndex];
                    break;
                }
                case ValidReceive:
                {
#ifdef DEBUG_Receive_LOG
                    printf("-校验-:0x%x \n", data);
#endif
                    [self setReceiveState:EndReceive];
                    receiveState = EndReceive;
                    break;
                    
                default:
#ifdef DEBUG_Receive_LOG
                    printf("default\n");
#endif
                    break;
                }
            }
            
            Byte tempByte[] = {data};
            [[self.nowWantedDataAndReceiveState objectForKey:@"data"] appendBytes:tempByte length:1];
            if (receiveState == EndReceive) {
                self.currentReceiveData = [self.nowWantedDataAndReceiveState objectForKey:@"data"];
                [self resetWantedDataAndReceiveState];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self receiveFinish: self.currentReceiveData];
                });
            }
        }
    }
    return 1;
}

- (void) prepareNewMission: (NSArray *)commands withSelector: (SEL)callback callbackTarget: (id)target missionTimeoutSeconds: (int)seconds mediumSelector: (SEL)mediumCallback{
    
    NSMutableData *data = [NSMutableData data];
    NSDictionary *mission = [NSDictionary dictionaryWithObjectsAndKeys:[commands mutableCopy], @"commands", NSStringFromSelector(callback), @"callBackString", target, @"target", data, @"data",  nil];
    
    self.nowHandlingMission = mission;
    self.totalCommandsCount = (int)[commands count];
    
    self.missionTimeout = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(setMissionStateTimeout) userInfo:nil repeats:NO];
    
    self.mediumSelector = mediumCallback;
}

- (void) cancelMission{
    self.isNowCancelOrTimeout = YES;
}


- (NSArray *)bytesToArray: (Byte *)bytes withLength: (int)length{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < length; i++) {
        [array addObject:[NSNumber numberWithInt:bytes[i]]];
    }
    return array;
}

#pragma mark
#pragma mark 中间处理回调
/**********************************************中间处理回调区块************************************************/

//有的时候需要在回调给使用者之前，改变一些自己内部的状态，即把自己的某个函数设为回调函数，再由这个函数来调用真正的回调函数.连接命令是一种。
- (void) connectionMediumCallback: (NSData *)data{
    
    self.isConnected = YES;
    
    [self completeMission];
}


- (void) obtainDataMediumCallback: (NSData *)data{
    
//    NSLog(@"%@:   obtainDataMediumCallback", data);
    
    Byte *bytesInData = (Byte *)[data bytes];
    int frameCount = bytesInData[1] * 256 + bytesInData[2];
    
    int frameCountOf4Group = (frameCount + 3) / 4; //如果按4个帧一组的话 有多少组。
    
    SEL callback = NSSelectorFromString([self.nowHandlingMission objectForKey: @"callBackString"]);
    
    id target = self.nowHandlingMission[@"target"];
    
    [self resetState];
    
    NSMutableArray *commandsArray = [NSMutableArray arrayWithCapacity:frameCountOf4Group];
    for (int i = 0; i < frameCountOf4Group; i++) {
        Byte obtainFrameDataBytes[] = {0xAA, 0x11, 0x02, static_cast<Byte>((i * 4) / 256), static_cast<Byte>((i * 4) % 256)};
        NSArray *commandArray = [self bytesToArray:obtainFrameDataBytes withLength:5];
        [commandsArray addObject:commandArray];
    }
    [self prepareNewMission:commandsArray withSelector:callback callbackTarget:target missionTimeoutSeconds:60 * 10 mediumSelector:@selector(defaultMediumCallback)];
    
    [self proceedMission];
    
    self.missionID = MissionIDSportsData;
}



/**********************************************具体发送命令区块***********************************************/

#pragma mark
#pragma mark 函数: 命令
- (void) obtainConnection: (SEL) callback byTarget: (id)target{
    self.hasFailManchester = NO;
    self.hasFailFSK = NO;
    self.hasFailSoundIndexOnce = NO;
    [self obtainConnectionCommand:callback byTarget:target];
}

- (void) obtainConnectionCommand: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA,0x01,0x00};
    NSArray *commandArray = [self bytesToArray:bytes withLength:3];
    NSArray *commandsArray = [NSArray arrayWithObjects:commandArray, nil];
    
    [self prepareNewMission:commandsArray withSelector:callback callbackTarget:target missionTimeoutSeconds:ConnectTimeOut mediumSelector:@selector(connectionMediumCallback:)];
    
    [self proceedMission];
}

- (void) connectDevice: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA,0x01,0x00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}

//为减少代码量的简单化常规命令，即没有中间处理函数的命令。
- (void) simplyRegularSendCommand: (Byte *) bytesOfCommand commandLength: (int)length  withSelector: (SEL)callback byTarget: (id)target{
    NSArray *commandArray = [self bytesToArray:bytesOfCommand withLength:length];
    NSArray *commandsArray = [NSArray arrayWithObjects:commandArray, nil];
    
    [self prepareNewMission:commandsArray withSelector:callback callbackTarget:target missionTimeoutSeconds:MissionTimeOut mediumSelector:@selector(defaultMediumCallback)]; //defaultMediumCallback 是个空方法 代表没有中间需要处理的函数
    
    [self proceedMission];
}


//获取设备类型obtainTypeAndVersion
- (void) obtainTypeAndVersion: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA, 0x02, 0x00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}


//获取设备id
- (void) obtainDeviceID: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA,0x04,0x00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}

//获取数据帧数
- (void) obtainDataFrameCount: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA,0x0C,0x00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}

//获取用户信息，和下方的有所区别
- (void) obtainDeviceUserInfo: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA,0x07,0x00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}

//获取用户信息，包括电量
- (void) obtainDeviceInfo: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA,0x08,0x00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}

//更新用户信息
- (void) updateDeviceUserInfoWithBytes: (Byte *)bytes withCallback:(SEL) callback byTarget: (id)target{
    [self simplyRegularSendCommand:bytes commandLength:17 withSelector:callback byTarget:target];
}

//更新用户信息，主要手环的活动提醒和智能闹钟
- (void) updateRingUserInfoWithBytes: (Byte *)bytes withCallback:(SEL) callback byTarget: (id)target{
    [self simplyRegularSendCommand:bytes commandLength:16 withSelector:callback byTarget:target];
}

- (void) setUserInfo: (SEL) callback byTarget: (id)target{
    NSData *userInfoData = [CDDeviceUtil userInfoCommandData];
    Byte *bytes = (Byte *)[userInfoData bytes];
    [self simplyRegularSendCommand:bytes commandLength:(int)userInfoData.length withSelector:callback byTarget:target];
}

//获取运动数据
- (void) obtainSportsData: (SEL) callback byTarget: (id)target{
    //先得获得数据条数
    Byte bytes[] = {0xAA, 0x0C, 0X00};
    NSArray *commandArray = [self bytesToArray:bytes withLength:3];
    NSArray *commandsArray = [NSArray arrayWithObjects:commandArray, nil];
    
    [self prepareNewMission:commandsArray withSelector:callback callbackTarget:target missionTimeoutSeconds:6 mediumSelector:@selector(obtainDataMediumCallback:)];
    
    [self proceedMission];
}

//清除运动数据
- (void) clearSportsData: (SEL) callback byTarget: (id)target{
    Byte bytes[] = {0xAA, 0x14, 0X00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}

//获取设备时间
- (void) obtainDeviceTime: (SEL) callback byTarget: (id) target{
    Byte bytes[] = {0xAA, 0x0b, 0X00};
    [self simplyRegularSendCommand:bytes commandLength:3 withSelector:callback byTarget:target];
}
//更新设备时间
- (void) updateDeviceDateTime: (Byte *)bytes withCallback: (SEL) callback byTarget: (id)target{
    [self simplyRegularSendCommand:bytes commandLength:10 withSelector:callback byTarget:target];
}

- (void) setDeviceTime: (SEL) callback byTarget: (id)target{
    NSData *timeData = [CDDeviceUtil timeCommandData];
    Byte *bytes = (Byte *)[timeData bytes];
    [self simplyRegularSendCommand:bytes commandLength:(int)timeData.length withSelector:callback byTarget:target];
}

- (void) setAlertAlarmInfo: (SEL) callback byTarget: (id)target{
    NSData *alertAlarmData = [CDDeviceUtil ringInfoCommandData];
    Byte *bytes = (Byte *)[alertAlarmData bytes];
    [self simplyRegularSendCommand:bytes commandLength:(int)alertAlarmData.length withSelector:callback byTarget:target];
}

//空的callback
- (void) blankCallBack: (NSData*)data{
//    NSLog(@"blankCallBack");
//    NSLog(@"%i", self.isConnected);
    
}

- (int) anotherSoundIndex: (int)soundIndex{
    return 1 - soundIndex;
}

- (HeadSetConnectMode) anotherHeadSetConnectMode: (HeadSetConnectMode)headSetConnectMode{
    if (headSetConnectMode == HeadSetConnectManchester) {
        return HeadSetConnectFsk;
    }else{
        return HeadSetConnectManchester;
    }
}

//通讯方式分两大类，曼彻斯特和fsk，曼彻斯特要试左右声道
//连接成功data是一个空NSDATA, 连接失败是nil
- (void) connectionComplete: (NSData *)data{
    self.modeConnectTryCount += 1;
    
    if (data) {
        
        self.isConnected = YES;
        if (self.hijackMgr.headSetConnectMode == HeadSetConnectManchester) {
            //保存声道索引
            [CDUtil setHeadSetConnectMode:HeadSetConnectManchester];
            [CDUtil setSoundChannelIndex:self.hijackMgr.soundChannel];
        }else{
            [CDUtil setHeadSetConnectMode:HeadSetConnectFsk];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            //发送链接成功的Notification
            [[NSNotificationCenter defaultCenter] postNotificationName:AudioConnectionSuccessNotification object:nil];
        });
    }else {
        //连接失败，如果是第一次连接失败，那就视当前连接模式调整方式.
        if (self.hijackMgr.headSetConnectMode == HeadSetConnectManchester) {
            if (self.hasFailSoundIndexOnce) {
                self.hasFailManchester = YES;
                if (!self.hasFailFSK) {
                    self.hijackMgr.headSetConnectMode = HeadSetConnectFsk;
                    [self obtainConnectionCommand:@selector(connectionComplete:) byTarget:self];
                }
            }else{
                self.hasFailSoundIndexOnce = YES;
                self.hijackMgr.soundChannel = [self anotherSoundIndex:self.hijackMgr.soundChannel];
                [self obtainConnectionCommand:@selector(connectionComplete:) byTarget:self];
            }
        }else{
            self.hasFailFSK = YES;
            if (!self.hasFailManchester) {
                self.hijackMgr.headSetConnectMode = HeadSetConnectManchester;
                self.hijackMgr.soundChannel = [CDUtil soundChannelIndex];
                [self obtainConnectionCommand:@selector(connectionComplete:) byTarget:self];
            }
        }
        
        
        if ([self isAllHeadSetFail]) {
            self.isConnected = NO;
            self.hijackMgr.soundChannel = [CDUtil soundChannelIndex];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:AudioConnectionFailNotification object:nil];
            });
        }
        
    }
    
}

- (BOOL) isAllHeadSetFail{
    return self.hasFailFSK && self.hasFailManchester;
}

- (void) manchesterFailHandler{
    
}



- (void) cancelConnection{
    [self cancelMission];
    
    [self resetState];
    self.isConnected = NO;
    
    self.isAllowSound = YES;
//    AudioSessionSetActive(FALSE);
    [self.hijackMgr unSetupRemoteIo];  //发现有耳机口拔出，把remoteIO销毁
}


// 跟isDeviceConnected的区别在于这是随便什么东西，只要是带耳麦的耳机插着就行。
- (BOOL) isHeadSetOutPlugIn{
    CFStringRef newRoute;
    UInt32 size = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
    if ([(__bridge NSString *)newRoute isEqualToString:@"HeadsetInOut"]) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL) isDeviceBond{
    return [self isHeadSetOutPlugIn];
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
}

@end
