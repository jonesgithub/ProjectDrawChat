//
//  ArthurActionSheet.m
//  MapNews
//
//  Created by lichen on 4/18/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import "ArthurNormalActionSheet.h"

@implementation ArthurNormalActionSheet

+ (void)showTitle:(NSString *)title 
           inView:(UIView *)view
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
    onDestructive:(VoidBlock)destructed
cancelButtonTitle:(NSString*)cancelButtonTitle
         onCancel:(VoidBlock)canceled
{
    UIActionSheet *actionSheet = [[self alloc] initWithTitle:title
                                      destructiveButtonTitle:destructiveButtonTitle 
                                               onDestructive:destructed
                                           cancelButtonTitle:cancelButtonTitle
                                                    onCancel:canceled];
    [actionSheet showInView:view];
}

- (id)initWithTitle:(NSString *)title
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
      onDestructive:(VoidBlock)destructed
  cancelButtonTitle:(NSString*)cancelButtonTitle
           onCancel:(VoidBlock)canceled
{
    AssertClass(destructiveButtonTitle, NSString);
    AssertClass(cancelButtonTitle, NSString);
    NSAssert(destructed, @"摧毁按钮响应函数不能为空");
    NSAssert(canceled, @"取消按钮响应函数不能为空");
    
    self = [super initWithTitle:title
                       delegate:self
              cancelButtonTitle:cancelButtonTitle
         destructiveButtonTitle:destructiveButtonTitle
              otherButtonTitles:nil];
    
    self.destructed = destructed;
    self.canceled = canceled;
    
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"%d", (int)buttonIndex);
    if (buttonIndex == 0) {
        NSAssert(self.destructed, @"摧毁按钮响应函数不能为空");
        self.destructed();
    }
    if (buttonIndex == 1) {
        NSAssert(self.canceled, @"取消按钮响应函数不能为空");
        self.canceled();
    }
}

@end
