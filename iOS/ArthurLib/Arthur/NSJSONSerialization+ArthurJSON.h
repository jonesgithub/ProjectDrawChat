//
//  NSJSONSerialization+ArthurJSON.h
//  JSON Learn
//
//  Created by lichen on 3/31/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (ArthurJSON)

+ (NSString *)toJSON: (id)data;
+ (id)evalJSON: (NSString *)strJSON;

@end
