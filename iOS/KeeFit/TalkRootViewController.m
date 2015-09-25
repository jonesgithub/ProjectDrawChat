//
//  TalkRootViewController.m
//  Talk
//
//  Created by lichen on 9/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "TalkRootViewController.h"
#import "NSJSONSerialization+ArthurJSON.h"
#import "GTMBase64.h"

@implementation TalkRootViewController

#pragma mark
#pragma mark 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self connectToServer];
    
    self.strLast = [[NSString alloc] init];
    
//    [[UIColor whiteColor] hexStringFromColor];
    
    [self.talkRootView.talkEventRouterLocal whenFadeOut:^{
        NSDictionary *dicEventDelete = @{kEventType: kEventTypeDelete};
        [self.talkRootView.talkEventRouterLocal event:dicEventDelete];
        [self sendData:dicEventDelete];
    }];
//    [self.talkRootView.talkEventRouterRemote whenFadeOut:^{
//        
//    }];
    
    NSString *strTest = @"12 32\n";
    NSArray *arrTest = [strTest componentsSeparatedByString:@"\n"];
    NSLog(@"%@", arrTest);
}

#pragma mark
#pragma mark 界面事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableDictionary *dicEvent = [self createEventWithTouches:touches];
    [dicEvent setObject:kEventTypeTouchBegin forKey:kEventType];
    [dicEvent setObject:[UIColor stringFromColor:kLineColorDefault] forKey:kDrawColor];
    [dicEvent setObject:@(kLineWidthDefault) forKey:kDrawWidth];
    [self.talkRootView.talkEventRouterLocal event:dicEvent];
    [self sendData:[dicEvent copy]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableDictionary *dicEvent = [self createEventWithTouches:touches];
    [dicEvent setObject:kEventTypeTouchMiddle forKey:kEventType];
    [self.talkRootView.talkEventRouterLocal event:dicEvent];
    [self sendData:[dicEvent copy]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableDictionary *dicEvent = [self createEventWithTouches:touches];
    [dicEvent setObject:kEventTypeTouchEnd forKey:kEventType];
    [self.talkRootView.talkEventRouterLocal event:dicEvent];
    [self sendData:[dicEvent copy]];
}

- (NSMutableDictionary *)createEventWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];  
    CGPoint currentLocation = [touch locationInView:self.view];
    NSMutableDictionary *dictEvent = [[NSMutableDictionary alloc] init];
    [dictEvent setObject:@(currentLocation.x) forKey:kPointX];
    [dictEvent setObject:@(currentLocation.y) forKey:kPointY];
    return dictEvent;
}

#pragma mark
#pragma mark    Socket事件
- (void)connectToServer
{
    if (self.client == nil) {
        self.client = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *err = nil;
        if (![self.client connectToHost:kServerHost onPort:kServerPort error:&err]) {
            NSLog(@"连接服务器失败.\n失败码: %ld \n失败原因: %@\n", (long)[err code], [err localizedDescription]);
            self.bConnected = NO;
        } else {
            NSLog(@"%@", @"开始连接");
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"%@", @"连接上了");
    [self.client readDataWithTimeout:-1 tag:0];
    self.bConnected = YES;
    [self sendLogin];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接断开.\n失败码: %ld \n失败原因: %@\n", (long)[err code], [err localizedDescription]);
    self.bConnected = NO;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"收到数据: %@end", str);
    [self receiveData:data];
    [self.client readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"%@", @"did write!");
}

//- (IBAction)buttonOfSendTouched:(id)sender 
//{
//    if (self.bConnected) {
//        NSString *strWrite = @"Hello World";
//        NSData *dataWrite = [strWrite dataUsingEncoding:NSUTF8StringEncoding];
//        [self.client writeData:dataWrite withTimeout:-1 tag:0];
//        NSLog(@"发送数据: %@", strWrite);
//    } else {
//        NSLog(@"%@", @"未连接，不能发消息");
//    }
//}

#pragma mark
#pragma mark 发送数据、收到数据
- (void)sendData:(NSDictionary *)dictData
{
    if (self.bConnected) {
        NSString *strJSON = [NSJSONSerialization toJSON:dictData];
        NSData *dataJSONBase64 = [GTMBase64 encodeData:[strJSON dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *strJSONBase64 = [[NSString alloc] initWithData:dataJSONBase64 encoding:NSUTF8StringEncoding];
        NSString *strSend = [NSString stringWithFormat:@"%d command %@\n", kUserIDDefault, strJSONBase64];
        NSLog(@"发送数据: %@", strSend);
        NSData *dataSend = [strSend dataUsingEncoding:NSUTF8StringEncoding];
        [self.client writeData:dataSend withTimeout:-1 tag:0];
        NSLog(@"%@", @"发送数据");
    } else {
        NSLog(@"%@", @"未连接，不能发消息");
    }
}

- (void)sendLogin
{
    if (self.bConnected) {
        NSString *strJSON = [NSJSONSerialization toJSON:@{@"nothing": @"nothing"}];
        NSData *dataJSONBase64 = [GTMBase64 encodeData:[strJSON dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *strJSONBase64 = [[NSString alloc] initWithData:dataJSONBase64 encoding:NSUTF8StringEncoding];
        NSString *strSend = [NSString stringWithFormat:@"%d login %@\n", kUserIDDefault, strJSONBase64];
        NSLog(@"发送数据: %@", strSend);
        NSData *dataSend = [strSend dataUsingEncoding:NSUTF8StringEncoding];
        [self.client writeData:dataSend withTimeout:-1 tag:0];
//        NSLog(@"%@", @"发送数据");
    } else {
        NSLog(@"%@", @"未连接，不能发消息");
    }
}

- (void)receiveData:(NSData *)dataReceive
{
    NSString *strRecive = [[NSString alloc] initWithData:dataReceive encoding:NSUTF8StringEncoding];
    NSLog(@"收到数据: %@end", strRecive);
    
    NSString *strAll = [self.strLast stringByAppendingString:strRecive];
    self.strLast = [[NSString alloc] init]; //用了之后就清空
    NSArray *arrSplite = [strAll componentsSeparatedByString:@"\n"];
    int nCount = [arrSplite count];
    
    if (nCount >= 2) {
        for (int nIndex = 0; nIndex < nCount-1; nIndex++) {
            NSString *strSeciton = arrSplite[nIndex];
            [self operateOneSection:strSeciton];
        }
    }
    
    if (nCount >= 1){
        if (![strAll hasSuffix:@"\n"]) {
            self.strLast = [arrSplite lastObject];
        }
    }
}

- (void)operateOneSection:(NSString *)strSection
{
    NSArray *arrComponents = [strSection componentsSeparatedByString:@" "];
    if ([arrComponents count] == 3) {
        if ([arrComponents[1] isEqualToString:@"command"]) {
            NSString *strJSONBase64 = arrComponents[2];
            NSData *dataJSON = [GTMBase64 decodeString:strJSONBase64];
            NSString *strJSON = [[NSString alloc] initWithData:dataJSON encoding:NSUTF8StringEncoding];
            NSDictionary *dicEvent = [NSJSONSerialization evalJSON:strJSON];
            [self.talkRootView.talkEventRouterRemote event:dicEvent];
        }
    } else {
        NSLog(@"%@", @"程序错误，数据节数不对");
    }
}

@end
