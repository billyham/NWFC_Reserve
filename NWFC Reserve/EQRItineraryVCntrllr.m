//
//  EQRItineraryVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryVCntrllr.h"
#import "EQRItineraryRowCell.h"
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

@interface EQRItineraryVCntrllr ()

@property (strong, nonatomic) IBOutlet UICollectionView* myMasterItineraryCollection;
@property (strong ,nonatomic) IBOutlet UICollectionView* myNavBarCollectionView;

@property (strong, nonatomic) NSDate* dateForShow;

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;

@property (strong, nonatomic) NSArray* arrayOfScheduleRequests;
@property (strong, nonatomic) NSArray* filteredArrayOfScheduleRequests;

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

-(IBAction)moveToNextDay:(id)sender;
-(IBAction)moveToPreviousDay:(id)sender;

@end

@implementation EQRItineraryVCntrllr

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
    [nc addObserver:self selector:@selector(refreshTheView) name:EQRAChangeWasMadeToTheSchedule object:nil];
    //partial refresh to when a switch is thrown in the itinarary cell view
    [nc addObserver:self selector:@selector(partialRefreshToUpdateTheArrayOfRequests:) name:EQRPartialRefreshToItineraryArray object:nil];
    //receive note from cellContentView to show check in out v controllr
    [nc addObserver:self selector:@selector(showCheckInOut:) name:EQRPresentCheckInOut object:nil];
    //receive note from itinerary row to show quick view
    [nc addObserver:self selector:@selector(showQuickView:) name:EQRPresentItineraryQuickView object:nil];
    
    //register collection view cell
    [self.myMasterItineraryCollection registerClass:[EQRItineraryRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
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
    
    //array that shit
    NSArray* arrayOfLeftButtons = [NSArray arrayWithObjects:twentySpace, searchBarButton, thirtySpace, leftBarButtonArrow, thirtySpace, todayBarButton, thirtySpace, rightBarButtonArrow, nil];
    
    //set leftBarButton item on SELF
    [self.navigationItem setLeftBarButtonItems:arrayOfLeftButtons];
    
    

    
    
    
    //right button
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:logText style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
    //array that shit
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];
    
    
    //___________

    
    
    
    
    
    //instantiate private request manager
//    if (!self.privateRequestManager){
//        
//        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
//    }
//    
//    //two important methods that initiate requestManager ivar arrays
//    [self.privateRequestManager resetEquipListAndAvailableQuantites];
//    [self.privateRequestManager retrieveAllEquipUniqueItems];
    
    
    //this will load the ivar array of scheduleReqeust items based on the dateForShow ivar
    [self refreshTheView];
   
    


}


-(void)viewWillAppear:(BOOL)animated{
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    
    //set title on bar button item
    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
    
    
}


-(void)refreshTheView{
    
    //update the array first
    [self partialRefreshToUpdateTheArrayOfRequests:nil];

    
    //reload the view
    [self.myMasterItineraryCollection reloadData];
    
}


-(void)partialRefreshToUpdateTheArrayOfRequests:(NSNotification*)note{
    
    //test if a cell is now displaying a status that has been filtered out
    //change bitmask to allow for that status
    BOOL needToReloadTheView = NO;
    
    NSUInteger cellBitmaskValue = [self determineTheBitmaskFromCellInfo:[note userInfo]];
    
    if ((self.currentFilterBitmask & cellBitmaskValue) == NO){
                
        //add the value to the bitmask
        self.currentFilterBitmask = self.currentFilterBitmask | cellBitmaskValue;
        
        //update the filter button to ON
        [self updateFilterButtonDisplayWithAddedBitmask:cellBitmaskValue];
        
        
        //if all filters are added, switch 'all' on
        if (self.currentFilterBitmask == EQRFilterAll){
            
            EQRColors* sharedColors = [EQRColors sharedInstance];
            [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            
            //set all other buttons to white (off color)
            [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        //need to reload the view???
        needToReloadTheView = YES;
    }
    
    
    //empty out the existing array
    if (self.arrayOfScheduleRequests){
        
        self.arrayOfScheduleRequests = nil;
    }
    
    //put the date in timestamp format
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatForDate stringFromDate:self.dateForShow]];
    NSString* dateEndString = [NSString stringWithFormat:@"%@ 23:59:59", [dateFormatForDate stringFromDate:self.dateForShow]];
    
    //go get an array
    NSArray* firstArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
    
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    //First, add the 'going' schedule items
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetScheduleItemsWithBeginDate.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        for (id object in muteArray){
            
            NSLog(@"this is the prep date: %@", [(EQRScheduleRequestItem*)object staff_prep_date]);
            
            //adjust the begin date by adding 9 hours... or 8 hours
            float secondsForOffset = 0;    //this is 9 hours = 32400, this is 8 hours = 28800;
            NSDate* newTimeBegin = [[(EQRScheduleRequestItem*)object request_time_begin] dateByAddingTimeInterval:secondsForOffset];
            NSDate* newTimeEnd = [[(EQRScheduleRequestItem*)object request_time_end] dateByAddingTimeInterval:secondsForOffset];
            [(EQRScheduleRequestItem*)object setRequest_time_begin:newTimeBegin];
            [(EQRScheduleRequestItem*)object setRequest_time_end:newTimeEnd];
            
            [tempMuteArray addObject:object];
        }
        
    }];
    
    //Second, add the 'returning' items to the same array
    [webData queryWithLink:@"EQGetScheduleItemsWithEndDate.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        for (id object in muteArray){
            
            //adjust the date by adding 9 hours... or 8 hours
            float secondsForOffset = 0;    //this is 9 hours = 32400, this is 8 hours = 28800;
            NSDate* newTimeBegin = [[(EQRScheduleRequestItem*)object request_time_begin] dateByAddingTimeInterval:secondsForOffset];
            NSDate* newTimeEnd = [[(EQRScheduleRequestItem*)object request_time_end] dateByAddingTimeInterval:secondsForOffset];
            [(EQRScheduleRequestItem*)object setRequest_time_begin:newTimeBegin];
            [(EQRScheduleRequestItem*)object setRequest_time_end:newTimeEnd];
            
            //mark the request item as a return object
            [(EQRScheduleRequestItem*) object setMarkedForReturn:YES];
            
            [tempMuteArray addObject:object];
        }
    }];
    
    
    
    
    //sort by request date begin (...and end)
    
    NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(EQRScheduleRequestItem* obj1, EQRScheduleRequestItem* obj2) {
        
        //use either time begin or time end depending on whether this item is going or returning
        
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
    
    //assign to ivar
    self.arrayOfScheduleRequests = tempMuteArrayAlpha;
    
    //if a bitmisk filer it on, update it also
    if (self.currentFilterBitmask != EQRFilterAll){
        
        [self createTheFilteredArray:self.currentFilterBitmask];
    }
    
    if (needToReloadTheView){
        
        [self.myMasterItineraryCollection reloadData];
    }
    
}


#pragma mark - show dismiss check out in view

-(void)showCheckInOut:(NSNotification*)note{
    
    NSString* scheduleKey = [[note userInfo] objectForKey:@"scheduleKey"];
    NSNumber* marked_for_returning = [[note userInfo] objectForKey:@"marked_for_returning"];
    NSNumber* switch_num = [[note userInfo] objectForKey:@"switch_num"];
    
    
    EQRCheckVCntrllr* checkViewController = [[EQRCheckVCntrllr alloc] initWithNibName:@"EQRCheckVCntrllr" bundle:nil];
    
    //extend edges under nav and tab bar
    checkViewController.edgesForExtendedLayout = UIRectEdgeAll;
    
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:scheduleKey, @"scheduleKey",
                            marked_for_returning, @"marked_for_returning",
                            switch_num, @"switch_num",
                            nil];
    
    //initial setup
    [checkViewController initialSetupWithInfo:newDic];
    
    //model pops up from below, removes navigiation controller
    UINavigationController* newNavController = [[UINavigationController alloc] initWithRootViewController:checkViewController];
    
    [self presentViewController:newNavController animated:YES completion:^{
        
    }];
}


#pragma mark - showStaffUser view


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
    
}




#pragma mark - showQuickView

-(void)showQuickView:(NSNotification*)note{
    
    //create quickview scroll view
    EQRQuickViewScrollVCntrllr* quickView = [[EQRQuickViewScrollVCntrllr alloc] initWithNibName:@"EQRQuickViewScrollVCntrllr" bundle:nil];
    self.myQuickViewScrollVCntrllr = quickView;
    
    //instatiate first page subview
    EQRQuickViewPage1VCntrllr* quickViewPage1 = [[EQRQuickViewPage1VCntrllr alloc] initWithNibName:@"EQRScheduleRowQuickViewVCntrllr" bundle:nil];
    
    self.myQuickViewScrollVCntrllr.myScheduleRowQuickView = quickViewPage1;
    
    self.myQuickView = [[UIPopoverController alloc] initWithContentViewController:self.myQuickViewScrollVCntrllr];
    [self.myQuickView setPopoverContentSize:CGSizeMake(300.f, 502.f)];
    
    
    //empty the temp array
    if ([self.temporaryDicFromQuickView count] > 0){
        
        self.temporaryDicFromQuickView = nil;
    }
    
    EQRScheduleRequestItem* myItem;
    for (EQRScheduleRequestItem* thisItem in self.arrayOfScheduleRequests){
        
        //marked_for_returning
        BOOL marked_for_returning = [[[note userInfo] objectForKey:@"marked_for_returning"] boolValue];
        
        if (([thisItem.key_id isEqualToString:[[note userInfo] objectForKey:@"key_ID"]]) && (marked_for_returning == thisItem.markedForReturn)){
            
            myItem = thisItem;
            
            //undo the adjustment to the time difference
//            //adjust the time by adding 9 hours... or 8 hours
//            float secondsForOffset = 28800;    //this is 9 hours = 32400;
//            myItem.request_time_begin = [myItem.request_time_begin dateByAddingTimeInterval:secondsForOffset];
//            myItem.request_time_end = [myItem.request_time_end dateByAddingTimeInterval:secondsForOffset];
            
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
    

    //undo the adjustment to the time difference
    //adjust the time by adding 9 hours... or 8 hours
    float secondsForOffset = 0 * 2;    //this is 9 hours = 32400, this is 8 hour = 28800;
    [dic setValue:[myItem.request_time_begin dateByAddingTimeInterval:secondsForOffset] forKey:@"request_time_begin"];
    [dic setValue:[myItem.request_time_end dateByAddingTimeInterval:secondsForOffset] forKey:@"request_time_end"];
    
    //pass dic to ivar to use in editor request
    self.temporaryDicFromQuickView = [NSDictionary dictionaryWithDictionary:dic];
    
   
    //do the busy work of creating the popOver view
    [quickViewPage1 initialSetupWithDic:dic];
    
//    NSValue* valueOfRect = [[note userInfo] objectForKey:@"rectOfSelectedNestedDayCell"];
//    CGRect selectedRect = [valueOfRect CGRectValue];
    
    
    //assign target of popover's "edit request" button
    [self.myQuickViewScrollVCntrllr.editRequestButton addTarget:self action:@selector(showRequestEditorFromQuickView:)  forControlEvents:UIControlEventAllEvents];
    
    
    //_____presenting the popover must be delayed (why?????)
    [self performSelector:@selector(mustDelayThePresentationOfAPopOver:) withObject:[note userInfo] afterDelay:0.1];
}


-(void)mustDelayThePresentationOfAPopOver:(NSDictionary*)userInfo{
    
    NSValue* rectValue = [userInfo objectForKey:@"rectValue"];
    CGRect thisRect = [rectValue CGRectValue];
    UIView* thisView = [userInfo objectForKey:@"thisView"];
    
    
    //show popover  MUST use NOT allow using the arrow directin from below, keyboard may cover the textview
    [self.myQuickView presentPopoverFromRect:thisRect inView:thisView permittedArrowDirections:UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionDown animated:YES];
    
    //attach page 1
    [self.myQuickViewScrollVCntrllr.myContentPage1 addSubview:self.myQuickViewScrollVCntrllr.myScheduleRowQuickView.view];
    
    
    //add gesture recognizers
    UISwipeGestureRecognizer* swipeLeftGestureOnQuickview = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideLeft:)];
    swipeLeftGestureOnQuickview.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.myQuickViewScrollVCntrllr.myContentPage1 addGestureRecognizer:swipeLeftGestureOnQuickview];
    
    UISwipeGestureRecognizer* swipeRightGestureOnQuickview = [[UISwipeGestureRecognizer alloc] initWithTarget:self.myQuickViewScrollVCntrllr action:@selector(slideRight:)];
    swipeRightGestureOnQuickview.direction = UISwipeGestureRecognizerDirectionRight;
    [self.myQuickViewScrollVCntrllr.myContentPage2 addGestureRecognizer:swipeRightGestureOnQuickview];
    
}


-(IBAction)showRequestEditorFromQuickView:(id)sender{
    
    //dismiss the quickView popover
    [self.myQuickView dismissPopoverAnimated:YES];
    
    EQREditorTopVCntrllr* editorViewController = [[EQREditorTopVCntrllr alloc] initWithNibName:@"EQREditorTopVCntrllr" bundle:nil];
    
    //prevent edges from extending beneath nav and tab bars
    editorViewController.edgesForExtendedLayout = UIRectEdgeNone;
    
    //_______******* THIS IS WEIRD need to subtract a day off the the dates
    float secondsForOffset = 0 * -3;
    NSDate* newBeginDate = [[self.temporaryDicFromQuickView objectForKey:@"request_date_begin"] dateByAddingTimeInterval:secondsForOffset];
    NSDate* newEndDate = [[self.temporaryDicFromQuickView objectForKey:@"request_date_end"] dateByAddingTimeInterval:secondsForOffset];
    
    NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:self.temporaryDicFromQuickView];
    
    [newDic setValue:newBeginDate forKey:@"request_date_begin"];
    [newDic setValue:newEndDate forKey:@"reqeust_date_end"];
    
    //initial setup
    [editorViewController initialSetupWithInfo:newDic];
    
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


//-(void)dismissedCheckInOut:(NSNotification*)note{
//    
//    NSString* scheduleKey = [[note userInfo] objectForKey:@"scheduleKey"];
//    NSString* completeOrIncomplete = [[note userInfo] objectForKey:@"comleteOrIncomplete"];
//    
//    if ([completeOrIncomplete isEqualToString:@"complete"]){
//        
//        self.
//        
//    }else{
//        
//        
//    }
//}


#pragma mark - day movement

-(IBAction)moveToNextDay:(id)sender{
    
    //seconds in a day 86400
    
    self.dateForShow = [self.dateForShow dateByAddingTimeInterval:86400];
    
    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    [self refreshTheView];
    
}



-(IBAction)moveToPreviousDay:(id)sender{
    
    self.dateForShow = [self.dateForShow dateByAddingTimeInterval:-86400];
    
    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    [self refreshTheView];
    
}


-(IBAction)moveToToday:(id)sender{
    
    self.dateForShow = [NSDate date];
    
    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    [self refreshTheView];
    
}


-(void)showDatePicker{
    
    EQRDayDatePickerVCntrllr* dayDateView = [[EQRDayDatePickerVCntrllr alloc] initWithNibName:@"EQRDayDatePickerVCntrllr" bundle:nil];
    self.myDayDatePicker = [[UIPopoverController alloc] initWithContentViewController:dayDateView];
    
    //set size
    [self.myDayDatePicker setPopoverContentSize:CGSizeMake(400, 400)];
    
    //present popover
    [self.myDayDatePicker presentPopoverFromBarButtonItem:[self.navigationItem.leftBarButtonItems objectAtIndex:1]  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //set target of continue button
    [dayDateView.myContinueButton addTarget:self action:@selector(dismissShowDatePicker:) forControlEvents:UIControlEventAllEvents];
    
    
}


-(IBAction)dismissShowDatePicker:(id)sender{
    
    //get date from the popover's content view controller, a public method
    self.dateForShow = [(EQRDayDatePickerVCntrllr*)[self.myDayDatePicker contentViewController] retrieveSelectedDate];

    //update day label
    NSDateFormatter* dayNameFormatter = [[NSDateFormatter alloc] init];
    dayNameFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dayNameFormatter.dateFormat =@"EEEE, MMM d, yyyy";
    
    //assign day to nav bar title
    self.navigationItem.title = [dayNameFormatter stringFromDate:self.dateForShow];
    
    //dismiss the picker
    [self.myDayDatePicker dismissPopoverAnimated:YES];
    
    [self refreshTheView];
}



#pragma mark - filter methods


-(IBAction)dismissFilters:(id)sender{
    
    self.currentFilterBitmask = EQRFilterAll;
    
    
    
}




-(IBAction)applyFilter:(id)sender{
    
    //get the color dic
    EQRColors* sharedColors = [EQRColors sharedInstance];
    
    
    if (self.currentFilterBitmask == EQRFilterAll){
        
        self.currentFilterBitmask = EQRFilterNone;
        
    }
    
    
    if ([sender tag] > 0){
        
        //if any filter button is tapped, make sure all button is set to white
        [self.buttonAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    //add to the bitmask based on the tag of the sender button
    switch ([sender tag]) {
        case 0:
            self.currentFilterBitmask = EQRFilterAll;
            [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
            
            //set all other buttons to white (off color)
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
                
                //if it already contains this bit, then remove it
                self.currentFilterBitmask = self.currentFilterBitmask & ~EQRGoingShelf;
                [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

                
            } else {
                
                //if it doesn't contain this bit, then add it
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
    
    //if all filters removed, switch all on
    if (self.currentFilterBitmask == EQRFilterNone) {
        
        self.currentFilterBitmask = EQRFilterAll;
     
        [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
        
    }
    
    //if all filters are added, switch 'all' on
    if ((self.currentFilterBitmask == EQRFilterAll) && ([sender tag] != 0)){
        
        [self.buttonAll setTitleColor:[sharedColors.colorDic objectForKey:EQRColorFilterOn] forState:UIControlStateNormal];
        
        //set all other buttons to white (off color)
        [self.buttonGoingShelf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonGoingPrepped setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonGoingPickedUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonReturningOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonReturningReturned setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonReturningShelved setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
//    NSLog(@"this is the bitmask: %u", (int)self.currentFilterBitmask);
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
        
        //use either time begin or time end depending on whether this item is going or returning
        
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
    BOOL cellNarkedForReturning = [[cellData objectForKey:@"markedForReturning"] boolValue];
    
    NSUInteger returnValue = EQRFilterNone;
    
    if ((cellStatus == 0) && (cellNarkedForReturning == NO)){
        
        returnValue = EQRGoingShelf;
    }
    
    if ((cellStatus == 1) && (cellNarkedForReturning == NO)){
        
        returnValue = EQRGoingPrepped;
    }
    
    if ((cellStatus == 2) && (cellNarkedForReturning == NO)){
        
        returnValue = EQRGoingPickedUp;
    }
    
    if ((cellStatus == 0) && (cellNarkedForReturning == YES)){
        
        returnValue = EQRReturningOut;
    }
    
    if ((cellStatus == 1) && (cellNarkedForReturning == YES)){
        
        returnValue = EQRReturningReturned;
    }
    
    if ((cellStatus == 2) && (cellNarkedForReturning == YES)){
        
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



#pragma mark - collection view data source methods


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //first test if a filter has been applied
    if (self.currentFilterBitmask == EQRFilterAll){
        //no filter
        
        return [self.arrayOfScheduleRequests count];
        
    }else{
        //yes filter
        
        return [self.filteredArrayOfScheduleRequests count];
    }
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    
    EQRItineraryRowCell* cell = [self.myMasterItineraryCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    //and reset the cell's background color...
    cell.backgroundColor = [UIColor whiteColor];
    
    
    //test if a filter has been applied
    
    if (self.currentFilterBitmask == EQRFilterAll){
        //no filter
        
        [cell initialSetupWithRequestItem:[self.arrayOfScheduleRequests objectAtIndex:indexPath.row]];

    }else{
        //yes filter
        
        [cell initialSetupWithRequestItem:[self.filteredArrayOfScheduleRequests objectAtIndex:indexPath.row]];

    }
    
    
    
    
    
    return cell;
}





#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
