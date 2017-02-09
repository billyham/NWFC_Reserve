//
//  EQREquipSelectionGenericVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/6/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREquipSelectionGenericVCntrllr.h"
#import "EQRScheduleRequestManager.h"
//#import "EQREquipSelectionVCntrllr.h"
#import "EQRWebData.h"
#import "EQREquipItem.h"
#import "EQRScheduleRequestItem.h"
#import "EQRClassCatalog_EquipTitleItem_Join.h"
#import "EQRGlobals.h"
#import "EQREquipUniqueItem.h"
#import "EQREquipSummaryGenericVCntrllr.h"
#import "EQRHeaderCellTemplate.h"
#import "EQRModeManager.h"
#import "EQREquipOptionsTableVC.h"
#import "EQRColors.h"
#import "EQRPriceMatrixVC.h"
#import "EQRRequestWrapperPriceMatrixVC.h"
#import "EQRStaffUserManager.h"
#import "EQRMiscJoin.h"

@interface EQREquipSelectionGenericVCntrllr () <UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet UIView *dataIsLoadingView;
@property (strong, nonatomic) NSArray* equipTitleArray;
@property (strong, nonatomic) NSMutableArray* equipTitleCategoriesList;
@property (strong, nonatomic) NSMutableArray* equipTitleArrayWithSections;
@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
@property BOOL privateRequestManagerFlag;
@property (strong, nonatomic) IBOutlet UIButton* listAllEquipButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topGuideLayoutThingy;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomGuideLayoutThingy;

@property BOOL dontReloadTheViewBecauseItWillEraseSelections;


//options button
@property (strong, nonatomic) EQREquipOptionsTableVC* optionsVC;
@property (strong, nonatomic) UIPopoverController* optionsPopover;

//notes button
@property (strong, nonatomic) IBOutlet UIButton* editNotesButton;
@property (strong, nonatomic) UIPopoverController* notesPopover;

// add miscellaneous button
@property (strong, nonatomic) IBOutlet UIButton *addMiscellaneousButton;
@property (strong, nonatomic) UIPopoverController* miscPopover;

//UISearchController
@property (strong, nonatomic) IBOutlet UIView *searchBoxView;
@property (strong, nonatomic) UISearchController *mySearchController;
@property (strong, nonatomic) NSArray *searchResultArrayOfEquipTitles;
@property (strong, nonatomic) NSArray *verticalConstraintsForSearchBar;
@property (strong, nonatomic) NSArray *horizontalConstraintsForSearchBar;

@end





@implementation EQREquipSelectionGenericVCntrllr

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
    
    self.dontReloadTheViewBecauseItWillEraseSelections = NO;
    
    //________this prevents the collection view from responding to touch events
    //________but is unnecessary, the plus and minus buttons will work with or without this disabled.
    //    self.equipCollectionView.allowsSelection = NO;
    
    //add the cancel button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTheThing:)];
    
    //add button to the current navigation item
    [self.navigationItem setRightBarButtonItem:cancelButton];
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
        //____****   create the manager's request ivar, and outfit with a classTitleKey???   ******____
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    //searchcontroller setup
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.mySearchController.searchResultsUpdater = self;
    
    self.mySearchController.dimsBackgroundDuringPresentation = NO;
    self.mySearchController.hidesNavigationBarDuringPresentation = NO;
    
    self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
    
    [self.searchBoxView addSubview:self.mySearchController.searchBar];
    
    self.mySearchController.searchBar.delegate = self;
    self.mySearchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    self.definesPresentationContext = YES;
}


-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    self.navigationItem.title = @"Equipment Selection";
    
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
    
    if (self.privateRequestManagerFlag){
        
        // Hide the notes button when in a popover
        [self.editNotesButton setHidden:YES];
    }
    
    // Add constraints
    // This MUST be added programmatically because you CANNOT specify the topLayoutGuide of a VC in a nib
    
    self.mainSubView.translatesAutoresizingMaskIntoConstraints = NO;
    id topGuide = self.topLayoutGuide;
    id bottomGuide = self.bottomLayoutGuide;
    
    NSDictionary *viewsDictionary = @{@"mainSubView":self.mainSubView, @"topGuide":topGuide, @"bottomGuide":bottomGuide};
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[mainSubView]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    
    
    NSArray *constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mainSubView]-0-[bottomGuide]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    
    // Drop exisiting constraints
    // THIS IS NECESSARY BECAUSE NIBS REALLY HATE IT IF YOU LEAVE OUT ANY CONSTRAINTS
    // THESE WERE ONLY TEMPORARY TO SATISIFY THE NIB FROM SCREAMING ERROR MESSAGES
    [[self.mainSubView superview] removeConstraints:[NSArray arrayWithObjects:self.topGuideLayoutThingy, self.bottomGuideLayoutThingy, nil]];

    //add replacement constraints
    [[self.mainSubView superview] addConstraints:constraint_POS_V];
    [[self.mainSubView superview] addConstraints:constraint_POS_VB];
    
    
    // These following constraints appear to have no effect
    // Add constraints for search box...
    self.mySearchController.searchBar.translatesAutoresizingMaskIntoConstraints = YES;
    
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated{
    
    if (self.dontReloadTheViewBecauseItWillEraseSelections){
        self.dataIsLoadingView.hidden = YES;
        return;
    }
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;

    [self renewTheViewWithRequestManager:requestManager];
    
    self.dontReloadTheViewBecauseItWillEraseSelections = YES;
}


-(void)renewTheViewWithRequestManager:(EQRScheduleRequestManager*)requestManager{

    // Renew the list of uniqueItems
    [requestManager retrieveAllEquipUniqueItems:^(NSMutableArray *muteArray){
//        TODO: retrieveAllEquipUniqueItems async
    }];
    
    //_______********  try allocating the gear list here... *****______
    
    // Must entirely build or rebuild list available equipment as the user could go back and change the dates at anytime
    [requestManager resetEquipListAndAvailableQuantites];
    
    // Factor in the gear already scheduled for the chosen dates in the available quantities.
    [self allocateGearList];
    
    // If request manager already has a request object, remove any recently added joins
    [requestManager emptyTheArrayOfEquipJoins];
    
    //register collection view cell
    [self.equipCollectionView registerClass:[EQREquipItemCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.equipCollectionView registerClass:[EQRHeaderCellTemplate class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    
    // Get class data from scheduleRequest object
    NSString* classTitleKey;
    if (requestManager.request.classTitle_foreignKey){
        classTitleKey = requestManager.request.classTitle_foreignKey;
    } else {
        classTitleKey = @"";
    };
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"renewTheViewWithRequestManager";
    queue.maxConcurrentOperationCount = 5;
    
    
    NSBlockOperation *getEquipTitlesWithClassCatalogKey = [NSBlockOperation blockOperationWithBlock:^{
        //set webData request for equiplist
        NSArray* secondParamArray = @[ @[@"ClassCatalog_foreignKey", classTitleKey] ];
        
        // Get list of ClassCatalog_EquipTitleItem_Join
        __block NSMutableArray* tempEquipMuteArray = [NSMutableArray arrayWithCapacity:1];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        if (([requestManager.request.renter_type isEqualToString:EQRRenterStudent]) && (requestManager.request.showAllEquipmentFlag == NO)){
            
            // Get a list of allocated gear using SQL with INNER JOIN
            [webData queryWithLink:@"EQGetEquipTitlesWithClassCatalogKey.php" parameters:secondParamArray class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
                
                if ([muteArray count] > 0){
                    for (id something in muteArray){
                        [tempEquipMuteArray addObject:something];
                    }
                }
            }];
        } else{
            //_____*****  the ScheduleTopVCntrllr does the same thing, with it's own ivars... **_____
            // Get the ENTIRE list of equipment titles... for staff and faculty
            [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
                
                for (EQREquipItem* equipItemThingy in muteArray){
                    [tempEquipMuteArray addObject:equipItemThingy];
                }
            }];
        }
        
        //... and save to ivar
        self.equipTitleArray = [NSArray arrayWithArray:tempEquipMuteArray];
    }];
    
    
    NSBlockOperation *everythingElse = [NSBlockOperation blockOperationWithBlock:^{
        // Go through this single array and build a nested array to accommodate sections based on category
        if (!self.equipTitleCategoriesList){
            self.equipTitleCategoriesList = [NSMutableArray arrayWithCapacity:1];
        }
        [self.equipTitleCategoriesList removeAllObjects];
        
        //A. first test if array of categories is valid
        if ([self.equipTitleCategoriesList count] < 1){
            
            NSMutableSet* tempSet = [NSMutableSet set];
            
            //create a list of unique categories names by looping through the array of equipTitles
            for (EQREquipItem* obj in self.equipTitleArray){
                
                if ([tempSet containsObject:obj.category] == NO){
                    
                    [tempSet addObject:obj.category];
                    [self.equipTitleCategoriesList addObject:[NSString stringWithString:obj.category]];
                }
            }
            
            [tempSet removeAllObjects];
            tempSet = nil;
        }
        
        // Save equipTitleCategoriesList to scheduleRequestManager
        if (!requestManager.arrayOfEquipTitleCategories){
            requestManager.arrayOfEquipTitleCategories = [NSMutableArray arrayWithCapacity:1];
        }
        [requestManager.arrayOfEquipTitleCategories removeAllObjects];
 
        [requestManager.arrayOfEquipTitleCategories addObjectsFromArray:self.equipTitleCategoriesList];
        
        
        // Sort the equipCatagoriesList
        NSSortDescriptor* sortDescAlpha = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
        NSArray* sortArray = [NSArray arrayWithObject:sortDescAlpha];
        NSArray* tempSortArrayCat = [self.equipTitleCategoriesList sortedArrayUsingDescriptors:sortArray];
        self.equipTitleCategoriesList = [NSMutableArray arrayWithArray:tempSortArrayCat];
        
        // Empty out the current ivar of arrayWithSections
        if (!self.equipTitleArrayWithSections){
            self.equipTitleArrayWithSections = [NSMutableArray arrayWithCapacity:1];
        }
        [self.equipTitleArrayWithSections removeAllObjects];
        
        // With a valid list of categories create a new array by populating each nested array with equiptitle that match each category
        for (NSString* categoryItem in self.equipTitleCategoriesList){
            
            NSMutableArray* subNestArray = [NSMutableArray arrayWithCapacity:1];
            
            for (EQREquipItem* equipItem in self.equipTitleArray){
                if ([equipItem.category isEqualToString:categoryItem]){
                    [subNestArray addObject: equipItem];
                }
            }
            [self.equipTitleArrayWithSections addObject:subNestArray];
        }
        
        // Sort the subnested arrays alphabetically
        NSMutableArray* tempSortedArrayWithSections = [NSMutableArray arrayWithCapacity:1];
        for (NSArray* obj in self.equipTitleArrayWithSections)  {
            
            NSArray* tempSubNestArray = [obj sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
                
                NSString* string1 = [(EQREquipItem*)obj1 shortname];
                NSString* string2 = [(EQREquipItem*)obj2 shortname];
                
                return [string1 compare:string2];
            }];
            
            // Re-sort the nested array to have alphabetizing going down the columns instead across the rows
            NSMutableArray *tempSubNestUsingColumns = [NSMutableArray arrayWithCapacity:1];
            NSInteger countOfItems = [tempSubNestArray count];
            NSInteger countOfItemsDividedByTwo = countOfItems / 2; //will round down
            NSInteger countOfItemsDividedByTwoRoundingUp = countOfItemsDividedByTwo;
            
            // Add one to half count if count is an odd number
            float moduloOfCount = countOfItems % 2;
            if (moduloOfCount > 0){
                countOfItemsDividedByTwoRoundingUp++;
            }
            
            
            NSArray *firstHalfOfItems = [tempSubNestArray subarrayWithRange:NSMakeRange(0, countOfItemsDividedByTwoRoundingUp)];
            NSIndexSet *thisSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfItemsDividedByTwoRoundingUp)];
            [tempSubNestUsingColumns insertObjects:firstHalfOfItems atIndexes:thisSet];
            
            NSArray *secondHalfOfItems = [tempSubNestArray subarrayWithRange:NSMakeRange(countOfItemsDividedByTwoRoundingUp, countOfItemsDividedByTwo)];
            NSInteger countOfItemsInSecondHalf = [secondHalfOfItems count];
            
            int i;
            for (i = 0 ; i < countOfItemsInSecondHalf ; i++){
                
                NSInteger indexOfItemInSecondHalf = countOfItemsDividedByTwoRoundingUp + i;
                id object = [tempSubNestArray objectAtIndex:indexOfItemInSecondHalf];
                [tempSubNestUsingColumns insertObject:object atIndex:(i * 2) + 1];
            }
            
            [tempSortedArrayWithSections addObject:tempSubNestUsingColumns];
            
        };
        self.equipTitleArrayWithSections = tempSortedArrayWithSections;
    }];
    [everythingElse addDependency:getEquipTitlesWithClassCatalogKey];
    
    
    NSBlockOperation *renderTable = [NSBlockOperation blockOperationWithBlock:^{
       dispatch_async(dispatch_get_main_queue(), ^{
           self.dataIsLoadingView.hidden = YES;
           
           //is this necessary_____???
           [self.equipCollectionView reloadData];
       });
    }];
    [renderTable addDependency:everythingElse];
    
    
    [queue addOperation:getEquipTitlesWithClassCatalogKey];
    [queue addOperation:everythingElse];
    [queue addOperation:renderTable];
}


-(void)overrideSharedRequestManager:(id)privateRequestManager{
    
    self.privateRequestManager = privateRequestManager;
    self.privateRequestManagerFlag = YES;
    
    self.isInPopover = YES;
}



#pragma mark - cancel

-(IBAction)cancelTheThing:(id)sender{
    
    //go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //send note to reset eveything back to 0
    //    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:nil];
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    [requestManager dismissRequest:YES];
    
    //_____!!!!!! is this OK, does it get triggered too soon?   !!!!_____
    requestManager = nil;
    
}


#pragma mark - list all buttons (only for staff user)

-(IBAction)listAllEquipment:(id)sender{
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    //show options submenu in popover
    EQREquipOptionsTableVC* optionsVC = [[EQREquipOptionsTableVC alloc] initWithNibName:@"EQREquipOptionsTableVC" bundle:nil];
    self.optionsVC = optionsVC;
    
    //set self as delegate to receive information about selection
    self.optionsVC.delegate = self;
    
    //set flags
    self.optionsVC.showAllEquipFlag = requestManager.request.showAllEquipmentFlag;
    self.optionsVC.allowSameDayFlag = requestManager.request.allowSameDayFlag;
    self.optionsVC.allowConflictFlag = requestManager.request.allowConflictFlag;
    self.optionsVC.allowSeriousServiceIssueFlag = requestManager.request.allowSeriousServiceIssueFlag;
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:self.optionsVC];
    self.optionsPopover = popOver;
    self.optionsPopover.delegate = self;
    
    [self.optionsPopover setPopoverContentSize:CGSizeMake(320.f, 300.f)];

    //show popover
    [self.optionsPopover presentPopoverFromRect:self.listAllEquipButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

-(void)optionsSelectionMade{
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    //sync flags
    requestManager.request.showAllEquipmentFlag = self.optionsVC.showAllEquipFlag;
    requestManager.request.allowSameDayFlag = self.optionsVC.allowSameDayFlag;
    requestManager.request.allowConflictFlag = self.optionsVC.allowConflictFlag;
    requestManager.request.allowSeriousServiceIssueFlag = self.optionsVC.allowSeriousServiceIssueFlag;
    
    //dismiss popover
    [self.optionsPopover dismissPopoverAnimated:YES];
    self.optionsPopover = nil;
    
    //______somehow save any current selections made...
    
    //reload the view
    [self renewTheViewWithRequestManager:requestManager];
}


-(IBAction)notesButtonTapped:(id)sender{
    
    EQRNotesVC* notesVC = [[EQRNotesVC alloc] initWithNibName:@"EQRNotesVC" bundle:nil];
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    notesVC.delegate = self;
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:notesVC];
    self.notesPopover = popOver;
    self.notesPopover.delegate = self;
    
    [self.notesPopover setPopoverContentSize:CGSizeMake(320.f, 400.f)];
    
    CGRect rect1 = [self.editNotesButton.superview.superview convertRect:self.editNotesButton.frame fromView:self.editNotesButton.superview];
    
    //present popOver
    [self.notesPopover presentPopoverFromRect:rect1 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //must be after presentation
    [notesVC initialSetupWithScheduleRequest:requestManager.request];
    
}


-(void)retrieveNotesData:(NSString*)noteText{
    
    //update request
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    requestManager.request.notes = noteText;
    
    //dismiss popover
    [self.notesPopover dismissPopoverAnimated:YES];
    
    //release delegate status
    [(EQRNotesVC*)[self.notesPopover contentViewController] setDelegate:nil];
    
    //dealloc popover
    self.notesPopover = nil;
}


-(IBAction)miscButtonTapped:(id)sender{
    
    EQRMiscEditVC* miscEditVC = [[EQRMiscEditVC alloc] init];
    miscEditVC.delegate = self;
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    UIPopoverController* miscEditPopover = [[UIPopoverController alloc] initWithContentViewController:miscEditVC];
    self.miscPopover = miscEditPopover;
    self.miscPopover.delegate = self;
    [self.miscPopover setPopoverContentSize:CGSizeMake(320.f, 500.f)];
    
    CGRect rect1 = [self.addMiscellaneousButton.superview.superview convertRect:self.editNotesButton.frame fromView:self.addMiscellaneousButton.superview];
    
    //present popOver
    [self.miscPopover presentPopoverFromRect:rect1 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //must be after presentation
    [miscEditVC initialSetupWithScheduleTrackingKey:requestManager.request.key_id];
    
}


-(void)receiveMiscData:(NSString*)miscItemText{

    // Update data layer new entry in db with item text
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    NSArray *topArray = @[ @[@"scheduleTracking_foreignKey", requestManager.request.key_id],
                           @[@"name", miscItemText] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
       [webData queryForStringwithAsync:@"EQSetNewMiscJoin.php" parameters:topArray completion:^(NSString *miscKeyID) {
           
           if (!miscKeyID) return NSLog(@"EQREquipSelectionGenericVC > failed to retreive miscKeyID");
           
           // Update misc array in request
           EQRMiscJoin *miscJoin = [[EQRMiscJoin alloc] init];
           miscJoin.name = miscItemText;
           miscJoin.key_id = miscKeyID;
           miscJoin.scheduleTracking_foreignKey = requestManager.request.key_id;
           if (!requestManager.request.arrayOfMiscJoins){
               requestManager.request.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
           }
           [requestManager.request.arrayOfMiscJoins addObject:miscJoin];
           
           //refresh the popover's view
           [(EQRMiscEditVC*)[self.miscPopover contentViewController] renewTheViewWithScheduleKey:requestManager.request.key_id];
       }];
    });
}


#pragma mark - allocation of gear items


-(IBAction)receiveContinueAction:(id)sender{
    
    //____show pricing ONLY if it is a public rental AND it is not in kiosk mode.
    
    EQRStaffUserManager *staffUserManager = [EQRStaffUserManager sharedInstance];
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    
    if (([requestManager.request.renter_type isEqualToString:EQRRenterPublic]) &&
        ([staffUserManager currentKioskMode] == NO)) {
        
        UIStoryboard *captureStoryboard = [UIStoryboard storyboardWithName:@"Pricing" bundle:nil];
        EQRRequestWrapperPriceMatrixVC *newView = [captureStoryboard instantiateViewControllerWithIdentifier:@"price_main_wrapper"];
        
        newView.edgesForExtendedLayout = UIRectEdgeAll;
        
        [self.navigationController pushViewController:newView animated:YES];
        
    }else{
        
        EQREquipSummaryGenericVCntrllr* summaryVCntrllr = [[EQREquipSummaryGenericVCntrllr alloc] initWithNibName:@"EQREquipSummaryGenericVCntrllr" bundle:nil];
        
        summaryVCntrllr.edgesForExtendedLayout = UIRectEdgeAll;
        
        [self.navigationController pushViewController:summaryVCntrllr animated:YES];
    }
}


//!!!!_______       THESE METHODS ARE DEPRECATED IN IOS 8!!!  _______________
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    //invalidate the flowlayout to force it to update with the correct inset
    [self.equipCollectionView.collectionViewLayout invalidateLayout];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    //needs to update the headings...
    [self.equipCollectionView reloadData];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    //____!!!! yuck   !!!!!_____
    //this works and is necessary to overcome a bug in the change in origin of the search bar
    //when rotated... but man does it look ugly....
    //only needs update if search bar is currently active
    if (self.mySearchController.active){
        [self performSelector:@selector(delayedSearchBarResizeWithText:) withObject:self.mySearchController.searchBar.text afterDelay:0.15];
        
        self.mySearchController.active = NO;
    }
}

-(void)delayedSearchBarResizeWithText:(NSString *)searchText{
    
    CGRect thisRect = CGRectMake(self.searchBoxView.bounds.origin.x, self.searchBoxView.bounds.origin.y, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);

    [UIView animateWithDuration:0.3 animations:^{
        
        self.mySearchController.searchBar.frame = thisRect;
        
    } completion:^(BOOL finished) {
        
        self.mySearchController.active = YES;
        
        [self.mySearchController.searchBar setText:searchText];
    }];
}


#pragma mark - schedule request manager delegate methods

-(void)refreshTheCollectionWithType:(NSString *)type SectionArray:(NSArray *)array{
    
    NSString* typeOfChange = type;
    NSArray* sectionArray = array;
    
    //abort if in search mode
    if (self.mySearchController.active){
        return;
    }
    
    //array of index paths to add or delete
    NSMutableArray* arrayOfIndexPaths = [NSMutableArray arrayWithCapacity:1];
    
    int indexPathToDelete;
    
    //test whether inserting or deleting
    if ([typeOfChange isEqualToString:@"insert"]){
        
        //loop through the sections of the equipment list to identify the index of the section
        for (NSArray* subArray in self.equipTitleArrayWithSections){
            
            NSString* thisIsCategory = [(EQREquipItem*)[subArray objectAtIndex:0] category];
            
            //loop through array of chosen sections
            for (NSString* sectionString in sectionArray){
                
                if ([thisIsCategory isEqualToString:sectionString]){
                    
                    //found a match, remember the index
                    indexPathToDelete = (int)[self.equipTitleArrayWithSections indexOfObject:subArray];
                    
                    //loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
        }
        
        //do the insert
        [self.equipCollectionView performBatchUpdates:^{
            
            [self.equipCollectionView insertItemsAtIndexPaths:arrayOfIndexPaths];
            
        } completion:^(BOOL finished) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRUpdateHeaderCellsInEquipSelection object:nil];
            
        }];
        
        
    }else if([typeOfChange isEqualToString:@"delete"]) {
        
        //loop through the sections of the equipment list to identify the index of the section
        for (NSArray* subArray in self.equipTitleArrayWithSections){
            
            NSString* thisIsCategory = [(EQREquipItem*)[subArray objectAtIndex:0] category];
            
            //loop through array of chosen sections
            for (NSString* sectionString in sectionArray){
                
                if ([thisIsCategory isEqualToString:sectionString]){
                    
                    //found a match, remember the index
                    indexPathToDelete = (int)[self.equipTitleArrayWithSections indexOfObject:subArray];
                    
                    //loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
        }
        
        //do the deletions
        [self.equipCollectionView performBatchUpdates:^{
            
            [self.equipCollectionView deleteItemsAtIndexPaths:arrayOfIndexPaths];

        } completion:^(BOOL finished) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRUpdateHeaderCellsInEquipSelection object:nil];
            
        }];
    }
    
    //reload data to ensure that header cells are updated correctly when the "All" button is tapped
//    [self.equipCollectionView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    
}


#pragma mark - allocation

-(void)allocateGearList{
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    [requestManager allocateGearListWithDates:nil];
}



#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (self.mySearchController.active){
        [self hideTheButtons];
    }
    
    
    NSString *searchString = [self.mySearchController.searchBar text];
    
    if ([searchString isEqualToString:@""]){
        searchString = @" ";
    }
    
    //    NSLog(@"inside updateSearchResultsForSearchController with search text: %@", searchString);
    
    NSString *scope = nil;
    
    [self filterContentForSearchText:searchString scope:scope];
    
    [self.equipCollectionView reloadData];
}

#pragma mark - UISearchBarDelegate

// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.mySearchController];
}

- (void)hideTheButtons{
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.editNotesButton.alpha = 0.3;
        self.addMiscellaneousButton.alpha = 0.3;
//        self.continueButton.alpha = 0.3;
        self.listAllEquipButton.alpha = 0.3;
    }];
    
    [self.editNotesButton setEnabled:NO];
    [self.addMiscellaneousButton setEnabled:NO];
//    [self.continueButton setEnabled:NO];
    [self.listAllEquipButton setEnabled:NO];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    //change background color
//    EQRColors *colors = [EQRColors sharedInstance];
//    self.searchBoxView.backgroundColor = [colors.colorDic objectForKey:EQRColorFilterBarAndSearchBarBackground];
//    self.mySearchController.searchBar.tintColor = [UIColor whiteColor];
//    self.mySearchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
//    self.mySearchController.searchBar.barTintColor = [colors.colorDic objectForKey:EQRColorFilterBarAndSearchBarBackground];
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    //change background color
//    self.searchBoxView.backgroundColor = [UIColor whiteColor];
//    self.mySearchController.searchBar.tintColor = nil;
//    self.mySearchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.editNotesButton.alpha = 1.0;
        self.addMiscellaneousButton.alpha = 1.0;
//        self.continueButton.alpha = 1.0;
        self.listAllEquipButton.alpha = 1.0;
    }];
    
    [self.editNotesButton setEnabled:YES];
    [self.addMiscellaneousButton setEnabled:YES];
//    [self.continueButton setEnabled:YES];
    [self.listAllEquipButton setEnabled:YES];
}


#pragma mark - Content Filtering

//Basically, a predicate is an expression that returns a Boolean value (true or false). You specify the search criteria in the format of NSPredicate and use it to filter data in the array. As the search is on the name of recipe, we specify the predicate as “name contains[c] %@”. The “name” refers to the name property of the Recipe object. NSPredicate supports a wide range of filters including: BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS. Here we choose to use the “contains” filter. The operator “[c]” means the comparison is case-insensitive.

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"shortname contains[c] %@", searchText];
    self.searchResultArrayOfEquipTitles = [self.equipTitleArray filteredArrayUsingPredicate:resultPredicate];
}





#pragma mark - view collection data source protocol methods

//Section Methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    EQRHeaderCellTemplate* cell = [self.equipCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* thisSubview in cell.contentView.subviews){
        
        [thisSubview removeFromSuperview];
    }
    
    //______this is unnecessary(?)
    //and ensure cell has user interaction enabled
    //    [cell setUserInteractionEnabled:YES];
    
    
    //_____test whether the section is collapsed or expanded
    BOOL iAmHidden = NO;
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    [cell setDelegate:requestManager];
    
    
    //test if in search mode, and tap out
    if (self.mySearchController.active){
        [cell initialSetupWithTitle:@"Search results" isHidden:NO isSearchResult:YES];
        return  cell;
    }
    
    
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeHidden){
        
        if ([sectionString isEqualToString:[(EQREquipItem*)[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] category]]){
            
            //found a match in the array of hidden sections
            iAmHidden = YES;
            
            break;
        }
    }
    
    //cell's initial setup method with label
    [cell initialSetupWithTitle:[self.equipTitleCategoriesList objectAtIndex:indexPath.section]
                       isHidden:iAmHidden
                 isSearchResult:NO];
    
    return cell;
}

//_____________  DO THIS EVERYWHERE A CELL IS REGISTERED TO OBSERVE NOTIFICATIONS!!! _________________
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    [[NSNotificationCenter defaultCenter] removeObserver:view];
}



//Cell Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //test if in search, tap out with count of search array
    if (self.mySearchController.active){
        return [self.searchResultArrayOfEquipTitles count];
    }
    
    //test if this section is flagged to be collapsed
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;

    EQREquipItem* sampleItem = [[self.equipTitleArrayWithSections objectAtIndex:section] objectAtIndex:0];
    
    
    //loop through array of hidden sections
    for (NSString* objectSection in requestManager.arrayOfEquipSectionsThatShouldBeHidden){
        
        if ([sampleItem.category isEqualToString:objectSection]){
            
            return 0;
        }
    }
    
    //otherwise... return the count of the array object
    NSArray* tempArray = [self.equipTitleArrayWithSections objectAtIndex:section];
    return [tempArray count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    //test if in search, tap out with 1
    if (self.mySearchController.active){
        return 1;
    }else{
        return [self.equipTitleArrayWithSections count];
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    EQREquipItemCell* cell = [self.equipCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    //and ensure cell has user interaction enabled
    [cell setUserInteractionEnabled:YES];
    
    //    cell.backgroundColor = [UIColor yellowColor];
    //    [cell setOpaque:YES];
    
    
    //assign the shared requestManager OR a private reqeust manager as a delegate to the equipItemCell
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    [cell setDelegate: requestManager];
    
    if ([self.equipTitleArray count] > 0){
        
        //_______determine either search results table or normal table
        if (self.mySearchController.active) {
            
            [cell initialSetupWithTitle:[[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row]  shortname] andEquipItem:[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row]];
            
        }else{
            
            [cell initialSetupWithTitle:[[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]  shortname] andEquipItem:[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            
            //        [cell initialSetupWithTitle:[(EQREquipItem*)[self.equipTitleArray objectAtIndex:indexPath.row] name] andEquipItem:[self.equipTitleArray objectAtIndex:indexPath.row]];
        }
        
    }else{
        
        NSLog(@"no count in the equiptitlearray");
    }
    
    return cell;
}


//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//}


#pragma mark - collection view delegate methods


//for equip item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"view collection delegate fires touch with indexPath: %u, %u", (int)indexPath.section, (int)indexPath.row);
    
    //if the selected cell has 0 for quantity, add one. otherwise, do nothing
    EQREquipItemCell* selectedCell = (EQREquipItemCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([selectedCell itemQuantity] < 1){
        
        [selectedCell plusHit:nil];
    }
}


#pragma mark - collection view flow layout delegate methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    
    //_______   NEED to know if it appears in a popOver, then DON'T implement this !!!!______
    if (self.isInPopover == YES){
        
        return UIEdgeInsetsMake(4.f, 0.f, 8.f, 0.f);
        
    } else {
        
        UIEdgeInsets edgeInsets;
        
        //test if in portrait or landscape view
        //______******   a better implementation of this is here:   ******_______
        //  http://stackoverflow.com/questions/13556554/change-uicollectionviewcell-size-on-different-device-orientations
        //uses two different flowlayout objects, one for each orientation
        
        UIInterfaceOrientation orientationOnLaunch = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientationOnLaunch)) {
            
            edgeInsets = UIEdgeInsetsMake(4.f, 4.f, 8.f, 4.f);
            
        }else{
            
            edgeInsets = UIEdgeInsetsMake(4.f, 132.f, 8.f, 132.f);
            
        }
        
        return edgeInsets;
    }
}


#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    if (popoverController == self.notesPopover){
        
        self.notesPopover = nil;
        
    }else if( popoverController == self.optionsPopover){
        
        self.optionsPopover = nil;
        
    }else if (popoverController == self.miscPopover){
        
        //release delegate status
        [(EQRMiscEditVC*)[self.miscPopover contentViewController] setDelegate:nil];
        self.miscPopover = nil;
    }
}


#pragma mark - memory warning

-(void)dealloc{
    
    self.privateRequestManager = nil;
    
    //____tested and I don't this is necessary(???)
    //unlist self from notificationCenter
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
