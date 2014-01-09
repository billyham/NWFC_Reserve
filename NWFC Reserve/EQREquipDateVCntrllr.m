//
//  EQREquipDateVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/30/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQREquipDateVCntrllr.h"
#import "EQRScheduleRequestItem.h"
#import "EQRScheduleRequestManager.h"


@interface EQREquipDateVCntrllr ()

@property (strong, nonatomic) IBOutlet UIDatePicker* pickUpDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnDatePicker;

@end

@implementation EQREquipDateVCntrllr

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
	// Do any additional setup after loading the view.
}


#pragma mark - UIDatePickerMethods

-(IBAction)receivePickUpDate:(id)sender{
    
    //set pick up date
    self.pickUpDate = [sender date];
    
    //max time by adding  three days to the pickup date
    NSDate* datePlusThree = [self.pickUpDate dateByAddingTimeInterval:259200]; //25920 is three days
    
    self.returnDatePicker.maximumDate = datePlusThree;
    
    //move return date to pick up date
    [self.returnDatePicker setDate:self.pickUpDate animated:YES];
    
    //min time is the pick up date
    self.returnDatePicker.minimumDate = self.pickUpDate;
    
    //assign pu date to the scheduleRequest
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_begin = self.pickUpDate;
}


-(IBAction)receiveReturnDate:(id)sender{
    
    self.returnDate = [sender date];
    
    //assign return date to the scheduleRequest
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_end = self.returnDate;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
