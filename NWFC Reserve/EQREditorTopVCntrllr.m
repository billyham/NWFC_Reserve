//
//  EQREditorTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorTopVCntrllr.h"
#import "EQREditorHeaderCell.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQREditorDateVCntrllr.h"
#import "EQREditorExtendedDateVC.h"
#import "EQREditorRenterVCntrllr.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQRColors.h"
#import "EQREquipSelectionGenericVCntrllr.h"
#import "EQRDataStructure.h"
#import "EQRMiscJoin.h"
#import "EQRModeManager.h"
#import "EQRPriceMatrixVC.h"
#import "EQRPricingWidgetVC.h"
#import "EQRAlternateWrappperPriceMatrix.h"
#import "EQRTransaction.h"

@interface EQREditorTopVCntrllr () <EQRPriceMatrixDelegate>

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) IBOutlet UIButton* nameTextField;
@property (strong, nonatomic) NSDate* pickUpDateDate;
@property (strong, nonatomic) NSDate* returnDateDate;
@property (strong, nonatomic) NSDate* pickUpTime;
@property (strong, nonatomic) NSDate* returnTime;

@property (strong, nonatomic) IBOutlet UITextField* pickupDateField;
@property (strong, nonatomic) IBOutlet UITextField* returnDateField;
@property (strong, nonatomic) IBOutlet UICollectionView* equipList;
@property (strong, nonatomic) IBOutlet UITextView* notesView;

@property (strong, nonatomic) IBOutlet UIButton* renterTypeField;
@property (strong, nonatomic) NSString* renterTypeString;  //I don't think this is used
@property (strong, nonatomic) EQREditorRenterVCntrllr* myRenterViewController;

@property (strong, nonatomic) IBOutlet UIButton* classField;
@property (strong, nonatomic) IBOutlet UIButton *removeClassButton;

@property (strong, nonatomic) IBOutlet UIButton* addEquipItemButton;

@property (strong, nonatomic) NSMutableArray* arrayOfSchedule_Unique_Joins;
@property (strong, nonatomic) NSMutableArray* arrayOfMiscJoins;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedMiscJoinIDs;
@property (strong, nonatomic) NSArray* arrayOfSchedule_Unique_JoinsWithStructure;

@property (strong, nonatomic) EQREditorDateVCntrllr* myDateVC;
@property (strong, nonatomic) EQRContactPickerVC* myContactVC;

//popOvers
@property (strong, nonatomic) UIPopoverController* theDatePopOver;
@property (strong, nonatomic) UIPopoverController* theRenterPopOver;
@property (strong, nonatomic) UIPopoverController* theEquipSelectionPopOver;
@property (strong, nonatomic) UIPopoverController* myContactPicker;
@property (strong, nonatomic) UIPopoverController* distIDPopover;
@property (strong, nonatomic) UIPopoverController* myNotesPopover;
@property (strong, nonatomic) UIPopoverController* myClassPicker;

@property (strong, nonatomic) IBOutlet UIView *priceMatrixSubView;
@property (strong, nonatomic) EQRPricingWidgetVC *priceWidget;
@property (strong, nonatomic) EQRTransaction *myTransaction;

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
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//    
//    //register to receive delete instructions from equipList cells
//    [nc addObserver:self selector:@selector(addEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeleted object:nil];
//    [nc addObserver:self selector:@selector(removeEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeletedCancel object:nil];
    
    //set ivar flag
    self.saveButtonTappedFlag = NO;
    
    //register collection view cell
    [self.equipList registerClass:[EQREditorEquipListCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.equipList registerClass:[EQREditorMiscListCell class] forCellWithReuseIdentifier:@"CellForMiscJoin"];
    [self.equipList registerClass:[EQREditorHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SuppCell"];
    
    //initialze ivar arrays
    if (!self.arrayOfSchedule_Unique_Joins){
        self.arrayOfSchedule_Unique_Joins = [NSMutableArray arrayWithCapacity:1];
    }else {
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    }
    
    if (!self.arrayOfMiscJoins){
        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }else{
        [self.arrayOfMiscJoins removeAllObjects];
    }
    
    if (!self.arrayOfToBeDeletedEquipIDs){
        self.arrayOfToBeDeletedEquipIDs = [NSMutableArray arrayWithCapacity:1];
    } else {
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    }
    
    if (!self.arrayOfToBeDeletedMiscJoinIDs){
        self.arrayOfToBeDeletedMiscJoinIDs = [NSMutableArray arrayWithCapacity:1];
    }else{
        [self.arrayOfToBeDeletedMiscJoinIDs removeAllObjects];
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
    
    
    
    
//    NSLog(@"this is the scheduleRequest key id: %@", [self.myUserInfo objectForKey:@"key_ID"]);
    
    //have the requestManager establish the list of available equipment?????
//    NSDictionary* datesDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                              self.pickUpDateDate, @"request_date_begin",
//                              self.returnDateDate, @"request_date_end",
//                              nil];
    
//    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //_______*******  THIS IS CRASHING BECAUSE THE DATE INFO IS NOT PRESENT_________**********
//    [requestManager allocateGearListWithDates:datesDic];
    
//    NSMutableArray* arrayToReturn = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayToReturnJoins = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"],  nil];
    NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
    
    //get Scheduletracking_equipUnique_joins   formerly used EQGetScheduleEquipJoins.php
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php"
                parameters:secondArray class:@"EQRScheduleTracking_EquipmentUnique_Join"
                completion:^(NSMutableArray *muteArray) {
       
        [arrayToReturnJoins addObjectsFromArray:muteArray];
    }];
    
    [self.arrayOfSchedule_Unique_Joins addObjectsFromArray:arrayToReturnJoins];
    
    //gather any misc joins
    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"]];
    NSArray* omegaArray = @[alphaArray];
    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
        for (id object in muteArray2){
            [tempMiscMuteArray addObject:object];
        }
    }];
    [self.arrayOfMiscJoins addObjectsFromArray:tempMiscMuteArray];
    
    //add structure to array
    self.arrayOfSchedule_Unique_JoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfSchedule_Unique_Joins withMiscJoins:self.arrayOfMiscJoins];
    
    //reload collection view
    [self.equipList reloadData];
    
    
    //set text in notes
//    NSArray* justKeyArray = [NSArray arrayWithObjects:@"key_id", self.privateRequestManager.request.key_id, nil];
//    NSArray* justTopArray = [NSArray arrayWithObjects:justKeyArray, nil];
//    NSMutableArray* tempMuteArrayJustKey = [NSMutableArray arrayWithCapacity:1];
//    [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:justTopArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
//        
//        for (EQRScheduleRequestItem* requestItem in muteArray){
//            
//            [tempMuteArrayJustKey addObject:requestItem];
//        }
//    }];
//    
//    //error handling if no items are returned
//    if ([tempMuteArrayJustKey count] > 0){
//        self.privateRequestManager.request.notes = [[tempMuteArrayJustKey objectAtIndex:0] notes];
//    }else{
//        NSLog(@"InboxRightVC > renewTheViewWithRequest failed to find a matching request key id");
//    }
//    
//    //_____set notes text
//    self.notesView.text = self.privateRequestManager.request.notes;
    
    //.... or.....
    self.notesView.text = [self.myUserInfo objectForKey:@"notes"];
    
    
    //make notes view hot to touch
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openNotesEditor)];
    [self.notesView addGestureRecognizer:tapGest];
    
    //background color for notes
    EQRColors* colors = [EQRColors sharedInstance];
    self.notesView.backgroundColor = [colors.colorDic objectForKey:EQRColorEditModeBGBlue];
    
    EQRPricingWidgetVC *priceWidget = [[EQRPricingWidgetVC alloc] initWithNibName:@"EQRPricingWidgetVC" bundle:nil];
    self.priceWidget = priceWidget;
    CGRect tempRect = CGRectMake(0, 0, self.priceMatrixSubView.frame.size.width, self.priceMatrixSubView.frame.size.height);
    priceWidget.view.frame = tempRect;
    
    [self.priceMatrixSubView addSubview:self.priceWidget.view];
    
    //set button target
    [self.priceWidget.editButton addTarget:self action:@selector(showPricingButton:) forControlEvents:UIControlEventTouchUpInside];

}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.myUserInfo = userInfo;
    
    //create private request manager as ivar
    if (!self.privateRequestManager){
        
        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
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
    
    //set notes
    self.notesView.text = [self.myUserInfo objectForKey:@"notes"];
    
    //add times to dates
    self.pickUpDateDate = [self.pickUpDateDate dateByAddingTimeInterval: [self.pickUpTime timeIntervalSinceReferenceDate]];
    self.returnDateDate = [self.returnDateDate dateByAddingTimeInterval:[self.returnTime timeIntervalSinceReferenceDate]];
    
    //______adjust by subtracting 8 hours
    float secondsForOffset = -28800;    //this is 9 hours = 32400, this is 8 hours = 28800;
    self.pickUpDateDate = [self.pickUpDateDate dateByAddingTimeInterval:secondsForOffset];
    self.returnDateDate = [self.returnDateDate dateByAddingTimeInterval:secondsForOffset];
    
    
    
    //instantiate the request item in ivar requestManager
    self.privateRequestManager.request = [[EQRScheduleRequestItem alloc] init];
    
    //two important methods that initiate requestManager ivar arrays
    [self.privateRequestManager resetEquipListAndAvailableQuantites];
    [self.privateRequestManager retrieveAllEquipUniqueItems];
    
    
    //and populate its ivars
//    self.privateRequestManager.request.key_id = [self.myUserInfo objectForKey:@"key_ID"];
    self.privateRequestManager.request.renter_type = [self.myUserInfo objectForKey:@"renter_type"];
    self.privateRequestManager.request.contact_name = [self.myUserInfo objectForKey:@"contact_name"];
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    self.privateRequestManager.request.notes = [self.myUserInfo objectForKey:@"notes"];
    self.privateRequestManager.request.staff_confirmation_id = [self.myUserInfo objectForKey:@"staff_confirmation_id"];
    self.privateRequestManager.request.staff_confirmation_date = [self.myUserInfo objectForKey:@"staff_confirmation_date"];
    self.privateRequestManager.request.staff_prep_id = [self.myUserInfo objectForKey:@"staff_prep_id"];
    self.privateRequestManager.request.staff_prep_date = [self.myUserInfo objectForKey:@"staff_prep_date"];
    self.privateRequestManager.request.staff_checkout_id = [self.myUserInfo objectForKey:@"staff_checkout_id"];
    self.privateRequestManager.request.staff_checkout_date = [self.myUserInfo objectForKey:@"staff_checkout_date"];
    self.privateRequestManager.request.staff_checkin_id = [self.myUserInfo objectForKey:@"staff_checkin_id"];
    self.privateRequestManager.request.staff_checkin_date = [self.myUserInfo objectForKey:@"staff_checkin_date"];
    self.privateRequestManager.request.staff_shelf_id = [self.myUserInfo objectForKey:@"staff_shelf_id"];
    self.privateRequestManager.request.staff_shelf_date = [self.myUserInfo objectForKey:@"staff_shelf_date"];
    
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* arrayWithKey = [NSArray arrayWithObjects:@"key_id",[userInfo objectForKey:@"key_ID"], nil];
    NSArray* topArrayWithKey = [NSArray arrayWithObject:arrayWithKey];
    [webData queryWithLink:@"EQGetScheduleRequestInComplete.php" parameters:topArrayWithKey class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        //____ERROR HANDLING WHEN NOTHING IS RETURNED_______
        if ([muteArray count] > 0){
            self.privateRequestManager.request.key_id = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] key_id];
            self.privateRequestManager.request.contact_foreignKey =  [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] contact_foreignKey];
            self.privateRequestManager.request.classSection_foreignKey = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] classSection_foreignKey];
            self.privateRequestManager.request.classTitle_foreignKey = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] classTitle_foreignKey];
            self.privateRequestManager.request.time_of_request = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] time_of_request];
        }
    }];
    
//    NSLog(@"this is the contact foreign key: %@", self.privateRequestManager.request.contact_foreignKey);
    
    

    //_________**********  LOAD REQUEST EDITOR COLLECTION VIEW WITH EquipUniqueItem_Joins  *******_____________
    
    
    //populate...
    //arrayOfSchedule_Unique_Joins
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //get class name using key
    if (([self.privateRequestManager.request.classTitle_foreignKey isEqualToString:EQRErrorCode88888888]) ||
        ([self.privateRequestManager.request.classTitle_foreignKey isEqualToString:@""]) ||
        (!self.privateRequestManager.request.classTitle_foreignKey)) {
        
//        [self.classField setHidden:YES];
        
    }else{
        
        NSArray* first2Array = [NSArray arrayWithObjects:@"key_id", self.privateRequestManager.request.classTitle_foreignKey, nil];
        NSArray* top2Array = [NSArray arrayWithObjects:first2Array, nil];
        NSString* classValueString = [webData queryForStringWithLink:@"EQGetClassCatalogTitleWithKey.php" parameters:top2Array];
        
        [self.classField setTitle:classValueString forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];
        
//        [self.classField setHidden:NO];
    }
    
    //set labels with provided dictionary
    //must do this AFTER loading the view
    [self.nameTextField setTitle:[self.myUserInfo objectForKey:@"contact_name"] forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
    self.renterTypeString = [self.myUserInfo objectForKey:@"renter_type"];
    
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d, yyyy, h:mm a";
    
    //set date labels
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    //set the renter field....
    [self.renterTypeField setTitle:self.privateRequestManager.request.renter_type forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    
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
    
    //pricing info
    if ([self.privateRequestManager.request.renter_type isEqualToString:EQRRenterPublic]){
        self.priceMatrixSubView.hidden = NO;
        [self getTransactionInfo];
    }else{
        self.priceMatrixSubView.hidden = YES;
    }
    
    [super viewWillAppear:animated];
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
    
//    NSLog(@"this is the classSection_foreignKey: %@", self.privateRequestManager.request.classSection_foreignKey);
    
    //must not include nil objects in array
    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
    if (!self.privateRequestManager.request.contact_foreignKey) self.privateRequestManager.request.contact_foreignKey = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.classSection_foreignKey) self.privateRequestManager.request.classSection_foreignKey = EQRErrorCode88888888;
    if ([self.privateRequestManager.request.classSection_foreignKey isEqualToString:@""]) self.privateRequestManager.request.classSection_foreignKey = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.classTitle_foreignKey) self.privateRequestManager.request.classTitle_foreignKey = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.request_date_begin) self.privateRequestManager.request.request_date_begin = [NSDate date];
    if (!self.privateRequestManager.request.request_date_end) self.privateRequestManager.request.request_date_end = [NSDate date];
    if (!self.privateRequestManager.request.contact_name) self.privateRequestManager.request.contact_name = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.time_of_request) self.privateRequestManager.request.time_of_request = [NSDate date];
    if (!self.privateRequestManager.request.notes) self.privateRequestManager.request.notes = @"";

    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatForDate stringFromDate:self.privateRequestManager.request.request_date_begin];
    NSString* dateEndString = [dateFormatForDate stringFromDate:self.privateRequestManager.request.request_date_end];
    
    //format the time
    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
    [dateFormatForTime setLocale:usLocale];
    [dateFormatForTime setDateFormat:@"HH:mm"];
    NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:self.privateRequestManager.request.request_date_begin];
    NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:self.privateRequestManager.request.request_date_end];
    NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
    NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
    
    //time of request
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:self.privateRequestManager.request.time_of_request];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.privateRequestManager.request.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", self.privateRequestManager.request.contact_foreignKey, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", self.privateRequestManager.request.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", self.privateRequestManager.request.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", timeBeginString, nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", timeEndString, nil];
    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", self.privateRequestManager.request.contact_name, nil];
    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", self.privateRequestManager.request.renter_type, nil];
    NSArray* eleventhArray = [NSArray arrayWithObjects:@"time_of_request", timeRequestString, nil];
    NSArray* twelfthArray = [NSArray arrayWithObjects:@"notes", self.privateRequestManager.request.notes, nil];
    
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
                         twelfthArray,
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
                NSArray* ayeArray = [NSArray arrayWithObjects:@"key_id", thisJoin.key_id, nil];
                NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
                [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoin.php" parameters:beeArray];
            }
        }
    }
    
    //_______*********  delete the marked MiscJoin
    for (NSString* thisKeyID in self.arrayOfToBeDeletedMiscJoinIDs){
        
        for (EQRMiscJoin* miscJoin in self.arrayOfMiscJoins){
            
            if ([thisKeyID isEqualToString:miscJoin.key_id]){
                
                //found a matching equipUnique item
                
                //send php message to detele with the miscjoin key_id
                NSArray* ayeArray = [NSArray arrayWithObjects:@"key_id", miscJoin.key_id, nil];
                NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
                [webData queryForStringWithLink:@"EQDeleteMiscJoin.php" parameters:beeArray];
            }
        }
    }
    
    //empty the arrays
    [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    [self.arrayOfMiscJoins removeAllObjects];
    [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    [self.arrayOfToBeDeletedMiscJoinIDs removeAllObjects];
    self.arrayOfSchedule_Unique_JoinsWithStructure = nil;

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


//_______this is repeated in EQRQuickViewPage2VCntrllr.m________
//_______works with an array of ScheduleTracking_EquipUnique_Joins, should also work with array of EquipUniqueItems_____
//#pragma mark - create structured array of equipment
//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//
//-(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray{
//    
//    //first get array of grouping objects
//    //get title items EQGetEquipmentTitlesAll (except items with hide_from_public set to YES)
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    __block NSMutableSet* tempMuteSetOfGroupingStrings = [NSMutableSet setWithCapacity:1];
//    __block NSMutableDictionary* tempMuteDicOfTitleKeysToGrouping = [NSMutableDictionary dictionaryWithCapacity:1];
//    
//    
//    [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
//        
//        //loop through entire title item array
//        for (EQREquipItem* item in muteArray){
//            
//            //add item's schedule_grouping to the dictionary
//            [tempMuteDicOfTitleKeysToGrouping setValue:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]forKey:item.key_id];
//            
//            BOOL foundTitleDontAdd = NO;
//            
//            for (NSString* titleString in tempMuteSetOfGroupingStrings){
//                
//                //identify items with schedule _grouping already in our muteable array
//                if ([[item performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:titleString]){
//                    
//                    foundTitleDontAdd = YES;
//                }
//            }
//            
//            //advance to next title item
//            if (foundTitleDontAdd == NO){
//                
//                //otherwise add grouping in set
//                [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
//            }
//        }
//    }];
//    
//    NSMutableArray* tempTopArray = [NSMutableArray arrayWithCapacity:1];
//    
//    //loop through ivar array of joins
//    for (EQRScheduleTracking_EquipmentUnique_Join* join in flatArray){
//        
//        //find a matching key_id
//        NSString* groupingString = [tempMuteDicOfTitleKeysToGrouping objectForKey:join.equipTitleItem_foreignKey];
//        
//        //assign to join object
//        join.schedule_grouping = groupingString;
//        
//        BOOL createNewSubArray = YES;
//        
//        for (NSMutableArray* subArray in tempTopArray){
//            
//            if ([join.schedule_grouping isEqualToString:[(EQRScheduleTracking_EquipmentUnique_Join*)[subArray objectAtIndex:0] schedule_grouping]]){
//                
//                createNewSubArray = NO;
//                
//                //add join to this subArray
//                [subArray addObject:join];
//            }
//        }
//        
//        if (createNewSubArray == YES){
//            
//            //create a new array
//            NSMutableArray* newArray = [NSMutableArray arrayWithObject:join];
//            
//            //add the subarray to the top array
//            [tempTopArray addObject:newArray];
//        }
//        
//    }
//    
//    NSArray* arrayToReturn = [NSArray arrayWithArray:tempTopArray];
//    
//    //sort the array alphabetically
//    NSArray* sortedTopArray = [arrayToReturn sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        
//        return [[(EQRScheduleTracking_EquipmentUnique_Join*)[obj1 objectAtIndex:0] schedule_grouping]
//                compare:[(EQRScheduleTracking_EquipmentUnique_Join*)[obj2 objectAtIndex:0] schedule_grouping]];
//    }];
//    
//    return sortedTopArray;
//}
//
//#pragma clang diagnostic pop



#pragma mark - alert view delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //buttonIndex at 0 is cancel

    //handle delete action when delete in confirmed
    if (buttonIndex == 1){
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        //delete the scheduleTracking item
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.privateRequestManager.request.key_id, nil];
        NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
        NSString* scheduleReturn = [webData queryForStringWithLink:@"EQDeleteScheduleItem.php" parameters:secondArray];
        NSLog(@"this is the schedule return: %@", scheduleReturn);
        
        //delete all scheduleTracking_equipUnique_joins
        NSArray* alphaArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey",self.privateRequestManager.request.key_id, nil];
        NSArray* betaArray = [NSArray arrayWithObjects:alphaArray, nil];
        NSString* joinReturn = [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoinWithScheduleKey.php" parameters:betaArray];
        NSLog(@"this is the join return: %@", joinReturn);
        
        //delete all miscJoins
        NSArray *unoArray = @[alphaArray];
        [webData queryForStringWithLink:@"EQDeleteAllMiscJoinsWithScheduleKey.php" parameters:unoArray];
        
        //empty the arrays
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
        [self.arrayOfMiscJoins removeAllObjects];
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
        [self.arrayOfToBeDeletedMiscJoinIDs removeAllObjects];
        self.arrayOfSchedule_Unique_JoinsWithStructure = nil;
        
        //send note to schedule that a change has been saved
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


#pragma mark - contact picker

-(IBAction)contactButton:(id)sender{
    
    EQRContactPickerVC* contactPickerVC = [[EQRContactPickerVC alloc] initWithNibName:@"EQRContactPickerVC" bundle:nil];
    self.myContactVC = contactPickerVC;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:self.myContactVC];
    [navController setNavigationBarHidden:YES];
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myContactPicker = popOver;
    self.myContactPicker.delegate = self;
    
    //set the size
    [self.myContactPicker setPopoverContentSize:CGSizeMake(320, 550)];
    
    //get coordinates in proper view
    
    //present popOver
    [self.myContactPicker presentPopoverFromRect:self.nameTextField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
    
    //self as delegate
    self.myContactVC.delegate = self;
    
}


-(void)retrieveSelectedNameItem{
    
    EQRContactNameItem* nameItem = [self.myContactVC retrieveContactItem];
    
    [self.nameTextField setTitle:nameItem.first_and_last forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
    
    //update data (needs to be saved)
    self.privateRequestManager.request.contactNameItem = nameItem;
    self.privateRequestManager.request.contact_name = nameItem.first_and_last;
    self.privateRequestManager.request.contact_foreignKey = nameItem.key_id;
    
    //release as delegate
    self.myContactVC.delegate = nil;
    
    //dismiss popover
    [self.myContactPicker dismissPopoverAnimated:YES];
    self.myContactPicker = nil;
    
    //release content view controller
//    self.myContactVC = nil;
}


#pragma mark - class picker methods


-(IBAction)classButton:(id)sender{
    
    EQRClassPickerVC* classPickerVC = [[EQRClassPickerVC alloc] initWithNibName:@"EQRClassPickerVC" bundle:nil];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:classPickerVC];
    [navController setNavigationBarHidden:YES];
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myClassPicker = popOver;
    self.myClassPicker.delegate = self;
    
    //set the size
    [self.myClassPicker setPopoverContentSize:CGSizeMake(300.f, 500.f)];

    
    //present the popover
    [self.myClassPicker presentPopoverFromRect:self.classField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
    
    //assign as delegate
    classPickerVC.delegate = self;
    
}


-(IBAction)removeClassButton:(id)sender{
    
    [self initiateRetrieveClassItem:nil];
    
}



-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem;{
    
//    EQRClassPickerVC* classPickerVC = (EQRClassPickerVC*)[self.myClassPicker contentViewController];
//    
//    //can be nil... no class assigned to request
//    EQRClassItem* thisClassItem = [classPickerVC retrieveClassItem];
    
    //update view objects
//    [self.classField setHidden:NO];
    if (!selectedClassItem){
        
        [self.classField setTitle:@"(No Class Selected)" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        
        //update schedule request
        self.privateRequestManager.request.classItem = nil;
        self.privateRequestManager.request.classSection_foreignKey = nil;
        self.privateRequestManager.request.classTitle_foreignKey = nil;
        
    }else{
        
        [self.classField setTitle:selectedClassItem.section_name forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        
        //update schedule request
        self.privateRequestManager.request.classItem = selectedClassItem;
        self.privateRequestManager.request.classSection_foreignKey = selectedClassItem.key_id;
        self.privateRequestManager.request.classTitle_foreignKey = selectedClassItem.catalog_foreign_key;
    }

    //____data layer is updated with save button___
    
    //release self as delegate
    self.myClassPicker.delegate = nil;
    
    //dismiss popover
    [self.myClassPicker dismissPopoverAnimated:YES];
    self.myClassPicker = nil;
    
}



#pragma mark - handle date view controller

-(IBAction)showDateVCntrllr:(id)sender{
    
    EQREditorDateVCntrllr* myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    
    UIPopoverController* popOverC = [[UIPopoverController alloc] initWithContentViewController:myDateViewController];
    self.theDatePopOver = popOverC;
    self.theDatePopOver.delegate = self;
    
    self.theDatePopOver.popoverContentSize = CGSizeMake(320.f, 570.f);

    
    [self.theDatePopOver presentPopoverFromRect:self.pickupDateField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //update dates labels
    myDateViewController.pickupDateField.date = self.pickUpDateDate;
    myDateViewController.returnDateField.date = self.returnDateDate;
    
    //update requestItem date properties
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(showExtendedDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //assign content VC as ivar
    self.myDateVC = myDateViewController;
}


-(IBAction)showExtendedDate:(id)sender{
    
//    NSLog(@"showOrHide action fires with class: %@", [[self.theDatePopOver contentViewController] class]);
    
    
    //change to Extended view
    EQREditorExtendedDateVC* myDateViewController = [[EQREditorExtendedDateVC alloc] initWithNibName:@"EQREditorExtendedDateVC" bundle:nil];
    CGSize thisSize = CGSizeMake(600.f, 570.f);
    
    [self.theDatePopOver setPopoverContentSize:thisSize animated:YES];
    [self.theDatePopOver setContentViewController:myDateViewController animated:YES];
    
    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(returnToStandardDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //need to set the date and time
    myDateViewController.pickupDateField.date = [self.myDateVC retrievePickUpDate];
    myDateViewController.pickupTimeField.date = [self.myDateVC retrievePickUpDate];
    myDateViewController.returnDateField.date = [self.myDateVC retrieveReturnDate];
    myDateViewController.returnTimeField.date = [self.myDateVC retrieveReturnDate];
    
    
    //assign content VC as ivar (necessary, because VCs always need to be retained)
    self.myDateVC = myDateViewController;
}


-(void)returnToStandardDate:(id)sender{
    
    //change to regular day view
    EQREditorDateVCntrllr* myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    CGSize thisSize = CGSizeMake(320.f, 570.f);
    
    [self.theDatePopOver setPopoverContentSize:thisSize animated:YES];
    [self.theDatePopOver setContentViewController:myDateViewController animated:YES];
    
    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(showExtendedDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //need to set the date
    myDateViewController.pickupDateField.date = [self.myDateVC retrievePickUpDate];
    myDateViewController.returnDateField.date = [self.myDateVC retrieveReturnDate];
    
    //assign content VC as ivar
    self.myDateVC = myDateViewController;
}


-(IBAction)dateSaveButton:(id)sender{
    
    //set dates in the view
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d, h:mm a";
    
    self.pickUpDateDate = [self.myDateVC retrievePickUpDate];
    self.returnDateDate = [self.myDateVC retrieveReturnDate];
    
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    //remove popover
    [self.theDatePopOver dismissPopoverAnimated:YES];
    self.theDatePopOver = nil;
    
}


#pragma mark - handle renter view controller

-(IBAction)showRenterVCntrllr:(id)sender{
    
    EQREditorRenterVCntrllr* myRenterVC = [[EQREditorRenterVCntrllr alloc] initWithNibName:@"EQREditorRenterVCntrllr" bundle:nil];
    self.myRenterViewController = myRenterVC;
    
    UIPopoverController* popOverC2 = [[UIPopoverController alloc] initWithContentViewController:self.myRenterViewController];
    self.theRenterPopOver = popOverC2;
    self.theRenterPopOver.delegate = self;
    
    //set size
    [self.theRenterPopOver setPopoverContentSize:CGSizeMake(300.f, 500.f)];
    
    [self.theRenterPopOver presentPopoverFromRect:self.renterTypeField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //initial setup
    [self.myRenterViewController initialSetupWithRenterTypeString:self.privateRequestManager.request.renter_type];
    
    
    //set self as delegate
    self.myRenterViewController.delegate = self;
    
    
}


-(void)initiateRetrieveRenterItem{
    
//    NSLog(@"this is the chosen renter type: %@", [self.myRenterViewController retrieveRenterType]);
    
    //set new renter type value
    [self.renterTypeField setTitle:[self.myRenterViewController retrieveRenterType] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    self.privateRequestManager.request.renter_type = [self.myRenterViewController retrieveRenterType];
    
    //remove popover
    [self.theRenterPopOver dismissPopoverAnimated:YES];
    self.theRenterPopOver = nil;
    
    //update pricing info
    if ([self.privateRequestManager.request.renter_type isEqualToString:EQRRenterPublic]){
        self.priceMatrixSubView.hidden = NO;
        [self getTransactionInfo];
    }else{
        self.priceMatrixSubView.hidden = YES;
    }
}


#pragma mark - Pricing Matrix

-(IBAction)showPricingButton:(id)sender{
    
    UIStoryboard *captureStoryboard = [UIStoryboard storyboardWithName:@"Pricing" bundle:nil];
    EQRAlternateWrappperPriceMatrix *newView = [captureStoryboard instantiateViewControllerWithIdentifier:@"price_alternate_wrapper"];
    newView.delegate = self;
    
    newView.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:newView animated:YES completion:^{
        
        //provide VC with request information
        [newView provideScheduleRequest:self.privateRequestManager.request];
        
        
    }];
    
    
    //
    //    newView.edgesForExtendedLayout = UIRectEdgeAll;
    //    [self.navigationController pushViewController:newView animated:YES];
}

// EQRPriceMatrixVC delegate method

-(void)aChangeWasMadeToPriceMatrix{
    
    [self getTransactionInfo];
}

-(void)getTransactionInfo{
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.privateRequestManager.request.key_id];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQGetTransactionWithScheduleRequestKey.php" parameters:topArray completion:^(EQRTransaction *transaction) {
            
            if (transaction){
                
                NSLog(@"this is the transaction's key_id: %@", transaction.key_id);
                
                self.myTransaction = transaction;
                
                //found a matching transaction for this schedule Request, go on...
                [self populatePricingWidget];
                
            }else{
                
                //no matching transaction, create a fresh one.
                NSLog(@"didn't find a matching Transaction");
                [self.priceWidget deleteExistingData];
            }
        }];
    });
}

-(void)populatePricingWidget{
    
    if (self.myTransaction){
        [self.priceWidget initialSetupWithTransaction:self.myTransaction];
    }else{
        [self.priceWidget deleteExistingData];
    }
    
}

#pragma mark - handle add equip item

-(IBAction)addEquipItem:(id)sender{
    
    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    //need to specify a privateRequestManager for the equip selection v cntrllr
    //also sets ivar isInPopover to YES
    [genericEquipVCntrllr overrideSharedRequestManager:self.privateRequestManager];
    
//    genericEquipVCntrllr.edgesForExtendedLayout = UIRectEdgeNone;
//    [self.navigationController pushViewController:genericEquipVCntrllr animated:NO];
    
    UIPopoverController* popOverMe = [[UIPopoverController alloc] initWithContentViewController:genericEquipVCntrllr];
    self.theEquipSelectionPopOver = popOverMe;
    self.theEquipSelectionPopOver.delegate = self;
    
    //must manually set the size, cannot be wider than 600px!!!!???? But seems to work ok at 800 anyway???
    self.theEquipSelectionPopOver.popoverContentSize = CGSizeMake(700, 600);
    
    [self.theEquipSelectionPopOver presentPopoverFromRect:self.addEquipItemButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated: YES];
    

    //need to reprogram the target of the save button
    [genericEquipVCntrllr.continueButton removeTarget:genericEquipVCntrllr action:NULL forControlEvents:UIControlEventAllEvents];
    [genericEquipVCntrllr.continueButton addTarget:self action:@selector(continueAddEquipItem:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)continueAddEquipItem:(id)sender{
    
    //replaces the uniqueItem key from "1" to an accurate value
    [self.privateRequestManager justConfirm];

    [self.theEquipSelectionPopOver dismissPopoverAnimated:YES];

    //dealloc the popover or it resumes to show selected items from a previous viewing.. ALSO need to do this in the popover delegate method!!
    //____!!!!!!  must also issue the same dealloc for the content VC in the Popover's delegate method for when cancelled  !!!!!!______
    self.theEquipSelectionPopOver = nil;

    //need to update self.arrayOfEquipUniqueItems ??
    //empty arrays first
    [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    [self.arrayOfMiscJoins removeAllObjects];
    self.arrayOfSchedule_Unique_JoinsWithStructure = nil;
    
    NSMutableArray* arrayToReturnJoins = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"],  nil];
    NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
    
    //get Scheduletracking_equipUnique_joins
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php"
                parameters:secondArray class:@"EQRScheduleTracking_EquipmentUnique_Join"
                completion:^(NSMutableArray *muteArray) {
        
        [arrayToReturnJoins addObjectsFromArray:muteArray];
        
    }];
    
    [self.arrayOfSchedule_Unique_Joins addObjectsFromArray:arrayToReturnJoins];
    
    //gather any misc joins
    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"]];
    NSArray* omegaArray = @[alphaArray];
    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
        for (id object in muteArray2){
            [tempMiscMuteArray addObject:object];
        }
    }];
    [self.arrayOfMiscJoins addObjectsFromArray:tempMiscMuteArray];
    
    //add structure
    self.arrayOfSchedule_Unique_JoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfSchedule_Unique_Joins withMiscJoins:self.arrayOfMiscJoins];
    
    //reload collection view
    [self.equipList reloadData];
    
    //____________***
}



#pragma mark - EQREditorEquipDelegate methods

-(void)tagEquipUniqueToDelete:(NSString*)key_id{
    
    [self.arrayOfToBeDeletedEquipIDs addObject:key_id];

}

-(void)tagEquipUniqueToCancelDelete:(NSString*)key_id{
    
    NSString* stringToBeRemoved;
    
    for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
        
        if ([thisString isEqualToString:key_id]){
            
            stringToBeRemoved = thisString;
        }
    }
    
    [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
}

#pragma mark - EQREditorMiscCellDelegate methods

-(void)tagMiscJoinToDelete:(NSString*)key_id{
    
    [self.arrayOfToBeDeletedMiscJoinIDs addObject:key_id];
}

-(void)tagMiscJoinToCancelDelete:(NSString*)key_id{
    
    NSString* stringToBeRemoved;
    
    for (NSString* thisString in self.arrayOfToBeDeletedMiscJoinIDs){
        
        if ([thisString isEqualToString:key_id]) {
            
            stringToBeRemoved = thisString;
        }
    }
    
    [self.arrayOfToBeDeletedMiscJoinIDs removeObject:stringToBeRemoved];
}


#pragma mark - Distinguishing ID Picker


-(void)distIDPickerTapped:(NSDictionary*)infoDictionary{
    
    //get cell's equipUniqueKey, titleKey, buttonRect and button
    NSString* equipTitleItem_foreignKey = [infoDictionary objectForKey:@"equipTitleItem_foreignKey"];
    NSString* equipUniqueItem_foreignKey = [infoDictionary objectForKey:@"equipUniqueItem_foreignKey"];
//    CGRect buttonRect = [(UIButton*)[infoDictionary objectForKey:@"distButton"] frame];
    UIButton* thisButton = (UIButton*)[infoDictionary objectForKey:@"distButton"];
    
    //create content VC
    EQRDistIDPickerTableVC* distIDPickerVC = [[EQRDistIDPickerTableVC alloc] initWithNibName:@"EQRDistIDPickerTableVC" bundle:nil];
    
    //initial setup
    [distIDPickerVC initialSetupWithOriginalUniqueKeyID:equipUniqueItem_foreignKey equipTitleKey:equipTitleItem_foreignKey scheduleItem:self.privateRequestManager.request];
    distIDPickerVC.delegate = self;
    
    //create uiPopoverController
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:distIDPickerVC];
    [popOver setPopoverContentSize:CGSizeMake(320.f, 300.f)];
    popOver.delegate = self;
    self.distIDPopover = popOver;
    
    CGRect fixedRect2 = [thisButton.superview.superview convertRect:thisButton.frame fromView:thisButton.superview];
    CGRect fixedRect3 = [thisButton.superview.superview.superview convertRect:fixedRect2 fromView:thisButton.superview.superview];
    CGRect fixedRect4 = [thisButton.superview.superview.superview.superview convertRect:fixedRect3 fromView:thisButton.superview.superview.superview];
    CGRect fixedRect5 = [thisButton.superview.superview.superview.superview.superview convertRect:fixedRect4 fromView:thisButton.superview.superview.superview.superview];
//    CGRect fixedRect6 = [thisButton.superview.superview.superview.superview.superview.superview convertRect:fixedRect5 fromView:thisButton.superview.superview.superview.superview.superview];
    
    //present popover
    [self.distIDPopover presentPopoverFromRect:fixedRect5 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//dist id picker delegate method
-(void)distIDSelectionMadeWithOriginalEquipUniqueKey:(NSString*)originalKeyID equipUniqueItem:(id)distEquipUniqueItem{
    
    //retrieve key id of selected equipUniqueItem AND indexPath of the collection cell that initiated the distID picker
    //tell content of the cell to use replace the dist ID
    //update the data model > schedule_equip_join has new unique_foreignKey
    
    //extract the unique's key as a string
    NSString* thisIsTheKey = [(EQREquipUniqueItem*)distEquipUniqueItem key_id];
    NSString* thisIsTheDistID = [(EQREquipUniqueItem*)distEquipUniqueItem distinquishing_id];
//    NSLog(@"this is the issue_service_name text: %@", [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name]);
    NSString* thisIsTheIssueShortName = [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name];
    NSString* thisIsTheStatusLevel = [(EQREquipUniqueItem*)distEquipUniqueItem status_level];
    
    
    EQRScheduleTracking_EquipmentUnique_Join* saveThisJoin;
    
    //update local ivar arrays
    for (EQRScheduleTracking_EquipmentUnique_Join* joinObj in self.arrayOfSchedule_Unique_Joins){
        
        if ([joinObj.equipUniqueItem_foreignKey isEqualToString:originalKeyID]){
            
            [joinObj setEquipUniqueItem_foreignKey:thisIsTheKey];
            [joinObj setDistinquishing_id:thisIsTheDistID];
            
            //_____need to know what service issues are a part of this new equipUnique and assign to local var in array______
            [joinObj setIssue_short_name:thisIsTheIssueShortName];
            [joinObj setStatus_level:thisIsTheStatusLevel];
            
            saveThisJoin = joinObj;
            break;
        }
    }
    
    self.arrayOfSchedule_Unique_JoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfSchedule_Unique_Joins withMiscJoins:self.arrayOfMiscJoins];
    
    //renew the collection view
    [self.equipList reloadData];
    
    
    //update the data layer
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", [saveThisJoin key_id], nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", [saveThisJoin equipUniqueItem_foreignKey], nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", [saveThisJoin equipTitleItem_foreignKey], nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryForStringWithLink:@"EQAlterScheduleEquipJoin.php" parameters:topArray];
//    NSLog(@"this is the return string: %@", returnString);
    
    
    //remove the popover
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController setDelegate:nil];
    
    [self.distIDPopover dismissPopoverAnimated:YES];
    
    //gracefully dealloc all the objects in the content VC
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController killThisThing];
    
    self.distIDPopover = nil;
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
}


#pragma mark - Notes popover methods

-(void)openNotesEditor{
    
    EQRNotesVC* thisNotes = [[EQRNotesVC alloc] initWithNibName:@"EQRNotesVC" bundle:nil];
    thisNotes.delegate = self;
    
    UIPopoverController* thisNotesPop = [[UIPopoverController alloc] initWithContentViewController:thisNotes];
    self.myNotesPopover = thisNotesPop;
    self.myNotesPopover.delegate = self;
    
    [self.myNotesPopover setPopoverContentSize:CGSizeMake(320.f, 400.f)];
    
    [self.myNotesPopover presentPopoverFromRect:self.notesView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //must be after presentation
    [thisNotes initialSetupWithScheduleRequest:self.privateRequestManager.request];
}


-(void)retrieveNotesData:(NSString*)noteText{
    
    //update notes view
    self.notesView.text = noteText;
    
    //update ivar request
    self.privateRequestManager.request.notes = noteText;
    
    //update data layer
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.privateRequestManager.request.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"notes", noteText, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryForStringWithLink:@"EQAlterNotesInScheduleRequest.php" parameters:topArray];
    
    //dismiss popover
    [self.myNotesPopover dismissPopoverAnimated:YES];
    self.myNotesPopover = nil;
}



#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        
    return [[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:section] count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return [self.arrayOfSchedule_Unique_JoinsWithStructure count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //__1__ An equipUniqueJoin item
    //__2__ A MiscJoin Item
    
    if ([[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] respondsToSelector:@selector(schedule_grouping)]){
        
        EQREditorEquipListCell* cell = [self.equipList dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //set self as cell's delegate
        cell.delegate = self;
        
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
            
            if ([keyToDelete isEqualToString:[[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] equipUniqueItem_foreignKey]]){
                
                toBeDeleted = YES;
                break;
            }
        }
        
        [cell initialSetupWithJoinObject:[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] deleteFlag:toBeDeleted editMode:YES];
        
        return cell;
        
    }else{
        
        EQREditorMiscListCell* cell = [self.equipList dequeueReusableCellWithReuseIdentifier:@"CellForMiscJoin" forIndexPath:indexPath];
        

        
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //set self as cell's delegate
        cell.delegate = self;
        
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedMiscJoinIDs){
            
            if ([keyToDelete isEqualToString:[[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id]]){
                
                toBeDeleted = YES;
                break;
            }
        }
        
        [cell initialSetupWithMiscJoin:[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] deleteFlag:toBeDeleted editMode:YES];
        
        return cell;
    }
}


-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SuppCell";
    
    EQREditorHeaderCell* cell = [self.equipList dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    if ([[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:0] respondsToSelector:@selector(schedule_grouping)]){
        [cell initialSetupWithTitle: [(EQREquipUniqueItem*)[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] schedule_grouping]];
    }else{
        [cell initialSetupWithTitle:@"Miscellaneous"];
    }
    
    return cell;
}


#pragma mark - collection view flow layout delegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //width is equal to the collectionView's width
    return CGSizeMake(self.equipList.frame.size.width, 35.f);
    
}

#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    //___There are 7 different popovers____
    //try a universal approach...
    //____this didn't work____
//    popoverController = nil;
    
    //this works... need to dealloc properties
    if (popoverController == self.theDatePopOver){
        
        self.theDatePopOver = nil;
        
    }else if (popoverController == self.theRenterPopOver){
        
        self.theRenterPopOver = nil;
        
    }else if (popoverController == self.theEquipSelectionPopOver){
        
        self.theEquipSelectionPopOver = nil;
        
    }else if (popoverController == self.myContactPicker){
        
        //release delegate
        self.myContactVC.delegate = self;
        
        //release content view controller
        self.myContactVC = nil;
        
        //release popover
        self.myContactPicker = nil;
        
    }else if (popoverController == self.distIDPopover){
        
        self.distIDPopover = nil;
        
    }else if(popoverController == self.myNotesPopover){
        
        self.myNotesPopover = nil;
        
    }else if(popoverController == self.myClassPicker){
        
        self.myClassPicker = nil;
    }
    
}


#pragma mark - change in orientation methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self.equipList reloadData];
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.privateRequestManager = nil;
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
