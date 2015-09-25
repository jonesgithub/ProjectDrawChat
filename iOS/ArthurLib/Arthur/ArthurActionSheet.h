//
//  ArthurActionSheet.h
//  精简选择对话框
//  主要用block的方式代替delegate
//
//  Created by lichen on 4/18/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VoidBlock)();
typedef void (^IndexBlock)(int buttonIndex);

@interface ArthurActionSheet : UIActionSheet<UIActionSheetDelegate>

@property (strong, nonatomic) NSString *destructiveButtonTitle;
@property (strong, nonatomic) NSArray *otherButtonTitles;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) VoidBlock destructed;
@property (strong, nonatomic) IndexBlock othersed;
@property (strong, nonatomic) VoidBlock canceled;

/**
 *  精简选择对话框
 *  主要用block的方式代替delegate
 *
 *  @param title                  显示的标题
 *  @param view                   显示在哪个view里面
 *  @param destructiveButtonTitle 取消按钮标题
 *  @param destructed             响应取消事件
 *  @param otherButtonTitles      其它按钮名字数组
 *  @param othersed               响应其它按钮的事件
 *  @param cancelButtonTitle      取消按钮标题
 *  @param canceled               响应消按事件
 */
+ (void)showTitle:(NSString *)title 
           inView:(UIView *)view
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
    onDestructive:(VoidBlock)destructed
otherButtonTitles:(NSArray *)otherButtonTitles
         onOthers:(IndexBlock)othersed
cancelButtonTitle:(NSString*)cancelButtonTitle
         onCancel:(VoidBlock)canceled;

- (id)initWithTitle:(NSString *)title
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
    onDestructive:(VoidBlock)destructed
otherButtonTitles:(NSArray *)otherButtonTitles
         onOthers:(IndexBlock)othersed
cancelButtonTitle:(NSString*)cancelButtonTitle
         onCancel:(VoidBlock)canceled;

//UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"title"
//                                                         delegate:self
//                                                cancelButtonTitle:nil
//                                           destructiveButtonTitle:@"destructive"
//                                                otherButtonTitles:@"other1", @"other2", nil];
//[actionSheet showInView:self.view];

@end
