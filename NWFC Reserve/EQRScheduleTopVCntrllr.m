//
//  EQRScheduleTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleTopVCntrllr.h"
#import "EQRGlobals.h"
#import "EQRCellTemplate.h"
#import "EQRScheduleCellContentVCntrllr.h"
#import "EQRScheduleRowCell.h"
#import "EQRScheduleRequestManager.h"
#import "EQRHeaderCellForSchedule.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRScheduleRequestItem.h"
#import "EQRScheduleNavBarCell.h"
#import "EQREditorTopVCntrllr.h"
#import "EQRColors.h"
#import "EQRDayDatePickerVCntrllr.h"
#import "EQRQuickViewPage1VCntrllr.h"
#import "EQRQuickViewScrollVCntrllr.h"
#import "EQRStaffUserPickerViewController.h"


@interface EQRScheduleTopVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterScheduleCollectionView;
@property (strong ,nonatomic) IBOutlet UICollectionView* myNavBarCollectionView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* myActivityIndicator;

@property (strong, nonatomic) NSArray* equipUniqueArray;
@property (strong, nonatomic) NSMutableArray* equipUniqueArrayWithSections;
//
//an alternate to the above array with a further nested array of sections defined by titleItems
@property (strong, nonatomic) NSMutableArray* equipUniqueArrayWithSubArraysAndSections;
//
@property (strong, nonatomic) NSMutableArray* equipUniqueCategoriesList;

@property (strong, nonatomic) NSDate* dateForShow;

@property (nonatomic, strong) EQRWebData* myWebData;
@property BOOL aChangeWasMade;
@property BOOL isLoadingEquipDataFlag;
@property (strong, nonatomic) NSTimer* timerForReloadCollectionView;

@property (strong, nonatomic) UIView* movingNestedCellView;
@property (strong, nonatomic) NSString* thisTempJoinKey;
@property (strong, nonatomic) NSIndexPath* thisTempIndexPath;
@property NSInteger thisTempNewRowInt;

@property (strong, nonatomic) UIPopoverController* myDayDatePicker;
@property (strong, nonatomic) UIPopoverController* myStaffUserPicker;
@property (strong, nonatomic) UIPopoverController* myScheduleRowQuickView;
@property (strong, nonatomic) NSDictionary* temporaryDicFromNestedDayCell;
@property (strong, nonatomic) EQRQuickViewScrollVCntrllr* myQuickViewScrollVCntrllr;



-(IBAction)moveToNextMonth:(id)sender;
-(IBAction)moveToPreviousMonth:(id)sender;


@end

@implementation EQRScheduleTopVCntrllr

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

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
    
    //set ivar so that the initial load will load the schedule info
    self.aChangeWasMade = YES;
    //ivar flag to indicate when data is loading
    self.isLoadingEquipDataFlag = NO;
	
    //register for notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    //notes from scheduleRequestManager for hiding and expanding equipment sections
    [nc addObserver:self selector:@selector(refreshTable:) name:EQRRefreshScheduleTable object:nil];
    //receive note from scheduleRowCell to present schedule row quick view
    [nc addObserver:self selector:@selector(showScheduleRowQuickView:) name:EQRPresentScheduleRowQuickView object:nil];
    //receives from scheduleRowCell command to present a requestEditor vcntrllr
    [nc addObserver:self selector:@selector(showRequestEditor:) name:EQRPresentRequestEditor object:nil];
    //receive notes from requestEditor and EquipSummaryVCntrllr when a change has been made and needs to refresh the view
    [nc addObserver:self selector:@selector(raiseFlagThatAChangeHasBeenMade:) name:EQRAChangeWasMadeToTheSchedule object:nil];
    //receive note from nestedDayCell about long press actions
    [nc addObserver:self selector:@selector(longPressMoveNestedDayCell:) name:EQRLongPressOnNestedDayCell object:nil];
    
    //register collection view cell
    [self.myMasterScheduleCollectionView registerClass:[EQRScheduleRowCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.myNavBarCollectionView registerClass:[EQRScheduleNavBarCell class] forCellWithReuseIdentifier:@"Cell"];

    //register for header cell
    [self.myMasterScheduleCollectionView registerClass:[EQRHeaderCellForSchedule class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    
    //adjust content and scroll insets if edges are extended
    //______this is janky!!!!
//    self.myMasterScheduleCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.myMasterScheduleCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //initial month is the current month
    self.dateForShow = [NSDate date];
    
    //hide the activity indicator
    self.myActivityIndicator.hidden = YES;
    
    //update month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    
    //assign flow layout programmatically
//    self.scheduleMasterFlowLayout = [[UICollectionViewFlowLayout alloc] init];
//    
//    [self.myMasterScheduleCollectionView setCollectionViewLayout:self.scheduleMasterFlowLayout];
    
    
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
    UIBarButtonItem* leftBarButtonArrow =[[UIBarButtonItem alloc] initWithImage:leftArrow style:UIBarButtonItemStylePlain target:self action:@selector(moveToPreviousMonth:)];
    UIBarButtonItem* todayBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(moveToCurrentMonth:)];
    UIBarButtonItem* rightBarButtonArrow = [[UIBarButtonItem alloc] initWithImage:rightArrow style:UIBarButtonItemStylePlain target:self action:@selector(moveToNextMonth:)];
    UIBarButtonItem* searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showDatePicker)];
    
    //array that shit
    NSArray* arrayOfLeftButtons = [NSArray arrayWithObjects:twentySpace, searchBarButton, thirtySpace, leftBarButtonArrow, thirtySpace, todayBarButton, thirtySpace, rightBarButtonArrow, nil];
    
    //set leftBarButton item on SELF
    [self.navigationItem setLeftBarButtonItems:arrayOfLeftButtons];
    
    
    
    //right button
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Logged in as Trevor" style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
    //array that shit
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];
     
    //___________
    
    //add gesture recognizers for swiping
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveToPreviousMonth:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGesture];
    
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveToNextMonth:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGesture];
    

}


-(void)viewWillAppear:(BOOL)animated{
    
//    NSLog(@"view will appear is called");
    
    //_____******  initialize how sections are hidden or not hidden  *****_______
    
    
    //load the scheduleTracking information BUT ONLY if a change has been made
    if (self.aChangeWasMade){
        
        [self renewTheView];
    }
    
    
    
    
    //______BUILD CURRENT LIST OF EQUIP UNIQUE ITEMS______
    //_____*****  this a repeat of what the EquipSelectionVCntrllr *****______
    NSMutableArray* tempEquipMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    //get the ENTIRE list of equiopment titles... for staff and faculty
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetEquipUniqueItemsAndCategories.php" parameters:nil class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
                
        //do something with the returned array...
        for (EQREquipUniqueItem* equipItemThingy in muteArray){
            
            [tempEquipMuteArray addObject:equipItemThingy];
        }
    }];
    
    //... and save to ivar
    self.equipUniqueArray = [NSArray arrayWithArray:tempEquipMuteArray];
    
    //2. Go through this sinlge array and build a nested array to accommodate sections based on grouping
    
    if (!self.equipUniqueCategoriesList){
        
        self.equipUniqueCategoriesList = [NSMutableArray arrayWithCapacity:1];
    }
    
    //A. first test if array of categories is valid
    if ([self.equipUniqueCategoriesList count] < 1){
        
        NSMutableSet* tempSet = [NSMutableSet set];
        
        
        //create a list of unique categories names by looping through the array of equipUniques
        for (EQREquipUniqueItem* obj in self.equipUniqueArray){
            
            
            
            if ([tempSet containsObject:[obj performSelector:NSSelectorFromString(EQRScheduleGrouping)]] == NO){
                
                [tempSet addObject:[obj performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
                [self.equipUniqueCategoriesList addObject:[NSString stringWithString:[obj performSelector:NSSelectorFromString(EQRScheduleGrouping)]]];
            }
            
            
        }
        
        [tempSet removeAllObjects];
        tempSet = nil;
    }
    
    
    //sort the equipCatagoriesList
    NSSortDescriptor* sortDescAlpha = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray* sortArray = [NSArray arrayWithObject:sortDescAlpha];
    NSArray* tempSortArrayCat = [self.equipUniqueCategoriesList sortedArrayUsingDescriptors:sortArray];
    self.equipUniqueCategoriesList = [NSMutableArray arrayWithArray:tempSortArrayCat];
    
    
    //B.1 empty out the current ivar of arrayWithSections
    //create it if it doesn't exist yet
    if (!self.equipUniqueArrayWithSections){
        
        self.equipUniqueArrayWithSections = [NSMutableArray arrayWithCapacity:1];
        
    }else{
        
        [self.equipUniqueArrayWithSections removeAllObjects];
    }
    
    
    //B. with a valid list of categories....
    //create a new array by populating each nested array with equiptitle that match each category or subcategory
    for (NSString* groupingItem in self.equipUniqueCategoriesList){
        
        NSMutableArray* subNestArray = [NSMutableArray arrayWithCapacity:1];
        
        for (EQREquipUniqueItem* equipItem in self.equipUniqueArray){
            
            if ([[equipItem performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:groupingItem]){
                
                [subNestArray addObject: equipItem];
            }
        }
        
        //add subNested array to the master array
        [self.equipUniqueArrayWithSections addObject:subNestArray];
        
    }
    
    //we now have a master cateogry array with subnested equipTitle arrays
    
    //sort the subnested arrays
    NSMutableArray* tempSortedArrayWithSections = [NSMutableArray arrayWithCapacity:1];
    for (NSArray* obj in self.equipUniqueArrayWithSections)  {
        
        NSArray* tempSubNestArray = [obj sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            
            //first, adjust the distinquishing id by adding a 0 in front of single digits
            NSString* newDist1;
            if ([(NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id] length] < 2){
                
                newDist1 = [NSString stringWithFormat:@"0%@", (NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id]];
            }else{
                
                newDist1 =(NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id];
            }
            
            NSString* newDist2;
            if ([(NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id] length] < 2){
                
                newDist2 = [NSString stringWithFormat:@"0%@", (NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id]];
            }else{
                
                newDist2 =(NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id];
            }
            
            
            
            NSString* string1 = [NSString stringWithFormat:@"%@%@",
                                 [(EQREquipUniqueItem*)obj1 shortname], newDist1];
            NSString* string2 = [NSString stringWithFormat:@"%@%@",
                                 [(EQREquipUniqueItem*)obj2 shortname], newDist2];
            
            return [string1 compare:string2];
        }];
        
        [tempSortedArrayWithSections addObject:tempSubNestArray];
    };
    
    self.equipUniqueArrayWithSections = tempSortedArrayWithSections;
    
    //pick an initial tracking sheet item
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    if (([self.equipUniqueCategoriesList count] > 0) && ([requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule count] < 1)){
        
        [requestManager collapseOrExpandSectionInSchedule:[self.equipUniqueCategoriesList objectAtIndex:0]];
        
    }
    
    //yes, this is necesary
    [self.myMasterScheduleCollectionView reloadData];
    [self.myNavBarCollectionView reloadData];
    

    
}


-(void)renewTheView{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData.xmlParser abortParsing];
    }
    
    //reset the ivar flag
    self.aChangeWasMade = NO;
    
    //______Get a list of tracking items (defaulting with the current month)
    NSDate* todaysDate = self.dateForShow;
    NSDateFormatter* timestampFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timestampFormatter setLocale:usLocale];
    [timestampFormatter setDateFormat:@"yyyy-MM"];
    NSString* initialDateString = [timestampFormatter stringFromDate:todaysDate];
    NSString* beginDateString = [NSString stringWithFormat:@"%@-01", initialDateString];
    NSString* endDateString = [NSString stringWithFormat:@"%@-31", initialDateString];
    
    //_______note that it creates a new webData object every time the view is renewed
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //assign to ivar
    self.myWebData = webData;
    
    NSArray* request_date_begin = [NSArray arrayWithObjects:@"request_date_begin", beginDateString, nil];
    NSArray* request_date_end = [NSArray arrayWithObjects:@"request_date_end", endDateString, nil];
    NSArray* topArray = [NSArray arrayWithObjects:request_date_begin, request_date_end, nil];
    
    
    
    
    
//    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
//    
//    [webData queryWithLink:@"EQGetScheduleEquipUniqueJoinsWithDateRange.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
//        
//        [tempMuteArray addObjectsFromArray:muteArray];
//    }];
//    
//    //save array to requestManager (for rowCell to access it as needed)
//    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
//    requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins = tempMuteArray;
    

    
    
    
    //_____test webdata delegation_____
    
    //delete the existing objects in the data source array
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins = nil;
    [self.myMasterScheduleCollectionView reloadData];
    
    //send async method to webData after assigning self as the delegate
    webData.delegateForSchedule = self;
    
    //raise the is loading flag
    self.isLoadingEquipDataFlag = YES;
    
    //activity indicator
    self.myActivityIndicator.hidden = NO;
    [self.myActivityIndicator startAnimating];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetScheduleEquipUniqueJoinsWithDateRange.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(BOOL isLoadingFlagUp) {
            
            //lower the isLoading flag
            self.isLoadingEquipDataFlag = NO;
            
            //stop activity indicator
            [self.myActivityIndicator stopAnimating];
            self.myActivityIndicator.hidden = YES;
        }];
        
    });
    //_________________________________

    
    

    
}



#pragma mark - button actions... also swipe actions


-(IBAction)moveToNextMonth:(id)sender{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData.xmlParser abortParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateForSchedule = nil;
    }
    
    //add a month the current month
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString* oldDateAsString = [dateFormatter stringFromDate:self.dateForShow];
    
    //year
    NSString* yearString = [oldDateAsString substringWithRange:NSMakeRange(0, 4)];
    int yearInt = (int)[yearString integerValue];
    
    //month
    NSString* monthString = [oldDateAsString substringWithRange:NSMakeRange(5, 2)];
    int monthInt = (int)[monthString integerValue];
    
    //add a month
    int newMonthInt = monthInt + 1;
    
    if (newMonthInt > 12){
        
        newMonthInt = 1;
        
        //change the year also
        yearInt = yearInt + 1;
    }
    
    NSDate* newMonthDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%u-%u-01", yearInt, newMonthInt]];
    
    //assign date to ivar
    self.dateForShow = newMonthDate;
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    
    [self renewTheView];
    
    [self.myMasterScheduleCollectionView reloadData];
}


-(IBAction)moveToPreviousMonth:(id)sender{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData.xmlParser abortParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateForSchedule = nil;
    }
    
    //subtract a month the current month
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString* oldDateAsString = [dateFormatter stringFromDate:self.dateForShow];
    
    //year
    NSString* yearString = [oldDateAsString substringWithRange:NSMakeRange(0, 4)];
    int yearInt = (int)[yearString integerValue];
    
    //month
    NSString* monthString = [oldDateAsString substringWithRange:NSMakeRange(5, 2)];
    int monthInt = (int)[monthString integerValue];
    
    //subtract a month
    int newMonthInt = monthInt - 1;
    
    if (newMonthInt < 1){
        
        newMonthInt = 12;
        
        //change the year also
        yearInt = yearInt - 1;
    }
    
    NSDate* newMonthDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%u-%u-01", yearInt, newMonthInt]];
    
    //assign date to ivar
    self.dateForShow = newMonthDate;
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    
    [self renewTheView];
    
    [self.myMasterScheduleCollectionView reloadData];
}


-(IBAction)moveToCurrentMonth:(id)sender{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData.xmlParser abortParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateForSchedule = nil;
    }
    
    //assign date to ivar
    self.dateForShow = [NSDate date];
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    
    [self renewTheView];
    
    [self.myMasterScheduleCollectionView reloadData];
}



-(void)showStaffUserPicker{
    
    EQRStaffUserPickerViewController* staffUserPicker = [[EQRStaffUserPickerViewController alloc] initWithNibName:@"EQRStaffUserPickerViewController" bundle:nil];
    self.myStaffUserPicker = [[UIPopoverController alloc] initWithContentViewController:staffUserPicker];
    
    //set size
    [self.myStaffUserPicker setPopoverContentSize:CGSizeMake(400, 400)];
    
    //present popover
    [self.myStaffUserPicker presentPopoverFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:0]  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //set target of continue button
    [staffUserPicker.continueButton addTarget:self action:@selector(dismissStaffUserPicker) forControlEvents:UIControlEventAllEvents];
}


-(void)dismissStaffUserPicker{
    
    //do stuff with the iboutlet of the
    EQRStaffUserPickerViewController* thisStaffUserPicker = (EQRStaffUserPickerViewController*)[self.myStaffUserPicker contentViewController];
    int selectedRow = (int)[thisStaffUserPicker.myPicker selectedRowInComponent:0];
    NSLog(@"this is the selected name: %@", [thisStaffUserPicker.arrayOfContactObjects objectAtIndex:selectedRow]);
    
    
    //dismiss the picker
    [self.myStaffUserPicker dismissPopoverAnimated:YES];
    
}



-(void)showDatePicker{
    
    EQRDayDatePickerVCntrllr* dayDateView = [[EQRDayDatePickerVCntrllr alloc] initWithNibName:@"EQRDayDatePickerVCntrllr" bundle:nil];
    self.myDayDatePicker = [[UIPopoverController alloc] initWithContentViewController:dayDateView];
    
    //set size
    [self.myDayDatePicker setPopoverContentSize:CGSizeMake(400, 400)];
    
    //present popover
    [self.myDayDatePicker presentPopoverFromBarButtonItem:[self.navigationItem.leftBarButtonItems objectAtIndex:1] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //set target of continue button
    [dayDateView.myContinueButton addTarget:self action:@selector(dismissShowDatePicker:) forControlEvents:UIControlEventAllEvents];
}


-(IBAction)dismissShowDatePicker:(id)sender{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData.xmlParser abortParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateForSchedule = nil;
    }
    
    //get date from the popover's content view controller, a public method
    self.dateForShow = [(EQRDayDatePickerVCntrllr*)[self.myDayDatePicker contentViewController] retrieveSelectedDate];
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    
    //dismiss the picker
    [self.myDayDatePicker dismissPopoverAnimated:YES];
    
    [self renewTheView];
}


#pragma mark - notifications

-(void)refreshTable:(NSNotification*)note{
    
    //don't use animations when data is loading or it will crash
    if (self.isLoadingEquipDataFlag){
        
        [self.myMasterScheduleCollectionView reloadData];
        
    }else {
        
        NSString* typeOfChange = [[note userInfo] objectForKey:@"type"];
        NSString* sectionString = [[note userInfo] objectForKey:@"sectionString"];
        
        //array of index paths to add or delete
        NSMutableArray* arrayOfIndexPaths = [NSMutableArray arrayWithCapacity:1];
        int indexPathToDelete;
        
        //test whether inserting or deleting
        if ([typeOfChange isEqualToString:@"insert"]){
            
            //loop through the sections of the equipment list to identify the index of the section
            for (NSArray* subArray in self.equipUniqueArrayWithSections){
                
                NSString* thisIsGrouping = [(EQREquipUniqueItem*)[subArray objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)];
                
                if ([thisIsGrouping isEqualToString:sectionString]){
                    
                    //found a match, remember the index
                    indexPathToDelete = (int)[self.equipUniqueArrayWithSections indexOfObject:subArray];
                    
                    //loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
            
            //do the insert
            [self.myMasterScheduleCollectionView insertItemsAtIndexPaths:arrayOfIndexPaths];
            
            
        }else if([typeOfChange isEqualToString:@"delete"]) {
            
            //loop through the sections of the equipment list to identify the index of the section
            for (NSArray* subArray in self.equipUniqueArrayWithSections){
                
                NSString* thisIsGrouping = [(EQREquipUniqueItem*)[subArray objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)];
                
                if ([thisIsGrouping isEqualToString:sectionString]){
                    
                    //found a match, remember the index
                    indexPathToDelete = (int)[self.equipUniqueArrayWithSections indexOfObject:subArray];
                    
                    //loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
            
            //do the deletions
            [self.myMasterScheduleCollectionView deleteItemsAtIndexPaths:arrayOfIndexPaths];
            
            
            //        [self.equipCollectionView reloadData];
        }
    }
}

-(void)raiseFlagThatAChangeHasBeenMade:(NSNotification*)note{
    
    self.aChangeWasMade = YES;
}



-(void)showScheduleRowQuickView:(NSNotification*)note{
    
    //create quickview scroll view
    EQRQuickViewScrollVCntrllr* quickView = [[EQRQuickViewScrollVCntrllr alloc] initWithNibName:@"EQRQuickViewScrollVCntrllr" bundle:nil];
    self.myQuickViewScrollVCntrllr = quickView;
    
    //instatiate first page subview
    EQRQuickViewPage1VCntrllr* quickViewPage1 = [[EQRQuickViewPage1VCntrllr alloc] initWithNibName:@"EQRScheduleRowQuickViewVCntrllr" bundle:nil];
    
    self.myQuickViewScrollVCntrllr.myScheduleRowQuickView = quickViewPage1;
    
    self.myScheduleRowQuickView = [[UIPopoverController alloc] initWithContentViewController:self.myQuickViewScrollVCntrllr];
    [self.myScheduleRowQuickView setPopoverContentSize:CGSizeMake(300.f, 502.f)];
    

    
    //__________****** assign userInfo dic to ivar SEEMS WEIRD but requires the dic in the showRequestEditor method *********_______
    self.temporaryDicFromNestedDayCell = [NSDictionary dictionaryWithDictionary:[note userInfo]];
    
    //do the busy work of creating the popOver view
    [quickViewPage1 initialSetupWithDic:self.temporaryDicFromNestedDayCell];
    
    NSValue* valueOfRect = [[note userInfo] objectForKey:@"rectOfSelectedNestedDayCell"];
    CGRect selectedRect = [valueOfRect CGRectValue];
    
    
    //assign target of popover's "edit request" button
    [self.myQuickViewScrollVCntrllr.editRequestButton addTarget:self action:@selector(showRequestEditorFromQuickView:)  forControlEvents:UIControlEventAllEvents];

    
    //show popover  MUST use NOT allow using the arrow directin from below, keyboard may cover the textview
    [self.myScheduleRowQuickView presentPopoverFromRect:selectedRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionDown animated:YES];
    
    //attach page 1
    [self.myQuickViewScrollVCntrllr.myContentPage1 addSubview:quickViewPage1.view];
    
    
    //add gesture recognizers
    UISwipeGestureRecognizer* swipeLeftGestureOnQuickview = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideLeft:)];
    swipeLeftGestureOnQuickview.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.myQuickViewScrollVCntrllr.myContentPage1 addGestureRecognizer:swipeLeftGestureOnQuickview];
    
    UISwipeGestureRecognizer* swipeRightGestureOnQuickview = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideRight:)];
    swipeRightGestureOnQuickview.direction = UISwipeGestureRecognizerDirectionRight;
    [self.myQuickViewScrollVCntrllr.myContentPage2 addGestureRecognizer:swipeRightGestureOnQuickview];
    
    
}


-(void) showRequestEditor:(NSNotification*)note{
    
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
    
    //dismiss the quickView popover
    [self.myScheduleRowQuickView dismissPopoverAnimated:YES];
    
    EQREditorTopVCntrllr* editorViewController = [[EQREditorTopVCntrllr alloc] initWithNibName:@"EQREditorTopVCntrllr" bundle:nil];
    
    //prevent edges from extending beneath nav and tab bars
    editorViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    //initial setup
    [editorViewController initialSetupWithInfo:self.temporaryDicFromNestedDayCell];;
    
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


#pragma mark - handle movement of nested day cells

-(void)longPressMoveNestedDayCell:(NSNotification*)note{
    
    UIGestureRecognizer* gesture = [[note userInfo] objectForKey:@"gesture"];
    CGRect frameSize = [[[note userInfo] objectForKey:@"frameSizeValue"] CGRectValue];
    NSString* joinKey_id = [[note userInfo] objectForKey:@"key_id"];
    NSString* joinTitleKey_id = [[note userInfo] objectForKey:@"equipTitleItem_foreignKey"];
    NSIndexPath* indexPathForRowCell = [[note userInfo] objectForKey:@"indexPath"];
    UIColor* myCellColor = [[note userInfo] objectForKey:@"color"];
    
    if (gesture.state == UIGestureRecognizerStateBegan){
        
        self.movingNestedCellView = [[UIView alloc] initWithFrame:frameSize];
        self.movingNestedCellView.backgroundColor = myCellColor;
        
        //expand the rect itself to new size
        [UIView animateWithDuration:0.25 animations:^{
            
            self.movingNestedCellView.frame = CGRectMake(frameSize.origin.x - 20, frameSize.origin.y - 10, frameSize.size.width + 40, frameSize.size.height + 20);
            
            self.movingNestedCellView.layer.cornerRadius = 5;
        }];

        
        
        [self.view addSubview:self.movingNestedCellView];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged){
        
        //get the y value
        CGPoint thisPoint = [gesture locationInView:self.view];
        
        //add 15 pts becasue origin is about the touch... plus a little sumptin' sumptin'
        float valueWithHalfHeight = thisPoint.y + (EQRScheduleItemHeightForDay * 0.5) + 10;
        
        //move only in increments equal to the cell height
        valueWithHalfHeight = valueWithHalfHeight / EQRScheduleItemHeightForDay;
        int newValueInt = valueWithHalfHeight;
        float newValueExpanded = newValueInt * EQRScheduleItemHeightForDay;
        
        //add in the scroll view offset from the collection view
        CGPoint scrollViewOffsetPoint = self.myMasterScheduleCollectionView.contentOffset;
        float scrollViewOffsetY = (int)scrollViewOffsetPoint.y % (int)EQRScheduleItemHeightForDay;
        newValueExpanded = newValueExpanded - scrollViewOffsetY;
        
        //subtract a further 10pnts to get the coordinates for the view to sync with our increment (based on origin of the collection view)
        newValueExpanded = newValueExpanded - 10;
        

        //add back into it, the resize adjustment
        newValueExpanded = newValueExpanded - 10;
        
        //create modified rect with new y value...
        CGRect thisRect = CGRectMake(self.movingNestedCellView.frame.origin.x, newValueExpanded, self.movingNestedCellView.frame.size.width, self.movingNestedCellView.frame.size.height);
        
        //assign to moving cell ivar
        self.movingNestedCellView.frame = thisRect;
        
    }
    
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        
        NSString* equipUniqueItem_foreignKey;
        NSString* equipTitleItem_foreignKey;
        
        //change equipKeyID on requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        //use the touch location to derive the target equipItem from the self.equipUniqueArrayWithSections ivar
        //we know the section from the supplied indexPath...
        //_______Use the center of the moving nested cell view_______
        CGPoint thatPoint = self.movingNestedCellView.center;
        
        //80 is the distance between the collectionView and the top of the view
        //must also add in the collection view offset
        CGPoint offsetPoint = self.myMasterScheduleCollectionView.contentOffset;
        int newRowInt = ((thatPoint.y - 80) + offsetPoint.y) / EQRScheduleItemHeightForDay;
        
        for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins){
            
            if ([thisJoin.key_id isEqualToString:joinKey_id]){
                
                //found a match
                
                equipTitleItem_foreignKey =[(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] equipTitleItem_foreignKey];
                
                
                //if titleKey doesn't match the original title key, then pause and give warning in an alert view
                if (![equipTitleItem_foreignKey isEqualToString:joinTitleKey_id]){
                    
                    //save joinkey and indexpath to use in alert delegate method
                    self.thisTempJoinKey = joinKey_id;
                    self.thisTempIndexPath = indexPathForRowCell;
                    self.thisTempNewRowInt = newRowInt;
                    
                    UIAlertView* newAlertView = [[UIAlertView alloc] initWithTitle:@"New Equipment" message:@"You have selected a different type of equipment" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Continue", nil];
                    
                    [newAlertView show];
                    
                }else{
                    
                    //or continue as planned...
                    
                    //now update the equipUnique and equipTitle values
                    equipUniqueItem_foreignKey = [(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] key_id];
                    
                    thisJoin.equipUniqueItem_foreignKey = equipUniqueItem_foreignKey;
                    
                    thisJoin.equipTitleItem_foreignKey = equipTitleItem_foreignKey;
                    
                    //then reload the collection views in the former and new rowCells
                    [self.myMasterScheduleCollectionView reloadData];
                    
                    
                    //webData query to change equipKeyID on schedule_equip_join (or delete previous and create a new one)
                    EQRWebData* webData = [EQRWebData sharedInstance];
                    NSArray* firstArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", equipUniqueItem_foreignKey, nil];
                    NSArray* secondArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", equipTitleItem_foreignKey, nil];
                    NSArray* thirdArray = [NSArray arrayWithObjects:@"key_id", joinKey_id, nil];
                    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                    
                    [webData queryForStringWithLink:@"EQAlterScheduleEquipJoin.php" parameters:topArray];
                    
                    
                    [self.movingNestedCellView removeFromSuperview];
                }
            }
        }
    }
    
    if ((gesture.state == UIGestureRecognizerStateCancelled) || (gesture.state ==UIGestureRecognizerStateFailed)){
        
        
    }
}


#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    
//    NSLog(@"this is the alert button index: %u", buttonIndex);
    
    //continue button tapped, continue with change
    if (buttonIndex == 1){
        
        NSString* joinKey_id = self.thisTempJoinKey;
        NSIndexPath* indexPathForRowCell = self.thisTempIndexPath;
        int newRowInt = (int)self.thisTempNewRowInt;
        NSString* equipUniqueItem_foreignKey;
        NSString* equipTitleItem_foreignKey;
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins){
            
            if ([thisJoin.key_id isEqualToString:joinKey_id]){
                
                //now update the equipUnique and equipTitle values
                equipUniqueItem_foreignKey = [(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] key_id];
                
                thisJoin.equipUniqueItem_foreignKey = equipUniqueItem_foreignKey;
                
                equipTitleItem_foreignKey =[(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] equipTitleItem_foreignKey];
                
                thisJoin.equipTitleItem_foreignKey = equipTitleItem_foreignKey;
                
                //then reload the collection views in the former and new rowCells
                [self.myMasterScheduleCollectionView reloadData];
                
                
                //webData query to change equipKeyID on schedule_equip_join (or delete previous and create a new one)
                EQRWebData* webData = [EQRWebData sharedInstance];
                NSArray* firstArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", equipUniqueItem_foreignKey, nil];
                NSArray* secondArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", equipTitleItem_foreignKey, nil];
                NSArray* thirdArray = [NSArray arrayWithObjects:@"key_id", joinKey_id, nil];
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                
                [webData queryForStringWithLink:@"EQAlterScheduleEquipJoin.php" parameters:topArray];
                
                [self.movingNestedCellView removeFromSuperview];
            }
        }
    }
    
    //cancel button, move nestedCellView back to original position
    if (buttonIndex == 0){
        
        [self.movingNestedCellView removeFromSuperview];
        
        //make original cell visible again
        [self.myMasterScheduleCollectionView reloadData];
        
    }
    
}


#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        //test if this section is flagged to be collapsed
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        EQREquipUniqueItem* sampleItem = [[self.equipUniqueArrayWithSections objectAtIndex:section] objectAtIndex:0];
        
        //loop through array of hidden sections
        for (NSString* objectSection in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
            
            if ([[sampleItem performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:objectSection]){
                
                return [(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:section] count];
            }
        }
        
        //otherwise...
        return 0;
        
    } else {
        
        NSLog(@"equiopUniqueCategoriesList count is: %u", (int)[self.equipUniqueCategoriesList count]);
        return [self.equipUniqueCategoriesList count];
    }
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        return [self.equipUniqueArrayWithSections count];
        
    } else {
        
        return 1;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";

    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        //FOR Row Cell
        EQRScheduleRowCell* cell = [self.myMasterScheduleCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell.backgroundColor = [UIColor whiteColor];
        
        //get the item name and distinquishing ID from the nested array
        NSString* myTitleString = [NSString stringWithFormat:@"%@  #%@",
                                   [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] shortname],
                                   [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] distinquishing_id]];
        
        [cell initialSetupWithTitle:myTitleString equipKey:[(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id] indexPath:indexPath dateForShow:self.dateForShow];
        
        //modify the background color to have alternate colors in rows
        if (indexPath.row % 2){
            //odd
            EQRColors* myColors = [EQRColors sharedInstance];
            cell.backgroundColor = [[myColors colorDic] objectForKey:EQRColorVeryLightGrey];;
        }
        
        
        //add content view from xib
        EQRScheduleCellContentVCntrllr* myContentViewController = [[EQRScheduleCellContentVCntrllr alloc] initWithNibName:@"EQRScheduleCellContentVCntrllr" bundle:nil];
        
        //add subview
        [cell.contentView addSubview:myContentViewController.view];
        //move to rear
        [cell.contentView sendSubviewToBack:myContentViewController.view];
        
        
        //change label AFTER adding it to the view else defaults to XIB file
        myContentViewController.myRowLabel.text = myTitleString;
        
        return cell;
        
    } else {
        
        //FOR Nav Bar
        EQRScheduleNavBarCell* cell2 = [self.myNavBarCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        for (UIView* view in cell2.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell2.backgroundColor = [UIColor whiteColor];
        
        [cell2 initialSetupWithTitle:(NSString*)[self.equipUniqueCategoriesList objectAtIndex:indexPath.row]];
//        [cell2 initialSetupWithTitle:@"Whee!"];

        //modify the background color to have alternate colors in rows
        if (indexPath.row % 2){
            //odd
            cell2.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
        }
        
        return cell2;
    }
}



#pragma mark - section header data source methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    EQRHeaderCellForSchedule* cell = [self.myMasterScheduleCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* thisSubview in cell.contentView.subviews){
        
        [thisSubview removeFromSuperview];
    }
    
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        //_____test whether the section is collapsed or expanded
        BOOL iAmVisible = NO;
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
            
            if ([sectionString isEqualToString:[(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)]]){
                
                //found a match in the array of visible sections
                iAmVisible = YES;
                
                break;
            }
        }
        
        //inverse the logic
        BOOL iAmHidden = abs(1 - iAmVisible);
        
        //get the category or subcategory for a sample item in the nested array
        NSString* thisTitleString = [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)];
        
        //cell's initial setup method with label
        [cell initialSetupWithTitle:thisTitleString isHidden:iAmHidden];
        
        
        
    } else {
        
        
    }
    
    return cell;
}



#pragma mark - change in orientation methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self.myMasterScheduleCollectionView reloadData];
    [self.myNavBarCollectionView reloadData];
}


#pragma mark - collection view delegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
    } else {
        
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        //_____********  must close any currently open sections first, then open the selected one  ********____
        
        //update request Manager to do the action and keep persistence
        [requestManager collapseOrExpandSectionInSchedule:[self.equipUniqueCategoriesList objectAtIndex:indexPath.row]];
    }
    
}

#pragma mark - collection view flow layout delegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        //for EquipUnique Stuff
        //______******   a better implementation of this is here:   ******_______
        //  http://stackoverflow.com/questions/13556554/change-uicollectionviewcell-size-on-different-device-orientations
        //uses two different flowlayout objects, one for each orientation
        
        UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
            
            //set size
            return CGSizeMake(768.f, 30.f);
            
        }else{
            
            //set size
            return CGSizeMake(1024.f, 30.f);
        }
        
    } else {
        
        //for NAV BAR
        //size of cell is based available length of collectoin view divided by count in array,
        
        float widthOfMe;
        
        UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
            
            widthOfMe = 768 / [self.equipUniqueCategoriesList count];
            
        }else{
            
            widthOfMe = 1024 / [self.equipUniqueCategoriesList count];

        }
        
        return CGSizeMake(widthOfMe, 50);
    }
    
}


#pragma mark - EQRWebData Delegate methods

-(void)addScheduleTrackingItem:(id)currentThing{
    
//    NSLog(@"WEBDATA SUCCESSFULLY CALLED DELEGATE'S METHOD: %@", [currentThing class]);
    
    //save array to requestManager (for rowCell to access it as needed)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins];
    
    [newArray addObject:currentThing];
    
    requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins = [NSArray arrayWithArray:newArray];
    
    //should do this only once every 1 second (with NSTimer) to prevent the 1000+ calls to reload
    //if the timer currently exists, don't do anything...
    
    if (![self.timerForReloadCollectionView isValid]){
        
        self.timerForReloadCollectionView = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerFiredReloadCollectionView) userInfo:nil repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:self.timerForReloadCollectionView forMode:NSDefaultRunLoopMode];
    }
}

-(void)timerFiredReloadCollectionView{
    
    [self.myMasterScheduleCollectionView reloadData];
}


#pragma mark - memory warning



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma clang diagnostic pop

@end
