//
//  EQRItineraryVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryVCntrllr.h"
#import "EQRItineraryRowCell.h"
#import "EQRItineraryRowCell2.h"
#import "EQRGlobals.h"
#import "EQRColors.h"
#import "EQRScheduleRequestItem.h"
#import "EQRScheduleRequestManager.h"
#import "EQRWebData.h"
#import "EQRCheckVCntrllr.h"
#import "EQRDayDatePickerVCntrllr.h"
#import "EQRQuickViewPage1VCntrllr.h"
#import "EQRQuickViewScrollVCntrllr.h"
#import "EQREditorTopVCntrllr.h"
#import "EQRStaffUserPickerViewController.h"
#import "EQRStaffUserManager.h"
#import "EQRModeManager.h"
#import "EQRMiscJoin.h"

@interface EQRItineraryVCntrllr () <EQRItineraryContentDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterItineraryCollection;
@property (strong ,nonatomic) IBOutlet UICollectionView* myNavBarCollectionView;

@property (strong, nonatomic) NSDate* dateForShow;

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;

@property (strong, nonatomic) NSMutableArray* arrayOfScheduleRequests;
@property (strong, nonatomic) NSArray* filteredArrayOfScheduleRequests;

@property (strong, nonatomic) NSMutableArray *arrayOfJoinsAll;

@property EQRItineraryFilter currentFilterBitmask;
@property (strong, nonatomic) IBOutlet UIButton* buttonAll;
@property (strong, nonatomic) IBOutlet UIButton* buttonGoingShelf;
@property (strong, nonatomic) IBOutlet UIButton* buttonGoingPrepped;
@property (strong, nonatomic) IBOutlet UIButton* buttonGoingPickedUp;
@property (strong, nonatomic) IBOutlet UIButton* buttonReturningOut;
@property (strong, nonatomic) IBOutlet UIButton* buttonReturningReturned;
@property (strong, nonatomic) IBOutlet UIButton* buttonReturningShelved;

@property (strong, nonatomic) UIPopoverController* myDayDatePicker;
@property (strong, nonatomic) UIPopoverController* myStaffUserPicker;
@property (strong, nonatomic) UIPopoverController* myQuickView;
@property (strong, nonatomic) EQRQuickViewScrollVCntrllr* myQuickViewScrollVCntrllr;
@property (strong, nonatomic) NSDictionary* temporaryDicFromQuickView;

@property (strong, nonatomic) NSTimer *partialRefreshTimer;

@property BOOL aChangeWasMade;

//async webData properties
//@property NSInteger countOfUltimageReturnedItems;
@property NSInteger indexOfLastReturnedItem;
@property BOOL finishedAsyncDBCallForPickup;
@property BOOL finishedAsyncDBCallForReturn;
//@property BOOL finishedAsyncDBCallForEquipJoins;
//@property BOOL finishedAsyncDBCallForMiscJoins;
@property BOOL readyToCheckForScheduleWarningsFlag;
@property BOOL freezeOnInsertionsFlag;
@property (strong, nonatomic) NSTimer *delayTheInsertions;
//@property BOOL newDataHasOccurredWhileFreezeWasOnFlag;
@property (strong, nonatomic) EQRWebData *webDataForPickup;
@property (strong, nonatomic) EQRWebData *webDataForReturn;
@property (strong, nonatomic) EQRWebData *webDataForEquipJoins;
@property (strong, nonatomic) EQRWebData *webDataForMiscJoins;

// Operation Queues
@property (strong, nonatomic) NSOperationQueue *updateLabelsQueue;


-(IBAction)moveToNextDay:(id)sender;
-(IBAction)moveToPreviousDay:(id)sender;

@end

@implementation EQRItineraryVCntrllr

#pragma mark - computed properties

-(NSArray *)pickupAndReturnDatesAsSQLStrings{
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatForDate stringFromDate:self.dateForShow]];
    NSString* dateEndString = [NSString stringWithFormat:@"%@ 23:59:59", [dateFormatForDate stringFromDate:self.dateForShow]];
    
    NSArray* arr = @[ @[@"request_date_begin", dateBeginString],
                           @[@"request_date_end", dateEndString] ];
    
    return arr;
}

#pragma mark - init methods

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

    //register for notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //refresh the view when a change is made
    [nc addObserver:self selector:@selector(raiseFlagThatAChangeHasBeenMade:) name:EQRAChangeWasMadeToTheSchedule object:nil];
    //partial refresh to when a switch is thrown in the itinarary cell view
    [nc addObserver:self selector:@selector(partialRefreshFromCheckInOutCellNotification:) name:EQRPartialRefreshToItineraryArray object:nil];
    //receive note from cellContentView to show check in out v controllr
    [nc addObserver:self selector:@selector(showCheckInOut:) name:EQRPresentCheckInOut object:nil];
    //receive note from itinerary row to show quick view
    [nc addObserver:self selector:@selector(showQuickView:) name:EQRPresentItineraryQuickView object:nil];
    //show request editor (from quick view duplicate button)
    [nc addObserver:self selector:@selector(showRequestEditor:) name:EQRPresentRequestEditorFromItinerary object:nil];
    
    
    
    //register collection view cell
    [self.myMasterItineraryCollection registerClass:[EQRItineraryRowCell2 class] forCellWithReuseIdentifier:@"Cell2"];
//    UINib *nib = [UINib nibWithNibName:@"EQRItineraryCellContent2VC" bundle:nil];
//    [self.myMasterItineraryCollection registerNib:nib  forCellWithReuseIdentifier:@"Cell2"];

    
    
    
    self.myMasterItineraryCollection.backgroundColor = [UIColor darkGrayColor];
    
    //set initial filter bitmask to 'all'
    self.currentFilterBitmask = EQRFilterAll;
    
    //set all button to filter on color
    EQRColors* sharedColors = [EQRColors sharedInstance];
    [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
    

    //initial day is the current day
    self.dateForShow = [NSDate date];
    
    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign date to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    //derive the current user name
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* logText = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    
    //_______custom bar buttons
    //create uiimages
    UIImage* leftArrow = [UIImage imageNamed:@"GenericLeftArrow"];
    UIImage* rightArrow = [UIImage imageNamed:@"GenericRightArrow"];
    
    //uibar buttons
    //create fixed spaces
    UIBarButtonItem* twentySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    twentySpace.width = 20;
    UIBarButtonItem* thirtySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    thirtySpace.width = 30;
    
    //wrap buttons in barbuttonitem
    UIBarButtonItem* leftBarButtonArrow =[[UIBarButtonItem alloc] initWithImage:leftArrow style:UIBarButtonItemStylePlain target:self action:@selector(moveToPreviousDay:)];
    UIBarButtonItem* todayBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(moveToToday:)];
    UIBarButtonItem* rightBarButtonArrow = [[UIBarButtonItem alloc] initWithImage:rightArrow style:UIBarButtonItemStylePlain target:self action:@selector(moveToNextDay:)];
    UIBarButtonItem* searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showDatePicker)];
    
    NSArray* arrayOfLeftButtons = [NSArray arrayWithObjects:twentySpace, searchBarButton, thirtySpace, leftBarButtonArrow, thirtySpace, todayBarButton, thirtySpace, rightBarButtonArrow, nil];
    
    //set leftBarButton item on SELF
    [self.navigationItem setLeftBarButtonItems:arrayOfLeftButtons];
    
    //right button
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:logText style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];
    
    //this will load the ivar array of scheduleReqeust items based on the dateForShow ivar
    [self refreshTheView];
}


-(void)viewWillAppear:(BOOL)animated{

    // Test if a change has occurred in the data
    if (self.aChangeWasMade == YES){
        self.aChangeWasMade = NO;
        [self refreshTheView];
    }
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    
    // Set title on bar button item
    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
    
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


-(void)raiseFlagThatAChangeHasBeenMade:(NSNotification*)note{
    
    self.aChangeWasMade = YES;
}

#pragma mark - refresh the view

-(void)releaseFreezeAndRefreshTheView{
    
    self.freezeOnInsertionsFlag = NO;
    [self refreshTheView];
}


-(void)refreshTheView{
    
    if ([self.arrayOfScheduleRequests count] > 0){
        self.freezeOnInsertionsFlag = YES;
    }
    [self.arrayOfScheduleRequests removeAllObjects];
    
    // Reload the collection
    [self.myMasterItineraryCollection reloadData];
    
    [self.webDataForPickup stopXMLParsing];
    [self.webDataForReturn stopXMLParsing];
    
    if (self.partialRefreshTimer){
        [self.partialRefreshTimer invalidate];
    }
    
    self.partialRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(partialRefreshToUpdateTheArrayOfRequests:) userInfo:nil repeats:NO];
}


-(void)partialRefreshFromCheckInOutCellNotification:(NSNotification*)note{
    
    NSArray* topArray = [self pickupAndReturnDatesAsSQLStrings];
    
    [self continueAfterPartialRequestCompletedASyncCallForRequestsWithTopArray: topArray];
    
    // Re-render the cell
    NSString *scheduleKey = [[note userInfo] objectForKey:@"scheduleKey"];
    for (EQRScheduleRequestItem *item in self.arrayOfScheduleRequests){
        if (([item.key_id isEqualToString:scheduleKey]) && (item.markedForReturn == [[[note userInfo] objectForKey:@"markedForReturning"] integerValue])){

            if ([[[note userInfo] objectForKey:@"markedForReturning"] isEqual:[NSNumber numberWithInteger:1]]){
                if ([[[note userInfo] objectForKey:@"status"] isEqual:[NSNumber numberWithInteger:2]]){
                    item.staff_shelf_date = [NSDate date];
                    item.staff_checkin_date = [NSDate date];
                    item.shouldCollapseReturningCell = YES;
                } else if ([[[note userInfo] objectForKey:@"status"] isEqual:[NSNumber numberWithInteger:1]]){
                    item.staff_shelf_date = nil;
                    item.staff_checkin_date = [NSDate date];
                    item.shouldCollapseReturningCell = YES;
                } else {
                    item.staff_shelf_date = nil;
                    item.staff_checkin_date = nil;
                    item.shouldCollapseReturningCell = NO;
                }
            }else{
                if ([[[note userInfo] objectForKey:@"status"] isEqual:[NSNumber numberWithInteger:2]]){
                    item.staff_checkout_date = [NSDate date];
                    item.staff_prep_date = [NSDate date];
                    item.shouldCollapseGoingCell = YES;
                } else if ([[[note userInfo] objectForKey:@"status"] isEqual:[NSNumber numberWithInteger:1]]){
                    item.staff_checkout_date = nil;
                    item.staff_prep_date = [NSDate date];
                    item.shouldCollapseGoingCell = NO;
                } else {
                    item.staff_checkout_date = nil;
                    item.staff_prep_date = nil;
                    item.shouldCollapseGoingCell = NO;
                }
            }
            break;
        }
    }
    
    [self.myMasterItineraryCollection reloadData];
}


// This notification method is ONLY called from the above method, never something sending a note to default notification center
-(void)partialRefreshToUpdateTheArrayOfRequests:(NSNotification*)note{
    
    // Remove all filters
    //_______!!!!!!!!! This is a work around for an unsolved error regarding crashing as a result of the collection view looking for rows in an empty array
    self.currentFilterBitmask = EQRFilterAll;
    [self resetColorsOnFilterButtons];
    
    self.filteredArrayOfScheduleRequests = nil;
    self.readyToCheckForScheduleWarningsFlag = NO;
    
    self.finishedAsyncDBCallForPickup = NO;
    self.finishedAsyncDBCallForReturn = NO;

    
    //________!!!!!!!!! This section is meaningless until the crashing error refernced above gets resolved
    //test if a cell is now displaying a status that has been filtered out
    //change bitmask to allow for that status
//    BOOL needToReloadTheView = NO;
//    
//    NSUInteger cellBitmaskValue = [self determineTheBitmaskFromCellInfo:[note userInfo]];
//    
//    if ((self.currentFilterBitmask & cellBitmaskValue) == NO){
//                
//        //add the value to the bitmask
//        self.currentFilterBitmask = self.currentFilterBitmask | cellBitmaskValue;
//        
//        //update the filter button to ON
//        [self updateFilterButtonDisplayWithAddedBitmask:cellBitmaskValue];
//        
//        //if all filters are added, switch 'all' on
//        if (self.currentFilterBitmask == EQRFilterAll){
//            
//            EQRColors* sharedColors = [EQRColors sharedInstance];
//            [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
//            
//            //set all other buttons to white (off color)
//            [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        }
//        
//        //need to reload the view???
//        needToReloadTheView = YES;
//    }
    
    
    //intiate array or empty out the existing array
    if (!self.arrayOfScheduleRequests){
        self.arrayOfScheduleRequests = [NSMutableArray arrayWithCapacity:1];
    }else{
        [self.arrayOfScheduleRequests removeAllObjects];
    }
    
    // Format the nsdates to a mysql compatible string
    NSArray* topArray = [self pickupAndReturnDatesAsSQLStrings];
    
    self.indexOfLastReturnedItem = -1;
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    self.webDataForPickup = webData;
    self.webDataForPickup.delegateDataFeed = self;
    
    SEL thisSelectorPickup = @selector(addPickupToIntineraryList:);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
       [self.webDataForPickup queryWithAsync:@"EQGetScheduleItemsWithBeginDate.php" parameters:topArray class:@"EQRScheduleRequestItem" selector:thisSelectorPickup completion:^(BOOL isLoadingFlagUp) {
          
           //identify when loading is complete
           self.finishedAsyncDBCallForPickup = isLoadingFlagUp;
           
           if (self.finishedAsyncDBCallForReturn){
               
               self.finishedAsyncDBCallForPickup = NO;
               self.finishedAsyncDBCallForReturn = NO;
               
               [self continueAfterPartialRequestCompletedASyncCallForRequestsWithTopArray:topArray];
               
               // If a bitmisk filter is on, update it also
               if (self.currentFilterBitmask != EQRFilterAll){
                   
                   [self createTheFilteredArray:self.currentFilterBitmask];
                    [self.myMasterItineraryCollection reloadData];
               }
           }
       }];
    });
    
    EQRWebData *webData2 = [EQRWebData sharedInstance];
    self.webDataForReturn = webData2;
    self.webDataForReturn.delegateDataFeed = self;
    SEL thisSelectorReturn = @selector(addReturnToItineraryList:);
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue2, ^{
       
        [self.webDataForReturn queryWithAsync:@"EQGetScheduleItemsWithEndDate.php" parameters:topArray class:@"EQRScheduleRequestItem" selector:thisSelectorReturn completion:^(BOOL isLoadingFlagUp) {
           
            self.finishedAsyncDBCallForReturn = isLoadingFlagUp;
            
            if (self.finishedAsyncDBCallForPickup){
                
                self.finishedAsyncDBCallForPickup = NO;
                self.finishedAsyncDBCallForReturn = NO;
                
                // Place data call all associated joins here, then update with "Some items are not..."
                [self continueAfterPartialRequestCompletedASyncCallForRequestsWithTopArray:topArray];
                
                // If a bitmisk filter is on, update it also
                if (self.currentFilterBitmask != EQRFilterAll){
                    
                    [self createTheFilteredArray:self.currentFilterBitmask];
                    [self.myMasterItineraryCollection reloadData];
                }
            }
        }];
    });
    
    // Reload the view
    [self.myMasterItineraryCollection reloadData];
}

// Update and render button labels
-(void)continueAfterPartialRequestCompletedASyncCallForRequestsWithTopArray:(NSArray *)topArray{

    // Top array has RequestDateBegin and RequestDateEnd values
    
    if (self.arrayOfJoinsAll){
        [self.arrayOfJoinsAll removeAllObjects];
    }
    
    if (!self.updateLabelsQueue){
        self.updateLabelsQueue = [[NSOperationQueue alloc] init];
        self.updateLabelsQueue.name = @"continueAfterPartialRequest";
        self.updateLabelsQueue.maxConcurrentOperationCount = 1;
    }
    [self.updateLabelsQueue cancelAllOperations];
    
    
    __block NSMutableArray *tempJoinsAll = [NSMutableArray arrayWithCapacity:1];
    NSBlockOperation *getScheduleEquipUniqueJoinsOnDate = [NSBlockOperation blockOperationWithBlock:^{
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleEquipUniqueJoinsOnDate.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
            if (!muteArray) return;
            [tempJoinsAll addObjectsFromArray:muteArray];
        }];
    }];
    
    NSBlockOperation *getMiscJoinsOnDate = [NSBlockOperation blockOperationWithBlock:^{
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetMiscJoinsOnDate.php" parameters:topArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray) {
            if (!muteArray) return;
            [tempJoinsAll addObjectsFromArray:muteArray];
        }];
    }];
    
    NSBlockOperation *updateAndRenderButtonLabels = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.arrayOfJoinsAll = tempJoinsAll;
            [self continueAfterJoinCallCompleted];
        });
    }];
    [updateAndRenderButtonLabels addDependency:getScheduleEquipUniqueJoinsOnDate];
    [updateAndRenderButtonLabels addDependency:getMiscJoinsOnDate];
    
    
    [self.updateLabelsQueue addOperation:getScheduleEquipUniqueJoinsOnDate];
    [self.updateLabelsQueue addOperation:getMiscJoinsOnDate];
    [self.updateLabelsQueue addOperation:updateAndRenderButtonLabels];
}

// Update and render button labels
-(void)continueAfterJoinCallCompleted{
    
    // Update array of scheduleRequests with info about completed and uncompleted joins
    
    for (EQRScheduleRequestItem *thisItem in self.arrayOfScheduleRequests){
        thisItem.totalJoinCoint = 0;
        thisItem.unTickedJoinCountForButton1 = 0;
        thisItem.unTickedJoinCountForButton2 = 0;
    }
    
    for (EQRScheduleRequestItem* thisItem in self.arrayOfScheduleRequests){
        for (EQRScheduleTracking_EquipmentUnique_Join *join in self.arrayOfJoinsAll){
            if ([join.scheduleTracking_foreignKey isEqualToString:thisItem.key_id]){
                thisItem.totalJoinCoint++;
                
                // Further test if this join item is incomplete
                
                // Marked to be picked up
                if (!thisItem.markedForReturn){
                    if (([join.prep_flag isEqualToString:@""]) || (join.prep_flag == nil)){
                        thisItem.unTickedJoinCountForButton1++;
                    }
                    
                    if (([join.checkout_flag isEqualToString:@""]) || (join.checkout_flag == nil)){
                        thisItem.unTickedJoinCountForButton2++;
                    }
                    
                // Marked to be returned
                }else{
                    if (([join.checkin_flag isEqualToString:@""]) || (join.checkin_flag == nil)){
                        thisItem.unTickedJoinCountForButton1++;
                    }
                    
                    if (([join.shelf_flag isEqualToString:@""]) || (join.shelf_flag == nil)){
                        thisItem.unTickedJoinCountForButton2++;
                    }
                }
            }
        }
    }

    // Tell cells to check for and show warning message
    self.readyToCheckForScheduleWarningsFlag = YES;
    
    NSArray *tempArray = [NSArray arrayWithArray:[self.myMasterItineraryCollection visibleCells]];
    for (EQRItineraryRowCell2 *cell in tempArray){
        
        NSInteger tempInt = [[self.myMasterItineraryCollection indexPathForCell:cell] row];
        
        if ([self.arrayOfScheduleRequests count] > tempInt){
            
            EQRScheduleRequestItem *thisItem = [self.arrayOfScheduleRequests objectAtIndex:tempInt];
            [cell updateButtonLabels:thisItem];
        }
    }
}


#pragma mark - show dismiss check out in view
-(void)showCheckInOut:(NSNotification*)note{
    NSString* scheduleKey = [[note userInfo] objectForKey:@"scheduleKey"];
    NSNumber* marked_for_returning = [[note userInfo] objectForKey:@"marked_for_returning"];
    NSNumber* switch_num = [[note userInfo] objectForKey:@"switch_num"];
    
    EQRCheckVCntrllr* checkViewController = [[EQRCheckVCntrllr alloc] initWithNibName:@"EQRCheckVCntrllr" bundle:nil];
    
    // Extend edges under nav and tab bar
    checkViewController.edgesForExtendedLayout = UIRectEdgeAll;
    
    NSDictionary* newDict = @{ @"scheduleKey": scheduleKey,
                               @"marked_for_returning": marked_for_returning,
                               @"switch_num": switch_num };
    // Initial setup
    [checkViewController initialSetupWithInfo:newDict];
    
    // Modal pops up from below, removes navigiation controller
    UINavigationController* newNavController = [[UINavigationController alloc] initWithRootViewController:checkViewController];
    
    // Add staff picker and cancel buttons in nav bar??
    
    [self presentViewController:newNavController animated:YES completion:^{
    }];
}


#pragma mark - showStaffUser view
-(void)showStaffUserPicker{
    EQRStaffUserPickerViewController* staffUserPicker = [[EQRStaffUserPickerViewController alloc] initWithNibName:@"EQRStaffUserPickerViewController" bundle:nil];
    self.myStaffUserPicker = [[UIPopoverController alloc] initWithContentViewController:staffUserPicker];
    self.myStaffUserPicker.delegate = self;
    
    //set size
    [self.myStaffUserPicker setPopoverContentSize:CGSizeMake(400, 400)];
    
    //present popover
    [self.myStaffUserPicker presentPopoverFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:0]  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //set target of continue button
    [staffUserPicker.continueButton addTarget:self action:@selector(dismissStaffUserPicker) forControlEvents:UIControlEventTouchUpInside];
}


-(void)dismissStaffUserPicker{
    // Do stuff with the iboutlet of the
    EQRStaffUserPickerViewController* thisStaffUserPicker = (EQRStaffUserPickerViewController*)[self.myStaffUserPicker contentViewController];
    int selectedRow = (int)[thisStaffUserPicker.myPicker selectedRowInComponent:0];

    //assign contact name object to shared staffUserManager
    EQRContactNameItem* selectedNameObject = (EQRContactNameItem*)[thisStaffUserPicker.arrayOfContactObjects objectAtIndex:selectedRow];
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    staffUserManager.currentStaffUser = selectedNameObject;
    
    //set title on bar button item
    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", selectedNameObject.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
    
    //save as default
    NSDictionary* newDic = [NSDictionary dictionaryWithObject:selectedNameObject.key_id forKey:@"staffUserKey"];
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"staffUserKey"];
    
    //dismiss the picker
    [self.myStaffUserPicker dismissPopoverAnimated:YES];
    self.myStaffUserPicker = nil;
}


#pragma mark - show request editor
-(void) showRequestEditor:(NSNotification*)note{
    // Dismiss any popovers that may exist (ie the quickview when "duplicate" is tapped)
    [self.myQuickView dismissPopoverAnimated:YES];
    self.myQuickView = nil;
    
    EQREditorTopVCntrllr* editorViewController = [[EQREditorTopVCntrllr alloc] initWithNibName:@"EQREditorTopVCntrllr" bundle:nil];
    
    //prevent edges from extending beneath nav and tab bars
    editorViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    //initial setup
    [editorViewController initialSetupWithInfo:[NSDictionary dictionaryWithDictionary:note.userInfo]];
    
    //assign editor's keyID property
    //    editorViewController.scheduleRequestKeyID = [note.userInfo objectForKey:@"keyID"];
    
    //______1_______pushes from the side and preserves navigation controller
    //    [self.navigationController pushViewController:editorViewController animated:YES];
    
    //______2_______model pops up from below, removes navigiation controller
    UINavigationController* newNavController = [[UINavigationController alloc] initWithRootViewController:editorViewController];
    //add cancel button
    
    [self presentViewController:newNavController animated:YES completion:^{
    }];
}


-(IBAction)showRequestEditorFromQuickView:(id)sender{
    // Dismiss the quickView popover
    [self.myQuickView dismissPopoverAnimated:YES];
    self.myQuickView = nil;
    
    EQREditorTopVCntrllr* editorViewController = [[EQREditorTopVCntrllr alloc] initWithNibName:@"EQREditorTopVCntrllr" bundle:nil];
    
    //prevent edges from extending beneath nav and tab bars
    editorViewController.edgesForExtendedLayout = UIRectEdgeTop;
    
    //_______******* THIS IS WEIRD need to subtract a day off the the dates
    float secondsForOffset = 0 * -3;
    NSDate* newBeginDate = [[self.temporaryDicFromQuickView objectForKey:@"request_date_begin"] dateByAddingTimeInterval:secondsForOffset];
    NSDate* newEndDate = [[self.temporaryDicFromQuickView objectForKey:@"request_date_end"] dateByAddingTimeInterval:secondsForOffset];
    
    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:self.temporaryDicFromQuickView];
    
    [newDic setValue:newBeginDate forKey:@"request_date_begin"];
    [newDic setValue:newEndDate forKey:@"reqeust_date_end"];
    
    // Initial setup
    [editorViewController initialSetupWithInfo:newDic];
    
    // Assign editor's keyID property
    //    editorViewController.scheduleRequestKeyID = [note.userInfo objectForKey:@"keyID"];
    
    //______1_______pushes from the side and preserves navigation controller
    //    [self.navigationController pushViewController:editorViewController animated:YES];
    
    //______2_______model pops up from below, removes navigiation controller
    UINavigationController* newNavController = [[UINavigationController alloc] initWithRootViewController:editorViewController];
    // Add cancel button
    
    [self presentViewController:newNavController animated:YES completion:^{
    }];
    
}


#pragma mark - showQuickView
-(void)showQuickView:(NSNotification*)note{
    // Create quickview scroll view
    EQRQuickViewScrollVCntrllr* quickView = [[EQRQuickViewScrollVCntrllr alloc] initWithNibName:@"EQRQuickViewScrollVCntrllr" bundle:nil];
    self.myQuickViewScrollVCntrllr = quickView;
    
    //instatiate first page subview
    EQRQuickViewPage1VCntrllr* quickViewPage1 = [[EQRQuickViewPage1VCntrllr alloc] initWithNibName:@"EQRQuickViewPage1VCntrllr" bundle:nil];
    EQRQuickViewPage2VCntrllr* quickViewPage2 = [[EQRQuickViewPage2VCntrllr alloc] initWithNibName:@"EQRQuickViewPage2VCntrllr" bundle:nil];
    EQRQuickViewPage3VCntrllr* quickViewPage3 = [[EQRQuickViewPage3VCntrllr alloc] initWithNibName:@"EQRQuickViewPage3VCntrllr" bundle:nil];
    
    self.myQuickViewScrollVCntrllr.myQuickViewPage1 = quickViewPage1;
    self.myQuickViewScrollVCntrllr.myQuickViewPage2 = quickViewPage2;
    self.myQuickViewScrollVCntrllr.myQuickViewPage3 = quickViewPage3;
    
    self.myQuickView = [[UIPopoverController alloc] initWithContentViewController:self.myQuickViewScrollVCntrllr];
    self.myQuickView.delegate = self;
    
    [self.myQuickView setPopoverContentSize:CGSizeMake(300.f, 502.f)];
    
    //empty the temp array
    if ([self.temporaryDicFromQuickView count] > 0){
        self.temporaryDicFromQuickView = nil;
    }
    
    NSMutableDictionary* dicAlso = [NSMutableDictionary dictionaryWithCapacity:1];

    EQRScheduleRequestItem* myItem;
    for (EQRScheduleRequestItem* thisItem in self.arrayOfScheduleRequests){
        
        //marked_for_returning
        BOOL marked_for_returning = [[[note userInfo] objectForKey:@"marked_for_returning"] boolValue];
        
        if (([thisItem.key_id isEqualToString:[[note userInfo] objectForKey:@"key_ID"]]) && (marked_for_returning == thisItem.markedForReturn)){
            
            myItem = thisItem;
            
            //get the remaining join information...
            NSArray* firstArray = @[@"key_id", myItem.key_id];
            NSArray* secondArray = @[firstArray];
            EQRWebData* webData = [EQRWebData sharedInstance];
            __block EQRScheduleRequestItem* thisRequestItem;
            [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:secondArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
                
                if ([muteArray count] > 0){
                    thisRequestItem = [muteArray objectAtIndex:0];
                }
            }];
            
            //add in information from quickviewData request
            if (thisRequestItem){
                if (thisRequestItem.notes)[dicAlso setObject:thisRequestItem.notes forKey:@"notes"];
                if (thisRequestItem.classTitle_foreignKey) [dicAlso setObject:thisRequestItem.classTitle_foreignKey forKey:@"classTitle_foreignKey"];
                if (thisRequestItem.staff_confirmation_id) [dicAlso setObject:thisRequestItem.staff_confirmation_id forKey:@"staff_confirmation_id"];
                if (thisRequestItem.staff_confirmation_date) [dicAlso setObject:thisRequestItem.staff_confirmation_date     forKey:@"staff_confirmation_date"];
                if (thisRequestItem.staff_prep_id) [dicAlso setObject:thisRequestItem.staff_prep_id forKey:@"staff_prep_id"];
                if (thisRequestItem.staff_prep_date) [dicAlso setObject:thisRequestItem.staff_prep_date forKey:@"staff_prep_date"];
                if (thisRequestItem.staff_checkout_id) [dicAlso setObject:thisRequestItem.staff_checkout_id forKey:@"staff_checkout_id"];
                if (thisRequestItem.staff_checkout_date) [dicAlso setObject:thisRequestItem.staff_checkout_date forKey:@"staff_checkout_date"];
                if (thisRequestItem.staff_checkin_id) [dicAlso setObject:thisRequestItem.staff_checkin_id forKey:@"staff_checkin_id"];
                if (thisRequestItem.staff_checkin_date) [dicAlso setObject:thisRequestItem.staff_checkin_date forKey:@"staff_checkin_date"];
                if (thisRequestItem.staff_shelf_id) [dicAlso setObject:thisRequestItem.staff_shelf_id forKey:@"staff_shelf_id"];
                if (thisRequestItem.staff_shelf_date) [dicAlso setObject:thisRequestItem.staff_shelf_date forKey:@"staff_shelf_date"];
            }
        }
    }
    
    //instantiate with details
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [[note userInfo] objectForKey: @"key_ID"],@"key_ID",
                                myItem.contact_name , @"contact_name",
                                myItem.renter_type, @"renter_type",
                                myItem.request_date_begin, @"request_date_begin",
                                myItem.request_date_end, @"request_date_end",
                                myItem.request_time_begin, @"request_time_begin",
                                myItem.request_time_end, @"request_time_end",
                                nil];
    
    [dic addEntriesFromDictionary:dicAlso];
    
    //undo the adjustment to the time difference
    //adjust the time by adding 9 hours... or 8 hours
    float secondsForOffset = 0 * 2;    //this is 9 hours = 32400, this is 8 hour = 28800;
    [dic setValue:[myItem.request_time_begin dateByAddingTimeInterval:secondsForOffset] forKey:@"request_time_begin"];
    [dic setValue:[myItem.request_time_end dateByAddingTimeInterval:secondsForOffset] forKey:@"request_time_end"];
    
    //pass dic to ivar to use in editor request
    self.temporaryDicFromQuickView = [NSDictionary dictionaryWithDictionary:dic];
    
    //initial infor
    [quickViewPage1 initialSetupWithDic:dic];
    [quickViewPage2 initialSetupWithKeyID:[[note userInfo] objectForKey: @"key_ID"]];
    [quickViewPage3 initialSetupWithKeyID:[[note userInfo] objectForKey: @"key_ID"] andUserInfoDic:dic];
    quickViewPage3.fromItinerary = YES;
    
    //_____presenting the popover must be delayed (why?????)
    [self performSelector:@selector(mustDelayThePresentationOfAPopOver:) withObject:[note userInfo] afterDelay:0.1];
}


-(void)mustDelayThePresentationOfAPopOver:(NSDictionary*)userInfo{
    NSValue* rectValue = [userInfo objectForKey:@"rectValue"];
    CGRect thisRect = [rectValue CGRectValue];
    UIView* thisView = [userInfo objectForKey:@"thisView"];
    
    
    //show popover  MUST use NOT allow using the arrow directin from below, keyboard may cover the textview
    [self.myQuickView presentPopoverFromRect:thisRect inView:thisView permittedArrowDirections:UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionDown animated:YES];
    
    //attach page 1 & 2
    [self.myQuickViewScrollVCntrllr.myContentPage1 addSubview:self.myQuickViewScrollVCntrllr.myQuickViewPage1.view];
    [self.myQuickViewScrollVCntrllr.myContentPage2 addSubview:self.myQuickViewScrollVCntrllr.myQuickViewPage2.view];
    [self.myQuickViewScrollVCntrllr.myContentPage3 addSubview:self.myQuickViewScrollVCntrllr.myQuickViewPage3.view];
    
    
    //__________needs a delay before assigning button target____________
    //assign target of popover's "edit request" button
    [self.myQuickViewScrollVCntrllr.editRequestButton addTarget:self action:@selector(showRequestEditorFromQuickView:)  forControlEvents:UIControlEventTouchUpInside];
    
    
    //add gesture recognizers
    UISwipeGestureRecognizer* swipeLeftGestureOnQuickview = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideLeft:)];
    swipeLeftGestureOnQuickview.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.myQuickViewScrollVCntrllr.myContentPage1 addGestureRecognizer:swipeLeftGestureOnQuickview];
    
    UISwipeGestureRecognizer* swipeLeftGestureOnQuickview2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideLeft:)];
    swipeLeftGestureOnQuickview2.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.myQuickViewScrollVCntrllr.myContentPage2 addGestureRecognizer:swipeLeftGestureOnQuickview2];
    
    UISwipeGestureRecognizer* swipeRightGestureOnQuickview = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideRight:)];
    swipeRightGestureOnQuickview.direction = UISwipeGestureRecognizerDirectionRight;
    [self.myQuickViewScrollVCntrllr.myContentPage2 addGestureRecognizer:swipeRightGestureOnQuickview];
    
    UISwipeGestureRecognizer* swipeRightGestureOnQuickview2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideRight:)];
    swipeRightGestureOnQuickview2.direction = UISwipeGestureRecognizerDirectionRight;
    [self.myQuickViewScrollVCntrllr.myContentPage3 addGestureRecognizer:swipeRightGestureOnQuickview2];
}


#pragma mark - day movement
-(IBAction)moveToNextDay:(id)sender{
    // Seconds in a day 86400
    self.dateForShow = [self.dateForShow dateByAddingTimeInterval:86400];
    
    // Update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    // Assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    // Remove all filters
    self.currentFilterBitmask = EQRFilterAll;
    [self resetColorsOnFilterButtons];
    
    [self refreshTheView];
}


-(IBAction)moveToPreviousDay:(id)sender{
    self.dateForShow = [self.dateForShow dateByAddingTimeInterval:-86400];
    
    // Update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    // Assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    // Remove all filters
    self.currentFilterBitmask = EQRFilterAll;
    [self resetColorsOnFilterButtons];
    
    [self refreshTheView];
}


-(IBAction)moveToToday:(id)sender{
    
    self.dateForShow = [NSDate date];
    
    // Update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    // Assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    // Remove all filters
    self.currentFilterBitmask = EQRFilterAll;
    [self resetColorsOnFilterButtons];
    
    [self refreshTheView];
}


-(void)showDatePicker{
    EQRDayDatePickerVCntrllr* dayDateView = [[EQRDayDatePickerVCntrllr alloc] initWithNibName:@"EQRDayDatePickerVCntrllr" bundle:nil];
    self.myDayDatePicker = [[UIPopoverController alloc] initWithContentViewController:dayDateView];
    self.myDayDatePicker.delegate = self;
    
    // Set size
    [self.myDayDatePicker setPopoverContentSize:CGSizeMake(400, 400)];
    
    // Present popover
    [self.myDayDatePicker presentPopoverFromBarButtonItem:[self.navigationItem.leftBarButtonItems objectAtIndex:1]  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    // Set target of continue button
    [dayDateView.myContinueButton addTarget:self action:@selector(dismissShowDatePicker:) forControlEvents:UIControlEventTouchUpInside];
}


-(IBAction)dismissShowDatePicker:(id)sender{
    // Get date from the popover's content view controller, a public method
    self.dateForShow = [(EQRDayDatePickerVCntrllr*)[self.myDayDatePicker contentViewController] retrieveSelectedDate];

    // Update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    // Assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    // Dismiss the picker
    [self.myDayDatePicker dismissPopoverAnimated:YES];
    self.myDayDatePicker = nil;
    
    // Remove all filters
    self.currentFilterBitmask = EQRFilterAll;
    [self resetColorsOnFilterButtons];
    
    [self refreshTheView];
}


#pragma mark - filter methods
-(IBAction)dismissFilters:(id)sender{
    self.currentFilterBitmask = EQRFilterAll;
}


-(IBAction)applyFilter:(id)sender{
    EQRColors* sharedColors = [EQRColors sharedInstance];
    if (self.currentFilterBitmask == EQRFilterAll){
        self.currentFilterBitmask = EQRFilterNone;
    }
    
    if ([sender tag] > 0){
        // If any filter button is tapped, make sure all button is set to white
        [self.buttonAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    // Add to the bitmask based on the tag of the sender button
    switch ([sender tag]) {
        case 0:
            self.currentFilterBitmask = EQRFilterAll;
            [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            
            // Set all other buttons to white (off color)
            [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [self.myMasterItineraryCollection reloadData];
            break;
            
        case 1:
            if (self.currentFilterBitmask & EQRGoingShelf){
                // If it already contains this bit, then remove it
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRGoingShelf;
                [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                // I it doesn't contain this bit, then add it
                self.currentFilterBitmask = self.currentFilterBitmask | EQRGoingShelf;
                [self.buttonGoingShelf setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            }
            [self createTheFilteredArray:self.currentFilterBitmask];
            [self.myMasterItineraryCollection reloadData];
            break;
            
        case 2:
            if (self.currentFilterBitmask & EQRGoingPrepped){
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRGoingPrepped;
                [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                self.currentFilterBitmask = self.currentFilterBitmask | EQRGoingPrepped;
                [self.buttonGoingPrepped setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            }
            [self createTheFilteredArray:self.currentFilterBitmask];
            [self.myMasterItineraryCollection reloadData];
            break;
            
        case 3:
            if (self.currentFilterBitmask & EQRGoingPickedUp){
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRGoingPickedUp;
                [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                self.currentFilterBitmask = self.currentFilterBitmask | EQRGoingPickedUp;
                [self.buttonGoingPickedUp setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            }
            [self createTheFilteredArray:self.currentFilterBitmask];
            [self.myMasterItineraryCollection reloadData];
            break;
            
        case 4:
            if (self.currentFilterBitmask & EQRReturningOut){
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRReturningOut;
                [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                self.currentFilterBitmask = self.currentFilterBitmask | EQRReturningOut;
                [self.buttonReturningOut setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            }
            [self createTheFilteredArray:self.currentFilterBitmask];
            [self.myMasterItineraryCollection reloadData];
            break;
            
        case 5:
            if (self.currentFilterBitmask & EQRReturningReturned){
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRReturningReturned;
                [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                self.currentFilterBitmask = self.currentFilterBitmask | EQRReturningReturned;
                [self.buttonReturningReturned setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            }
            [self createTheFilteredArray:self.currentFilterBitmask];
            [self.myMasterItineraryCollection reloadData];
            break;
            
        case 6:
            if (self.currentFilterBitmask & EQRReturningShelved){
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRReturningShelved;
                [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                self.currentFilterBitmask = self.currentFilterBitmask | EQRReturningShelved;
                [self.buttonReturningShelved setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            }
            [self createTheFilteredArray:self.currentFilterBitmask];
            [self.myMasterItineraryCollection reloadData];
            break;
            
        default:
            break;
    }
    
    // If all filters removed, switch all on
    if (self.currentFilterBitmask == EQRFilterNone) {
        self.currentFilterBitmask = EQRFilterAll;
        [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
    }
    
    // If all filters are added, switch 'all' on
    if ((self.currentFilterBitmask == EQRFilterAll) && ([sender tag] != 0)){
        [self resetColorsOnFilterButtons];
    }
}


-(void)resetColorsOnFilterButtons{
    EQRColors *sharedColors = [EQRColors sharedInstance];
    [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
    
    // Set all other buttons to white (off color)
    [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


-(void)createTheFilteredArray:(NSUInteger)myBitmask{
    NSMutableArray* tempFilteredArray = [NSMutableArray arrayWithCapacity:1];
    
    if (myBitmask & EQRGoingShelf){
        for (EQRScheduleRequestItem* object in self.arrayOfScheduleRequests){
            if (!object.markedForReturn && !object.staff_prep_date){
                [tempFilteredArray addObject:object];
            }
        }
    }
    
    if (myBitmask & EQRGoingPrepped){
        for (EQRScheduleRequestItem* object in self.arrayOfScheduleRequests){
            if (!object.markedForReturn && object.staff_prep_date && !object.staff_checkout_date){
                [tempFilteredArray addObject:object];
            }
        }
    }
    
    if (myBitmask & EQRGoingPickedUp){
        for (EQRScheduleRequestItem* object in self.arrayOfScheduleRequests){
            if (!object.markedForReturn && object.staff_checkout_date){
                [tempFilteredArray addObject:object];
            }
        }
    }
    
    if (myBitmask & EQRReturningOut){
        for (EQRScheduleRequestItem* object in self.arrayOfScheduleRequests){
            if (object.markedForReturn && !object.staff_checkin_date){
                [tempFilteredArray addObject:object];
            }
        }
    }
    
    if (myBitmask & EQRReturningReturned){
        for (EQRScheduleRequestItem* object in self.arrayOfScheduleRequests){
            if (object.markedForReturn && object.staff_checkin_date && !object.staff_shelf_date){
                [tempFilteredArray addObject:object];
            }
        }
    }
    
    if (myBitmask & EQRReturningShelved){
        for (EQRScheduleRequestItem* object in self.arrayOfScheduleRequests){
            if (object.markedForReturn && object.staff_shelf_date){
                [tempFilteredArray addObject:object];
            }
        }
    }
    
    //must sort it first
    //sort by request date begin (...and end)
    
    NSArray* tempFilterArrayAlpha = [tempFilteredArray sortedArrayUsingComparator:^NSComparisonResult(EQRScheduleRequestItem* obj1, EQRScheduleRequestItem* obj2) {
        
        // Use either time begin or time end depending on whether this item is going or returning
        
        NSDate* date1;
        if (!obj1.markedForReturn){
            date1 = [obj1 request_time_begin];
        } else{
            date1 = [obj1 request_time_end];
        }
        
        NSDate* date2;
        if (!obj2.markedForReturn){
            date2 = [obj2 request_time_begin];
        } else{
            date2 = [obj2 request_time_end];
        }
        return [date1 compare:date2];
    }];
    self.filteredArrayOfScheduleRequests = [NSArray arrayWithArray:tempFilterArrayAlpha];
}


-(NSUInteger)determineTheBitmaskFromCellInfo:(NSDictionary*)cellData{
    NSUInteger cellStatus = [[cellData objectForKey:@"status"] unsignedIntegerValue];
    BOOL cellMarkedForReturning = [[cellData objectForKey:@"markedForReturning"] boolValue];
    
    NSUInteger returnValue = EQRFilterNone;
    
    if ((cellStatus == 0) && (cellMarkedForReturning == NO)){
        returnValue = EQRGoingShelf;
    }
    if ((cellStatus == 1) && (cellMarkedForReturning == NO)){
        returnValue = EQRGoingPrepped;
    }
    if ((cellStatus == 2) && (cellMarkedForReturning == NO)){
        returnValue = EQRGoingPickedUp;
    }
    if ((cellStatus == 0) && (cellMarkedForReturning == YES)){
        returnValue = EQRReturningOut;
    }
    if ((cellStatus == 1) && (cellMarkedForReturning == YES)){
        returnValue = EQRReturningReturned;
    }
    if ((cellStatus == 2) && (cellMarkedForReturning == YES)){
        returnValue = EQRReturningShelved;
    }
    return returnValue;
}


-(int)determineFilterButtonTagFromBitmaskValue:(NSUInteger)bitmaskValue{
    int returnValue = 0;
    
    switch (bitmaskValue) {
            
        case EQRFilterAll:
            returnValue = 0;
            break;
            
        case EQRGoingShelf:
            returnValue = 1;
            break;
            
        case EQRGoingPrepped:
            returnValue = 2;
            break;
            
        case EQRGoingPickedUp:
            returnValue = 3;
            break;
            
        case EQRReturningOut:
            returnValue = 4;
            break;
            
        case EQRReturningReturned:
            returnValue = 5;
            break;
            
        case EQRReturningShelved:
            returnValue = 6;
            break;
            
        default:
            break;
    }
    return returnValue;
}


-(void)updateFilterButtonDisplayWithAddedBitmask:(NSUInteger)addedBitmask{
    EQRColors* sharedColors = [EQRColors sharedInstance];
    
    switch (addedBitmask) {
            
        case EQRGoingShelf:
            [self.buttonGoingShelf setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            break;
            
        case EQRGoingPrepped:
            [self.buttonGoingPrepped setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            break;
            
        case EQRGoingPickedUp:
            [self.buttonGoingPickedUp setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            break;
            
        case EQRReturningOut:
            [self.buttonReturningOut setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            break;
            
        case EQRReturningReturned:
            [self.buttonReturningReturned setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            break;
            
        case EQRReturningShelved:
            [self.buttonReturningShelved setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark - request box methods
-(IBAction)requestBoxOpen:(id)sender{
    
}


#pragma mark - webData Delegate methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"inside EQRItinerary, cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
    
}

-(void)addPickupToIntineraryList:(id)currentThing{
    if (!currentThing){
        return;
    }
    NSInteger indexpathRow;
    
    //set some properties at 0
    [(EQRScheduleRequestItem *)currentThing setTotalJoinCoint:0];
    [(EQRScheduleRequestItem *)currentThing setUnTickedJoinCountForButton1:0];
    [(EQRScheduleRequestItem *)currentThing setUnTickedJoinCountForButton2:0];
    
    //evaluate if cell should be collapsed
    if ([(EQRScheduleRequestItem *)currentThing markedForReturn] == YES){
        if ([(EQRScheduleRequestItem *)currentThing staff_checkin_date]){
            [(EQRScheduleRequestItem *)currentThing setShouldCollapseReturningCell:YES];
        }
    }else{
        if ([(EQRScheduleRequestItem *)currentThing staff_checkout_date]){
            [(EQRScheduleRequestItem *)currentThing setShouldCollapseGoingCell:YES];
        }
    }
    [self.arrayOfScheduleRequests addObject:currentThing];
    
    // Sort by request date begin (...and end)
    NSArray* tempArrayAlpha = [self.arrayOfScheduleRequests sortedArrayUsingComparator:^NSComparisonResult(EQRScheduleRequestItem* obj1, EQRScheduleRequestItem* obj2) {
        
        // Use either time begin or time end depending on whether this item is going or returning
        NSDate* date1;
        if (!obj1.markedForReturn){
            date1 = [obj1 request_time_begin];
        } else{
            date1 = [obj1 request_time_end];
        }
        
        NSDate* date2;
        if (!obj2.markedForReturn){
            date2 = [obj2 request_time_begin];
        } else{
            date2 = [obj2 request_time_end];
        }
        return [date1 compare:date2];
    }];
    self.arrayOfScheduleRequests = [NSMutableArray arrayWithArray:tempArrayAlpha];
    
    // The new index of the newly added item
    indexpathRow = [self.arrayOfScheduleRequests indexOfObject:currentThing];

    // Uptick on the index
    self.indexOfLastReturnedItem = self.indexOfLastReturnedItem + 1;
    
    //__1__
    //try inserting in the collection view
    NSInteger countOfCollectionView = [self.myMasterItineraryCollection numberOfItemsInSection:0];
    NSMutableArray *tempArray = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:indexpathRow inSection:0]];
    
    // It is instructing to make 1 insertion. The count of items array should be exactly one more than the items in the collection view. If the difference is greater or less than 1, don't insert, fire the timer to reload the collection view.
    
    NSInteger y = [self.arrayOfScheduleRequests count] - countOfCollectionView;
    if (y != 1){
        self.freezeOnInsertionsFlag = YES;
    }
    if (self.freezeOnInsertionsFlag == NO){
        [self.myMasterItineraryCollection insertItemsAtIndexPaths:tempArray];
    }else{
        if (self.delayTheInsertions){
            [self.delayTheInsertions invalidate];
        }
        
        self.delayTheInsertions = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self.myMasterItineraryCollection selector:@selector(reloadData) userInfo:nil repeats:NO];
    }
    
    //__2__
    //try re-intializing all cells at and above the new cell's row
//    NSInteger i;
//    for (i = indexpathRow ; i <= self.indexOfLastReturnedItem ; i++){
//        
//        //test to see if the cell is visible...
//        for (NSIndexPath* indexPath in [self.myMasterItineraryCollection indexPathsForVisibleItems]){
//            
//            if (i == indexPath.row){
//                
//                NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                //            NSArray* rowsOfIndexPaths = @[newIndexPath];
//                
//                //_____!!!!!!!!  this causes cells to call for initialSetup multiple times   !!!!!_______
//                [(EQRItineraryRowCell *)[self.myMasterItineraryCollection cellForItemAtIndexPath:newIndexPath] initialSetupWithRequestItem:[self.arrayOfScheduleRequests objectAtIndex:i]];
//                
//                break;
//            }
//        }
//    }
}


-(void)addReturnToItineraryList:(id)currentThing{
    if (currentThing){
        // Mark the request item as a return object
        [(EQRScheduleRequestItem*)currentThing setMarkedForReturn:YES];
    }
    [self addPickupToIntineraryList:currentThing];
}


#pragma mark - EQRItineraryContentDelegate methods
-(void)collapseTapped:(NSString *) requestKeyId isReturning:(BOOL)markedForReturning{
    // Test if a filter has been applied
    NSArray *variableArray;
    
    if (self.currentFilterBitmask == EQRFilterAll){
        variableArray = self.arrayOfScheduleRequests;
    } else {  //a filter has been applied
        variableArray = self.filteredArrayOfScheduleRequests;
    }
    
    [variableArray enumerateObjectsUsingBlock:^(EQRScheduleRequestItem *requestItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (([requestItem.key_id isEqualToString:requestKeyId]) && (requestItem.markedForReturn == markedForReturning)){
            if (requestItem.markedForReturn){
                requestItem.shouldCollapseReturningCell = YES;
            }else{
                requestItem.shouldCollapseGoingCell = YES;
            }
            
            UICollectionViewFlowLayout *thisFlowLayout = [[UICollectionViewFlowLayout alloc] init];
            //min spacing size for cells is 0, min spacing size for lines is 2
            thisFlowLayout.minimumLineSpacing = 2.0;
            //section inset at top is 10. All other insets are 0.
            UIEdgeInsets thisInsets = UIEdgeInsetsMake(10.0, 0, 0, 0);
            thisFlowLayout.sectionInset = thisInsets;
            
            //_____you could instead call performBatchUpdates on the collectionView here
            //_____but this way you can specify the animation duration
            
            [UIView animateWithDuration: 0.15 animations:^{
                [self.myMasterItineraryCollection setCollectionViewLayout:thisFlowLayout animated:YES];
            }];
            
            *stop = YES;
            return;
        }
    }];
}

-(void)expandTapped:(NSString *) requestKeyId isReturning:(BOOL)markedForReturning{
    
    //test if a filter has been applied
    NSArray *variableArray;
    
    if (self.currentFilterBitmask == EQRFilterAll){
        variableArray = self.arrayOfScheduleRequests;
    } else {  //a filter has been applied
        variableArray = self.filteredArrayOfScheduleRequests;
    }
    
    [variableArray enumerateObjectsUsingBlock:^(EQRScheduleRequestItem *requestItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (([requestItem.key_id isEqualToString:requestKeyId]) && (requestItem.markedForReturn == markedForReturning)){
            if (requestItem.markedForReturn){
                requestItem.shouldCollapseReturningCell = NO;
            }else{
                requestItem.shouldCollapseGoingCell = NO;
            }
            
            UICollectionViewFlowLayout *thisFlowLayout = [[UICollectionViewFlowLayout alloc] init];
            //min spacing size for cells is 0, min spacing size for lines is 2
            thisFlowLayout.minimumLineSpacing = 2.0;
            //section inset at top is 10. All other insets are 0.
            UIEdgeInsets thisInsets = UIEdgeInsetsMake(10.0, 0, 0, 0);
            thisFlowLayout.sectionInset = thisInsets;

            //_____you could instead call performBatchUpdates on the collectionView here
            //_____but this way you can specify the animation duration
            [UIView animateWithDuration: 0.15 animations:^{
                
                [self.myMasterItineraryCollection setCollectionViewLayout:thisFlowLayout animated:YES];
            }];
            
            *stop = YES;
            return;
        }
    }];
}


-(IBAction)collapseAllCells:(id)sender{
    // Test if a filter has been applied
    NSArray *variableArray;
    
    if (self.currentFilterBitmask == EQRFilterAll){
        variableArray = self.arrayOfScheduleRequests;
    } else {  //a filter has been applied
        variableArray = self.filteredArrayOfScheduleRequests;
    }
    
    [variableArray enumerateObjectsUsingBlock:^(EQRScheduleRequestItem *requestItem, NSUInteger idx, BOOL * _Nonnull stop) {
        // Skip this request item if the cell is already expanded...
        if (requestItem.shouldCollapseReturningCell && (requestItem.markedForReturn == YES)){
            return;
        }
        if (requestItem.shouldCollapseGoingCell && (requestItem.markedForReturn == NO)){
            return;
        }
        
        // Get the cell
        EQRItineraryCellContent2VC *cellContentVC = (EQRItineraryCellContent2VC *)[(EQRItineraryRowCell2 *)[self.myMasterItineraryCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]] contentVC];
        cellContentVC.isCollapsed = YES;
        cellContentVC.collapseButton.alpha = 0.0;
        cellContentVC.collapseButton.hidden = YES;
        cellContentVC.textOverButton1.alpha = 0.0;
        cellContentVC.textOverButton2.alpha = 0.0;
        [cellContentVC.button1 setTransform:CGAffineTransformMakeScale(.5, .5)];
        [cellContentVC.button2 setTransform:CGAffineTransformMakeScale(.5, .5)];
        cellContentVC.topOfButton1Constraint.constant = 16;
        cellContentVC.topOfButton2Constraint.constant = 16;
        cellContentVC.topOfTextConstraint.constant = -8;

        if (requestItem.markedForReturn){
            requestItem.shouldCollapseReturningCell = YES;
        }else{
            requestItem.shouldCollapseGoingCell = YES;
        }
    }];
    
    [self.myMasterItineraryCollection performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        UICollectionViewFlowLayout *thisFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        // Min spacing size for cells is 0, min spacing size for lines is 2
        thisFlowLayout.minimumLineSpacing = 2.0;
        // Section inset at top is 10. All other insets are 0.
        UIEdgeInsets thisInsets = UIEdgeInsetsMake(10.0, 0, 0, 0);
        thisFlowLayout.sectionInset = thisInsets;
        
        [UIView animateWithDuration: 0.15 animations:^{
            [self.myMasterItineraryCollection setCollectionViewLayout:thisFlowLayout animated:YES];
        }];
    }];
}

-(IBAction)expandAllCells:(id)sender{
    // Test if a filter has been applied
    NSArray *variableArray;
    
    if (self.currentFilterBitmask == EQRFilterAll){
        variableArray = self.arrayOfScheduleRequests;
    } else {  //a filter has been applied
        variableArray = self.filteredArrayOfScheduleRequests;
    }
    
    [variableArray enumerateObjectsUsingBlock:^(EQRScheduleRequestItem *requestItem, NSUInteger idx, BOOL * _Nonnull stop) {
        // Skip this request item if the cell is already expanded...
        if (!requestItem.shouldCollapseReturningCell && (requestItem.markedForReturn == YES)){
            return;
        }
        if (!requestItem.shouldCollapseGoingCell && (requestItem.markedForReturn == NO)){
            return;
        }
        
        // Get the cell
        EQRItineraryCellContent2VC *cellContentVC = (EQRItineraryCellContent2VC *)[(EQRItineraryRowCell2 *)[self.myMasterItineraryCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]] contentVC];
        cellContentVC.isCollapsed = NO;
        cellContentVC.collapseButton.alpha = 1.0;
        cellContentVC.collapseButton.hidden = NO;
        cellContentVC.textOverButton1.alpha = 1.0;
        cellContentVC.textOverButton2.alpha = 1.0;
        [cellContentVC.button1 setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [cellContentVC.button2 setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        cellContentVC.topOfButton1Constraint.constant = 8;
        cellContentVC.topOfButton2Constraint.constant = 8;
        cellContentVC.topOfTextConstraint.constant = 0;
        //self.bottomOfMainSubviewConstraint.constant = -60;
        
        if (requestItem.markedForReturn){
            requestItem.shouldCollapseReturningCell = NO;
        }else{
            requestItem.shouldCollapseGoingCell = NO;
        }
    }];
    
    [self.myMasterItineraryCollection performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        
        UICollectionViewFlowLayout *thisFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        //min spacing size for cells is 0, min spacing size for lines is 2
        thisFlowLayout.minimumLineSpacing = 2.0;
        //section inset at top is 10. All other insets are 0.
        UIEdgeInsets thisInsets = UIEdgeInsetsMake(10.0, 0, 0, 0);
        thisFlowLayout.sectionInset = thisInsets;
        
        //_____you could instead call performBatchUpdates on the collectionView here
        //_____but this way you can specify the animation duration
        [UIView animateWithDuration: 0.15 animations:^{
            
            [self.myMasterItineraryCollection setCollectionViewLayout:thisFlowLayout animated:YES];
        }];
    }];
}


#pragma mark - collection view data source methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // Test if a filter has been applied
    if (self.currentFilterBitmask == EQRFilterAll){
        return [self.arrayOfScheduleRequests count];
    }else{
        return [self.filteredArrayOfScheduleRequests count];
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier = @"Cell2";
    
    EQRItineraryRowCell2 *cell = [self.myMasterItineraryCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    // Content view potentially has the wrong size
    cell.contentView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    // And reset the cell's background color...
    cell.backgroundColor = [UIColor whiteColor];
    
    // Test if a filter has been applied
    if (self.currentFilterBitmask == EQRFilterAll){          // No filter
        
        // Determine if data is loaded
        if ([self.arrayOfScheduleRequests count] > indexPath.row){  // Yes, indexed object has arrived
            
            [cell initialSetupWithRequestItem:[self.arrayOfScheduleRequests objectAtIndex:indexPath.row]];
            cell.contentVC.delegate = self;
            
            // Determine if all joins are loaded
            if (self.readyToCheckForScheduleWarningsFlag){
                EQRScheduleRequestItem* thisItem = [self.arrayOfScheduleRequests objectAtIndex:indexPath.row];
                [cell updateButtonLabels:thisItem];
            }
        }else{ // No, the data is not loaded yet
            return cell;
        }
    }else{    // Yes filter
        [cell initialSetupWithRequestItem:[self.filteredArrayOfScheduleRequests objectAtIndex:indexPath.row]];
        cell.contentVC.delegate = self;
    }
    return cell;
}


#pragma mark - collection view delegate methods
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.freezeOnInsertionsFlag = NO;
}


// Cell size
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // Test if a filter has been applied
    NSArray *variableArray;
    
    if (self.currentFilterBitmask == EQRFilterAll){
        variableArray = self.arrayOfScheduleRequests;
    } else {  // A filter has been applied
        variableArray = self.filteredArrayOfScheduleRequests;
    }
    
    // If cell button was tapped to collapse
    // or if cell requestObject has been completed
    EQRScheduleRequestItem *tempRequestItem = (EQRScheduleRequestItem *)[variableArray objectAtIndex:indexPath.row];
    if (tempRequestItem.shouldCollapseReturningCell && tempRequestItem.markedForReturn){
        return  CGSizeMake(668.0, 40);
    }else if (tempRequestItem.shouldCollapseGoingCell && !tempRequestItem.markedForReturn){
        return  CGSizeMake(668.0, 40);
    }else{
        return CGSizeMake(668.0, 100.0);
    }
}

#pragma mark - dealloc and such
-(void)dealloc{
    self.privateRequestManager = nil;
}


- (void)viewWillDisappear:(BOOL)animated{
    // Stop the async data loading
    [self.webDataForPickup stopXMLParsing];
    [self.webDataForReturn stopXMLParsing];
    [super viewWillDisappear:animated];
}


#pragma mark - popover delegate methods
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    if (popoverController == self.myDayDatePicker){
        self.myDayDatePicker = nil;
    }else if (popoverController == self.myStaffUserPicker){
        self.myStaffUserPicker = nil;
    }else if (popoverController == self.myQuickView){
        self.myQuickView = nil;
    }
}

#pragma mark - memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
