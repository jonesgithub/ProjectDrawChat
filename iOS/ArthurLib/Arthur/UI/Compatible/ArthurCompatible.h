//
//  ArthurCompatible.h
//  KeeFit
//
//  Created by lichen on 6/19/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArthurCompatible : NSObject

//屏幕frame
+ (CGRect)frameOfScreen;

//当前控制器内，导航栏高度:
+ (float)heightOfNavigationBarInController:(UIViewController *)viewController;

//pickerView的高度
+ (float)heightOfPickerView;

//无用的顶部状态栏高度
+ (float)heightOfUnusedStatusBar;

//兼容UISegmentedControl
+ (void)uniformSegment:(UISegmentedControl *)segment withSelectedColor:(UIColor *)selectedColor backgroundColor:(UIColor *)backgroundColor;

//转UIColor成一张图
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (void)uniformButton:(UIButton *)button withBackgroundColor:(UIColor *)backgroundColor;

//字符串的显示大小
+ (CGSize)sizeOfString:(NSString *)str withFontSize:(float)fSize;
@end
