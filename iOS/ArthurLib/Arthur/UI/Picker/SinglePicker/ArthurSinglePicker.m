//
//  ArthurTimePickerController.m
//  KeeFit
//
//  Created by lichen on 6/10/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import "ArthurSinglePicker.h"

@implementation ArthurSinglePicker

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
    [self updateIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setIndex:(int)nIndex
{
    self.nIndex = nIndex;
    [self updateIndex];
}

- (void)totalCount:(onTotalCount)handerTotalCount valueAtRow:(onValueAtRow)handerValueAtRow indexChange:(onIndexChanged)handerIndexChange
{
    self.handerTotalCount = handerTotalCount;
    self.handerValueAtRow = handerValueAtRow;
    self.handerIndexChange = handerIndexChange;
}

- (void)updateIndex
{
    [self.pickerOfSingle selectRow:self.nIndex inComponent:0 animated:NO];
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView: (UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.handerValueAtRow) {
        return self.handerTotalCount();
    } else {
        return 0;
    }
}

#pragma Picker Delegate Methods
- (NSString *)pickerView: (UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.handerValueAtRow) {
        return self.handerValueAtRow((int)row);
    } else {
        return @"程序错误于ArthurSinglePicker";
    }
}

- (void)pickerView: (UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.handerIndexChange) {
        self.handerIndexChange((int)row);
    }
}

@end
