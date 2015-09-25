//
//  ArthurNetworkOperation2.h
//  MapNews
//
//  Created by lichen on 4/18/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

typedef void (^Success)(NSDictionary *response);
typedef void (^Fail)();

@interface ArthurNetworkOperation2 : NSURLConnection<NSURLConnectionDelegate>

@property (copy, nonatomic) NSString *strName;
@property (nonatomic, retain)  NSMutableData *receiveData;
@property (strong, nonatomic) Success successed;
@property (strong, nonatomic) Fail failed;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

+ (ArthurNetworkOperation2 *)asynPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName success:(Success)successed fail:(Fail)failed inView:(UIView *)view;
- (id)initWithPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName success:(Success)successed fail:(Fail)failed inView:(UIView *)view;

@end
