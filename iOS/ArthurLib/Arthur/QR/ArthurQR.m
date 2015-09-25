//
//  ArthurQR.m
//  Treadmill
//
//  Created by lichen on 7/23/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurQR.h"

@implementation ArthurQR

+ (void)scanQRInController:(UIViewController *)containerController onScan:(onScan)handerScan
{
    ZBarReaderViewController *reader = [[self alloc] initWithContainerController:containerController onScan:handerScan];
    [containerController presentViewController:reader animated:YES completion:^{}];
}

//初始化一个reader
- (id)initWithContainerController:(UIViewController *)containerController onScan:(onScan)handerScan
{
    self = [super init];
    
    self.containerController = containerController;
    self.readerDelegate = self;
    self.supportedOrientationsMask = ZBarOrientationMaskAll;
    [self.scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    //设置回调
    self.handerScan = handerScan;
    
    return self;
}

#pragma mark
#pragma mark delegate
#pragma mark
#pragma mark Delegate
- (void) imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    //完成扫描
    [self.containerController dismissViewControllerAnimated:YES completion:^{}];
    
    //获取数据
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    if (symbol) {
        NSLog(@"数据: %@", symbol.data);
        dispatch_async(dispatch_get_main_queue(), ^{  
            self.handerScan(symbol.data);
        });
    } else {
        NSLog(@"%@", @"无数据");
        dispatch_async(dispatch_get_main_queue(), ^{  
            self.handerScan(nil);
        });
    }
}

@end
