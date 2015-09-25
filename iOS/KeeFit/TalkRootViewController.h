//
//  TalkRootViewController.h
//  Talk
//
//  Created by lichen on 9/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TalkRootView.h"
#import "TalkConstant.h"
#import "GCDAsyncSocket.h"

@interface TalkRootViewController : UIViewController<GCDAsyncSocketDelegate>

//socket
@property (nonatomic, strong) GCDAsyncSocket *client;
@property BOOL bConnected;

@property (strong, nonatomic) IBOutlet TalkRootView *talkRootView;
@property (nonatomic, strong) NSTimer *timerPauseToErase;

@property (nonatomic, strong) NSString *strLast;

@end
