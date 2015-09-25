//
//  ArthurDialogTimePickerController.h
//  KeeFit
//
//  Created by lichen on 6/10/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^onTimeChanged)(int nTimeOfInt);

@interface ArthurDialogTimePickerController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerOfTime;

@property (nonatomic, strong) onTimeChanged handerTimeChanged;

//eg: 8:23 => 823
- (void)setTime:(int)nTimeOfInt;
- (void)timeChanged:(onTimeChanged)handerTimeChanged;

@property int nTimeOfInt;

@end
