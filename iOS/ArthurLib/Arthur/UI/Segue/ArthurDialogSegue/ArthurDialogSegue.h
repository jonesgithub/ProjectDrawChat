//
//  ArthurDialogSegue.h
//  CustomSegue
//
//  Created by lichen on 6/11/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

//自定义UIStoryboardSegue
//主要功能:
//1. 使destinationController.view覆盖在当前界面上
//2. destinationController.view背景自动改成透明
//3. destinationController.view注册触摸事件，点击背景时，destinationController.view自动消失，回到当前界面

#import <UIKit/UIKit.h>

@interface ArthurDialogSegue : UIStoryboardSegue

//为简化外部需在显示的dialog，提供一个类方法，可以直接显示
+ (void)showDialogController:(UIViewController *) dialogController 
                inController:(UIViewController *) inController 
         withSegueIdentifier: (NSString *)strSegueIdentifier;

//使view向下消失，并且把它removeFromSuperView
+ (void)dismissDialogView:(UIView *)view;

@end
