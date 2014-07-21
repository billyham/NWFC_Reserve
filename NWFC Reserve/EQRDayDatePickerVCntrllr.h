//
//  EQRDayDatePickerVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 7/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRDayDatePickerVCntrllr : UIViewController

@property (strong, nonatomic) IBOutlet UIDatePicker* myDatePicker;
@property (strong, nonatomic) IBOutlet UIButton* myContinueButton;

-(NSDate*)retrieveSelectedDate;

@end
