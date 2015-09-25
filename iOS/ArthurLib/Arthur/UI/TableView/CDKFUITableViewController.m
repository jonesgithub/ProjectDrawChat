//
//  CDKFUITableViewController.m
//  KeeFit
//
//  Created by lichen on 6/19/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "CDKFUITableViewController.h"

@interface CDKFUITableViewController ()

@end

@implementation CDKFUITableViewController

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
    self.bUIFunctionCalled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //判断UI函数是否已经被调用
    NSAssert(self.bUIFunctionCalled, @"Warning: 本类中的UI函数未被调用!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)UI
{
    //验证数据
    AssertClass(self.title, NSString);
    
    //背景色
    self.view.backgroundColor = kBackgroundColor;
    
    //隐藏掉TableView多条线
    UIView *view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    //tableview的seperator颜色
    [self.tableView setSeparatorColor:kTableViewSeperatorColor];
    
    //navigation的标题
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:kNavigationTitleFont];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = kNavigationTitleColor;
    self.navigationItem.titleView = label;
    label.text = self.title;
    [label sizeToFit];
    
    //navigation的回退
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 14, 24)];
    [button setImage:[UIImage imageNamed:@"btn_last_0.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_last_1.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(backButtonClicked)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]
                                   initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    //navigation底部的白边
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(
                                                                 0,
                                                                 self.navigationController.navigationBar.frame.size.height-1,
                                                                 self.navigationController.navigationBar.frame.size.width, 
                                                                 1)];
    [navBorder setBackgroundColor:kNavigationBottomBorderColor];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    self.bUIFunctionCalled = YES;
}

- (void)backButtonClicked
{
    if ([self tryToPopBack]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark
#pragma mark 函数: 子类重写的是否返回上一层
- (BOOL)tryToPopBack
{
    return YES;
}

@end
