//
//  ColorHexConvert.h
//  Talk
//
//  Created by lichen on 9/30/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (ColorHexConvert)

+(UIColor *)colorFromHexString:(NSString*)colorString;
+(NSString*)stringFromColor:(UIColor*)color;

-(void)getRGBComponents:(CGFloat [3])components;

@end
