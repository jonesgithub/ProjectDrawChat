//
//  TalkRootViewController.m
//  Talk
//
//  Created by lichen on 9/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "TalkRootViewController.h"

@implementation TalkRootViewController

#pragma mark
#pragma mark 初始化
- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];  
    CGPoint currentLocation = [touch locationInView:self.view];
    if (self.talkRootView.arrPoints == nil) {
        self.talkRootView.arrPoints = [[NSMutableArray alloc] init];
    }
    [self.talkRootView.arrPoints addObject:@(currentLocation.x)];
    [self.talkRootView.arrPoints addObject:@(currentLocation.y)];
    [self.talkRootView setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.talkRootView sectionEnds];
}

@end
