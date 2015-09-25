//
//  ArthurAnimationButton.m
//  AninationButtonGourp
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import "ArthurAnimationButton.h"

@implementation ArthurAnimationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)backgroundTouched
{
    self.bEnable = !self.bEnable;
    //当前色
    if (self.bEnable) {
        self.backgroundColor = self.controller.enableColor;
    } else {
        self.backgroundColor = self.controller.disableColor;
    }
    [self setNeedsDisplay];
    [self.controller buttonToggleWithIndex:self.nIndex enable:self.bEnable];
}

- (void)addTouchGesture
{
    UITapGestureRecognizer *backgroundTouchedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched)];
    backgroundTouchedGesture.numberOfTapsRequired = 1;   
    [self addGestureRecognizer:backgroundTouchedGesture];
}

- (void) initializeShowWithController:(AnimationButtonGroup *)controller withIndex:(int)nIndex
{
    self.nIndex = nIndex;
    self.controller = controller;
    self.bEnable = [self.controller.arrButtonEnables[nIndex] boolValue];
    
    //设置tag，以好识别
    self.tag = self.nIndex;
    
    //当前色
    if (self.bEnable) {
        self.backgroundColor = self.controller.enableColor;
    } else {
        self.backgroundColor = self.controller.disableColor;
    }

    //显示
    [self.controller.superView addSubview:self];
    
    //添加事件响应
    [self addTouchGesture];
}

- (void)drawRect:(CGRect)rect
{    
    //显示button的name
    NSString *strToShow = self.controller.arrButtonNames[self.nIndex];
    AssertClass(strToShow, NSString);
    UIFont *font = [UIFont systemFontOfSize:self.controller.nFontSize];    
    CGSize size = [strToShow sizeWithFont:font];
    [strToShow drawAtPoint:CGPointMake(self.frame.size.width / 2 - size.width / 2, self.frame.size.height / 2 - size.height / 2) withFont:font];
}

@end
