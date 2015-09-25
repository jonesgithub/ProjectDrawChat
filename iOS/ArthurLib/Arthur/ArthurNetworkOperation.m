#import "ArthurNetworkOperation.h"
#import "NSJSONSerialization+ArthurJSON.h"
#import "MNLib.h"

@implementation ArthurNetworkOperation

//同步get
+(NSString* ) synGet: (NSString *) str_url
{
    NSURL *url = [NSURL URLWithString:str_url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return str;
}

//同步post
+(NSString* ) synPost: (NSString *) str_url post_data:(NSString*)post_data
{
    NSURL *url = [NSURL URLWithString:str_url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [post_data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return str1;
}

//同步post
+(NSDictionary *) synPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName
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
    
    //获取到数据
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (!received) {
        return nil;
    }
    
    //转NSString
    NSString *receiveStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    if (!receiveStr) {
        return nil;
    }
    
    //转JSON
    NSDictionary *response = [NSJSONSerialization evalJSON:receiveStr];
    if (response) {
        if ([response[@"ack"]  isEqual: @100]) {
            return response;
        } else if ([response[@"ack"]  isEqual: @102]){
            return response;
        } else if ([response[@"ack"]  isEqual: @101]){
            [MNLib showTitle:@"失败" message:response[@"message"] buttonName:@"OK"];
            return nil;
        } else {
            NSLog(@"error code:%@\nmessage:%@", response[@"ack"], response[@"message"]);
            return nil;
        }
    } else {
        [MNLib showTitle:@"请求失败" message:strName buttonName:@"OK"];
        return nil;
    }
}

//异步get
+(NSURLConnection *) asynGet: (NSString *) str_url delegate: (id)delegate
{
    NSURL *url = [NSURL URLWithString:str_url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:delegate];
    return connection;
}

////异步post
//+(NSURLConnection *) http_asyn_post: (NSString *) str_url post_data:(NSString*)post_data delegate: (id)delegate
//{
//    NSURL *url = [NSURL URLWithString:str_url];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//    [request setHTTPMethod:@"POST"];
//    NSData *data = [post_data dataUsingEncoding:NSUTF8StringEncoding];
//    [request setHTTPBody:data];
//    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:delegate];
//    return connection;
//}

//异步post
+(NSURLConnection *) asynPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName delegate: (id<ArthurNetworkOperation_AsynPost>) delegate
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
    
    //todo: 这有点危险, networkOperation未被任务object持有?
    ArthurNetworkOperation * networkOperation = [[ArthurNetworkOperation alloc] init];
    networkOperation.delegate = delegate;
    networkOperation.strName = strName;
    NSURL *url = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [strPost dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    networkOperation.connection = [[NSURLConnection alloc]initWithRequest:request delegate:networkOperation];
    return networkOperation.connection;
}

- (void)setStrName:(NSString *)strName
{
    if (![strName isEqual:_strName]) {
        _strName = [strName copy];
    }
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

//delegate回应错误与正确结果
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [MNLib showTitle:@"网络请求失败" message:@"无法连接到服务器，请检查网络是否打开！" buttonName:@"OK"];
    [self.delegate connection:self.connection didFailWithError:error];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *receiveStr = [[NSString alloc]initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSDictionary *response = [NSJSONSerialization evalJSON:receiveStr];
    if (response) {
        if ([response[@"ack"]  isEqual: @100]) {
            [self.delegate connection:self.connection didSuccessWithData:response];
        } else if ([response[@"ack"]  isEqual: @102]){
            [self.delegate connection:self.connection didSuccessWithData:response];
        } else if ([response[@"ack"]  isEqual: @101]){
            NSLog(@"%@", response[@"message"]);
            [self.delegate connection:self.connection didFailWithError:nil];
        } else {
            NSLog(@"error code:%@\nmessage:%@", response[@"ack"], response[@"message"]);
            [self.delegate connection:self.connection didFailWithError:nil];
        }
    } else {
        [MNLib showTitle:@"请求失败" message:self.strName buttonName:@"OK"];
        [self.delegate connection:self.connection didFailWithError:nil];
    }
}
@end
