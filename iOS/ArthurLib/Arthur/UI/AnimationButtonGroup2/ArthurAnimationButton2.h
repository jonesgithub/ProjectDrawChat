//
//  ArthurAnimationButton.h
//  AninationButtonGourp
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationButtonGroup2.h"

@interface ArthurAnimationButton2 : UIControl

@property (nonatomic, weak) AnimationButtonGroup2 *controller;
@property int nIndex;
@property BOOL bEnable;

@property (nonatomic, strong) UIImage *imageSelected;

- (void) initializeShowWithController:(AnimationButtonGroup2 *)controller withIndex:(int)nIndex;


@end
