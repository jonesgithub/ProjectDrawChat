//
//  TalkRootView.h
//  Talk
//
//  Created by lichen on 9/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TalkConstant.h"
#import "TalkEventRouter.h"

@interface TalkRootView : UIView

@property (nonatomic, strong) NSTimer *timerFreshView;

@property (nonatomic, strong) TalkEventRouter *talkEventRouterLocal;
@property (nonatomic, strong) TalkEventRouter *talkEventRouterRemote;

@end
