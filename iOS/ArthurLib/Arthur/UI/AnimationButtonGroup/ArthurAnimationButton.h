//
//  ArthurAnimationButton.h
//  AninationButtonGourp
//
//  Created by lichen on 6/12/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationButtonGroup.h"

@interface ArthurAnimationButton : UIControl

@property (nonatomic, weak) AnimationButtonGroup *controller;
@property int nIndex;
@property BOOL bEnable;

- (void) initializeShowWithController:(AnimationButtonGroup *)controller withIndex:(int)nIndex;


@end
