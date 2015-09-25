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

@interface ArthurNormalActionSheet : UIActionSheet<UIActionSheetDelegate>

@property (strong, nonatomic) NSString *destructiveButtonTitle;
@property (strong, nonatomic) NSArray *otherButtonTitles;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) VoidBlock destructed;
@property (strong, nonatomic) VoidBlock canceled;

//最常规的应用: 两个按钮，一个去取消，一个确认
+ (void)showTitle:(NSString *)title 
           inView:(UIView *)view
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
    onDestructive:(VoidBlock)destructed
cancelButtonTitle:(NSString*)cancelButtonTitle
         onCancel:(VoidBlock)canceled;

- (id)initWithTitle:(NSString *)title
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
      onDestructive:(VoidBlock)destructed
  cancelButtonTitle:(NSString*)cancelButtonTitle
           onCancel:(VoidBlock)canceled;

@end
