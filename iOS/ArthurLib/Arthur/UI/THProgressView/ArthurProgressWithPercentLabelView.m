//
//  ArthurProgressWithPercentLabelView.m
//  ArthurProgressWithPercentLabel
//
//  Created by lichen on 7/2/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import "ArthurProgressWithPercentLabelView.h"

@implementation ArthurProgressWithPercentLabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)initializeWithBackgroundColor:(UIColor *)backgroundColor tintColor:(UIColor *)tintColor heightOfProgress:(float)fheightOfProgress
{
    //清空背景
    self.backgroundColor = [UIColor clearColor];
    
    //存高度
    self.fHeightOfProgress = fheightOfProgress;
    self.fHeightOfLabel = self.frame.size.height - fheightOfProgress;

    //线条背景
    self.viewOfBackground = [[UIView alloc] initWithFrame:CGRectMake(0, self.fHeightOfLabel, self.frame.size.width, self.fHeightOfProgress)];
    self.viewOfBackground.layer.cornerRadius = fheightOfProgress / 2;
    self.viewOfBackground.backgroundColor = backgroundColor;
    [self addSubview:self.viewOfBackground];
    
    //线条进度
    self.viewOfProgress = [[UIView alloc] initWithFrame:CGRectMake(0, self.fHeightOfLabel, 0, self.fHeightOfProgress)];
    self.viewOfProgress.layer.cornerRadius = fheightOfProgress / 2;
    self.viewOfProgress.backgroundColor = tintColor;
    [self addSubview:self.viewOfProgress];
    
    //描述label
    float fFontHeight = self.fHeightOfLabel * 0.8;
    CGSize detailSize = [ArthurCompatible sizeOfString:@"100%" withFontSize:fFontHeight];
    self.labelOfPercent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, detailSize.width, fFontHeight)];
    self.labelOfPercent.textColor = tintColor;
    self.labelOfPercent.font = [UIFont systemFontOfSize:fFontHeight];
    self.labelOfPercent.backgroundColor = [UIColor clearColor];
    [self addSubview:self.labelOfPercent];
}

- (void)setPercent:(NSNumber *)percent
{
    [UIView animateWithDuration:0.1 animations:^{
        //进度
        float fProgress = [percent intValue] * self.frame.size.width / 100.0;
        self.viewOfProgress.frame = CGRectMake(0, self.fHeightOfLabel, fProgress, self.fHeightOfProgress);
        //label位置
        float fLabelPositon = [percent intValue] * (self.frame.size.width - self.labelOfPercent.frame.size.width) / 100.0;
        self.labelOfPercent.text = [NSString stringWithFormat:@"%2d%%", [percent intValue]];
        self.labelOfPercent.frame = CGRectMake(fLabelPositon, 0, self.labelOfPercent.frame.size.width, self.labelOfPercent.frame.size.height);
    }];
}

@end
