//
//  CDKFUITableViewController.h
//  KeeFit
//
//  Created by lichen on 6/19/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDKFUITableViewController: UITableViewController

@property BOOL bUIFunctionCalled;

- (void)UI;
- (BOOL)tryToPopBack;

@end
