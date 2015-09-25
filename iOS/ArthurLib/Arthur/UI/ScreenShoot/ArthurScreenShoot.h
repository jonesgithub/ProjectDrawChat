//
//  ArthurScreenShoot.h
//  KeeFit
//
//  Created by lichen on 6/16/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArthurScreenShoot : NSObject

//获取view的内容成image
+ (UIImage *)captureScreen:(UIView *)view;

//全屏image
+ (UIImage *)captureFullScreen:(UIView *)viewInside;

//保存一个view成图片
+ (void)saveScreenshotToPhotosAlbum:(UIView *)view ;

@end
