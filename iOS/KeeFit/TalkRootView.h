//
//  TalkRootView.h
//  Talk
//
//  Created by lichen on 9/28/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkRootView : UIView

@property (nonatomic, strong) NSMutableArray *arrPoints;
@property (nonatomic, strong) NSMutableArray *arrAllPoints;

- (void)sectionEnds;

@end
