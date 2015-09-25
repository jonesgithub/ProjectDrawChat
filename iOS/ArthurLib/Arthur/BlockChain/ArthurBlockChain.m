//
//  ArthurBlockChain.m
//  KeeFit
//
//  Created by lichen on 5/18/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurBlockChain.h"

@implementation ArthurBlockChain

- (id)init
{
    self = [super init];
    if (self) {
        self.arrSelectorString = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.arrSelectorString = nil;
}

- (void)chainNextStep:(onChainNextStep)handerChainNextStep
{
    self.handerChainNextStep = handerChainNextStep;
}

- (void)chainBreak:(onChainBreak)handerChianBreak
{
    self.handerChainBreak = handerChianBreak;
}

- (void)chainDone:(onChainDone)handerChainDone
{
    self.handerChainDone = handerChainDone;
}

- (void)addSelector:(SEL)selector
{
    [self.arrSelectorString addObject:NSStringFromSelector(selector)];
}

- (void)start
{
    [self reSet];
    [self StepNext:YES];
}

- (void)reSet
{
    self.nIndex = 0;
}

- (void)StepNext:(BOOL)bStepNext
{
    if (!bStepNext) {
        if (self.handerChainBreak) {
            self.handerChainBreak();
        }
        [self reSet];
        return;
    }
    
    if (!self.delegate) {
        NSLog(@"%@", @"程序错误，未设置delegate");
        return;
    }
    
    if (self.handerChainNextStep) {
        self.handerChainNextStep();
    }
    
    int nChainLength = (int)[self.arrSelectorString count];
    if (self.nIndex < nChainLength) {
        SEL selector = NSSelectorFromString(self.arrSelectorString[self.nIndex]);
        self.nIndex++;
        if ([self.delegate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.delegate performSelector:selector withObject:nil];
#pragma clang diagnostic pop
        } else {
            NSLog(@"块链出现错误: %@", NSStringFromSelector(selector));
        }
    } else{
        [self reSet];
        if (self.handerChainDone) {
            self.handerChainDone();
        }
    }
}

@end
