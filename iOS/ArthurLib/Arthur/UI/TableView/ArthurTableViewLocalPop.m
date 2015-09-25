//
//  ArthurViewController.m
//  StaticCell
//
//  Created by lichen on 6/9/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import "ArthurTableViewLocalPop.h"

@interface ArthurTableViewLocalPop ()

@end

@implementation ArthurTableViewLocalPop

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.tableViewOfData.scrollEnabled = NO;
    self.bSelected = NO;
    [self setExtraCellLineHidden:self.tableView];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //mutable copy the cells
    self.sectionCells = [[NSMutableArray alloc] init];
    NSArray *arrSectionCells = [self staticSectionCells];
    for (id arrCells in arrSectionCells) {
        if ([arrCells isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrMutableCells = [arrCells mutableCopy];
            [self.sectionCells addObject:arrMutableCells];
        } else {
//            NSLog(@"%@", [arrCells class]);
            AssertClass(arrCells, UITableViewCell);
            NSMutableArray *arrMutableCells = [[NSMutableArray alloc] init];
            [arrMutableCells addObject:arrCells];
            [self.sectionCells addObject:arrMutableCells];
        }
    }
}

//隐藏掉多条线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

//静单元素
- (NSArray *)staticSectionCells
{
    return nil;
}

//对每一个cell的pop cell
- (UITableViewCell *)popCellAtIndexpath:(NSIndexPath *)indexPath;
{
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.sectionCells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrCell = self.sectionCells[section];
    return arrCell.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.bSelected) {
        self.bSelected = NO;
        NSIndexPath *pathDelete = [NSIndexPath indexPathForItem:self.selectedIndexPath.row+1 inSection:self.selectedIndexPath.section];
        [self.sectionCells[pathDelete.section] removeObjectAtIndex:pathDelete.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[pathDelete] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
        
        if (![indexPath isEqual:self.selectedIndexPath]) {
            //如果同section，已删除在前，因为多加一条的原因，应减1
            if ((indexPath.section == self.selectedIndexPath.section) && (indexPath.row > self.selectedIndexPath.row)) {
                self.selectedIndexPath = [NSIndexPath indexPathForItem:(indexPath.row - 1) inSection:indexPath.section];
            } else {
                self.selectedIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
            }
            
            UITableViewCell *cell = [self popCellAtIndexpath:self.selectedIndexPath];
            if (cell) {
                self.bSelected = YES;
                //添加
                NSIndexPath *pathAdd = [NSIndexPath indexPathForItem:(self.selectedIndexPath.row + 1) inSection:indexPath.section];
                [self.sectionCells[indexPath.section] insertObject:cell atIndex:pathAdd.row];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[pathAdd] withRowAnimation:UITableViewRowAnimationMiddle];
                [self.tableView endUpdates];
            }
        }
    } else {
        UITableViewCell *cell = [self popCellAtIndexpath:indexPath];
        if (cell) {
            self.bSelected = YES;
            self.selectedIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
            //数据
            NSIndexPath *pathAdd = [NSIndexPath indexPathForItem:(self.selectedIndexPath.row+1) inSection:indexPath.section];
            [self.sectionCells[pathAdd.section] insertObject:cell atIndex:pathAdd.row];
            //cell
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[pathAdd] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.tableView endUpdates];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.sectionCells[indexPath.section][indexPath.row];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.sectionCells[indexPath.section][indexPath.row];
}

@end
