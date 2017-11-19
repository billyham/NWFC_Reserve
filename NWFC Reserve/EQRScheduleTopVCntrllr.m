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


@interface EQRScheduleTopVCntrllr () <UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterScheduleCollectionView;
@property (strong ,nonatomic) IBOutlet UICollectionView* myNavBarCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView* myDateBarCollection;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView* myActivityIndicator;
@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@property (strong, nonatomic) IBOutlet UIView *filterBoxView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainSubViewTopConstraint;

@property (strong, nonatomic) NSArray* equipUniqueArray;
@property (strong, nonatomic) NSMutableArray* equipUniqueArrayWithSections;
// An alternate to the above array with a further nested array of sections defined by titleItems
@property (strong, nonatomic) NSMutableArray* equipUniqueArrayWithSubArraysAndSections;

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

@property (strong, nonatomic) EQRStaffUserPickerViewController *staffUserPicker;
@property (strong, nonatomic) EQRDayDatePickerVCntrllr *dayDateView;

@property (strong, nonatomic) NSDictionary* temporaryDicFromNestedDayCell;
@property (strong, nonatomic) EQRQuickViewScrollVCntrllr* myQuickViewScrollVCntrllr;

@property (strong, nonatomic) IBOutlet EQRNavBarDatesView* navBarDates;
@property (strong, nonatomic) IBOutlet EQRNavBarWeeksView *navBarWeeks;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *navWeeksConstraint;

@property NSInteger weekIndicatorOffset;
@property BOOL dateForShowIsNOTCurrentMonth;

@property (strong, nonatomic) NSString *filter_classSectionKey;
@property BOOL filterIsOnFlag;
@property BOOL isSuppressingNavBarSelection;

-(IBAction)moveToNextMonth:(id)sender;
-(IBAction)moveToPreviousMonth:(id)sender;
@end

@implementation EQRScheduleTopVCntrllr


#pragma mark - methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad {
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
//    [self.myMasterScheduleCollectionView setCollectionViewLayout:self.scheduleMasterFlowLayout];
    
    //derive the current user name
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* logText = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    
    // Custom bar buttons
    // Create uiimages
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
        
        // Indicate that the array for the NavBar categories needs to be refeshed
        [self.equipUniqueCategoriesList removeAllObjects];
        self.isSuppressingNavBarSelection = YES;
        [self renewTheView];
    }
    
    // Set the current staffUser name in nav bar
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
                
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if ([tempSet containsObject:[obj performSelector:NSSelectorFromString(EQRScheduleGrouping)]] == NO){
                    
                    [tempSet addObject:[obj performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
                    [self.equipUniqueCategoriesList addObject:[NSString stringWithString:[obj performSelector:NSSelectorFromString(EQRScheduleGrouping)]]];
                }
#pragma clang diagnostic pop
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
                
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if ([[equipItem performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:groupingItem]){
                    [subNestArray addObject: equipItem];
                }
#pragma clang diagnostic pop
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
                                     [(EQREquipUniqueItem*)obj1 short_name], newDist1];
                NSString* string2 = [NSString stringWithFormat:@"%@%@",
                                     [(EQREquipUniqueItem*)obj2 short_name], newDist2];
                
                return [string1 compare:string2];
            }];
            
            [tempSortedArrayWithSections addObject:tempSubNestArray];
        };
        
        tempUniqueArrayWithSections = tempSortedArrayWithSections;
        
        // Pick an initial tracking sheet item
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        if (([self.equipUniqueCategoriesList count] > 0) && ([requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule count] < 1)){
            dispatch_async(dispatch_get_main_queue(), ^{
                [requestManager collapseOrExpandSectionInSchedule:[self.equipUniqueCategoriesList objectAtIndex:0]];
                
                // This delay is not an ideal solution
                [self performSelector:@selector(delayedHighlight:) withObject:@{@"sectionString": [self.equipUniqueCategoriesList objectAtIndex:0]} afterDelay:0.5];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.equipUniqueArrayWithSections = [NSMutableArray arrayWithArray:tempUniqueArrayWithSections];
            
            [self.myMasterScheduleCollectionView reloadData];
            [self.myNavBarCollectionView reloadData];
            
            self.isSuppressingNavBarSelection = NO;
        });
    });
    
    // Update opacity and width of navBarDates if changing orientation
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

    // This updates placement of day and dates if orientation changed while in a different tab
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

-(void)delayedHighlight:(NSDictionary *)dict{
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRButtonHighlight object:nil userInfo:dict];
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
    self.staffUserPicker = staffUserPicker;
    
    staffUserPicker.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [staffUserPicker popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popover.barButtonItem = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
    
    [self presentViewController:staffUserPicker animated:YES completion:^{ }];
    
    // Set target of continue button
    [staffUserPicker.continueButton addTarget:self action:@selector(dismissStaffUserPicker) forControlEvents:UIControlEventTouchUpInside];
}


- (void)dismissStaffUserPicker{
    
    // Do stuff with the iboutlet of the
    int selectedRow = (int)[self.staffUserPicker.myPicker selectedRowInComponent:0];
    
    // Assign contact name object to shared staffUserManager
    EQRContactNameItem* selectedNameObject = (EQRContactNameItem*)[self.staffUserPicker.arrayOfContactObjects objectAtIndex:selectedRow];
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    staffUserManager.currentStaffUser = selectedNameObject;
    
    // Set title on bar button item
    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", selectedNameObject.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
    
    // Save as default
    NSDictionary* newDic = [NSDictionary dictionaryWithObject:selectedNameObject.key_id forKey:@"staffUserKey"];
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"staffUserKey"];
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


-(void)showDatePicker{
    
    EQRDayDatePickerVCntrllr* dayDateView = [[EQRDayDatePickerVCntrllr alloc] initWithNibName:@"EQRDayDatePickerVCntrllr" bundle:nil];
    self.dayDateView = dayDateView;
    
    dayDateView.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [dayDateView popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popover.barButtonItem = [self.navigationItem.leftBarButtonItems objectAtIndex:1];
    
    [self presentViewController:dayDateView animated:YES completion:^{ }];
    
    // Set target of continue button
    [dayDateView.myContinueButton addTarget:self action:@selector(dismissShowDatePicker:) forControlEvents:UIControlEventTouchUpInside];
}


- (IBAction)dismissShowDatePicker:(id)sender{
    
    // Cancel any existing web data parsing
    if (self.myWebData){
        [self.myWebData stopXMLParsing];
        
        // The former Webdata object continues feeding data for a
        // fraction of a second after loading a new month,
        // falsely showing equip joins from a previous month.
        // Remedy by disconnecting the webdata's delegate
        self.myWebData.delegateDataFeed = nil;
    }
    
    //  Get date from the popover's content view controller, a public method
    self.dateForShow = [self.dayDateView retrieveSelectedDate];
    
    self.dateForShowIsNOTCurrentMonth = [self evaluateIfDateForShowIsNOTCurrentMonth];
    
    // Assign new month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    // Assign month to nav bar title
    if (self.filterIsOnFlag == NO){
        self.navigationItem.title = [monthNameFormatter stringFromDate:self.dateForShow];
    }else{
        // Assign month to nav bar title
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - Filtered Results",
                                     [monthNameFormatter stringFromDate:self.dateForShow]];
    }
    [self dismissViewControllerAnimated:YES completion:^{ }];
    [self renewTheView];
    // Reload dates
    [self.myDateBarCollection reloadData];
}


- (void)filterResults{
    if (self.filterIsOnFlag == YES){
        self.filterIsOnFlag = NO;
        self.filter_classSectionKey = nil;
        
        // Update month label
        NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
        monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        monthNameFormatter.dateFormat =@"MMMM yyyy";
        
        // Assign month to nav bar title
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
        
        navController.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popover = [navController popoverPresentationController];
        popover.permittedArrowDirections = UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight | UIPopoverArrowDirectionUp;
        popover.barButtonItem = [self.navigationItem.leftBarButtonItems objectAtIndex:9];
        
        [self presentViewController:navController animated:YES completion:^{ }];
        
        classPickerVC.delegate = self;
    }
}


#pragma mark - class picker 
- (void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem{
    
    self.filterIsOnFlag = YES;
    
    // Update month label
    NSDateFormatter* monthNameFormatter = [[NSDateFormatter alloc] init];
    monthNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    monthNameFormatter.dateFormat =@"MMMM yyyy";
    
    // Assign month to nav bar title
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - Filtered Results",
                                 [monthNameFormatter stringFromDate:self.dateForShow]];
    
    self.filter_classSectionKey = selectedClassItem.key_id;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainSubViewTopConstraint.constant = 50;
        [self.view layoutIfNeeded];
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
    [self renewTheView];
}


#pragma mark - notifications
- (void)refreshTable:(NSNotification*)note{
    
    // Don't use animations when data is loading or it will crash
    if (self.isLoadingEquipDataFlag){
        [self.myMasterScheduleCollectionView reloadData];
    }else {
        NSString* typeOfChange = [[note userInfo] objectForKey:@"type"];
        NSString* sectionString = [[note userInfo] objectForKey:@"sectionString"];
        
        // Array of index paths to add or delete
        NSMutableArray* arrayOfIndexPaths = [NSMutableArray arrayWithCapacity:1];
        int indexPathToDelete;
        
        // Test whether inserting or deleting
        if ([typeOfChange isEqualToString:@"insert"]){
            
            // Loop through the sections of the equipment list to identify the index of the section
            for (NSArray* subArray in self.equipUniqueArrayWithSections){
                
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                NSString* thisIsGrouping = [(EQREquipUniqueItem*)[subArray objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)];
#pragma clang diagnostic pop
                
                if ([thisIsGrouping isEqualToString:sectionString]){
                    
                    // Found a match, remember the index
                    indexPathToDelete = (int)[self.equipUniqueArrayWithSections indexOfObject:subArray];
                    
                    // Loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
            // Do the insert
            [self.myMasterScheduleCollectionView insertItemsAtIndexPaths:arrayOfIndexPaths];
        }else if([typeOfChange isEqualToString:@"delete"]) {
            
            // Loop through the sections of the equipment list to identify the index of the section
            for (NSArray* subArray in self.equipUniqueArrayWithSections){
                
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                NSString* thisIsGrouping = [(EQREquipUniqueItem*)[subArray objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)];
#pragma clang diagnostic pop
                
                if ([thisIsGrouping isEqualToString:sectionString]){
                    
                    // Found a match, remember the index
                    indexPathToDelete = (int)[self.equipUniqueArrayWithSections indexOfObject:subArray];
                    
                    // Loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
            // Do the deletions
            [self.myMasterScheduleCollectionView deleteItemsAtIndexPaths:arrayOfIndexPaths];
        }
    }
}


- (void)raiseFlagThatAChangeHasBeenMade:(NSNotification*)note{
    self.aChangeWasMade = YES;
}


- (void)showScheduleRowQuickView:(NSNotification*)note{
    // Create quickview scroll view
    EQRQuickViewScrollVCntrllr* quickView = [[EQRQuickViewScrollVCntrllr alloc] initWithNibName:@"EQRQuickViewScrollVCntrllr" bundle:nil];
    self.myQuickViewScrollVCntrllr = quickView;
    
    // Instatiate first page subview
    EQRQuickViewPage1VCntrllr* quickViewPage1 = [[EQRQuickViewPage1VCntrllr alloc] initWithNibName:@"EQRQuickViewPage1VCntrllr" bundle:nil];
    EQRQuickViewPage2VCntrllr* quickViewPage2 = [[EQRQuickViewPage2VCntrllr alloc] initWithNibName:@"EQRQuickViewPage2VCntrllr" bundle:nil];
    EQRQuickViewPage3VCntrllr* quickViewPage3 = [[EQRQuickViewPage3VCntrllr alloc] initWithNibName:@"EQRQuickViewPage3VCntrllr" bundle:nil];
    
    self.myQuickViewScrollVCntrllr.myQuickViewPage1 = quickViewPage1;
    self.myQuickViewScrollVCntrllr.myQuickViewPage2 = quickViewPage2;
    self.myQuickViewScrollVCntrllr.myQuickViewPage3 = quickViewPage3;
    
    //  Assign userInfo dic to ivar SEEMS WEIRD but requires the dic in the showRequestEditor method
    self.temporaryDicFromNestedDayCell = [NSDictionary dictionaryWithDictionary:[note userInfo]];
    
    //initial setup for pages
    [quickViewPage1 initialSetupWithDic:self.temporaryDicFromNestedDayCell];
    [quickViewPage2 initialSetupWithKeyID:[self.temporaryDicFromNestedDayCell objectForKey:@"key_ID"]];
    [quickViewPage3 initialSetupWithKeyID:[self.temporaryDicFromNestedDayCell objectForKey:@"key_ID"] andUserInfoDic:self.temporaryDicFromNestedDayCell];
    
    NSValue* valueOfRect = [[note userInfo] objectForKey:@"rectOfSelectedNestedDayCell"];
    CGRect selectedRect = [valueOfRect CGRectValue];
    CGRect rect1 = [self.view convertRect:selectedRect fromView:self.mainSubView];
    
    self.myQuickViewScrollVCntrllr.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [self.myQuickViewScrollVCntrllr popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionDown;
    popover.sourceRect = rect1;
    popover.sourceView = self.view;
    
    self.myQuickViewScrollVCntrllr.preferredContentSize = CGSizeMake(300.f, 502.f);
    
    [self presentViewController:self.myQuickViewScrollVCntrllr animated:YES completion:^{
        [self.myQuickViewScrollVCntrllr.editRequestButton addTarget:self action:@selector(showRequestEditorFromQuickView:)  forControlEvents:UIControlEventTouchUpInside];
    }];
    
    // Attach page 1 & 2
    [self.myQuickViewScrollVCntrllr.myContentPage1 addSubview:quickViewPage1.view];
    [self.myQuickViewScrollVCntrllr.myContentPage2 addSubview:quickViewPage2.view];
    [self.myQuickViewScrollVCntrllr.myContentPage3 addSubview:quickViewPage3.view];
    
    
    // Add gesture recognizers
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


- (void)showRequestEditor:(NSNotification*)note{
    
    // Dismiss the Quickview popover that exists
    [self dismissViewControllerAnimated:YES completion:^{
        EQREditorTopVCntrllr* editorViewController = [[EQREditorTopVCntrllr alloc] initWithNibName:@"EQREditorTopVCntrllr" bundle:nil];
        
        // Prevent edges from extending beneath nav and tab bars
        editorViewController.edgesForExtendedLayout = UIRectEdgeNone;
        
        // Initial setup
        [editorViewController initialSetupWithInfo:[NSDictionary dictionaryWithDictionary:note.userInfo]];
        
        // Assign editor's keyID property
        //    editorViewController.scheduleRequestKeyID = [note.userInfo objectForKey:@"keyID"];
        
        // Modal pops up from below, removes navigiation controller
        UINavigationController* newNavController = [[UINavigationController alloc] initWithRootViewController:editorViewController];
        
        [self presentViewController:newNavController animated:YES completion:^{  }];
    }];
}


- (IBAction)showRequestEditorFromQuickView:(id)sender{
    
    // Dismiss the quickView popover
    [self dismissViewControllerAnimated:YES completion:^{
        EQREditorTopVCntrllr* editorViewController = [[EQREditorTopVCntrllr alloc] initWithNibName:@"EQREditorTopVCntrllr" bundle:nil];
        
        // Prevent edges from extending beneath nav and tab bars
        editorViewController.edgesForExtendedLayout = UIRectEdgeTop;
        
        // Initial setup
        [editorViewController initialSetupWithInfo:self.temporaryDicFromNestedDayCell];;
        
        // Assign editor's keyID property
        //editorViewController.scheduleRequestKeyID = [note.userInfo objectForKey:@"keyID"];
        
        // Modal pops up from below, removes navigiation controller
        UINavigationController* newNavController = [[UINavigationController alloc] initWithRootViewController:editorViewController];
        
        [self presentViewController:newNavController animated:YES completion:^{ }];
    }];
}


#pragma mark - handle movement of nested day cells
- (void)longPressMoveNestedDayCell:(NSNotification*)note{
    
    UIGestureRecognizer* gesture = [[note userInfo] objectForKey:@"gesture"];
    CGRect frameSize = [[[note userInfo] objectForKey:@"frameSizeValue"] CGRectValue];
    NSString* joinKey_id = [[note userInfo] objectForKey:@"key_id"];
    NSString* joinTitleKey_id = [[note userInfo] objectForKey:@"equipTitleItem_foreignKey"];
    NSIndexPath* indexPathForRowCell = [[note userInfo] objectForKey:@"indexPath"];
    UIColor* myCellColor = [[note userInfo] objectForKey:@"color"];
    
    if (gesture.state == UIGestureRecognizerStateBegan){
        
        self.movingNestedCellView = [[UIView alloc] initWithFrame:frameSize];
        self.movingNestedCellView.backgroundColor = myCellColor;
        
        // Expand the rect itself to new size
        [UIView animateWithDuration:0.25 animations:^{
            self.movingNestedCellView.frame = CGRectMake(frameSize.origin.x - 20, frameSize.origin.y - 10, frameSize.size.width + 40, frameSize.size.height + 20);
            self.movingNestedCellView.layer.cornerRadius = 5;
        }];

        [self.mainSubView addSubview:self.movingNestedCellView];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged){
        
        // Get the y value
        CGPoint thisPoint = [gesture locationInView:self.mainSubView];
        
        // Add 15 pts becasue origin is about the touch... plus a little sumptin' sumptin'
        float valueWithHalfHeight = thisPoint.y + (EQRScheduleItemHeightForDay * 0.5) + 10;
        
        // Move only in increments equal to the cell height
        valueWithHalfHeight = valueWithHalfHeight / EQRScheduleItemHeightForDay;
        int newValueInt = valueWithHalfHeight;
        float newValueExpanded = newValueInt * EQRScheduleItemHeightForDay;
        
        // Add in the scroll view offset from the collection view
        CGPoint scrollViewOffsetPoint = self.myMasterScheduleCollectionView.contentOffset;
        float scrollViewOffsetY = (int)scrollViewOffsetPoint.y % (int)EQRScheduleItemHeightForDay;
        newValueExpanded = newValueExpanded - scrollViewOffsetY;
        
        // Subtract a further 10pnts to get the coordinates for the view to sync with our increment (based on origin of the collection view)
        newValueExpanded = newValueExpanded - 10;
        

        // Add back into it, the resize adjustment
        newValueExpanded = newValueExpanded - 10;
        
        // Create modified rect with new y value...
        CGRect thisRect = CGRectMake(self.movingNestedCellView.frame.origin.x, newValueExpanded, self.movingNestedCellView.frame.size.width, self.movingNestedCellView.frame.size.height);
        
        // Assign to moving cell ivar
        self.movingNestedCellView.frame = thisRect;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        NSString* equipUniqueItem_foreignKey;
        NSString* equipTitleItem_foreignKey;
        
        // Change equipKeyID on requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        // Use the touch location to derive the target equipItem from the self.equipUniqueArrayWithSections ivar
        // We know the section from the supplied indexPath...
        // Use the center of the moving nested cell view
        CGPoint thatPoint = self.movingNestedCellView.center;
        
        // 144 is the distance between the collectionView and the top of the view  //80 is original value
        // Must also add in the collection view offset
        //______!!!!!!  need to add in the added distance of the VC prompt with in demo mode   !!!!_______
        int addedYValueForPromptInNavItem = 0;
        
        CGPoint offsetPoint = self.myMasterScheduleCollectionView.contentOffset;
        int newRowInt = (((thatPoint.y - 80) + offsetPoint.y) - addedYValueForPromptInNavItem) / EQRScheduleItemHeightForDay;
        
        for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins){
            
            if ([thisJoin.key_id isEqualToString:joinKey_id]){
                
                equipTitleItem_foreignKey =[(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] equipTitleItem_foreignKey];
                
                // If titleKey doesn't match the original title key,
                // then pause and give warning in an alert view
                if (![equipTitleItem_foreignKey isEqualToString:joinTitleKey_id]){
                    
                    // Save joinkey and indexpath to use in alert delegate method
                    self.thisTempJoinKey = joinKey_id;
                    self.thisTempIndexPath = indexPathForRowCell;
                    self.thisTempNewRowInt = newRowInt;
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Equipment" message:@"You have selected a different type of equipment" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *alertContinue = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self continueLongPressMove];
                    }];
                    
                    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [self cancelLongPressAction];
                    }];
                    
                    [alert addAction:alertContinue];
                    [alert addAction:alertCancel];
                    [self presentViewController:alert animated:YES completion:^{ }];
                    
                }else{  // TitleKey remains the same
                    
                    // Alert if selected an item that has serious service issues
                    if ([[(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] status_level] integerValue] >= EQRThresholdForSeriousIssue){
                        
                        // Save joinkey and indexpath to use in alert delegate method
                        self.thisTempJoinKey = joinKey_id;
                        self.thisTempIndexPath = indexPathForRowCell;
                        self.thisTempNewRowInt = newRowInt;
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Equipment Down" message:@"You have selected an item that is not available or not functioning properly" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *alertContinue = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self continueLongPressMove];
                        }];
                        
                        UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [self cancelLongPressAction];
                        }];
                        
                        [alert addAction:alertContinue];
                        [alert addAction:alertCancel];
                        [self presentViewController:alert animated:YES completion:^{  }];
                        
                    }else{  // Continue as planned
                        
                        // Now update the equipUnique and equipTitle values
                        equipUniqueItem_foreignKey = [(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] key_id];
                        
                        thisJoin.equipUniqueItem_foreignKey = equipUniqueItem_foreignKey;
                        thisJoin.equipTitleItem_foreignKey = equipTitleItem_foreignKey;
                        
                        // Then reload the collection views in the former and new rowCells
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
- (void)continueLongPressMove {
    
    NSString* joinKey_id = self.thisTempJoinKey;
    NSIndexPath* indexPathForRowCell = self.thisTempIndexPath;
    int newRowInt = (int)self.thisTempNewRowInt;
    NSString* equipUniqueItem_foreignKey;
    NSString* equipTitleItem_foreignKey;
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins){
        
        if ([thisJoin.key_id isEqualToString:joinKey_id]){
            
            // Now update the equipUnique and equipTitle values
            equipUniqueItem_foreignKey = [(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] key_id];
            
            thisJoin.equipUniqueItem_foreignKey = equipUniqueItem_foreignKey;
            
            equipTitleItem_foreignKey =[(EQREquipUniqueItem*)[[self.equipUniqueArrayWithSections objectAtIndex:indexPathForRowCell.section] objectAtIndex:newRowInt] equipTitleItem_foreignKey];
            
            thisJoin.equipTitleItem_foreignKey = equipTitleItem_foreignKey;
            
            // Then reload the collection views in the former and new rowCells
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

- (void)cancelLongPressAction {
    [self.movingNestedCellView removeFromSuperview];
    // Make original cell visible again
    [self.myMasterScheduleCollectionView reloadData];
}


#pragma mark - collection view data source methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //Decide which collection should be affected
    if (collectionView == self.myMasterScheduleCollectionView){
        if ([self.equipUniqueArrayWithSections count] <= section){
            return 0;
        }
        if ([(NSArray *)[self.equipUniqueArrayWithSections objectAtIndex:section] count] == 0){
            return 0;
        }
        // Test if this section is flagged to be collapsed
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        EQREquipUniqueItem* sampleItem = [[self.equipUniqueArrayWithSections objectAtIndex:section] objectAtIndex:0];
        // Loop through array of hidden sections
        for (NSString* objectSection in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
            
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([[sampleItem performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:objectSection]){
                return [(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:section] count];
            }
#pragma clang diagnostic pop
        }
        // Otherwise...
        return 0;
    } else if (collectionView == self.myNavBarCollectionView){
        return [self.equipUniqueCategoriesList count];
    } else {  // Must be self.myDateBarCollection
        return 31;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    // Decide which collection should be affected
    if (collectionView == self.myMasterScheduleCollectionView){
        return [self.equipUniqueArrayWithSections count];
    } else if (collectionView == self.myNavBarCollectionView){
        return 1;
    }else{   // Must be self.myDateBarCollection
        return 1;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* CellIdentifier = @"Cell";
    // Decide which collection should be affected
    if (collectionView == self.myMasterScheduleCollectionView){
        
        // For Row Cell
        EQRScheduleRowCell* cell = [self.myMasterScheduleCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        for (UIView* view in cell.contentView.subviews){
            
            //____!!!!!!  SEE below
            [view removeFromSuperview];
            
            // Also remove notifications
            [[NSNotificationCenter defaultCenter] removeObserver:cell];
        }
        
        // And reset the cell's background color...
        cell.backgroundColor = [UIColor whiteColor];
        
        // Get the item name and distinquishing ID from the nested array
        NSString* myTitleString = [NSString stringWithFormat:@"%@  #%@",
                                   [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] short_name],
                                   [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] distinquishing_id]];
        
        [cell initialSetupWithTitle:myTitleString equipKey:[(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id] indexPath:indexPath dateForShow:self.dateForShow];
        
        // Modify the background color to have alternate colors in rows
        if (indexPath.row % 2){
            //odd
            EQRColors* myColors = [EQRColors sharedInstance];
            cell.backgroundColor = [[myColors colorDic] objectForKey:EQRColorVeryLightGrey];;
        }
        
        //_____!!!!!  MAYBE instead of removing the contentViewController and reloading every time, we can just alter the
        //_____!!!!!  the contentViewController as necessary ???
        //_____!!!!! in the interest of smoother scrolling
        // Add content view from xib
        EQRScheduleCellContentVCntrllr* myContentViewController = [[EQRScheduleCellContentVCntrllr alloc] initWithNibName:@"EQRScheduleCellContentVCntrllr" bundle:nil];
        
        // Tell cell content view if it is in the current month
        if (self.dateForShowIsNOTCurrentMonth){
            myContentViewController.dateForShowIsCurrentMonth = NO;
        }else{
            myContentViewController.dateForShowIsCurrentMonth = YES;
        }
        
        // Assign to cell's ivar
        cell.cellContentVC = myContentViewController;
        //add subview
        [cell.contentView addSubview:myContentViewController.view];
        // Move to rear
        [cell.contentView sendSubviewToBack:myContentViewController.view];
        
        // Define if narrow or not
        [cell signalToAssignNarrow];
        
        // Change label AFTER adding it to the view else defaults to XIB file
        myContentViewController.myRowLabel.text = myTitleString;
        
        // Offset week vertical line indicators
        myContentViewController.weekIndicatorOffset = self.weekIndicatorOffset;
        UIInterfaceOrientation orientationOnLaunch = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientationOnLaunch)) {
            myContentViewController.weeksLeadingConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel+(EQRScheduleItemWidthForDayNarrow * self.weekIndicatorOffset);
        }else{
            myContentViewController.weeksLeadingConstraint.constant = EQRScheduleLengthOfEquipUniqueLabel + (EQRScheduleItemWidthForDay * self.weekIndicatorOffset);
        }
        
        // Determine if service issues should be visible or hidden (default hidden)
        // Does a servcie issue exist?
        NSString* issue_short_name = [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] issue_short_name];
        
        NSString* statusLevel = [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] status_level];
        NSInteger statusLevelInt = [statusLevel integerValue];
        
        if ([issue_short_name isEqualToString:@""]){
            
            // No issues, hide button
            myContentViewController.serviceIssuesButton.hidden = YES;
            
        } else if(statusLevelInt < EQRThresholdForDescriptiveNote){   //Service issue exists but it is resolved, so don't show
            
            myContentViewController.serviceIssuesButton.hidden = YES;
            
        }else{
            // Show issue button
            myContentViewController.serviceIssuesButton.hidden = NO;
            [myContentViewController.serviceIssuesButton setTitle:issue_short_name forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
            
            // Set color of button
            EQRColors* colors = [EQRColors sharedInstance];
            
            if (statusLevelInt >= EQRThresholdForSeriousIssue){  //Outstanding issue that should prevent selection
                
                [myContentViewController.serviceIssuesButton setTitleColor:[colors.colorDic objectForKey:EQRColorIssueSerious] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
                
                // Change background color
                cell.backgroundColor = [UIColor lightGrayColor];
                
            }else if((statusLevelInt >= EQRThresholdForMinorIssue) && (statusLevelInt < EQRThresholdForSeriousIssue)){  //equip is flawed but functional
                
                [myContentViewController.serviceIssuesButton setTitleColor:[colors.colorDic objectForKey:EQRColorIssueMinor] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
            }else{
                
                [myContentViewController.serviceIssuesButton setTitleColor:[colors.colorDic objectForKey:EQRColorIssueDescriptive] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
            }
        }
        
        // Text label on issue button must be altered for two lines
        myContentViewController.serviceIssuesButton.titleLabel.numberOfLines = 2;
        myContentViewController.serviceIssuesButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        return cell;
    } else if (collectionView == self.myNavBarCollectionView){
        
        // For Nav Bar
        EQRScheduleNavBarCell* cell2 = [self.myNavBarCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        for (UIView* view in cell2.contentView.subviews){
            [view removeFromSuperview];
        }
        
        // And reset the cell's background color...
        cell2.backgroundColor = [UIColor whiteColor];
        
        [cell2 initialSetupWithTitle:(NSString*)[self.equipUniqueCategoriesList objectAtIndex:indexPath.row]];

        // Modify the background color to have alternate colors in rows
        if (indexPath.row % 2){
            //odd
            cell2.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
        }
        
        return cell2;
        
    }else{  // Must be self.myDateBarCollection
        
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
        
        NSString *dateString = [NSString stringWithFormat:@"%ld", (long)indexPath.row + (long)1];
        
        // Delete the datestring if the month doesn't extend that far
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
    
    // Remove subviews
    for (UIView* thisSubview in cell.contentView.subviews){
        [thisSubview removeFromSuperview];
    }
    
    // DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        // Test whether the section is collapsed or expanded
        BOOL iAmVisible = NO;
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
            
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([sectionString isEqualToString:[(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)]]){
                
                //found a match in the array of visible sections
                iAmVisible = YES;
                
                break;
            }
#pragma clang diagnostic pop
        }
        
        // Inverse the logic
        BOOL iAmHidden = abs(1 - iAmVisible);
        
        // Get the category or subcategory for a sample item in the nested array
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString* thisTitleString = [(EQREquipUniqueItem*)[(NSArray*)[self.equipUniqueArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] performSelector:NSSelectorFromString(EQRScheduleGrouping)];
#pragma clang diagnostic pop
        
        // Cell's initial setup method with label
        [cell initialSetupWithTitle:thisTitleString isHidden:iAmHidden isSearchResult:NO];
    } else if (collectionView == self.myNavBarCollectionView){
        // No action necessary
    }else{  // Must be self.myDateBarCollection
        // No action necessary
    }
    return cell;
}


#pragma mark - change in orientation methods
//!!!!_______       THESE METHODS ARE DEPRECATED IN IOS 8!!!  _______________
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
        
    // Inform schedulecellcontentVcntrllrs about change in orientation
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:toInterfaceOrientation] forKey:@"orientation"];
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshViewWhenOrientationRotates object:nil userInfo:dic];
    
    // Update navBarDates view
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


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self.myMasterScheduleCollectionView performBatchUpdates:nil completion:nil];
    [self.myNavBarCollectionView performBatchUpdates:nil completion:nil];
    [self.myDateBarCollection performBatchUpdates:nil completion:nil];

    // Enumerate through visible cells and invalidate the layout
    // to force the update of nested cells
    [[self.myMasterScheduleCollectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        [[[(EQRScheduleRowCell*)obj myUniqueItemCollectionView] collectionViewLayout] invalidateLayout];
    }];

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark - collection view delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED

    if (collectionView == self.myMasterScheduleCollectionView){
        //no action necessary
    } else if (collectionView == self.myNavBarCollectionView){
        if (self.isSuppressingNavBarSelection) return;
        
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        
        //_____********  must close any currently open sections first, then open the selected one  ********____
        
        // Update request Manager to do the action and keep persistence
        [requestManager collapseOrExpandSectionInSchedule:[self.equipUniqueCategoriesList objectAtIndex:indexPath.row]];
    }else{  //must be self.myDateBarCollection
    }
}

#pragma mark - collection view flow layout delegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //DECIDE WHICH COLLECTION VIEW SHOULD BE AFFECTED
    
    if (collectionView == self.myMasterScheduleCollectionView){
        
        // For EquipUnique Stuff
        //______******   a better implementation of this is here:   ******_______
        //  http://stackoverflow.com/questions/13556554/change-uicollectionviewcell-size-on-different-device-orientations
        // Uses two different flowlayout objects, one for each orientation
        
        UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
            // Set size
            return CGSizeMake(768.f, 30.f);
        }else{
            // Set size
            return CGSizeMake(1024.f, 30.f);
        }
    } else if (collectionView == self.myNavBarCollectionView){
        
        // For NAV BAR
        // Size of cell is based available length of collectoin view divided by count in array,
        
        float widthOfMe;
        UIInterfaceOrientation orientationOnLunch = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientationOnLunch)) {
            widthOfMe = 768.f / [self.equipUniqueCategoriesList count];
        }else{
            widthOfMe = 1024.f / [self.equipUniqueCategoriesList count];
        }
        return CGSizeMake(widthOfMe, 50);
    }else{   // Must be self.myNavBarCollection
        // Doesn't use flow layout so this doesn't get called??? maybe...
        return CGSizeMake(0, 0);
    }
}


#pragma mark - EQRWebData Delegate methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //a Abort if selector is unrecognized
    if (![self respondsToSelector:action]){
        NSLog(@"cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
    // Test if filter is on, act accordingly???

    // Save array to requestManager (for rowCell to access it as needed)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins];
    
    [newArray addObject:currentThing];
    
    requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins = [NSArray arrayWithArray:newArray];
    
    // Should do this only once every 1 second (with NSTimer) to prevent the 1000+ calls to reload
    // If the timer currently exists, don't do anything...
    
    if (![self.timerForReloadCollectionView isValid]){
        
        self.timerForReloadCollectionView = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerFiredReloadCollectionView) userInfo:nil repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:self.timerForReloadCollectionView forMode:NSDefaultRunLoopMode];
    }
}

-(void)timerFiredReloadCollectionView{
    [self.myMasterScheduleCollectionView reloadData];
}


#pragma mark - view disappear
- (void)viewWillDisappear:(BOOL)animated{
    
    // Stop the async data loading...
    [self.myWebData stopXMLParsing];
    
    // Tell view to reload if it aborts loading
    if (self.isLoadingEquipDataFlag){
        self.aChangeWasMade = YES;
    }
    [super viewWillDisappear:animated];
}

#pragma mark - memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
