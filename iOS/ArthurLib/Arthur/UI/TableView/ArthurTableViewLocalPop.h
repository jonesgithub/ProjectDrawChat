//
//  ArthurViewController.h
//  StaticCell
//
//  Created by lichen on 6/9/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArthurTableViewLocalPop : UITableViewController

@property (strong, nonatomic) NSMutableArray *sectionCells;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property BOOL bSelected;

- (NSArray *)staticSectionCells;
- (UITableViewCell *)popCellAtIndexpath:(NSIndexPath *)indexPath;

@end
