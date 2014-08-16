//
//  EQRDayExtendedPickerVC.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRDayExtendedPickerVC : UIViewController

@property (strong, nonatomic) IBOutlet UIDatePicker* myDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* myTimePicker;
@property (strong, nonatomic) IBOutlet UIButton* myContinueButton;
@property (strong, nonatomic) IBOutlet UIButton* myExtendedButton;

-(NSDate*)retrieveSelectedDate;


@end
