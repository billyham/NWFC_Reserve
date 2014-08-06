//
//  EQRStaffUserPickerViewController.h
//  NWFC Reserve
//
//  Created by Ray Smith on 8/4/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRContactNameItem.h"

@interface EQRStaffUserPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSArray* arrayOfContactObjects;
@property (strong, nonatomic) IBOutlet UIButton* continueButton;
@property (strong, nonatomic) IBOutlet UIPickerView* myPicker;

@end
