//
//  ArthurFile.m
//  NSBundle
//
//  Created by lichen on 5/16/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import "ArthurFile.h"

@implementation ArthurFile

+ (NSString*)docPath
{
    NSArray* array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if([array count] > 0){
        return [array objectAtIndex: 0];  // the same as: return array[0];
    } else {
        return @"";
    }
}

@end
