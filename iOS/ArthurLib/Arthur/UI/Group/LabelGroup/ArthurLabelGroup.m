//
//  ArthurLabelGroup.m
//  LabelGroup
//
//  Created by lichen on 7/3/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import "ArthurLabelGroup.h"

@implementation ArthurLabelGroup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initializeWithNames:(NSArray *)arrNames tintColor:(UIColor *)tintColor
{
    //remove掉所有原有子类
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //验证arrNames
    AssertClass(arrNames, NSArray);
    
    float fHeight = self.frame.size.height;
    float fUnitWidth = self.frame.size.width / [arrNames count];
    for (int index = 0; index < [arrNames count]; index++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(fUnitWidth * index, 0, fUnitWidth, fHeight)];
        label.textColor = tintColor;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:fHeight];
        AssertClass(arrNames[index], NSString);
        label.text = arrNames[index];
        [self addSubview:label];
    }
}

@end
