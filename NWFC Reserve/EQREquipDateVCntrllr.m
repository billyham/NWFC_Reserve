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
//    self.pickUpDatePicker.datePickerMode = UIDatePickerModeDate;
//    self.returnDatePicker.datePickerMode = UIDatePickerModeDate;
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.request_date_begin = self.pickUpDate;
    requestManager.request.request_time_begin = self.pickUpDate;
    requestManager.request.request_date_end = self.returnDate;
    requestManager.request.request_time_end = self.returnDate;
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        [UIView setAnimationsEnabled:YES];
        
    }else{
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
        [UIView setAnimationsEnabled:YES];
    }
    
    [super viewWillAppear:animated];
}


-(void)viewDidLayoutSubviews{
    
    //doesn't work in viewDidLoad
    
    //________Accessing childviewcontrollers
    NSArray* arrayOfChildVCs = [self childViewControllers];
    
    if ([arrayOfChildVCs count] > 0){
        
        EQREditorDateVCntrllr* myDateViewVCntrllr = (EQREditorDateVCntrllr*)[(UINavigationController*)[arrayOfChildVCs objectAtIndex:0] topViewController];
        
        //set button targets
        [myDateViewVCntrllr.saveButton addTarget:self action:@selector(receiveContinueAction:) forControlEvents:UIControlEventTouchUpInside];
        [myDateViewVCntrllr.showOrHideExtendedButton addTarget:self action:@selector(showOrHidExtendedPicker:) forControlEvents:UIControlEventTouchUpInside];
        
        //set actions from pickers
        [myDateViewVCntrllr.pickupDateField addTarget:self action:@selector(receivePickUpDate:) forControlEvents:UIControlEventValueChanged];
        [myDateViewVCntrllr.returnDateField addTarget:self action:@selector(receiveReturnDate:) forControlEvents:UIControlEventValueChanged];
        
        
    }else{
        
        //error handling
    }
}

//-(IBAction)showAllEquipment:(id)sender{
//    
//    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
//    
//    requestManager.request.showAllEquipmentFlag = YES;
//    
//}


#pragma mark - childviewcontroller for dateview

-(IBAction)receiveContinueAction:(id)sender{
    
    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    genericEquipVCntrllr.edgesForExtendedLayout = UIRectEdgeAll;
    
    [self.navigationController pushViewController:genericEquipVCntrllr animated:YES];
    
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
        [[(EQREditorExtendedDateVC*)viewController saveButton] addTarget:self action:@selector(receiveContinueAction:) forControlEvents:UIControlEventTouchUpInside];
        [[(EQREditorExtendedDateVC*)viewController showOrHideExtendedButton] addTarget:self action:@selector(showOrHidExtendedPicker:) forControlEvents:UIControlEventTouchUpInside];
        
        //set actions from date pickers
        [[(EQREditorExtendedDateVC*)viewController pickupDateField] addTarget:self action:@selector(receivePickUpDate:) forControlEvents:UIControlEventValueChanged];
        [[(EQREditorExtendedDateVC*)viewController returnDateField] addTarget:self action:@selector(receiveReturnDate:) forControlEvents:UIControlEventValueChanged];
        
        //also receive actions from time pickers
        [[(EQREditorExtendedDateVC*)viewController pickupTimeField] addTarget:self action:@selector(receivePickUpDate:) forControlEvents:UIControlEventValueChanged];
        [[(EQREditorExtendedDateVC*)viewController returnTimeField] addTarget:self action:@selector(receiveReturnDate:) forControlEvents:UIControlEventValueChanged];
        
        [[(EQREditorExtendedDateVC*)viewController pickupDateField] setDate:self.pickUpDate animated:YES];
        [[(EQREditorExtendedDateVC*)viewController pickupTimeField] setDate:self.pickUpDate animated:YES];
        [[(EQREditorExtendedDateVC*)viewController returnDateField] setDate:self.returnDate animated:YES];
        [[(EQREditorExtendedDateVC*)viewController returnTimeField] setDate:self.returnDate animated:YES];
        
    }else if([viewController class] == [EQREditorDateVCntrllr class] ){
        
        [[(EQREditorDateVCntrllr*)viewController pickupDateField] setDate:self.pickUpDate animated:YES];
        [[(EQREditorDateVCntrllr*)viewController returnDateField] setDate:self.returnDate animated:YES];
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
    
    //send note to reset eveything back to 0
//    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:nil];
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager dismissRequest:YES];
    
}



#pragma mark - UIDatePickerMethods

-(IBAction)receivePickUpDate:(id)sender{
    
//    //set pick up date
////    self.pickUpDate = [sender date];
//    
//    //max time by adding  three days to the pickup date
//    NSDate* datePlusThree = [self.pickUpDate dateByAddingTimeInterval:259200]; //25920 is three days
//    
//    //max return date
//    if (EQRDisableTimeLimitForRequest){
//        
//        self.returnDatePicker.maximumDate = nil;
//   
//    } else {
//        
//        self.returnDatePicker.maximumDate = datePlusThree;
//    }
//    
//    //min time for return date is the pick up date
//    self.returnDatePicker.minimumDate = self.pickUpDate;
//    
//    //move return date to pick up date, unless it has already by set
//    if (!self.datePickupSelectionFlag){
//        
//        [self.returnDatePicker setDate:self.pickUpDate animated:YES];
//    }
    
    
    
    
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
            
            dateVCntrllr.returnDateField.maximumDate = nil;
            
        }else {
            
            dateVCntrllr.returnDateField.maximumDate = datePlusThree;
        }
        
        //min time for return date is the pick up date
        dateVCntrllr.returnDateField.minimumDate = self.pickUpDate;
        
        //move return date to pick up date, unless it has already by set
        if (!self.datePickupSelectionFlag){
            
            [dateVCntrllr.returnDateField setDate:self.pickUpDate animated:YES];
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
    
    
//    self.returnDate = [sender date];
    
    
    
    
    
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
