//
//  ArthurScreenShoot.m
//  KeeFit
//
//  Created by lichen on 6/16/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurScreenShoot.h"

@implementation ArthurScreenShoot

//获取view的内容成image
+ (UIImage *)captureScreen:(UIView *)view
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        UIGraphicsBeginImageContextWithOptions(view.window.bounds.size, YES, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(view.window.bounds.size);
    }
    
    [view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    if ([ArthurApp systmeVersion] >= 7.0) {
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)captureFullScreen:(UIView *)viewInside
{
    UIView *view;
    if ([ArthurApp systmeVersion] >= 7.0) {
        view = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    } else {
        view = viewInside;
    }
    NSLogRect(view.frame); 
    NSLogRect(view.bounds);
    NSLog(@"scale: %f", [UIScreen mainScreen].scale);
    if ([ArthurApp systmeVersion] >= 7.0) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
            UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
        } else {
            UIGraphicsBeginImageContext(view.frame.size);
        }
    } else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
            UIGraphicsBeginImageContextWithOptions(view.window.frame.size, YES, [UIScreen mainScreen].scale);
        } else {
            UIGraphicsBeginImageContext(view.window.frame.size);
        }
    }
    
    [view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    if ([ArthurApp systmeVersion] >= 7.0) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//保存一个view成图片
+ (void)saveScreenshotToPhotosAlbum:(UIView *)view 
{
    UIImageWriteToSavedPhotosAlbum([self captureScreen:view], nil, nil, nil);
}

@end
