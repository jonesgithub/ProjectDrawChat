//
//  ArthurBlockChain.m
//  KeeFit
//
//  Created by lichen on 5/18/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurBlockChain2.h"

@implementation ArthurBlockChain2

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.arrBlock = nil;
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

- (void)addBlock:(onBlockCall)block
{
    if (nil == self.arrBlock) {
        self.arrBlock = [[NSMutableArray alloc] init];
    }
    [self.arrBlock addObject:block];
}

- (void)start
{
    [self StepNext:YES];
}

- (void)clear
{
    self.nIndex = 0;
    self.arrBlock = nil;
    self.handerChainBreak = nil;
    self.handerChainDone = nil;
    self.handerChainNextStep = nil;
}

- (void)StepNext:(BOOL)bStepNext
{
    if (!bStepNext) {
        NSAssert(nil != self.handerChainBreak, @"没有chain断掉的回调");
        self.handerChainBreak();
        [self clear];
        return;
    }
    
    //如果有每步之后的回调，执行它
    if (nil != self.handerChainNextStep) {
        self.handerChainNextStep();
    }
    
    int nChainLength = (int)[self.arrBlock count];
    if (self.nIndex < nChainLength) {
        onBlockCall block= self.arrBlock[self.nIndex];
        self.nIndex++;
        block(self);
    } else{
        NSAssert(nil != self.handerChainDone, @"没有block chain执行完后的回调");
        self.handerChainDone();
        [self clear];
    }
}

@end
