//
//  ArthurQR.h
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"

typedef void (^onScan)(NSString *strScaned);

@interface ArthurQR : ZBarReaderViewController<ZBarReaderDelegate>

+ (void)scanQRInController:(UIViewController *)containerController onScan:(onScan)handerScan;

@property (nonatomic, weak) UIViewController *containerController;
@property (nonatomic, strong) onScan handerScan;

@end
