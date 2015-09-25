//
//  ArthurCompatible.m
//  KeeFit
//
//  Created by lichen on 6/19/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurCompatible.h"

@implementation ArthurCompatible

#pragma mark
#pragma mark 函数: 统一6.0与7.0
//兼容UISegmentedControl
+ (void)uniformSegment:(UISegmentedControl *)segment withSelectedColor:(UIColor *)selectedColor backgroundColor:(UIColor *)backgroundColor
{
    //系统版本小于7.0时,segment变成相应颜色
    if ([ArthurApp systmeVersion] < 7.0) {
        //设置高度
        CGRect segmentFrame = segment.frame;
        segmentFrame.origin.y = segmentFrame.origin.y + (segmentFrame.size.height - 28)/2;
        segmentFrame.size.height = 28;
        segment.frame = segmentFrame;
        
        //设置背景色、文字颜色
        [segment setBackgroundImage:[self imageWithColor:selectedColor size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateSelected
                                                 barMetrics:UIBarMetricsDefault];
        
        [segment setBackgroundImage:[self imageWithColor:backgroundColor size:CGSizeMake(1, 29)]
                                                   forState:UIControlStateNormal
                                                 barMetrics:UIBarMetricsDefault];
        
        [segment setDividerImage:[self imageWithColor:selectedColor size:CGSizeMake(1, 29)] 
                                     forLeftSegmentState:UIControlStateNormal 
                                       rightSegmentState:UIControlStateSelected 
                                              barMetrics:UIBarMetricsDefault];
        
        [segment setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor: selectedColor,
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] }
                                                       forState:UIControlStateNormal];
        
        [segment setTitleTextAttributes:@{
                                                                  UITextAttributeTextColor: backgroundColor,
                                                                  UITextAttributeFont: [UIFont systemFontOfSize:14],
                                                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]}
                                                       forState:UIControlStateSelected];
        
        //设置边框
        segment.layer.borderColor = selectedColor.CGColor;
        segment.layer.borderWidth = 1.0f;
        segment.layer.cornerRadius = 4.0f;
        segment.layer.masksToBounds = YES;
    }
}

//通一button
+ (void)uniformButton:(UIButton *)button withBackgroundColor:(UIColor *)backgroundColor
{
    if ([ArthurApp systmeVersion] < 7.0) {
        [button setBackgroundImage:[ArthurCompatible imageWithColor:kBackgroundColor size:button.frame.size] forState:UIControlStateNormal];
    } else {
        button.backgroundColor = [UIColor clearColor];
    }
}


#pragma mark
#pragma mark 函数: 辅助函数
//转UIColor成一张图
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//屏幕frame
+ (CGRect)frameOfScreen
{
    return [[UIScreen mainScreen] bounds];
}

//当前控制器内，导航栏高度:
+ (float)heightOfNavigationBarInController:(UIViewController *)viewController
{
    if (!viewController.navigationController.navigationBarHidden) {
        return viewController.navigationController.navigationBar.frame.size.height;
    } else {
        return 0;
    }
}

//pickerView的高度
+ (float)heightOfPickerView
{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    return pickerView.frame.size.height;
}

//无用的顶部状态栏高度
+ (float)heightOfUnusedStatusBar
{
    if ([ArthurApp systmeVersion] >= 7.0) {
        return 0.0;
    } else {
        return 20.0;
    }
}

//字符串的显示大小
+ (CGSize)sizeOfString:(NSString *)str withFontSize:(float)fSize
{
    CGSize detailSize;
    UIFont *font = [UIFont systemFontOfSize:fSize];
    if ([ArthurApp systmeVersion] >= 7.0) {
        detailSize = [str sizeWithAttributes:@{UITextAttributeFont:font}];
    } else {
        detailSize = [str sizeWithFont:font];
    }
    return detailSize;
}

@end
