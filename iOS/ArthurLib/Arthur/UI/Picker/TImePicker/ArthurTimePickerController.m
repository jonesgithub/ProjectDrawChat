//
//  ArthurTimePickerController.m
//  KeeFit
//
//  Created by lichen on 6/10/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurTimePickerController.h"

@implementation ArthurTimePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self pickerUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setTime:(int)nTimeOfInt
{
    self.nTimeOfInt = nTimeOfInt;
    [self pickerUpdate];
}

- (void)pickerUpdate
{
    int nHour = self.nTimeOfInt / 100;
    int nMinute = self.nTimeOfInt % 100;
    [self.pickerOfTime selectRow:nHour inComponent:0 animated:NO];
    [self.pickerOfTime selectRow:nMinute inComponent:1 animated:NO];
}

- (void)timeChanged:(onTimeChanged)handerTimeChanged
{
    self.handerTimeChanged = handerTimeChanged;
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView: (UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 24;
    } else {
        return 60;
    }
}

#pragma Picker Delegate Methods
- (NSString *)pickerView: (UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%02ld", (long)row];
}

- (void)pickerView: (UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int nHour = (int)[self.pickerOfTime selectedRowInComponent:0];
    int nMinute = (int)[self.pickerOfTime selectedRowInComponent:1];
    int nTimeOfInt = nHour * 100 + nMinute;
    if (self.handerTimeChanged) {
        self.handerTimeChanged(nTimeOfInt);
    }
}

@end
