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
#import "EQREquipSelectionGenericVCntrllr.h"


@interface EQREquipDateVCntrllr ()

@property (strong, nonatomic) IBOutlet UIDatePicker* pickUpDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* pickUpTimePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnTimePicker;
@property BOOL datePickupSelectionFlag;
@property BOOL dateReturnSelectionFlag;

@property (strong, nonatomic) IBOutlet UIButton* showAllEquipmentButton;


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
//    self.dateReturnSelectionFlag = NO;
    
    //preset dates
    self.pickUpDate = [NSDate date];
    self.returnDate = [NSDate date];
    
    //_________use this when entering archival information
    //set datepicker mode
    self.pickUpDatePicker.datePickerMode = UIDatePickerModeDate;
    self.returnDatePicker.datePickerMode = UIDatePickerModeDate;
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_begin = self.pickUpDate;
    requestManager.request.request_date_end = self.returnDate;
    
}


-(IBAction)showAllEquipment:(id)sender{
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    requestManager.request.showAllEquipmentFlag = YES;
    
}


#pragma mark - continue

-(IBAction)receiveContinueAction:(id)sender{

    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    genericEquipVCntrllr.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationController pushViewController:genericEquipVCntrllr animated:YES];
    
}


#pragma mark - void date selection

-(void)receiveVoidScheduleItem:(NSNotification*)note{

    self.datePickupSelectionFlag = NO;
//    self.dateReturnSelectionFlag = NO;
    
}


#pragma mark - cancel

-(IBAction)cancelTheThing:(id)sender{
    
    //go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //send note to reset eveything back to 0
//    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:nil];
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager dismissRequest];
    
}



#pragma mark - UIDatePickerMethods

-(IBAction)receivePickUpDate:(id)sender{
    
    //set pick up date
    self.pickUpDate = [sender date];
    
    //max time by adding  three days to the pickup date
    NSDate* datePlusThree = [self.pickUpDate dateByAddingTimeInterval:259200]; //25920 is three days
    
    //max return date
    if (EQRDisableTimeLimitForRequest){
        
        self.returnDatePicker.maximumDate = nil;
   
    } else {
        
        self.returnDatePicker.maximumDate = datePlusThree;
    }
    
    //min time for return date is the pick up date
    self.returnDatePicker.minimumDate = self.pickUpDate;
    
    //move return date to pick up date, unless it has already by set
    if (!self.datePickupSelectionFlag){
        
        [self.returnDatePicker setDate:self.pickUpDate animated:YES];
    }
    
    //assign pu date to the scheduleRequest
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_begin = self.pickUpDate;
    
    //MUST also send returnd date because it always change due to the minimumDate property
    requestManager.request.request_date_end = self.returnDatePicker.date;
    
    self.datePickupSelectionFlag = YES;
}


-(IBAction)receiveReturnDate:(id)sender{
    
//    self.dateReturnSelectionFlag = YES;
    
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
