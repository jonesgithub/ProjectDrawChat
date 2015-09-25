//
//  ArthurProgressWithPercentLabelView.h
//  ArthurProgressWithPercentLabel
//
//  Created by lichen on 7/2/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArthurProgressWithPercentLabelView : UIView

@property float fHeightOfProgress;
@property float fHeightOfLabel;

@property (nonatomic, strong) NSNumber *percent;
@property (nonatomic, strong) UIView *viewOfBackground;
@property (nonatomic, strong) UIView *viewOfProgress;
@property (nonatomic, strong) UILabel *labelOfPercent;

- (void)initializeWithBackgroundColor:(UIColor *)backgroundColor tintColor:(UIColor *)tintColor heightOfProgress:(float)fheightOfProgress;
- (void)setPercent:(NSNumber *)percent;

@end
