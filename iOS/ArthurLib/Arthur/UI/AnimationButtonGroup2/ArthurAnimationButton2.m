//
//  ArthurAnimationButton.m
//  AninationButtonGourp
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import "ArthurAnimationButton2.h"

@implementation ArthurAnimationButton2

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
    [self setNeedsDisplay];
    [self.controller buttonToggleWithIndex:self.nIndex enable:self.bEnable];
}

- (void)addTouchGesture
{
    UITapGestureRecognizer *backgroundTouchedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched)];
    backgroundTouchedGesture.numberOfTapsRequired = 1;   
    [self addGestureRecognizer:backgroundTouchedGesture];
}

- (void) initializeShowWithController:(AnimationButtonGroup2 *)controller withIndex:(int)nIndex
{
    self.nIndex = nIndex;
    self.controller = controller;
    self.bEnable = [self.controller.arrButtonEnables[nIndex] boolValue];
    
    //设置tag，以好识别
    self.tag = self.nIndex;
    
    //背景色
    self.backgroundColor = self.controller.disableColor;
    
    self.imageSelected = [UIImage imageNamed:@"selected.png"];

    //显示
    [self.controller.superView addSubview:self];
    
    //添加事件响应
    [self addTouchGesture];
}

- (void)drawRect:(CGRect)rect
{    
    //边框
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = self.controller.borderColor.CGColor;
    
    //显示button的name
    [[UIColor whiteColor] set];
    NSString *strToShow = self.controller.arrButtonNames[self.nIndex];
    AssertClass(strToShow, NSString);
    UIFont *font = [UIFont systemFontOfSize:self.controller.nFontSize];    
    CGSize size = [strToShow sizeWithFont:font];
    [strToShow drawAtPoint:CGPointMake(self.frame.size.width / 2 - size.width / 2, self.frame.size.height / 2 - size.height / 2) withFont:font];
    
    //画图
    if (self.bEnable) {
        [self.controller.enableColor setFill];
    } else {
        [self.controller.disableColor setFill];
    }
    float fCircleRadius = 3.0;
    float fX = self.frame.size.width / 2;
    float fY = self.frame.size.height / 2 + size.height + fCircleRadius;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, fX, fY, fCircleRadius, 0, 2*M_PI, 0);  
    CGContextDrawPath(context, kCGPathFill);
}

@end
