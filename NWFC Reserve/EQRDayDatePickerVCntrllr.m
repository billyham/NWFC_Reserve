//
//  EQRDayDatePickerVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 7/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRDayDatePickerVCntrllr.h"

@interface EQRDayDatePickerVCntrllr ()

@end

@implementation EQRDayDatePickerVCntrllr

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
    // Do any additional setup after loading the view from its nib.
}


-(NSDate*)retrieveSelectedDate{
    
    NSDate* newDate = self.myDatePicker.date;
    
    return newDate;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
