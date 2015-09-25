//
//  MNLib.m
//  地图新闻
//
//  Created by lichen on 4/11/14.
//  Copyright (c) 2014 lichen. All rights reserved.
//

#import "MNLib.h"

@implementation MNLib

+(void)showTitle:(NSString *)strTitle message:(NSString *)strMessage buttonName:(NSString *)strButtonName
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMessage
                                                   delegate:nil
                                          cancelButtonTitle:strButtonName
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showTitle:(NSString *)strTitle message:(NSString *)strMessage delayTime:(float)delayTime completion:(VoidBlock)completion
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMessage
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];
    
    //很牛逼的NSTimer的block用法
    [NSTimer scheduledTimerWithTimeInterval:delayTime
                                     target:[NSBlockOperation blockOperationWithBlock:^{
        completion();
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }]
                                   selector:@selector(main)
                                   userInfo:nil
                                    repeats:NO
     ];
}

+(BOOL)dictionary:(NSDictionary *)dict hasKeys:(NSArray *)arrKeys
{
    for (int index = 0; index < [arrKeys count]; index++) {
        if (![dict objectForKey:arrKeys[index]]) {
            return NO;
        }
    }
    return YES;
}

+ (void)delay:(float)delayTime doSomething:(VoidBlock)something
{
    [NSTimer scheduledTimerWithTimeInterval:delayTime
                                     target:[NSBlockOperation blockOperationWithBlock:^{
        something();
    }]
                                   selector:@selector(main)
                                   userInfo:nil
                                    repeats:NO
     ];
}

+ (NSArray *)getBiggerFrom:(NSArray *)array1 withArray:(NSArray *)array2
{
    if ([array1 count] != [array2 count]) {
        NSLog(@"%@", @"数组不一样大");
        return nil;
    } else {
        NSMutableArray *arrayReturn = [[NSMutableArray alloc] initWithCapacity:[array1 count]];
        for (int index = 0; index < [array1 count]; index++) {
            if (array1[index] > array2[index]) {
                [arrayReturn addObject:array1[index]];
            } else {
                [arrayReturn addObject:array2[index]];
            }
        }
        return [NSArray arrayWithArray:arrayReturn];
    }
}

@end
