//
//  UIView+FindFirstResponder.m
//  MapNews
//
//  Created by lichen on 4/17/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import "UIView+FindFirstResponder.h"

@implementation UIView (FindFirstResponder)

- (id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;        
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

@end
