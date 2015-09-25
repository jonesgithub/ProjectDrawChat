//
//  ArthurActionSheet.h
//  MapNews
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
