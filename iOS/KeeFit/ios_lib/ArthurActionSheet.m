//
//  ArthurActionSheet.m
//  MapNews
//
//  Created by lichen on 4/18/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import "ArthurActionSheet.h"

@implementation ArthurActionSheet

+ (void)showTitle:(NSString *)title 
           inView:(UIView *)view
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
    onDestructive:(VoidBlock)destructed
otherButtonTitles:(NSArray *)otherButtonTitles
         onOthers:(IndexBlock)othersed
cancelButtonTitle:(NSString*)cancelButtonTitle
         onCancel:(VoidBlock)canceled
{
    UIActionSheet *actionSheet = [[self alloc] initWithTitle:title
                                      destructiveButtonTitle:destructiveButtonTitle 
                                               onDestructive:destructed
                                           otherButtonTitles:otherButtonTitles
                                                    onOthers:othersed
                                           cancelButtonTitle:cancelButtonTitle
                                                    onCancel:canceled];
    [actionSheet showInView:view];
}

- (id)initWithTitle:(NSString *)title
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
        onDestructive:(VoidBlock)destructed
    otherButtonTitles:(NSArray *)otherButtonTitles
             onOthers:(IndexBlock)othersed
    cancelButtonTitle:(NSString*)cancelButtonTitle
             onCancel:(VoidBlock)canceled
{
    self = [super initWithTitle:title
                       delegate:self
              cancelButtonTitle:nil
         destructiveButtonTitle:destructiveButtonTitle
              otherButtonTitles:nil];
    for(NSString* otherButtonTitle in otherButtonTitles){
        [self addButtonWithTitle:otherButtonTitle];
    }
    [self addButtonWithTitle:cancelButtonTitle];
    
    self.destructiveButtonTitle = destructiveButtonTitle;
    self.destructed = destructed;
    self.otherButtonTitles = otherButtonTitles;
    self.othersed = othersed;
    self.cancelButtonTitle = cancelButtonTitle;
    self.canceled = canceled;
    
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d", buttonIndex);
    int index = (int)buttonIndex;
    if (self.destructiveButtonTitle) {
        index -= 1;
        if (index == -1) {
            self.destructed();
            return;
        }
    }
    [self othersAndCancelWithIndex:index];
}

- (void)othersAndCancelWithIndex:(int)index
{
    if (self.cancelButtonTitle && [self.otherButtonTitles count] == index) {
        self.canceled();
    } else {
        if (self.otherButtonTitles) {
            self.othersed(index);
        } else {
            NSLog(@"%@", @"程序错误: ArthurActionSheet: othersAndCancelWithIndex");
        }
    }
}

@end
