//
//  ArthurTimePickerController.h
//  KeeFit
//
//  Created by lichen on 6/10/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^onIndexChanged)(int nIndex);
typedef int (^onTotalCount)();
typedef NSString *(^onValueAtRow)(int nRow);

@interface ArthurSinglePicker : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerOfSingle;

@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, strong) onIndexChanged handerIndexChange;
@property (nonatomic, strong) onTotalCount handerTotalCount;
@property (nonatomic, strong) onValueAtRow handerValueAtRow;

- (void)setIndex:(int)nIndex;
- (void)totalCount:(onTotalCount)handerTotalCount valueAtRow:(onValueAtRow)handerValueAtRow indexChange:(onIndexChanged)handerIndexChange;

@property int nIndex;

@end
