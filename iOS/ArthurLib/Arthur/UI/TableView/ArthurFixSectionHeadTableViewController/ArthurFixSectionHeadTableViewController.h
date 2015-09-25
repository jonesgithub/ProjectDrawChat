//
//  ArthurFixSectionHeadTableViewController.h
//  KeeFit
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

//太吊了，这个扩展
//完成拦截"点击返回"事件
#import "UIViewController+BackButtonHandler.h"

@interface ArthurFixSectionHeadTableViewController : UITableViewController<UIGestureRecognizerDelegate>

/**
 *  响应返回按钮被点击，或者滑动退回到上一层
 *  在此类中自动监听此事件，子类可以重写该方法以完成相应动作
 *
 *  @param sender 返回按钮，或者为nil
 */
//- (IBAction)buttonOfBackTouched:(id)sender;

- (BOOL)tryToPopBack;

@end
