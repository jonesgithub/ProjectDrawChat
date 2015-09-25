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
@interface ArthurBlockChain2 : NSObject

typedef void (^onBlockCall)(ArthurBlockChain2 *);

- (void)addBlock:(onBlockCall)block;
- (void)chainNextStep:(onChainNextStep)handerChianNextStep;
- (void)chainBreak:(onChainBreak)handerChianBreak;
- (void)chainDone:(onChainDone)handerChainDone;
- (void)start;
- (void)StepNext:(BOOL)bStepNext;

//private
@property (strong, nonatomic) onChainNextStep handerChainNextStep;
@property (strong, nonatomic) onChainBreak handerChainBreak;
@property (strong, nonatomic) onChainDone handerChainDone;
@property (strong, nonatomic) NSMutableArray *arrBlock;
@property int nIndex;
- (void)clear;

@end
