//
//  NSJSONSerialization+ArthurJSON.m
//  JSON Learn
//
//  Created by lichen on 3/31/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import "NSJSONSerialization+ArthurJSON.h"

@implementation NSJSONSerialization (ArthurJSON)

+ (NSString *)toJSON: (id)data
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:kNilOptions
                                                         error:&error];
    NSString* strJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([jsonData length] > 0 && error == nil){
        return strJSON;
    }else{
        NSLog(@"converter failed with error: %@", error.localizedDescription);
        return nil;
    }
}

+ (id)evalJSON: (NSString *)strJSON
{
    NSData* data = [strJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil){
        return nil;
    } else {
        return result;
    }
}

@end