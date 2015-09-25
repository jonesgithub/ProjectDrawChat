//
//  THProgressView.m
//
//  Created by Tiago Henriques on 10/22/13.
//  Copyright (c) 2013 Tiago Henriques. All rights reserved.
//

#import "ArthurProgressView.h"

#import <QuartzCore/QuartzCore.h>


static const CGFloat kArthurBorderWidth = 0.5f;

#pragma mark -
#pragma mark THProgressLayer

@implementation ArthurProgressView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInContext:context];
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = CGRectInset(self.bounds, kArthurBorderWidth, kArthurBorderWidth);
    
    CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
    CGRect progressRect = CGRectInset(rect, 2 * kArthurBorderWidth, 2 * kArthurBorderWidth);
    progressRect.size.width = fmaxf(self.progress * progressRect.size.width, 2.0f * 0);
    progressRect.size.width = progressRect.size.width - 2;
    [self drawRectangleInContext:context inRect:progressRect withRadius:0];
    CGContextFillPath(context);
}

- (void)drawRectangleInContext:(CGContextRef)context inRect:(CGRect)rect withRadius:(CGFloat)radius
{
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    self.progress = progress;
    [self setNeedsDisplay];
}
@end
