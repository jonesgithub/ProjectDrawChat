//
//  ArthurBlockChain.h
//  KeeFit
//
//  Created by lichen on 5/18/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^onChainNextStep)();
typedef void (^onChainBreak)();
typedef void (^onChainDone)();

//块链
@interface ArthurBlockChain : NSObject

@property (weak, nonatomic) id delegate;

@property (strong, nonatomic) onChainNextStep handerChainNextStep;
@property (strong, nonatomic) onChainBreak handerChainBreak;
@property (strong, nonatomic) onChainDone handerChainDone;
@property (strong, nonatomic) NSMutableArray *arrSelectorString;
@property int nIndex;

- (void)chainNextStep:(onChainNextStep)handerChianNextStep;
- (void)chainBreak:(onChainBreak)handerChianBreak;
- (void)chainDone:(onChainDone)handerChainDone;
- (void)addSelector:(SEL)selector;
- (void)start;
- (void)reSet;
- (void)StepNext:(BOOL)bStepNext;

@end
