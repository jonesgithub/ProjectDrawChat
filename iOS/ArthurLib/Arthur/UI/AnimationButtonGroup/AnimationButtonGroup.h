//
//  AnimationBubttonGroupViewController.h
//  AninationButtonGourp
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^onButtonValuesChanged)(NSArray *arrButtonEnables);

@interface AnimationButtonGroup : NSObject

//模拟按钮组: 使用UIControl模拟
@property (nonatomic, strong) NSMutableArray *arrUIControls;
@property (nonatomic, strong) NSMutableArray *arrButtonEnables;
@property (nonatomic, strong) onButtonValuesChanged handerButtonValuesChanged;

@property (nonatomic, strong) NSArray *arrButtonNames;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic, strong) UIColor *disableColor;
@property (nonatomic, strong) UIColor *enableColor;
@property (nonatomic, strong) UIColor *borderColor;
@property int nFontSize;
@property (nonatomic, strong) UIColor *fontColor;

//sample delegate
- (void)buttonToggleWithIndex:(int)nIndex enable:(BOOL)enable;

//初始化
- (void)addButtons:(NSArray *)arrButtonNames 
        withValues:(NSArray *)arrButtonEnables 
            inView:(UIView *)view
    withTopPadding:(int)nTopPadding 
   withLeftPadding:(int)nLeftPadding 
      withSeperate:(int)nSeperate
      disableColor:(UIColor *)disableColor 
       enableColor:(UIColor *)enableColor
       borderColor: (UIColor *)borderColor 
          fontSize:(int)nFontSize 
         fontColor:(UIColor *)fontColor
onButtonValuesChanged:(onButtonValuesChanged)handerButtonValuesChanged;

@end
