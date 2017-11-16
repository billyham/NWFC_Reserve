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
@property (strong, nonatomic) EQREditorDateVCntrllr *myExtendedDateVC;
@property (strong, nonatomic) EQRContactPickerVC* myContactVC;

//popOvers
//@property (strong, nonatomic) UIPopoverController* theDatePopOver;
@property (strong, nonatomic) UIPopoverController* theRenterPopOver;
@property (strong, nonatomic) UIPopoverController* theEquipSelectionPopOver;
@property (strong, nonatomic) UIPopoverController* distIDPopover;
@property (strong, nonatomic) UIPopoverController* myNotesPopover;

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
    
    // Register for notes
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    // Set ivar flag
    self.saveButtonTappedFlag = NO;
    
    // Register collection view cell
    [self.equipList registerClass:[EQREditorEquipListCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.equipList registerClass:[EQREditorMiscListCell class] forCellWithReuseIdentifier:@"CellForMiscJoin"];
    [self.equipList registerClass:[EQREditorHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SuppCell"];
    
    // Initialze ivar arrays
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
    
    // Set color of collection view
    EQRColors* eqrColors = [EQRColors sharedInstance];
    self.equipList.backgroundColor = [eqrColors.colorDic objectForKey:EQRColorVeryLightGrey];
    
    // Save bar button
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    
    // Cancel bar button
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    // Set title
    self.navigationItem.title = @"Editor Request";
    
    
    
    NSMutableArray* arrayToReturnJoins = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"],  nil];
    NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
    
    // Get Scheduletracking_equipUnique_joins 
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php"
                parameters:secondArray class:@"EQRScheduleTracking_EquipmentUnique_Join"
                completion:^(NSMutableArray *muteArray) {
       
        [arrayToReturnJoins addObjectsFromArray:muteArray];
    }];
    
    [self.arrayOfSchedule_Unique_Joins addObjectsFromArray:arrayToReturnJoins];
    
    // Gather any misc joins
    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"]];
    NSArray* omegaArray = @[alphaArray];
    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
        for (id object in muteArray2){
            [tempMiscMuteArray addObject:object];
        }
    }];
    [self.arrayOfMiscJoins addObjectsFromArray:tempMiscMuteArray];
    
    // Add structure to array
    self.arrayOfSchedule_Unique_JoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfSchedule_Unique_Joins withMiscJoins:self.arrayOfMiscJoins];
    
    // Reload collection view
    [self.equipList reloadData];
    
    
    // Set text in notes
    self.notesView.text = [self.myUserInfo objectForKey:@"notes"];
    
    // Make notes view hot to touch
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openNotesEditor)];
    [self.notesView addGestureRecognizer:tapGest];
    
    // Background color for notes
    EQRColors* colors = [EQRColors sharedInstance];
    self.notesView.backgroundColor = [colors.colorDic objectForKey:EQRColorEditModeBGBlue];
    
    EQRPricingWidgetVC *priceWidget = [[EQRPricingWidgetVC alloc] initWithNibName:@"EQRPricingWidgetVC" bundle:nil];
    self.priceWidget = priceWidget;
    CGRect tempRect = CGRectMake(0, 0, self.priceMatrixSubView.frame.size.width, self.priceMatrixSubView.frame.size.height);
    priceWidget.view.frame = tempRect;
    
    [self.priceMatrixSubView addSubview:self.priceWidget.view];
    
    // Set button target
    [self.priceWidget.editButton addTarget:self action:@selector(showPricingButton:) forControlEvents:UIControlEventTouchUpInside];

}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.myUserInfo = userInfo;
    
    // Create private request manager as ivar
    if (!self.privateRequestManager){
        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
    }
    
    // Set dates
    self.pickUpDateDate = [self.myUserInfo objectForKey:@"request_date_begin"];
    self.returnDateDate = [self.myUserInfo objectForKey:@"request_date_end"];
    self.pickUpTime = [self.myUserInfo objectForKey:@"request_time_begin"];
    self.returnTime = [self.myUserInfo objectForKey:@"request_time_end"];
    
    // Set notes
    self.notesView.text = [self.myUserInfo objectForKey:@"notes"];
    
    // Add times to dates
    self.pickUpDateDate = [self.pickUpDateDate dateByAddingTimeInterval: [self.pickUpTime timeIntervalSinceReferenceDate]];
    self.returnDateDate = [self.returnDateDate dateByAddingTimeInterval:[self.returnTime timeIntervalSinceReferenceDate]];
    
    // Adjust by subtracting 8 hours
    float secondsForOffset = -28800;    //this is 9 hours = 32400, this is 8 hours = 28800;
    self.pickUpDateDate = [self.pickUpDateDate dateByAddingTimeInterval:secondsForOffset];
    self.returnDateDate = [self.returnDateDate dateByAddingTimeInterval:secondsForOffset];
    
    
    // Instantiate the request item in ivar requestManager
    self.privateRequestManager.request = [[EQRScheduleRequestItem alloc] init];
    
    // Two important methods that initiate requestManager ivar arrays
    [self.privateRequestManager resetEquipListAndAvailableQuantites];
    [self.privateRequestManager retrieveAllEquipUniqueItems:^(NSMutableArray *muteArray) {
//        TODO: retrieveAllEquipUniqueItems async
    }];
    
    
    // Populate its ivars
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
    NSArray* topArrayWithKey = @[ @[@"key_id", [userInfo objectForKey:@"key_ID"]] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        [webData queryForStringwithAsync:@"EQGetScheduleRequestInComplete.php" parameters:topArrayWithKey completion:^(EQRScheduleRequestItem *chosenItem) {
            
            if (!chosenItem) return;
            
            self.privateRequestManager.request.key_id = [chosenItem key_id];
            self.privateRequestManager.request.contact_foreignKey =  [chosenItem  contact_foreignKey];
            self.privateRequestManager.request.classSection_foreignKey = [chosenItem  classSection_foreignKey];
            self.privateRequestManager.request.classTitle_foreignKey = [chosenItem  classTitle_foreignKey];
            self.privateRequestManager.request.time_of_request = [chosenItem  time_of_request];
            
            [self renderClass];
            [self renderPricMatrix];
        }];
    });
    
    //_________**********  LOAD REQUEST EDITOR COLLECTION VIEW WITH EquipUniqueItem_Joins  *******_____________
    //populate...
    //arrayOfSchedule_Unique_Joins
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self renderClass];
    [self renderPricMatrix];
    
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

-(void)renderPricMatrix{
    if (([self.privateRequestManager.request.key_id isEqualToString:EQRErrorCode88888888]) ||
        ([self.privateRequestManager.request.key_id isEqualToString:@""]) ||
        (!self.privateRequestManager.request.key_id)){
        return;
    }
    
    //pricing info
    if ([self.privateRequestManager.request.renter_type isEqualToString:EQRRenterPublic]){
        self.priceMatrixSubView.hidden = NO;
        [self getTransactionInfo];
    }else{
        self.priceMatrixSubView.hidden = YES;
    }
}

-(void)renderClass{
    if (([self.privateRequestManager.request.classTitle_foreignKey isEqualToString:EQRErrorCode88888888]) ||
        ([self.privateRequestManager.request.classTitle_foreignKey isEqualToString:@""]) ||
        (!self.privateRequestManager.request.classTitle_foreignKey)) {
        return;
    }

    NSArray* top2Array = @[ @[@"key_id", self.privateRequestManager.request.classTitle_foreignKey] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQGetClassCatalogTitleWithKey.php" parameters:top2Array completion:^(NSString *catalogTitle) {
            [self.classField setTitle:catalogTitle forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];
        }];
    });
}


#pragma mark - button actions
-(void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


-(IBAction)saveAction:(id)sender{
    
    self.saveButtonTappedFlag = YES;
    
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

    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"saveAction";
    queue.maxConcurrentOperationCount = 3;
    
    
    NSBlockOperation *setNewScheduleRequest = [NSBlockOperation blockOperationWithBlock:^{
        // Format the nsdates to a mysql compatible string
        NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatForDate setLocale:usLocale];
        [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
        NSString* dateBeginString = [dateFormatForDate stringFromDate:self.privateRequestManager.request.request_date_begin];
        NSString* dateEndString = [dateFormatForDate stringFromDate:self.privateRequestManager.request.request_date_end];
        
        // Format the time
        NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
        [dateFormatForTime setLocale:usLocale];
        [dateFormatForTime setDateFormat:@"HH:mm"];
        NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:self.privateRequestManager.request.request_date_begin];
        NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:self.privateRequestManager.request.request_date_end];
        NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
        NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
        
        // Time of request
        NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
        [timeStampFormatter setLocale:usLocale];
        [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* timeRequestString = [timeStampFormatter stringFromDate:self.privateRequestManager.request.time_of_request];
        
        NSArray* bigArray = @[ @[@"key_id", self.privateRequestManager.request.key_id],
                               @[@"contact_foreignKey", self.privateRequestManager.request.contact_foreignKey],
                               @[@"classSection_foreignKey", self.privateRequestManager.request.classSection_foreignKey],
                               @[@"classTitle_foreignKey", self.privateRequestManager.request.classTitle_foreignKey],
                               @[@"request_date_begin", dateBeginString],
                               @[@"request_date_end", dateEndString],
                               @[@"request_time_begin", timeBeginString],
                               @[@"request_time_end", timeEndString],
                               @[@"contact_name", self.privateRequestManager.request.contact_name],
                               @[@"renter_type", self.privateRequestManager.request.renter_type],
                               @[@"time_of_request", timeRequestString],
                               @[@"notes", self.privateRequestManager.request.notes] ];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
    }];
    
    
    NSBlockOperation *deleteScheduleEquipJoin = [NSBlockOperation blockOperationWithBlock:^{
        // Delete scheduleTracking_equip_joins
        EQRWebData* webData = [EQRWebData sharedInstance];
        for (NSString* thisKeyID in self.arrayOfToBeDeletedEquipIDs){
            for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in self.arrayOfSchedule_Unique_Joins){
                
                if ([thisKeyID isEqualToString:thisJoin.equipUniqueItem_foreignKey]){
                    
                    // Delete Equip Joing with the join key_id
                    NSArray* beeArray = @[ @[@"key_id", thisJoin.key_id] ];
                    [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoin.php" parameters:beeArray];
                }
            }
        }
    }];
    
    
    NSBlockOperation *deleteMiscJoin = [NSBlockOperation blockOperationWithBlock:^{
        // Delete the marked MiscJoins
        EQRWebData* webData = [EQRWebData sharedInstance];
        for (NSString* thisKeyID in self.arrayOfToBeDeletedMiscJoinIDs){
            for (EQRMiscJoin* miscJoin in self.arrayOfMiscJoins){
                
                if ([thisKeyID isEqualToString:miscJoin.key_id]){
                    
                    // Delete Misc Join the join key_id
                    NSArray* beeArray = @[ @[@"key_id", miscJoin.key_id] ];
                    [webData queryForStringWithLink:@"EQDeleteMiscJoin.php" parameters:beeArray];
                }
            }
        }
    }];
    
    
    NSBlockOperation *updateArraysAndRender = [NSBlockOperation blockOperationWithBlock:^{
        //empty the arrays
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
        [self.arrayOfMiscJoins removeAllObjects];
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
        [self.arrayOfToBeDeletedMiscJoinIDs removeAllObjects];
        self.arrayOfSchedule_Unique_JoinsWithStructure = nil;
        
        //send note to schedule that a change has been saved
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        });
    }];
    [updateArraysAndRender addDependency:setNewScheduleRequest];
    [updateArraysAndRender addDependency:deleteScheduleEquipJoin];
    [updateArraysAndRender addDependency:deleteMiscJoin];
    
    
    [queue addOperation:setNewScheduleRequest];
    [queue addOperation:deleteScheduleEquipJoin];
    [queue addOperation:deleteMiscJoin];
    [queue addOperation:updateArraysAndRender];
}


-(IBAction)deleteRequest:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Confirmation" message:@"Are you sure you want to delete this reservation?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertContinue = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteContinue];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
    
    [alert addAction:alertContinue];
    [alert addAction:alertCancel];
    [self presentViewController:alert animated:YES completion:^{ }];
}


#pragma mark - alert view delegate methods

- (void)deleteContinue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"deleteButtonAlert";
    queue.maxConcurrentOperationCount = 1;
    
    
    NSBlockOperation *deleteScheduleItem = [NSBlockOperation blockOperationWithBlock:^{
        // Delete the scheduleTracking item
        NSArray* secondArray = @[ @[@"key_id", self.privateRequestManager.request.key_id] ];
        EQRWebData* webData = [EQRWebData sharedInstance];
        NSString *result = [webData queryForStringWithLink:@"EQDeleteScheduleItem.php" parameters:secondArray];
        if (!result) NSLog(@"EQREditorTopVC > alertView, failed to delete schedule item");
    }];
    
    
    NSBlockOperation *deleteScheduleEquipJoinWithScheduleKey = [NSBlockOperation blockOperationWithBlock:^{
        // Delete all scheduleTracking_equipUnique_joins
        NSArray* betaArray = @[ @[@"scheduleTracking_foreignKey",self.privateRequestManager.request.key_id] ];
        EQRWebData* webData = [EQRWebData sharedInstance];
        NSString *result = [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoinWithScheduleKey.php" parameters:betaArray];
        if (!result) NSLog(@"EQREditorTopVC > alertView, failed to delete schedule equip joins");
    }];
    
    
    NSBlockOperation *deleteAllMiscJoinsWithScheduleKey = [NSBlockOperation blockOperationWithBlock:^{
        // Delete all miscJoins
        NSArray *unoArray = @[ @[@"scheduleTracking_foreignKey",self.privateRequestManager.request.key_id] ];
        EQRWebData* webData = [EQRWebData sharedInstance];
        NSString *result = [webData queryForStringWithLink:@"EQDeleteAllMiscJoinsWithScheduleKey.php" parameters:unoArray];
        if (!result) NSLog(@"EQREditorTopVC > alertView, failed to delete schedule misc joins");
    }];
    
    
    NSBlockOperation *updateArraysAndRender = [NSBlockOperation blockOperationWithBlock:^{
        
        // Empty the arrays
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
        [self.arrayOfMiscJoins removeAllObjects];
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
        [self.arrayOfToBeDeletedMiscJoinIDs removeAllObjects];
        self.arrayOfSchedule_Unique_JoinsWithStructure = nil;
        
        // Send note to schedule that a change has been saved
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
            
            }];
        });
    }];
    
    
    [queue addOperation:deleteScheduleItem];
    [queue addOperation:deleteScheduleEquipJoinWithScheduleKey];
    [queue addOperation:deleteAllMiscJoinsWithScheduleKey];
    [queue addOperation:updateArraysAndRender];
}


#pragma mark - contact picker

- (IBAction)contactButton:(id)sender{
    
    EQRContactPickerVC* contactPickerVC = [[EQRContactPickerVC alloc] initWithNibName:@"EQRContactPickerVC" bundle:nil];
    self.myContactVC = contactPickerVC;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.myContactVC];
    [navController setNavigationBarHidden:YES];
    
//    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
//    self.myContactPicker = popOver;
//    self.myContactPicker.delegate = self;
//
//    //set the size
//    [self.myContactPicker setPopoverContentSize:CGSizeMake(320, 550)];
//
//    //get coordinates in proper view
//
//    //present popOver
//    [self.myContactPicker presentPopoverFromRect:self.nameTextField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];

    //self as delegate
    self.myContactVC.delegate = self;
    
    navController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popoverPC = [navController popoverPresentationController];
    popoverPC.permittedArrowDirections = UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
    popoverPC.delegate = self;
    [popoverPC setSourceRect:self.nameTextField.frame];
    [popoverPC setSourceView:self.view];
    
    [self presentViewController:navController animated:YES completion:^{ }];
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
//    [self.myContactPicker dismissPopoverAnimated:YES];
//    self.myContactPicker = nil;

    [self dismissViewControllerAnimated:YES completion:^{  }];
}


#pragma mark - class picker methods
- (IBAction)classButton:(id)sender{
    
    EQRClassPickerVC* classPickerVC = [[EQRClassPickerVC alloc] initWithNibName:@"EQRClassPickerVC" bundle:nil];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:classPickerVC];
    [navController setNavigationBarHidden:YES];
    
    classPickerVC.delegate = self;
    
    navController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popoverPC = [navController popoverPresentationController];
    popoverPC.permittedArrowDirections = UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft;
    popoverPC.delegate = self;
    popoverPC.sourceRect = self.classField.frame;
    popoverPC.sourceView = self.view;
    
    [self presentViewController:navController animated:YES completion:^{ }];
}


-(IBAction)removeClassButton:(id)sender{
    [self clearClass];
}


- (void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem;{
    
    if (!selectedClassItem){
        [self clearClass];
    }else{
        [self.classField setTitle:selectedClassItem.section_name forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        
        //update schedule request
        self.privateRequestManager.request.classItem = selectedClassItem;
        self.privateRequestManager.request.classSection_foreignKey = selectedClassItem.key_id;
        self.privateRequestManager.request.classTitle_foreignKey = selectedClassItem.catalog_foreign_key;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


- (void)clearClass {
    [self.classField setTitle:@"(No Class Selected)" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    
    //update schedule request
    self.privateRequestManager.request.classItem = nil;
    self.privateRequestManager.request.classSection_foreignKey = nil;
    self.privateRequestManager.request.classTitle_foreignKey = nil;
}


#pragma mark - handle date view controller
- (IBAction)showDateVCntrllr:(id)sender{
    
    EQREditorDateVCntrllr* myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];

    self.myDateVC = myDateViewController;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:myDateViewController];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(standardDateSave:)];
    [myDateViewController.navigationItem setLeftBarButtonItem:leftButton];
    [myDateViewController.navigationItem setRightBarButtonItem:rightButton];
    
    // Update dates labels
    [myDateViewController setPickupDate:self.pickUpDateDate returnDate:self.returnDateDate];
    [myDateViewController setShowExtended:@"showExtendedDate:" withTarget:self];
    
    // Update requestItem date properties
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    [self presentViewController:navController animated:YES completion:^{ }];
}

- (void)dismissDateSheet {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (IBAction)showExtendedDate:(id)sender{
    
    //change to Extended view
    EQREditorExtendedDateVC* myDateViewController = [[EQREditorExtendedDateVC alloc] initWithNibName:@"EQREditorExtendedDateVC" bundle:nil];
    
//    CGSize preferredSize = CGSizeMake(600.f, 570.f);
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(extendedDateSave:)];
    [myDateViewController.navigationItem setRightBarButtonItem:rightButton];
    
    [[self.myDateVC navigationController] pushViewController:myDateViewController animated:YES];
    
//    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
//                              forControlEvents:UIControlEventTouchUpInside];
    
    [myDateViewController setShowExtended:@"returnToStandardDate:" withTarget:self];
//    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(returnToStandardDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //need to set the date and time
    [myDateViewController setPickupDate:[self.myDateVC retrievePickUpDate] returnDate:[self.myDateVC retrieveReturnDate]];
//    myDateViewController.pickupDateField.date = [self.myDateVC retrievePickUpDate];
//    myDateViewController.returnDateField.date = [self.myDateVC retrieveReturnDate];

    myDateViewController.pickupTimeField.date = [self.myDateVC retrievePickUpDate];
    myDateViewController.returnTimeField.date = [self.myDateVC retrieveReturnDate];
    
    self.myExtendedDateVC = myDateViewController;
}


- (void)returnToStandardDate:(id)sender{
    [[self.myExtendedDateVC navigationController] popViewControllerAnimated:NO];

    //change to regular day view
//    EQREditorDateVCntrllr* myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    
//    CGSize thisSize = CGSizeMake(320.f, 570.f);
    
//    [self.theDatePopOver setPopoverContentSize:thisSize animated:YES];
//    [self.theDatePopOver setContentViewController:myDateViewController animated:YES];
    
//    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
//                              forControlEvents:UIControlEventTouchUpInside];
//    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(showExtendedDate:) forControlEvents:UIControlEventTouchUpInside];
//
//    //need to set the date
//    myDateViewController.pickupDateField.date = [self.myDateVC retrievePickUpDate];
//    myDateViewController.returnDateField.date = [self.myDateVC retrieveReturnDate];
//
//    //assign content VC as ivar
//    self.myDateVC = myDateViewController;
}

- (IBAction)standardDateSave:(id)sender {
    [self dateSaveButtonWithPickup:[self.myDateVC retrievePickUpDate]
                            return:[self.myDateVC retrieveReturnDate]];
}

- (IBAction)extendedDateSave:(id)sender {
    [self dateSaveButtonWithPickup:[self.myExtendedDateVC retrievePickUpDate]
                            return:[self.myExtendedDateVC retrieveReturnDate]];
}

- (IBAction)dateSaveButtonWithPickup:(NSDate *)pickupDate return:(NSDate *)returnDate{
    
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d, h:mm a";
    
    self.pickUpDateDate = pickupDate;
    self.returnDateDate = returnDate;
    
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


#pragma mark - handle renter view controller
- (IBAction)showRenterVCntrllr:(id)sender{
    
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
//                NSLog(@"this is the transaction's key_id: %@", transaction.key_id);
                self.myTransaction = transaction;
                
                //found a matching transaction for this schedule Request, go on...
                [self populatePricingWidget];
                
            }else{
                
                //no matching transaction, create a fresh one.
//                NSLog(@"didn't find a matching Transaction");
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

// dist id picker delegate method
-(void)distIDSelectionMadeWithOriginalEquipUniqueKey:(NSString*)originalKeyID equipUniqueItem:(id)distEquipUniqueItem{
    
    //retrieve key id of selected equipUniqueItem AND indexPath of the collection cell that initiated the distID picker
    //tell content of the cell to use replace the dist ID
    //update the data model > schedule_equip_join has new unique_foreignKey
    
    // Extract the unique's key as a string
    NSString* thisIsTheKey = [(EQREquipUniqueItem*)distEquipUniqueItem key_id];
    NSString* thisIsTheDistID = [(EQREquipUniqueItem*)distEquipUniqueItem distinquishing_id];
    NSString* thisIsTheIssueShortName = [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name];
    NSString* thisIsTheStatusLevel = [(EQREquipUniqueItem*)distEquipUniqueItem status_level];
    
    EQRScheduleTracking_EquipmentUnique_Join* saveThisJoin;
    
    // Update local ivar arrays
    for (EQRScheduleTracking_EquipmentUnique_Join* joinObj in self.arrayOfSchedule_Unique_Joins){
        
        if ([joinObj.equipUniqueItem_foreignKey isEqualToString:originalKeyID]){
            
            [joinObj setEquipUniqueItem_foreignKey:thisIsTheKey];
            [joinObj setDistinquishing_id:thisIsTheDistID];
            
            // Need to know what service issues are a part of this new equipUnique and assign to local var in array
            [joinObj setIssue_short_name:thisIsTheIssueShortName];
            [joinObj setStatus_level:thisIsTheStatusLevel];
            
            saveThisJoin = joinObj;
            break;
        }
    }
    
    self.arrayOfSchedule_Unique_JoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfSchedule_Unique_Joins withMiscJoins:self.arrayOfMiscJoins];
    
    // Renew the collection view
    [self.equipList reloadData];
    
    // Remove the popover
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController setDelegate:nil];
    
    [self.distIDPopover dismissPopoverAnimated:YES];
    
    // Gracefully dealloc all the objects in the content VC
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController resetDistIdPicker];
    
    self.distIDPopover = nil;
    
    // Update the data layer
    NSArray* topArray = @[ @[@"key_id", [saveThisJoin key_id]],
                           @[@"equipUniqueItem_foreignKey", [saveThisJoin equipUniqueItem_foreignKey]],
                           @[@"equipTitleItem_foreignKey", [saveThisJoin equipTitleItem_foreignKey]] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQAlterScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnString) {
            if (!returnString) NSLog(@"EQREditorTupVC > distIDSelectionMad..., failed to alter schedule equip join");
            
            // Send note to schedule that a change has been saved
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        }];
    });
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
    
    if (popoverController == self.theRenterPopOver){
        
        self.theRenterPopOver = nil;
        
    }else if (popoverController == self.theEquipSelectionPopOver){
        
        self.theEquipSelectionPopOver = nil;
        
//    }else if (popoverController == self.myContactPicker){
//
//        //release delegate
//        self.myContactVC.delegate = self;
//
//        //release content view controller
//        self.myContactVC = nil;
//
//        //release popover
//        self.myContactPicker = nil;
        
    }else if (popoverController == self.distIDPopover){
        
        self.distIDPopover = nil;
        
    }else if(popoverController == self.myNotesPopover){
        
        self.myNotesPopover = nil;
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
