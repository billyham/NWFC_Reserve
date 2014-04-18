//
//  EQREditorRenterVCntrllrViewController.h
//  NWFC Reserve
//
//  Created by Ray Smith on 4/17/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREditorRenterVCntrllr : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSString* renter_type;
@property (nonatomic, strong) IBOutlet UIPickerView* renterTypePicker;
@property (strong, nonatomic) IBOutlet UIButton* saveButton;


-(void)initialSetup;

@end
