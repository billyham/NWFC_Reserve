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
#import "EQRGlobals.h"


@interface EQREquipDateVCntrllr ()

@property (strong, nonatomic) IBOutlet UIDatePicker* pickUpDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnDatePicker;
@property BOOL datePickupSelectionFlag;

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
    
    //register for notification
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    //observe for voiding schedule tracking item
    [nc addObserver:self selector:@selector(receiveVoidScheduleItem:) name:EQRVoidScheduleItemObjects object:nil];
    
    self.datePickupSelectionFlag = NO;
}



#pragma mark - void date selection

-(void)receiveVoidScheduleItem:(NSNotification*)note{

    self.datePickupSelectionFlag = NO;
    
}



#pragma mark - UIDatePickerMethods

-(IBAction)receivePickUpDate:(id)sender{
    
    //set pick up date
    self.pickUpDate = [sender date];
    
    //max time by adding  three days to the pickup date
    NSDate* datePlusThree = [self.pickUpDate dateByAddingTimeInterval:259200]; //25920 is three days
    
    //max return date
    self.returnDatePicker.maximumDate = datePlusThree;
    
    //min time for return date is the pick up date
    self.returnDatePicker.minimumDate = self.pickUpDate;
    
    //move return date to pick up date, unless it has already by set
    if (!self.datePickupSelectionFlag){
        
        [self.returnDatePicker setDate:self.pickUpDate animated:YES];
    }
    //assign pu date to the scheduleRequest
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_begin = self.pickUpDate;
    
    self.datePickupSelectionFlag = YES;
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
