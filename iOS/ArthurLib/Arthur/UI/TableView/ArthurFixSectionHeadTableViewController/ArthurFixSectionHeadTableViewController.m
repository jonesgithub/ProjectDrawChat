//
//  ArthurFixSectionHeadTableViewController.m
//  KeeFit
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurFixSectionHeadTableViewController.h"

@interface ArthurFixSectionHeadTableViewController ()

@end

@implementation ArthurFixSectionHeadTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //固定section高度
    self.tableView.sectionFooterHeight = 1.0;
}

//添加返回手势监听
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //暂时去掉手势
//    // Disable iOS 7 back gesture
//    // 测试是否支持"返回手势"
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO; //TODO: 应取消这个，以支持手势
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
//    }
}

//去掉返回手势监听
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Enable iOS 7 back gesture
    // 测试是否支持"返回手势"
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark TableView
//固定section高度: header高度
- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{
    return 20.0;
}

#pragma mark
#pragma mark 事件响应
//拦截"点击返回"事件
- (BOOL)navigationShouldPopOnBackButton
{
//    if ([self tryToPopBack]) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    return NO;
    return [self tryToPopBack];
}

//拦截”滑动返回"事件
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"%@", @"gesture");
    NSLog(@"%@", [gestureRecognizer class]);
    
//    if ([self tryToPopBack]) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    return NO;
    
    return [self tryToPopBack];
}


#pragma mark
#pragma mark 函数: 子类重写的是否返回上一层
- (BOOL)tryToPopBack
{
    return YES;
}

@end
