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
#import "EQREquipSelectionFromReserveVC.h"
#import "EQREditorDateVCntrllr.h"
#import "EQREditorExtendedDateVC.h"
#import "EQRModeManager.h"
#import "EQRColors.h"

@interface EQREquipDateVCntrllr ()

//remove from xib and then delete these
@property (strong, nonatomic) IBOutlet UIDatePicker* pickUpDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* pickUpTimePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnTimePicker;
//

@property BOOL datePickupSelectionFlag;
@property BOOL dateReturnSelectionFlag;

@property (strong, nonatomic) IBOutlet UIButton* showAllEquipmentButton;
@property (strong, nonatomic) IBOutlet UIView* containerViewForDatePicker;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
//    self.pickUpDatePicker.datePickerMode = UIDatePickerModeDate;
//    self.returnDatePicker.datePickerMode = UIDatePickerModeDate;
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_begin = self.pickUpDate;
    requestManager.request.request_time_begin = self.pickUpDate;
    requestManager.request.request_date_end = self.returnDate;
    requestManager.request.request_time_end = self.returnDate;
}


-(void)viewWillAppear:(BOOL)animated{
    
    // Update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        // Set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"DEMO MODE";
        
        // Set colors of navigation bar and item
        [modeManager alterNavigationBar:self.navigationController.navigationBar navigationItem:self.navigationItem isInDemo:YES];
        
        [UIView setAnimationsEnabled:YES];
        
    }else{
        // Set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        // Set colors of navigation bar and item
        [modeManager alterNavigationBar:self.navigationController.navigationBar navigationItem:self.navigationItem isInDemo:NO];
        
        [UIView setAnimationsEnabled:YES];
    }
    [super viewWillAppear:animated];
}


-(void)viewDidLayoutSubviews{
    
    //________Accessing childviewcontrollers
    NSArray* arrayOfChildVCs = [self childViewControllers];
    
    if ([arrayOfChildVCs count] > 0){
        
        EQREditorDateVCntrllr* myDateViewVCntrllr = (EQREditorDateVCntrllr*)[(UINavigationController*)[arrayOfChildVCs objectAtIndex:0] topViewController];
        
        //set button targets
        [myDateViewVCntrllr setSaveSelector:@"receiveContinueAction:" forTarget:self];
        [myDateViewVCntrllr setShowExtended:@"showOrHideExtendedPicker:" withTarget:self];
        
        //set actions from pickers
        [myDateViewVCntrllr setPickupAction:@"receivePickUpDate:" returnAction:@"receiveReturnDate:" forTarget:self];
        
        [myDateViewVCntrllr setPickupDate:self.pickUpDate returnDate:self.returnDate];
        
    }else{
        //error handling
    }
}


#pragma mark - childviewcontroller for dateview
-(IBAction)receiveContinueAction:(id)sender{
    
//    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    EQREquipSelectionFromReserveVC *equipVC = [[EQREquipSelectionFromReserveVC alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    equipVC.edgesForExtendedLayout = UIRectEdgeAll;
    
    [self.navigationController pushViewController:equipVC animated:YES];
}


-(IBAction)showOrHidExtendedPicker:(id)sender{
    
    if ([self.childViewControllers count] > 0){
        
        UINavigationController* navController = [self.childViewControllers objectAtIndex:0];
        
        if ([navController.topViewController class] == [EQREditorExtendedDateVC class]){
            
            //pop back to standard view controller
            [navController popToRootViewControllerAnimated:YES];
            
        }else{
            
            EQREditorExtendedDateVC* extendedVC = [[EQREditorExtendedDateVC alloc] initWithNibName:@"EQREditorExtendedDateVC" bundle:nil];
            
            //push to extended view controller
            [navController pushViewController:extendedVC  animated:YES];
            
            //set delegate for navcontroller to self
            //______because I can't set the targets of the new  view controller until they view is loaded
            [navController setDelegate:self];
        }
    }
}


#pragma mark - uinavigationcontroller delegate methods
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ([viewController class] == [EQREditorExtendedDateVC class]){
        
        //assign targets of extended vc
        //set button targets
        [(EQREditorExtendedDateVC *)viewController setSaveSelector:@"receiveContinueAction:" forTarget:self];
        [(EQREditorExtendedDateVC *)viewController setShowExtended:@"showOrHidExtendedPicker:" withTarget:self];
        
        //set actions from date pickers
        [(EQREditorExtendedDateVC *)viewController setPickupAction:@"receivePickUpDate:" returnAction:@"receiveReturnDate:" forTarget:self];
        
        //also receive actions from time pickers
        [[(EQREditorExtendedDateVC*)viewController pickupTimeField] addTarget:self action:@selector(receivePickUpDate:) forControlEvents:UIControlEventValueChanged];
        [[(EQREditorExtendedDateVC*)viewController returnTimeField] addTarget:self action:@selector(receiveReturnDate:) forControlEvents:UIControlEventValueChanged];
        
        [(EQREditorExtendedDateVC *)viewController setPickupDate:self.pickUpDate returnDate:self.returnDate];

        [[(EQREditorExtendedDateVC*)viewController pickupTimeField] setDate:self.pickUpDate animated:YES];
        [[(EQREditorExtendedDateVC*)viewController returnTimeField] setDate:self.returnDate animated:YES];
        
    }else if([viewController class] == [EQREditorDateVCntrllr class] ){

//        [(EQREditorDateVCntrllr *)viewController setPickupDate:self.pickUpDate returnDate:self.returnDate];
    }
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
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager dismissRequest:YES];
}


#pragma mark - UIDatePickerMethods
-(IBAction)receivePickUpDate:(id)sender{
    
    //set pick up date
    //____*****   error handling for NULL tempReturnDate   *****_____
    NSDate* tempReturnDate;
    
    NSArray* arrayOfChildVCs = [self childViewControllers];
    if ([arrayOfChildVCs count] > 0){
        
        EQREditorDateVCntrllr* dateVCntrllr = (EQREditorDateVCntrllr*) [(UINavigationController*)[arrayOfChildVCs objectAtIndex:0] topViewController];

        
        //get pick up date
        self.pickUpDate = [dateVCntrllr retrievePickUpDate];
        
        //get the return date
        tempReturnDate = [dateVCntrllr retrieveReturnDate];
        
        
        //max time by adding  three days to the pickup date
        NSDate* datePlusThree = [self.pickUpDate dateByAddingTimeInterval:259200]; //25920 is three days
        
        //max return date
        if (EQRDisableTimeLimitForRequest){
            
//            dateVCntrllr.returnDateField.maximumDate = nil;
            [dateVCntrllr setReturnMax:nil];
            
        }else {
            
//            dateVCntrllr.returnDateField.maximumDate = datePlusThree;
            [dateVCntrllr setReturnMax:datePlusThree];
        }
        
        //min time for return date is the pick up date
//        dateVCntrllr.returnDateField.minimumDate = self.pickUpDate;
        [dateVCntrllr setReturnMin:self.pickUpDate];
        
        //move return date to pick up date, unless it has already by set
        if (!self.datePickupSelectionFlag){
            
//            [dateVCntrllr.returnDateField setDate:self.pickUpDate animated:YES];
            [dateVCntrllr setReturnDateAnimated:self.pickUpDate];
        }
    }
    
    //assign pu date to the scheduleRequest
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_begin = self.pickUpDate;
    requestManager.request.request_time_begin = self.pickUpDate;
    
    //MUST also send returnd date because it always change due to the minimumDate property
    requestManager.request.request_date_end = tempReturnDate;
    requestManager.request.request_time_end = tempReturnDate;
    
    self.datePickupSelectionFlag = YES;
}


-(IBAction)receiveReturnDate:(id)sender{
    
    NSArray* arrayOfChildVCs = [self childViewControllers];
    if ([arrayOfChildVCs count] > 0){
        
        EQREditorDateVCntrllr* dateVCntrllr = (EQREditorDateVCntrllr*) [(UINavigationController*)[arrayOfChildVCs objectAtIndex:0] topViewController];
        
        self.returnDate = [dateVCntrllr retrieveReturnDate];
    }
    
    //assign return date to the scheduleRequest
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_end = self.returnDate;
    requestManager.request.request_time_end = self.returnDate;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
