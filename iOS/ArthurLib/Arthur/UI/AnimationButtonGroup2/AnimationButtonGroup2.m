//
//  AnimationBubttonGroupViewController.m
//  AninationButtonGourp
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import "AnimationButtonGroup2.h"
#import "ArthurAnimationButton2.h"

@implementation AnimationButtonGroup2

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
onButtonValuesChanged:(onButtonValuesChanged)handerButtonValuesChanged
{
    AssertClass(arrButtonEnables, NSArray);
    AssertClass(arrButtonNames, NSArray);
    NSAssert([arrButtonNames count] == [arrButtonEnables count], @"添加的button的数量，从名字与Enable计算应该一样");
    self.handerButtonValuesChanged = handerButtonValuesChanged;
    self.arrButtonEnables = [arrButtonEnables mutableCopy];
    
    self.arrButtonNames = [arrButtonNames copy];
    self.superView = view;
    self.disableColor = disableColor;
    self.enableColor = enableColor;
    self.borderColor = borderColor;
    self.nFontSize = nFontSize;
    self.fontColor = fontColor;
    
    float fStartX = nLeftPadding;
    float fStartY = nTopPadding;
    
    float fButtonHeight = view.frame.size.height - 2 * nTopPadding;
    float fButtonWidth = (view.frame.size.width -  ([arrButtonNames count] - 1)* nSeperate - 2 * nLeftPadding) / [arrButtonNames count];
    
    //清空界面
    if (self.arrUIControls != nil) {
        for (ArthurAnimationButton2 *button in self.arrUIControls) {
            [button removeFromSuperview];
        }
    }
    self.arrUIControls = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [arrButtonNames count]; i++) {
        CGRect rectOfButton = CGRectMake(fStartX, fStartY, fButtonWidth+1, fButtonHeight);
        fStartX += fButtonWidth + nSeperate;
        ArthurAnimationButton2 *button = [[ArthurAnimationButton2 alloc] initWithFrame:rectOfButton];
        [button initializeShowWithController:self withIndex:i];
        
        //存储
        [self.arrUIControls addObject:button];
    }
}

- (void)buttonToggleWithIndex:(int)nIndex enable:(BOOL)enable
{
    self.arrButtonEnables[nIndex] = [[NSNumber alloc] initWithBool:enable];
    if (self.handerButtonValuesChanged) {
        self.handerButtonValuesChanged([self.arrButtonEnables copy]);
    }
}

@end
