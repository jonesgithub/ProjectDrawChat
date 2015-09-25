//
//  ArthurNetworkOperation2.m
//  MapNews
//
//  Created by lichen on 4/18/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import "ArthurNetworkOperation2.h"
#import "NSJSONSerialization+ArthurJSON.h"
#import "MNLib.h"

@implementation ArthurNetworkOperation2

//网络的统一状态: 暂时先放这里，不一定有用
static bool bNetworkWorking = true;

+ (bool)isNetworkWorking
{
    return bNetworkWorking;
}

+ (ArthurNetworkOperation2 *)asynPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName success:(Success)successed fail:(Fail)failed inView:(UIView *)view
{
    ArthurNetworkOperation2 * opertation = [[ArthurNetworkOperation2 alloc] initWithPostURL:strURL
                                                data:dictData
                                                name:strName
                                             success:successed
                                                fail:failed
                                            inView:view];
    return opertation;
}

- (id)initWithPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName success:(Success)successed fail:(Fail)failed inView:(UIView *)view
{
    NSMutableDictionary *mutableDictData = [dictData mutableCopy];
    //检测参数
    if (![MNLib dictionary:mutableDictData hasKeys:@[@"resource", @"method"]]) {
        NSLog(@"%@", @"程序错误: 网络请求未设置resource与method");
        return nil;
    }
    if (![mutableDictData objectForKey:@"token"]) {
        [mutableDictData setValue:@"" forKey:@"token"];
    }
    if (![mutableDictData objectForKey:@"id"]) {
        [mutableDictData setValue:@"" forKey:@"id"];
    }
    
    //把请求数据转成相应格式，使外部直接传入NSDictionary
    NSString *strPostData = [NSJSONSerialization toJSON:mutableDictData];
    NSString *strPost = [NSString stringWithFormat:@"requestParameter=%@", strPostData];
    
    NSURL *url = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [strPost dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    self = [super initWithRequest:request delegate:self];
    self.strName = strName;
    self.successed = successed;
    self.failed = failed;
    
//    if (view) {
//        self.HUD = [[MBProgressHUD alloc] initWithView:view];
//        [view addSubview:self.HUD];
//        self.HUD.labelText = [NSString stringWithFormat:@"%@...", strName];
//        [self.HUD show:YES];
//    }
    if (view) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:
                                      UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.frame = view.frame;
        [view addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
    
    return self;
}

//接收到服务器回应的时候调用此方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receiveData = [NSMutableData data];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}

- (void)hideActivityIndicatorView
{
    if (self.activityIndicatorView) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
}

- (void)cancel
{
    [super cancel];
    [self hideActivityIndicatorView];
}

//delegate回应错误与正确结果
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self hideActivityIndicatorView];
    [MNLib showTitle:@"网络请求失败" message:@"无法连接到服务器，请检查网络是否打开！" buttonName:@"OK"];
    bNetworkWorking = false;
    self.failed();
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideActivityIndicatorView];
    bNetworkWorking = true;
    NSString *receiveStr = [[NSString alloc]initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSDictionary *response = [NSJSONSerialization evalJSON:receiveStr];
    if (response) {
        if ([response[@"ack"]  isEqual: @100]) {
            self.successed(response);
        } else if ([response[@"ack"]  isEqual: @102]){
            self.successed(response);
        } else if ([response[@"ack"]  isEqual: @200]){
            self.successed(response);   //无记录
        } else if ([response[@"ack"]  isEqual: @101]){
            NSLog(@"%@", response[@"message"]);
            self.failed();
        } else {
            NSLog(@"error code:%@\nmessage:%@", response[@"ack"], response[@"message"]);
            self.failed();
        }
    } else {
        [MNLib showTitle:@"请求失败" message:self.strName buttonName:@"OK"];
        self.failed();
    }
}

@end
