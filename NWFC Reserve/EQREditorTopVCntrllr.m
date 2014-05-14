//
//  EQREditorTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorTopVCntrllr.h"
#import "EQREditorEquipListCell.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQREditorDateVCntrllr.h"
#import "EQREditorRenterVCntrllr.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQRColors.h"
#import "EQREquipSelectionGenericVCntrllr.h"

@interface EQREditorTopVCntrllr ()

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequesetManager;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) IBOutlet UITextField* nameTextField;
@property (strong, nonatomic) NSDate* pickUpDateDate;
@property (strong, nonatomic) NSDate* returnDateDate;
@property (strong, nonatomic) NSDate* pickUpTime;
@property (strong, nonatomic) NSDate* returnTime;

@property (strong, nonatomic) IBOutlet UITextField* pickupDateField;
@property (strong, nonatomic) IBOutlet UITextField* returnDateField;
@property (strong, nonatomic) IBOutlet UICollectionView* equipList;
@property (strong, nonatomic) EQREditorDateVCntrllr* myDateViewController;
@property (strong, nonatomic) UIPopoverController* theDatePopOver;

@property (strong, nonatomic) IBOutlet UITextField* renterTypeField;
//@property (strong ,nonatomic) IBOutlet UIPickerView* renterTypePicker;
@property (strong, nonatomic) NSString* renterTypeString;  //I don't think this is used
@property (strong, nonatomic) EQREditorRenterVCntrllr* myRenterViewController;
@property (strong, nonatomic) UIPopoverController* theRenterPopOver;

@property (strong, nonatomic) UIPopoverController* theEquipSelectionPopOver;
@property (strong, nonatomic) IBOutlet UIButton* addEquipItemButton;

@property (strong, nonatomic) NSMutableArray* arrayOfSchedule_Unique_Joins;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipUniqueItems;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;

@end

@implementation EQREditorTopVCntrllr

#pragma mark - methods

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
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    //register to receive delete instructions from equipList cells
    [nc addObserver:self selector:@selector(addEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeleted object:nil];
    [nc addObserver:self selector:@selector(removeEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeletedCancel object:nil];
    
    //set ivar flag
    self.saveButtonTappedFlag = NO;
    
    
    
    //register collection view cell
    [self.equipList registerClass:[EQREditorEquipListCell class] forCellWithReuseIdentifier:@"Cell"];
    
    //initialze ivar arrays
    if (!self.arrayOfEquipUniqueItems){
        
        self.arrayOfEquipUniqueItems = [NSMutableArray arrayWithCapacity:1];
        
    }else {
        
        [self.arrayOfEquipUniqueItems removeAllObjects];
    }
    
    if (!self.arrayOfSchedule_Unique_Joins){
        
        self.arrayOfSchedule_Unique_Joins = [NSMutableArray arrayWithCapacity:1];
        
    }else {
        
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    }
    
    
    if (!self.arrayOfToBeDeletedEquipIDs){
        
        self.arrayOfToBeDeletedEquipIDs = [NSMutableArray arrayWithCapacity:1];
        
    } else {
        
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    }
    
    //set color of collection view
    EQRColors* eqrColors = [EQRColors sharedInstance];
    self.equipList.backgroundColor = [eqrColors.colorDic objectForKey:EQRColorVeryLightGrey];
    
    //save bar button
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    
    //cancel bar button
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    [self.navigationItem setRightBarButtonItem:rightButton];
    

    
    //set title
    self.navigationItem.title = @"Editor Request";
    
    //get scheduleTrackingRequest info and...
    //get array of schedule_equipUnique_joins
    //user self.scheduleRequestKeyID
    
    
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d, h:mm a";
    
    //set labels with provided dictionary
    //must do this AFTER loading the view
    self.nameTextField.text =[self.myUserInfo objectForKey:@"contact_name"];
    self.renterTypeString = [self.myUserInfo objectForKey:@"renter_type"];

    //set date labels
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    //set the renter field....
    self.renterTypeField.text = self.privateRequesetManager.request.renter_type;
    
//    NSLog(@"this is the scheduleRequest key id: %@", [self.myUserInfo objectForKey:@"key_ID"]);
    
    //have the requestManager establish the list of available equipment?????
//    NSDictionary* datesDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                              self.pickUpDateDate, @"request_date_begin",
//                              self.returnDateDate, @"request_date_end",
//                              nil];
    
//    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //_______*******  THIS IS CRASHING BECAUSE THE DATE INFO IS NOT PRESENT_________**********
//    [requestManager allocateGearListWithDates:datesDic];
    
    NSMutableArray* arrayToReturn = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayToReturnJoins = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"],  nil];
    NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
    
    //get Scheduletracking_equipUnique_joins
    [webData queryWithLink:@"EQGetScheduleEquipJoins.php" parameters:secondArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
       
        [arrayToReturnJoins addObjectsFromArray:muteArray];
        
    }];
    
    [self.arrayOfSchedule_Unique_Joins addObjectsFromArray:arrayToReturnJoins];
    
    
    //get equipUniqueItems
    [webData queryWithLink:@"EQGetUniqueItemKeysWithScheduleTrackingKeys.php" parameters:secondArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
        
        [arrayToReturn addObjectsFromArray:muteArray];
    }];
    
    [self.arrayOfEquipUniqueItems addObjectsFromArray:arrayToReturn];

    //reload collection view
    [self.equipList reloadData];
    
    
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.myUserInfo = userInfo;
    
    //create private request manager as ivar
    if (!self.privateRequesetManager){
        
        self.privateRequesetManager = [[EQRScheduleRequestManager alloc] init];
    }
    
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    dateFormatter.dateFormat = @"yyyy-MM-dd";
    // HH:mm:ss
    
    //set dates
    self.pickUpDateDate = [self.myUserInfo objectForKey:@"request_date_begin"];
    self.returnDateDate = [self.myUserInfo objectForKey:@"request_date_end"];
    self.pickUpTime = [self.myUserInfo objectForKey:@"request_time_begin"];
    self.returnTime = [self.myUserInfo objectForKey:@"request_time_end"];
    
    //add times to dates
    self.pickUpDateDate = [self.pickUpDateDate dateByAddingTimeInterval: [self.pickUpTime timeIntervalSinceReferenceDate]];
    self.returnDateDate = [self.returnDateDate dateByAddingTimeInterval:[self.returnTime timeIntervalSinceReferenceDate]];
        
    //instantiate the request item in ivar requestManager
    self.privateRequesetManager.request = [[EQRScheduleRequestItem alloc] init];
    
    //two important methods that initiate requestManager ivar arrays
    [self.privateRequesetManager resetEquipListAndAvailableQuantites];
    [self.privateRequesetManager retrieveAllEquipUniqueItems];
    
    
    //and populate its ivars
//    self.privateRequesetManager.request.key_id = [self.myUserInfo objectForKey:@"key_ID"];
    self.privateRequesetManager.request.renter_type = [self.myUserInfo objectForKey:@"renter_type"];
    self.privateRequesetManager.request.contact_name = [self.myUserInfo objectForKey:@"contact_name"];
    self.privateRequesetManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequesetManager.request.request_date_end = self.returnDateDate;
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* arrayWithKey = [NSArray arrayWithObjects:@"key_id",[userInfo objectForKey:@"key_ID"], nil];
    NSArray* topArrayWithKey = [NSArray arrayWithObject:arrayWithKey];
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:topArrayWithKey class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        //____ERROR HANDLING WHEN NOTHING IS RETURNED_______
        if ([muteArray count] > 0){
            self.privateRequesetManager.request.key_id = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] key_id];
            self.privateRequesetManager.request.contact_foreignKey =  [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] contact_foreignKey];
            self.privateRequesetManager.request.classSection_foreignKey = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] classSection_foreignKey];
            self.privateRequesetManager.request.time_of_request = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] time_of_request];
        }
    }];
    
//    NSLog(@"this is the contact foreign key: %@", self.privateRequesetManager.request.contact_foreignKey);
    

    //_________**********  LOAD REQUEST EDITOR COLLECTION VIEW WITH EquipUniqueItem_Joins  *******_____________
    
    
    //populate...
    //arrayOfSchedule_Unique_Joins
    
    
    
}


-(void)cancelAction{
    
//    [self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


-(IBAction)saveAction:(id)sender{
    
    self.saveButtonTappedFlag = YES;
    
    //update SQL with new request information
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSLog(@"this is the classSection_foreignKey: %@", self.privateRequesetManager.request.classSection_foreignKey);
    
    //must not include nil objects in array
    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
    if (!self.privateRequesetManager.request.contact_foreignKey) self.privateRequesetManager.request.contact_foreignKey = @"88888888";
    if (!self.privateRequesetManager.request.classSection_foreignKey) self.privateRequesetManager.request.classSection_foreignKey = @"88888888";
    if ([self.privateRequesetManager.request.classSection_foreignKey isEqualToString:@""]) self.privateRequesetManager.request.classSection_foreignKey = @"88888888";
    if (!self.privateRequesetManager.request.classTitle_foreignKey) self.privateRequesetManager.request.classTitle_foreignKey = @"88888888";
    if (!self.privateRequesetManager.request.request_date_begin) self.privateRequesetManager.request.request_date_begin = [NSDate date];
    if (!self.privateRequesetManager.request.request_date_end) self.privateRequesetManager.request.request_date_end = [NSDate date];
    if (!self.privateRequesetManager.request.contact_name) self.privateRequesetManager.request.contact_name = @"88888888";
    if (!self.privateRequesetManager.request.time_of_request) self.privateRequesetManager.request.time_of_request = [NSDate date];

    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatForDate stringFromDate:self.privateRequesetManager.request.request_date_begin];
    NSString* dateEndString = [dateFormatForDate stringFromDate:self.privateRequesetManager.request.request_date_end];
    
    //format the time
    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
    [dateFormatForTime setLocale:usLocale];
    [dateFormatForTime setDateFormat:@"HH:mm"];
    NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:self.privateRequesetManager.request.request_date_begin];
    NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:self.privateRequesetManager.request.request_date_end];
    NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
    NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
    
    //time of request
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:self.privateRequesetManager.request.time_of_request];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.privateRequesetManager.request.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", self.privateRequesetManager.request.contact_foreignKey, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", self.privateRequesetManager.request.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", self.privateRequesetManager.request.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", timeBeginString, nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", timeEndString, nil];
    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", self.privateRequesetManager.request.contact_name, nil];
    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", self.privateRequesetManager.request.renter_type, nil];
    NSArray* eleventhArray = [NSArray arrayWithObjects:@"time_of_request", timeRequestString, nil];
    
    NSArray* bigArray = [NSArray arrayWithObjects:
                         firstArray,
                         secondArray,
                         thirdArray,
                         fourthArray,
                         fifthArray,
                         sixthArray,
                         seventhArray,
                         eighthArray,
                         ninthArray,
                         tenthArray,
                         eleventhArray,
                         nil];
    
    
    for (NSArray* arraySample in bigArray){
    NSLog(@"%@", arraySample);
    }
    
    
    NSString* returnID = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
    NSLog(@"this is the returnID: %@", returnID);
    
    
    //_______*********  delete the delted scheduleTracking_equip_joins
    for (NSString* thisKeyID in self.arrayOfToBeDeletedEquipIDs){
        
        for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in self.arrayOfSchedule_Unique_Joins){
         
            if ([thisKeyID isEqualToString:thisJoin.equipUniqueItem_foreignKey]){
                
                //found a matching equipUnique item
                
                //send php message to detele with the join key_id
                NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", thisJoin.key_id, nil];
                NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
                NSString* returnString = [webData queryForStringWithLink:@"EQRDeleteScheduleEquipJoin.php" parameters:beeArray];
                
                NSLog(@"this is the result: %@", returnString);
            }
            
        }
    }
    
    //empty the arrays
    [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    [self.arrayOfEquipUniqueItems removeAllObjects];
    [self.arrayOfToBeDeletedEquipIDs removeAllObjects];

    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


-(IBAction)deleteRequest:(id)sender{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete Confirmation" message:@"Are you sure want to delete this reservation?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [alertView show];
    
    
    
}

#pragma mark - alert view delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //buttonIndex at 0 is cancel

    //handle delete action when delete in confirmed
    if (buttonIndex == 1){
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        //delete the scheduleTracking item
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.privateRequesetManager.request.key_id, nil];
        NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
        NSString* scheduleReturn = [webData queryForStringWithLink:@"EQDeleteScheduleItem.php" parameters:secondArray];
        NSLog(@"this is the schedule return: %@", scheduleReturn);
        
        //delete all scheduleTracking_equipUnique_joins
        NSArray* alphaArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey",self.privateRequesetManager.request.key_id, nil];
        NSArray* betaArray = [NSArray arrayWithObjects:alphaArray, nil];
        NSString* joinReturn = [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoinWithScheduleKey.php" parameters:betaArray];
        NSLog(@"this is the join return: %@", joinReturn);
        
        //empty the arrays
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
        [self.arrayOfEquipUniqueItems removeAllObjects];
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
        
        //send note to schedule that a change has been saved
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}



#pragma mark - handle date view controller

-(IBAction)showDateVCntrllr:(id)sender{
    
    self.myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    
    UIPopoverController* popOverC = [[UIPopoverController alloc] initWithContentViewController:self.myDateViewController];
    self.theDatePopOver = popOverC;
    
    [self.theDatePopOver presentPopoverFromRect:self.pickupDateField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //update dates labels
    self.myDateViewController.pickupDateField.date = self.pickUpDateDate;
    self.myDateViewController.returnDateField.date = self.returnDateDate;
    
    //update requestItem date properties
    self.privateRequesetManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequesetManager.request.request_date_end = self.returnDateDate;
    
    [self.myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:) forControlEvents:UIControlEventAllTouchEvents];
}


-(IBAction)dateSaveButton:(id)sender{
    
    //set dates in the view
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d h:mm a";
    
    self.pickUpDateDate = self.myDateViewController.pickupDateField.date;
    self.returnDateDate = self.myDateViewController.returnDateField.date;
    
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    self.privateRequesetManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequesetManager.request.request_date_end = self.returnDateDate;

    
    
    //remove popover
    [self.theDatePopOver dismissPopoverAnimated:YES];
    
}


#pragma mark - handle renter view controller

-(IBAction)showRenterVCntrllr:(id)sender{
    
    self.myRenterViewController = [[EQREditorRenterVCntrllr alloc] initWithNibName:@"EQREditorRenterVCntrllr" bundle:nil];
    
    UIPopoverController* popOverC2 = [[UIPopoverController alloc] initWithContentViewController:self.myRenterViewController];
    self.theRenterPopOver= popOverC2;
    
    [self.theRenterPopOver presentPopoverFromRect:self.renterTypeField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //set renterViewController value ivar
    self.myRenterViewController.renter_type = self.privateRequesetManager.request.renter_type;
    
    //initial setup
    [self.myRenterViewController initialSetup];

    [self.myRenterViewController.saveButton addTarget:self action:@selector(renterSaveButton:) forControlEvents:UIControlEventAllTouchEvents];
    
}


-(IBAction)renterSaveButton:(id)sender{
    
    //set new renter type value
    self.renterTypeField.text = self.myRenterViewController.renter_type;
//    self.renterTypeString = self.myRenterViewController.renter_type;
    self.privateRequesetManager.request.renter_type = self.myRenterViewController.renter_type;
    
    //remove popover
    [self.theRenterPopOver dismissPopoverAnimated:YES];
}


#pragma mark - handle add equip item

-(IBAction)addEquipItem:(id)sender{
    
    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    //need to specify a privateRequestManager for the equip selection v cntrllr
    [genericEquipVCntrllr overrideSharedRequestManager:self.privateRequesetManager];
    
    
//    genericEquipVCntrllr.edgesForExtendedLayout = UIRectEdgeNone;
//    [self.navigationController pushViewController:genericEquipVCntrllr animated:NO];
    
    UIPopoverController* popOverMe = [[UIPopoverController alloc] initWithContentViewController:genericEquipVCntrllr];
    self.theEquipSelectionPopOver = popOverMe;
    //must manually set the size, cannot be wider than 600px!!!!???? But seems to work ok at 800 anyway???
    self.theEquipSelectionPopOver.popoverContentSize = CGSizeMake(800, 600);
    
    [self.theEquipSelectionPopOver presentPopoverFromRect:self.addEquipItemButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated: YES];
    

    //need to reprogram the target of the save button
    [genericEquipVCntrllr.continueButton removeTarget:genericEquipVCntrllr action:NULL forControlEvents:UIControlEventAllEvents];
    [genericEquipVCntrllr.continueButton addTarget:self action:@selector(continueAddEquipItem:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)continueAddEquipItem:(id)sender{
    
    //replaces the uniqueItem key from "1" to an accurate value
    [self.privateRequesetManager justConfirm];

    [self.theEquipSelectionPopOver dismissPopoverAnimated:YES];
    
    
    
    
    //_________***  need to update self.arrayOfEquipUniqueItems
    //empty arrays first
    [self.arrayOfEquipUniqueItems removeAllObjects];
    [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    
    NSMutableArray* arrayToReturn = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayToReturnJoins = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"],  nil];
    NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
    
    //get Scheduletracking_equipUnique_joins
    [webData queryWithLink:@"EQGetScheduleEquipJoins.php" parameters:secondArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
        
        [arrayToReturnJoins addObjectsFromArray:muteArray];
        
    }];
    
    [self.arrayOfSchedule_Unique_Joins addObjectsFromArray:arrayToReturnJoins];
    
    
    //get equipUniqueItems
    [webData queryWithLink:@"EQGetUniqueItemKeysWithScheduleTrackingKeys.php" parameters:secondArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
        
        [arrayToReturn addObjectsFromArray:muteArray];
    }];
    
    [self.arrayOfEquipUniqueItems addObjectsFromArray:arrayToReturn];
    
    //reload collection view
    [self.equipList reloadData];
    
    //____________***
    

    
}


#pragma mark - notification methods

-(void)addEquipUniqueToBeDeletedArray:(NSNotification*)note{
    
    [self.arrayOfToBeDeletedEquipIDs addObject:[note.userInfo objectForKey:@"key_id"]];
    
}

-(void)removeEquipUniqueToBeDeletedArray:(NSNotification*)note{
    
    NSString* stringToBeRemoved;
    
    for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
        
        if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
            
            stringToBeRemoved = thisString;
        }
    }

    [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
}






#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.arrayOfEquipUniqueItems count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    
    EQREditorEquipListCell* cell = [self.equipList dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    NSString* thisName = [[self.arrayOfEquipUniqueItems objectAtIndex:indexPath.row] name];
    NSString* thisDistNumber = [[self.arrayOfEquipUniqueItems objectAtIndex:indexPath.row] distinquishing_id];
    NSString* thisTitle = [NSString stringWithFormat:@"%@: #%@", thisName, thisDistNumber];
    
    
    BOOL toBeDeleted = NO;
    for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
        if ([keyToDelete isEqualToString:[[self.arrayOfEquipUniqueItems objectAtIndex:indexPath.row] key_id]]){
            toBeDeleted = YES;
        }
    }
    
    [cell initialSetupWithTitle:thisTitle keyID:[[self.arrayOfEquipUniqueItems objectAtIndex:indexPath.row] key_id] deleteFlag:toBeDeleted];
    
    return cell;
}


#pragma mark - collection view delegate methods





#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
