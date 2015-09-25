//
//  ArthurLabelGroup.h
//  LabelGroup
//
//  Created by lichen on 7/3/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArthurLabelGroup : UIView

/**
 *  初始化label与颜色
 *
 *  @param arrNames  label名字数组
 *  @param tintColor label颜色
 */
- (void)initializeWithNames:(NSArray *)arrNames tintColor:(UIColor *)tintColor;

@end
