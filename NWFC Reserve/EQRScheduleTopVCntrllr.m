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
#import "EQRQuickViewPage2VCntrllr.h"
#import "EQRQuickViewPage3VCntrllr.h"
#import "EQRQuickViewScrollVCntrllr.h"
#import "EQRStaffUserPickerViewController.h"
#import "EQRStaffUserManager.h"
#import "EQRModeManager.h"
#import "EQRScheduleNestedDateBarCell.h"
#import "EQRNavBarDatesView.h"
#import "EQRNavBarWeeksView.h"
#import "EQRDataStructure.h"
#import "EQRClassItem.h"


@interface EQRScheduleTopVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterScheduleCollectionView;
@property (strong ,nonatomic) IBOutlet UICollectionView* myNavBarCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView* myDateBarCollection;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* myActivityIndicator;
@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@property (strong, nonatomic) IBOutlet UIView *filterBoxView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainSubViewTopConstraint;

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

@property (strong, nonatomic) IBOutlet EQRNavBarDatesView* navBarDates;
@property (strong, nonatomic) IBOutlet EQRNavBarWeeksView *navBarWeeks;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *navWeeksConstraint;

@property NSInteger weekIndicatorOffset;
@property BOOL dateForShowIsNOTCurrentMonth;

@property (strong, nonatomic) UIPopoverController* myClassPicker;
@property (strong, nonatomic) NSString *filter_classSectionKey;
@property BOOL filterIsOnFlag;

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
    [nc addObserver:self selector:@selector(showRequestEditor:) name:EQRPresentRequestEditorFromSchedule object:nil];
    //receive notes from requestEditor and EquipSummaryVCntrllr when a change has been made and needs to refresh the view
    [nc addObserver:self selector:@selector(raiseFlagThatAChangeHasBeenMade:) name:EQRAChangeWasMadeToTheSchedule object:nil];
    //receive note from nestedDayCell about long press actions
    [nc addObserver:self selector:@selector(longPressMoveNestedDayCell:) name:EQRLongPressOnNestedDayCell object:nil];
    
    //register collection view cell
    [self.myMasterScheduleCollectionView registerClass:[EQRScheduleRowCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.myNavBarCollectionView registerClass:[EQRScheduleNavBarCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.myDateBarCollection registerClass:[EQRScheduleNestedDateBarCell class] forCellWithReuseIdentifier:@"CellForDateBar"];

    //register for header cell
    [self.myMasterScheduleCollectionView registerClass:[EQRHeaderCellForSchedule class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    

    self.myMasterScheduleCollectionView.contentOffset = CGPointMake(0, 0);
    
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
    
    //background color of collection view
    EQRColors *colors = [EQRColors sharedInstance];
    self.myDateBarCollection.backgroundColor = [UIColor clearColor];
    self.filterBoxView.backgroundColor = [colors.colorDic objectForKey:EQRColorFilterBarAndSearchBarBackground];
    
    //assign flow layout programmatically
//    self.scheduleMasterFlowLayout = [[UICollectionViewFlowLayout alloc] init];
//    
//    [self.myMasterScheduleCollectionView setCollectionViewLayout:self.scheduleMasterFlowLayout];
    
    
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
    UIBarButtonItem* leftBarButtonArrow =[[UIBarButtonItem alloc] initWithImage:leftArrow style:UIBarButtonItemStylePlain target:self action:@selector(moveToPreviousMonth:)];
    UIBarButtonItem* todayBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(moveToCurrentMonth:)];
    UIBarButtonItem* rightBarButtonArrow = [[UIBarButtonItem alloc] initWithImage:rightArrow style:UIBarButtonItemStylePlain target:self action:@selector(moveToNextMonth:)];
    UIBarButtonItem* searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showDatePicker)];
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterResults)];
    
    NSArray* arrayOfLeftButtons = [NSArray arrayWithObjects:twentySpace, searchBarButton, thirtySpace, leftBarButtonArrow, thirtySpace, todayBarButton, thirtySpace, rightBarButtonArrow, thirtySpace, filterBarButton, nil];
    
    //set leftBarButton item on SELF
    [self.navigationItem setLeftBarButtonItems:arrayOfLeftButtons];
    
    
    
    //right button
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:logText style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
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
    
    // Load the scheduleTracking information BUT ONLY if a change has been made
    if (self.aChangeWasMade){
        [self renewTheView];
    }
    
    //set the current staffUser name in nav bar
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
    
    
    //______BUILD CURRENT LIST OF EQUIP UNIQUE ITEMS______
    //_____*****  this a repeat of what the EquipSelectionVCntrllr *****______
    
    // Get the ENTIRE list of equipment titles
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSMutableArray* tempEquipMuteArray = [NSMutableArray arrayWithCapacity:1];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetEquipUniqueItemsAndCategories.php" parameters:nil class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
            
            //do something with the returned array...
            for (EQREquipUniqueItem* equipItemThingy in muteArray){
                [tempEquipMuteArray addObject:equipItemThingy];
            }
        }];
        self.equipUniqueArray = [NSArray arrayWithArray:tempEquipMuteArray];
        
        // Go through this single array and build a nested array to accommodate sections based on grouping
        
        if (!self.equipUniqueCategoriesList){
            self.equipUniqueCategoriesList = [NSMutableArray arrayWithCapacity:1];
        }
        
        // Test if array of categories is valid
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
        
        // Sort the equipCatagoriesList
        NSSortDescriptor* sortDescAlpha = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
        NSArray* sortArray = [NSArray arrayWithObject:sortDescAlpha];
        NSArray* tempSortArrayCat = [self.equipUniqueCategoriesList sortedArrayUsingDescriptors:sortArray];
        self.equipUniqueCategoriesList = [NSMutableArray arrayWithArray:tempSortArrayCat];
        
        NSMutableArray *tempUniqueArrayWithSections = [NSMutableArray arrayWithCapacity:1];
        
        // Valid list of categories....
        // Create a new array by populating each nested array with equiptitle that match each category or subcategory
        for (NSString* groupingItem in self.equipUniqueCategoriesList){
            
            NSMutableArray* subNestArray = [NSMutableArray arrayWithCapacity:1];
            
            for (EQREquipUniqueItem* equipItem in self.equipUniqueArray){
                
                if ([[equipItem performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:groupingItem]){
                    [subNestArray addObject: equipItem];
                }
            }
            // Add subNested array to the master array
            [tempUniqueArrayWithSections addObject:subNestArray];
        }
        
        // We now have a master cateogry array with subnested equipTitle arrays
        
        // Sort the subnested arrays
        NSMutableArray* tempSortedArrayWithSections = [NSMutableArray arrayWithCapacity:1];
        for (NSArray* obj in tempUniqueArrayWithSections)  {
            
            NSArray* tempSubNestArray = [obj sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
                
                //______first change the single digits...
                NSString* newDist1;
                if ([(NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id] length] < 2){
                    newDist1 = [NSString stringWithFormat:@"00%@", (NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id]];
                }else{
                    newDist1 =(NSString*)[(EQREquipUniqueItem*)obj1 distinquishing_id];
                }
                
                NSString* newDist2;
                if ([(NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id] length] < 2){
                    newDist2 = [NSString stringWithFormat:@"00%@", (NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id]];
                }else{
                    newDist2 =(NSString*)[(EQREquipUniqueItem*)obj2 distinquishing_id];
                }
                
                //______next change the double digits...
                //if dist id is only one character in length, add a 0 to the start.
                if ([newDist1 length] < 3){
                    newDist1 = [NSString stringWithFormat:@"0%@", newDist1];
                }
                
                if ([newDist2 length] < 3){
                    newDist2 = [NSString stringWithFormat:@"0%@", newDist2];
                }
                
                NSString* string1 = [NSString stringWithFormat:@"%@%@",
                                     [(EQREquipUniqueItem*)obj1 shortname], newDist1];
                NSString* string2 = [NSString stringWithFormat:@"%@%@",
                                     [(EQREquipUniqueItem*)obj2 shortname], newDist2];
                
                return [string1 compare:string2];
            }];
            
            [tempSortedArrayWithSections addObject:tempSubNestArray];
        };
        
        tempUniqueArrayWithSections = tempSortedArrayWithSections;
        
        // Pick an initial tracking sheet item
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        if (([self.equipUniqueCategoriesList count] > 0) && ([requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule count] < 1)){
            [requestManager collapseOrExpandSectionInSchedule:[self.equipUniqueCategoriesList objectAtIndex:0]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.equipUniqueArrayWithSections = [NSMutableArray arrayWithArray:tempUniqueArrayWithSections];
            
            // Yes, this is necesary
            [self.myMasterScheduleCollectionView reloadData];
            [self.myNavBarCollectionView reloadData];
            
            [self.myNavBarCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        });
    
    });
    
    
    
    // Update opacity and width of navBarDates if in change orientation
    UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
        
        self.navBarDates.isNarrowFlag = YES;
        self.navBarWeeks.isNarrowFlag = YES;
        self.navBarDates.alpha = 0.5;
        self.navBarWeeks.alpha = 0.5;
        [self.navBarDates setNeedsDisplay];
        [self.navBarWeeks setNeedsDisplay];
        
    }else{
        
        self.navBarDates.isNarrowFlag = NO;
        self.navBarWeeks.isNarrowFlag = NO;
        self.navBarDates.alpha = 1.0;
        self.navBarWeeks.alpha = 1.0;
        [self.navBarDates setNeedsDisplay];
        [self.navBarWeeks setNeedsDisplay];
    }

    //this updates placement of day and dates if orientation changed while in a different tab
    [self.myDateBarCollection.collectionViewLayout invalidateLayout];
    
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
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    self.myMasterScheduleCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.myMasterScheduleCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}


-(void)renewTheView{
    
    // Cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData stopXMLParsing];
    }
    
    // Reset the ivar flag
    self.aChangeWasMade = NO;
    
    //____offset the week indicators
    NSString *dateAsString = [EQRDataStructure dateAsString:self.dateForShow];
    NSString *revisedDateAsString = [NSString stringWithFormat:@"%@01%@", [dateAsString substringToIndex:8], [dateAsString substringWithRange:NSMakeRange(10, 1)]];
    NSDate *newDate = [EQRDataStructure dateWithoutTimeFromString:revisedDateAsString];
    
    NSDateFormatter* dayOfWeekAsNumber = [[NSDateFormatter alloc] init];
    [dayOfWeekAsNumber setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    dayOfWeekAsNumber.dateFormat = @"e";
    NSString* numberString = [dayOfWeekAsNumber stringFromDate:newDate];
    self.weekIndicatorOffset = 7 - [numberString integerValue];
    
    //offset week vertical line indicators
    UIInterfaceOrientation orientationOnLaunch = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientationOnLaunch)) {
        self.navWeeksConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel+(EQRScheduleItemWidthForDayNarrow * self.weekIndicatorOffset);
    }else{
        self.navWeeksConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel + (EQRScheduleItemWidthForDay * self.weekIndicatorOffset);
    }
    [self.navBarWeeks setNeedsDisplay];
    //____//
    
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
    
    //delete the existing objects in the data source array
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins = nil;
    [self.myMasterScheduleCollectionView reloadData];
    
    //send async method to webData after assigning self as the delegate
    webData.delegateDataFeed = self;
    
    //raise the is loading flag
    self.isLoadingEquipDataFlag = YES;
    
    //activity indicator
    self.myActivityIndicator.hidden = NO;
    [self.myActivityIndicator startAnimating];
    
    SEL thisSelector = @selector(timerFiredReloadCollectionView);
    
    if (self.filterIsOnFlag == NO){
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleEquipUniqueJoinsWithDateRange.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
                
                //lower the isLoading flag
                self.isLoadingEquipDataFlag = NO;
                
                //stop activity indicator
                [self.myActivityIndicator stopAnimating];
                self.myActivityIndicator.hidden = YES;
            }];
            
        });
        
    } else{
        
        NSArray* classFilter = @[@"classSection_foreignKey", self.filter_classSectionKey];
        NSArray* topArray1 = [NSArray arrayWithObjects:request_date_begin, request_date_end, classFilter,  nil];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleEquipUniqueJoinsWithDateRangeAndClassSectionKey.php" parameters:topArray1 class:@"EQRScheduleTracking_EquipmentUnique_Join" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
                
                //lower the isLoading flag
                self.isLoadingEquipDataFlag = NO;
                
                //stop activity indicator
                [self.myActivityIndicator stopAnimating];
                self.myActivityIndicator.hidden = YES;
            }];
            
        });
    }
}



#pragma mark - button actions... also swipe actions


-(IBAction)moveToNextMonth:(id)sender{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData stopXMLParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateDataFeed = nil;
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
    
    self.dateForShowIsNOTCurrentMonth = [self evaluateIfDateForShowIsNOTCurrentMonth];
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    if (self.filterIsOnFlag == NO){
        self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    }else{
        //assign month to nav bar title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Filtered Results",
                                     [monthNameFormatter stringFromDate:self.dateForShow]];
    }
    
    [self renewTheView];
    
    [self.myMasterScheduleCollectionView reloadData];
    [self.myDateBarCollection reloadData];
}


-(IBAction)moveToPreviousMonth:(id)sender{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData stopXMLParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateDataFeed = nil;
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
    
    self.dateForShowIsNOTCurrentMonth = [self evaluateIfDateForShowIsNOTCurrentMonth];
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    if (self.filterIsOnFlag == NO){
        self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    }else{
        //assign month to nav bar title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Filtered Results",
                                     [monthNameFormatter stringFromDate:self.dateForShow]];
    }
    
    [self renewTheView];
    
    [self.myMasterScheduleCollectionView reloadData];
    [self.myDateBarCollection reloadData];
}


-(IBAction)moveToCurrentMonth:(id)sender{
    
    self.dateForShowIsNOTCurrentMonth = NO;
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData stopXMLParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateDataFeed = nil;
    }
    
    //assign date to ivar
    self.dateForShow = [NSDate date];
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    if (self.filterIsOnFlag == NO){
        self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    }else{
        //assign month to nav bar title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Filtered Results",
                                     [monthNameFormatter stringFromDate:self.dateForShow]];
    }
    
    [self renewTheView];
    
    [self.myMasterScheduleCollectionView reloadData];
    [self.myDateBarCollection reloadData];
}

-(BOOL)evaluateIfDateForShowIsNOTCurrentMonth{
    
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [monthFormatter setDateFormat:@"MM yyyy"];
    
    NSString *currentDateAsString = [monthFormatter stringFromDate:currentDate];
    NSString *dateForShowAsString = [monthFormatter stringFromDate:self.dateForShow];
    
    if ([currentDateAsString isEqualToString:dateForShowAsString]){
        return NO;
    }else{
        return YES;
    }
}


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
    
    //do stuff with the iboutlet of the
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



-(void)showDatePicker{
    
    EQRDayDatePickerVCntrllr* dayDateView = [[EQRDayDatePickerVCntrllr alloc] initWithNibName:@"EQRDayDatePickerVCntrllr" bundle:nil];
    self.myDayDatePicker = [[UIPopoverController alloc] initWithContentViewController:dayDateView];
    self.myDayDatePicker.delegate = self;
    
    //set size
    [self.myDayDatePicker setPopoverContentSize:CGSizeMake(400, 400)];
    
    //present popover
    [self.myDayDatePicker presentPopoverFromBarButtonItem:[self.navigationItem.leftBarButtonItems objectAtIndex:1] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //set target of continue button
    [dayDateView.myContinueButton addTarget:self action:@selector(dismissShowDatePicker:) forControlEvents:UIControlEventTouchUpInside];
}


-(IBAction)dismissShowDatePicker:(id)sender{
    
    //cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData stopXMLParsing];
        
        //_________the former Webdata object continues feeding data for a fraction of a second after loading a new month,
        //_________falsely showing equip joins from a previous month
        //_________remedy by disconnecting the webdata's delegate
        self.myWebData.delegateDataFeed = nil;
    }
    
    //get date from the popover's content view controller, a public method
    self.dateForShow = [(EQRDayDatePickerVCntrllr*)[self.myDayDatePicker contentViewController] retrieveSelectedDate];
    
    self.dateForShowIsNOTCurrentMonth = [self evaluateIfDateForShowIsNOTCurrentMonth];
    
    //assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    if (self.filterIsOnFlag == NO){
        self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    }else{
        //assign month to nav bar title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Filtered Results",
                                     [monthNameFormatter stringFromDate:self.dateForShow]];
    }
    
    //dismiss the picker
    [self.myDayDatePicker dismissPopoverAnimated:YES];
    self.myDayDatePicker = nil;
    
    [self renewTheView];
    
    //reload dates
    [self.myDateBarCollection reloadData];
}


-(void)filterResults{
    
    if (self.filterIsOnFlag == YES){
        self.filterIsOnFlag = NO;
        self.filter_classSectionKey = nil;
        
        //update month label
        NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
        monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        monthNameFormatter.dateFormat =@"MMMM yyyy";
        
        //assign month to nav bar title
        self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.mainSubViewTopConstraint.constant = 0;
            
            [self.view layoutIfNeeded];
        }];
        
        [self renewTheView];
        
    }else{

        
        EQRClassPickerVC* classPickerVC = [[EQRClassPickerVC alloc] initWithNibName:@"EQRClassPickerVC" bundle:nil];
        
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:classPickerVC];
        [navController setNavigationBarHidden:YES];
        
        UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.myClassPicker = popOver;
        self.myClassPicker.delegate = self;
        
        //set the size
        [self.myClassPicker setPopoverContentSize:CGSizeMake(300.f, 500.f)];
        
        //convert coordinates of textField frame to self.view
        UIView* originalRect = self.navigationItem.titleView;
        CGRect step1Rect = [originalRect.superview.superview convertRect:originalRect.frame fromView:originalRect.superview];
        CGRect step2Rect = [originalRect.superview.superview.superview convertRect:step1Rect fromView:originalRect.superview.superview];
        
        
        //present the popover
        [self.myClassPicker presentPopoverFromRect:step2Rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
        
        //assign as delegate
        classPickerVC.delegate = self;
    }
    
    
    
    
}

#pragma mark - class picker 

-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem{
    
    self.filterIsOnFlag = YES;
    
    //update month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    //assign month to nav bar title
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - Filtered Results",
                                 [monthNameFormatter stringFromDate:self.dateForShow]];
    
    self.filter_classSectionKey = selectedClassItem.key_id;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainSubViewTopConstraint.constant = 50;
        
        [self.view layoutIfNeeded];
    }];
    
    [self renewTheView];
    
    //release self as delegate
    self.myClassPicker.delegate = nil;
    
    //dismiss popover
    [self.myClassPicker dismissPopoverAnimated:YES];
    self.myClassPicker = nil;
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
    EQRQuickViewPage1VCntrllr* quickViewPage1 = [[EQRQuickViewPage1VCntrllr alloc] initWithNibName:@"EQRQuickViewPage1VCntrllr" bundle:nil];
    EQRQuickViewPage2VCntrllr* quickViewPage2 = [[EQRQuickViewPage2VCntrllr alloc] initWithNibName:@"EQRQuickViewPage2VCntrllr" bundle:nil];
    EQRQuickViewPage3VCntrllr* quickViewPage3 = [[EQRQuickViewPage3VCntrllr alloc] initWithNibName:@"EQRQuickViewPage3VCntrllr" bundle:nil];
    
    self.myQuickViewScrollVCntrllr.myQuickViewPage1 = quickViewPage1;
    self.myQuickViewScrollVCntrllr.myQuickViewPage2 = quickViewPage2;
    self.myQuickViewScrollVCntrllr.myQuickViewPage3 = quickViewPage3;
    
    self.myScheduleRowQuickView = [[UIPopoverController alloc] initWithContentViewController:self.myQuickViewScrollVCntrllr];
    self.myScheduleRowQuickView.delegate = self;
    [self.myScheduleRowQuickView setPopoverContentSize:CGSizeMake(300.f, 502.f)];
    

    
    //__________****** assign userInfo dic to ivar SEEMS WEIRD but requires the dic in the showRequestEditor method *********_______
    self.temporaryDicFromNestedDayCell = [NSDictionary dictionaryWithDictionary:[note userInfo]];
    
    
    //initial setup for pages
    [quickViewPage1 initialSetupWithDic:self.temporaryDicFromNestedDayCell];
    [quickViewPage2 initialSetupWithKeyID:[self.temporaryDicFromNestedDayCell objectForKey:@"key_ID"]];
    [quickViewPage3 initialSetupWithKeyID:[self.temporaryDicFromNestedDayCell objectForKey:@"key_ID"] andUserInfoDic:self.temporaryDicFromNestedDayCell];
    
    NSValue* valueOfRect = [[note userInfo] objectForKey:@"rectOfSelectedNestedDayCell"];
    CGRect selectedRect = [valueOfRect CGRectValue];

    CGRect rect1 = [self.view convertRect:selectedRect fromView:self.mainSubView];
    
    //show popover  MUST use NOT allow using the arrow directin from below, keyboard may cover the textview
    [self.myScheduleRowQuickView presentPopoverFromRect:rect1 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionDown animated:YES];
    
    //attach page 1 & 2
    [self.myQuickViewScrollVCntrllr.myContentPage1 addSubview:quickViewPage1.view];
    [self.myQuickViewScrollVCntrllr.myContentPage2 addSubview:quickViewPage2.view];
    [self.myQuickViewScrollVCntrllr.myContentPage3 addSubview:quickViewPage3.view];
    
    
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
    
    
    //_____presenting the popover must be delayed (why?????)
    [self performSelector:@selector(mustDelayThePresentationOfAPopOver:) withObject:[note userInfo] afterDelay:0.1];
    
}


-(void)mustDelayThePresentationOfAPopOver:(NSDictionary*)userInfo{
    
    //it just doesn't work without a delay
    
    //assign target of popover's "edit request" button
    [self.myQuickViewScrollVCntrllr.editRequestButton addTarget:self action:@selector(showRequestEditorFromQuickView:)  forControlEvents:UIControlEventTouchUpInside];
    
    
    
}


-(void) showRequestEditor:(NSNotification*)note{
    
    //dismiss any popovers that may exist (ie the quickview when "duplicate" is tapped)
    [self.myScheduleRowQuickView dismissPopoverAnimated:YES];
    self.myScheduleRowQuickView = nil;
    
    
   
    
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
    self.myScheduleRowQuickView = nil;
    
    EQREditorTopVCntrllr* editorViewController = [[EQREditorTopVCntrllr alloc] initWithNibName:@"EQREditorTopVCntrllr" bundle:nil];
    
    //prevent edges from extending beneath nav and tab bars
    editorViewController.edgesForExtendedLayout = UIRectEdgeTop;
    
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

        
        
        [self.mainSubView addSubview:self.movingNestedCellView];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged){
        
        //get the y value
        CGPoint thisPoint = [gesture locationInView:self.mainSubView];
        
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
        
        //144 is the distance between the collectionView and the top of the view  //80 is original value
        //must also add in the collection view offset
        //______!!!!!!  need to add in the added distance of the VC prompt with in demo mode   !!!!_______
        int addedYValueForPromptInNavItem = 0;
//        if ([[EQRModeManager sharedInstance] isInDemoMode]){
//            addedYValueForPromptInNavItem = 30;
//        }
//        if (self.filterIsOnFlag == YES){
//            addedYValueForPromptInNavItem = addedYValueForPromptInNavItem - self.mainSubViewTopConstraint.constant;
//        }
        
        CGPoint offsetPoint = self.myMasterScheduleCollectionView.contentOffset;
        int newRowInt = (((thatPoint.y - 80) + offsetPoint.y) - addedYValueForPromptInNavItem) / EQRScheduleItemHeightForDay;
        
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
                    
                }else{  //titleKey remains the same
                    
                    //alert if selected an item that has serious service issues
                    if ([[(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] status_level] integerValue] >= EQRThresholdForSeriousIssue){
                        
                        //save joinkey and indexpath to use in alert delegate method
                        self.thisTempJoinKey = joinKey_id;
                        self.thisTempIndexPath = indexPathForRowCell;
                        self.thisTempNewRowInt = newRowInt;
                        
                        //landed on item that has serious service issues
                        UIAlertView* issueAlertView = [[UIAlertView alloc] initWithTitle:@"Equipment Down" message:@"You have selected an item that is not available or non-functioning properly" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Continue", nil];
                        
                        [issueAlertView show];
                        
                    }else{  //continue as planned
                        
                        // Now update the equipUnique and equipTitle values
                        equipUniqueItem_foreignKey = [(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] key_id];
                        
                        thisJoin.equipUniqueItem_foreignKey = equipUniqueItem_foreignKey;
                        thisJoin.equipTitleItem_foreignKey = equipTitleItem_foreignKey;
                        
                        //Then reload the collection views in the former and new rowCells
                        [self.myMasterScheduleCollectionView reloadData];
                        
                        // WebData query to change equipKeyID on schedule_equip_join (or delete previous and create a new one)
                        NSArray* topArray = @[ @[@"equipUniqueItem_foreignKey", equipUniqueItem_foreignKey],
                                               @[@"equipTitleItem_foreignKey", equipTitleItem_foreignKey],
                                               @[@"key_id", joinKey_id] ];
                        
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0u);
                        dispatch_async(queue, ^{
                            EQRWebData* webData = [EQRWebData sharedInstance];
                            [webData queryForStringwithAsync:@"EQAlterScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnString) {
                                if (!returnString){
                                    NSLog(@"EQRScheduleTopVC > longPressMoveNestedDayCell, faile to alter schedule equip join");
                                }
                            }];
                        });
                        
                        [self.movingNestedCellView removeFromSuperview];
                    }
                }
            }
        }
    }
    
    if ((gesture.state == UIGestureRecognizerStateCancelled) || (gesture.state ==UIGestureRecognizerStateFailed)){
        
        
    }
}


#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    // Continue button tapped, continue with change
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
                
                // WebData query to change equipKeyID on schedule_equip_join (or delete previous and create a new one)
                NSArray* topArray = @[ @[@"equipUniqueItem_foreignKey", equipUniqueItem_foreignKey],
                                       @[@"equipTitleItem_foreignKey", equipTitleItem_foreignKey],
                                       @[@"key_id", joinKey_id] ];
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0u);
                dispatch_async(queue, ^{
                    EQRWebData* webData = [EQRWebData sharedInstance];
                    [webData queryForStringwithAsync:@"EQAlterScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnString) {
                        if (!returnString){
                            NSLog(@"EQRScheduleTopVC > longPressMoveNestedDayCell, faile to alter schedule equip join");
                        }
                    }];
                });
                
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
        
    } else if (collectionView == self.myNavBarCollectionView){
        
        return [self.equipUniqueCategoriesList count];
        
    } else {  //must be self.myDateBarCollection
        
        return 31;
    }
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        return [self.equipUniqueArrayWithSections count];
        
    } else if (collectionView == self.myNavBarCollectionView){
        
        return 1;
        
    }else{   //must be self.myDateBarCollection
        
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
            
            //____!!!!!!  SEE below
            [view removeFromSuperview];
            
            //also remove notifications
            [[NSNotificationCenter defaultCenter] removeObserver:cell];
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
        
        //_____!!!!!  MAYBE instead of removing the contentViewController and reloading every time, we can just alter the
        //_____!!!!!  the contentViewController as necessary ???
        //_____!!!!! in the interest of smoother scrolling
        //add content view from xib
        EQRScheduleCellContentVCntrllr* myContentViewController = [[EQRScheduleCellContentVCntrllr alloc] initWithNibName:@"EQRScheduleCellContentVCntrllr" bundle:nil];
        
        //tell cell content view if it is in the current month
        if (self.dateForShowIsNOTCurrentMonth){
            myContentViewController.dateForShowIsCurrentMonth = NO;
        }else{
            myContentViewController.dateForShowIsCurrentMonth = YES;
        }
        
        //assign to cell's ivar
        cell.cellContentVC = myContentViewController;
        //add subview
        [cell.contentView addSubview:myContentViewController.view];
        //move to rear
        [cell.contentView sendSubviewToBack:myContentViewController.view];
        
        //define if narrow or not
        [cell signalToAssignNarrow];
        
        //change label AFTER adding it to the view else defaults to XIB file
        myContentViewController.myRowLabel.text = myTitleString;
        
        //offset week vertical line indicators
        myContentViewController.weekIndicatorOffset = self.weekIndicatorOffset;
        UIInterfaceOrientation orientationOnLaunch = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientationOnLaunch)) {
            myContentViewController.weeksLeadingConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel+(EQRScheduleItemWidthForDayNarrow * self.weekIndicatorOffset);
        }else{
            myContentViewController.weeksLeadingConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel + (EQRScheduleItemWidthForDay * self.weekIndicatorOffset);
        }
        
        //determine if service issues should be visible or hidden (default hidden)
        //does a servcie issue exist?
        NSString* issue_short_name = [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] issue_short_name];
        
        NSString* statusLevel = [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] status_level];
        NSInteger statusLevelInt = [statusLevel integerValue];
        
        if ([issue_short_name isEqualToString:@""]){
            
            //no issues, hide button
            myContentViewController.serviceIssuesButton.hidden = YES;
            
        } else if(statusLevelInt < EQRThresholdForDescriptiveNote){   //service issue exists but it is resolved, so don't show
            
            myContentViewController.serviceIssuesButton.hidden = YES;
            
        }else{
            
            //show issue button
            myContentViewController.serviceIssuesButton.hidden = NO;
            [myContentViewController.serviceIssuesButton setTitle:issue_short_name forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
            
            //set color of button
            EQRColors* colors = [EQRColors sharedInstance];
            
            if (statusLevelInt >= EQRThresholdForSeriousIssue){  //outstanding issue that should prevent selection
                
                [myContentViewController.serviceIssuesButton setTitleColor:[colors.colorDic objectForKey:EQRColorIssueSerious] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
                
                //change background color
                cell.backgroundColor = [UIColor lightGrayColor];
                
            }else if((statusLevelInt >= EQRThresholdForMinorIssue) && (statusLevelInt < EQRThresholdForSeriousIssue)){  //equip is flawed but functional
                
                [myContentViewController.serviceIssuesButton setTitleColor:[colors.colorDic objectForKey:EQRColorIssueMinor] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
            }else{
                
                [myContentViewController.serviceIssuesButton setTitleColor:[colors.colorDic objectForKey:EQRColorIssueDescriptive] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
            }
        }
        
        //text label on issue button must be altered for two lines
        myContentViewController.serviceIssuesButton.titleLabel.numberOfLines = 2;
        myContentViewController.serviceIssuesButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        
        return cell;
        
    } else if (collectionView == self.myNavBarCollectionView){
        
        //FOR Nav Bar
        EQRScheduleNavBarCell* cell2 = [self.myNavBarCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        for (UIView* view in cell2.contentView.subviews){
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell2.backgroundColor = [UIColor whiteColor];
        
        [cell2 initialSetupWithTitle:(NSString*)[self.equipUniqueCategoriesList objectAtIndex:indexPath.row]];

        //modify the background color to have alternate colors in rows
        if (indexPath.row % 2){
            //odd
            cell2.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
        }
        
        return cell2;
        
    }else{  //must be self.myDateBarCollection
        
        static NSString* CellIdentifier = @"CellForDateBar";
        EQRScheduleNestedDateBarCell* cell = [self.myDateBarCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        for (UIView* view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        
        NSString *stringFromDate = [EQRDataStructure dateAsStringSansTime:self.dateForShow];
        NSString *stringDateDayRemoved = [stringFromDate substringToIndex:7];
        NSNumber *dayIndexAsNumber = [NSNumber numberWithLong:(indexPath.row + 1)];
        NSString *revisedStringDate = [NSString stringWithFormat:@"%@-%@", stringDateDayRemoved, dayIndexAsNumber];
        NSDate *thisDate = [EQRDataStructure dateWithoutTimeFromString:revisedStringDate];
        
        NSDateFormatter* dayOFWeekAsLetter = [[NSDateFormatter alloc] init];
        [dayOFWeekAsLetter setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        dayOFWeekAsLetter.dateFormat = @"EEEEE";
        
        NSDateFormatter* dayOfWeekAsNumber = [[NSDateFormatter alloc] init];
        [dayOfWeekAsNumber setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        dayOfWeekAsNumber.dateFormat = @"EEEE";
        
        NSString* letterString = [dayOFWeekAsLetter stringFromDate:thisDate];
        NSString* numberString = [dayOfWeekAsNumber stringFromDate:thisDate];
        
        if ([numberString isEqualToString:@"Tuesday"]){
            letterString = @"Tu";
        }
        if ([numberString isEqualToString:@"Thursday"]){
            letterString = @"Th";
        }
        if ([numberString isEqualToString:@"Saturday"]){
            letterString = @"Sa";
        }
        if ([numberString isEqualToString:@"Sunday"]){
            letterString = @"Su";
        }
        
        NSString *dateString = [NSString stringWithFormat:@"%ld", (NSInteger)indexPath.row + 1];
        
        //delete the datestring if the month doesn't extend that far
        if (!letterString){
            dateString = @"";
        }
        
        [cell initialSetupWithDate:dateString DayOfWeek:letterString];
        
        return cell;
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
        [cell initialSetupWithTitle:thisTitleString isHidden:iAmHidden isSearchResult:NO];
        
        
        
    } else if (collectionView == self.myNavBarCollectionView){
        
        //no action necessary
        
    }else{  //must be self.myDateBarCollection
        
        //no action necessary
    }
    
    return cell;
}



#pragma mark - change in orientation methods


//!!!!_______       THESE METHODS ARE DEPRECATED IN IOS 8!!!  _______________
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
        
    //inform schedulecellcontentVcntrllrs about change in orientation
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:toInterfaceOrientation] forKey:@"orientation"];
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshViewWhenOrientationRotates object:nil userInfo:dic];
    
    //update navBarDates view
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)){
        
        self.navBarDates.isNarrowFlag = YES;
        self.navBarWeeks.isNarrowFlag = YES;
        self.navBarDates.alpha = 0.5;
        self.navBarWeeks.alpha = 0.5;
        
        self.navWeeksConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel+(EQRScheduleItemWidthForDayNarrow * self.weekIndicatorOffset);
        
        [self.navBarDates setNeedsDisplay];
        [self.navBarWeeks setNeedsDisplay];
        
    }else{
        
        self.navBarDates.isNarrowFlag = NO;
        self.navBarWeeks.isNarrowFlag = NO;
        self.navBarDates.alpha = 1.0;
        self.navBarWeeks.alpha = 1.0;
        
        self.navWeeksConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel+(EQRScheduleItemWidthForDay * self.weekIndicatorOffset);
        
        [self.navBarDates setNeedsDisplay];
        [self.navBarWeeks setNeedsDisplay];
    }
    
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self.myMasterScheduleCollectionView performBatchUpdates:nil completion:nil];
    [self.myNavBarCollectionView performBatchUpdates:nil completion:nil];
    [self.myDateBarCollection performBatchUpdates:nil completion:nil];

    //enumerate through visible cells and invalidate the layout to force the update of nested cells
    [[self.myMasterScheduleCollectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        [[[(EQRScheduleRowCell*)obj myUniqueItemCollectionView] collectionViewLayout] invalidateLayout];
    }];

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark - collection view delegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        //no action necessary
        
    } else if (collectionView == self.myNavBarCollectionView){
        
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        //_____********  must close any currently open sections first, then open the selected one  ********____
        
        //update request Manager to do the action and keep persistence
        [requestManager collapseOrExpandSectionInSchedule:[self.equipUniqueCategoriesList objectAtIndex:indexPath.row]];
        
    }else{  //must be self.myDateBarCollection
        
        
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
        
    } else if (collectionView == self.myNavBarCollectionView){
        
        //for NAV BAR
        //size of cell is based available length of collectoin view divided by count in array,
        
        float widthOfMe;
        
        UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
            
            widthOfMe = 768.f / [self.equipUniqueCategoriesList count];
            
        }else{
            
            widthOfMe = 1024.f / [self.equipUniqueCategoriesList count];

        }
        
        return CGSizeMake(widthOfMe, 50);
        
    }else{   //must be self.myNavBarCollection
        
        //_____doesn't use flow layout so this doesn't get called??? maybe...
        return CGSizeMake(0, 0);
    }
}


#pragma mark - EQRWebData Delegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized
    if (![self respondsToSelector:action]){
        NSLog(@"cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
    //test if filter is on, act accordingly???

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


#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    if (popoverController == self.myDayDatePicker){
        
        self.myDayDatePicker = nil;
        
    }else if (popoverController == self.myStaffUserPicker){
        
        self.myStaffUserPicker = nil;
        
    }else if (popoverController == self.myScheduleRowQuickView){
        
        self.myScheduleRowQuickView = nil;
        
    }else if (popoverController == self.myClassPicker){
        
        self.myClassPicker = nil;
    }
}

#pragma mark - view disappear

- (void)viewWillDisappear:(BOOL)animated{
    
    //___!!!!  stop the async data loading...
    [self.myWebData stopXMLParsing];
    
    //tell view to reload if it aborts loading
    if (self.isLoadingEquipDataFlag){
        self.aChangeWasMade = YES;
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - memory warning


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma clang diagnostic pop

@end
