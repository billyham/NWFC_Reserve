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

@interface EQREquipSelectionGenericVCntrllr () <UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UIPopoverPresentationControllerDelegate>

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

//notes button
@property (strong, nonatomic) IBOutlet UIButton* editNotesButton;

// add miscellaneous button
@property (strong, nonatomic) IBOutlet UIButton *addMiscellaneousButton;
@property (strong, nonatomic) EQRMiscEditVC *miscEditVC;

//UISearchController
@property (strong, nonatomic) IBOutlet UIView *searchBoxView;
@property (strong, nonatomic) UISearchController *mySearchController;
@property (strong, nonatomic) NSArray *searchResultArrayOfEquipTitles;
@property (strong, nonatomic) NSArray *verticalConstraintsForSearchBar;
@property (strong, nonatomic) NSArray *horizontalConstraintsForSearchBar;

// Operation Queues
@property (strong, nonatomic) NSOperationQueue *renewTheViewQueue;

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
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
        //____****   create the manager's request ivar, and outfit with a classTitleKey???   ******____
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    // Searchcontroller setup
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.mySearchController.delegate = self;
    
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
    
    // Update navigation bar
    self.navigationItem.title = @"Equipment Selection";
    
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
//    [requestManager resetEquipListAndAvailableQuantites];

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
    
    
    if (!self.renewTheViewQueue){
        self.renewTheViewQueue = [[NSOperationQueue alloc] init];
        self.renewTheViewQueue.name = @"renewTheViewWithRequestManager";
        self.renewTheViewQueue.maxConcurrentOperationCount = 3;
    }
    [self.renewTheViewQueue cancelAllOperations];
    
    
    NSBlockOperation *getEquipTitlesWithClassCatalogKey = [NSBlockOperation blockOperationWithBlock:^{

        // Set webData request for equiplist
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
        
        // Save as property
        self.equipTitleArray = [NSArray arrayWithArray:tempEquipMuteArray];
    }];
    
    NSBlockOperation *everythingElse = [NSBlockOperation blockOperationWithBlock:^{
        // Go through this single array and build a nested array to accommodate sections based on category
        if (!self.equipTitleCategoriesList){
            self.equipTitleCategoriesList = [NSMutableArray arrayWithCapacity:1];
        }
        [self.equipTitleCategoriesList removeAllObjects];
        
        // Test if array of categories is valid
        if ([self.equipTitleCategoriesList count] < 1){
            
            NSMutableSet* tempSet = [NSMutableSet set];
            
            // Create a list of unique categories names by looping through the array of equipTitles
            for (EQREquipItem* obj in self.equipTitleArray){
                
                if (obj.category != nil) {
                    if ([tempSet containsObject:obj.category] == NO){
                        [tempSet addObject:obj.category];
                        [self.equipTitleCategoriesList addObject:[NSString stringWithString:obj.category]];
                    }
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
                
                NSString* string1 = [(EQREquipItem*)obj1 short_name];
                NSString* string2 = [(EQREquipItem*)obj2 short_name];
                
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
           
           [self.equipCollectionView reloadData];
       });
    }];
    [renderTable addDependency:everythingElse];
    
    
    [self.renewTheViewQueue addOperation:getEquipTitlesWithClassCatalogKey];
    [self.renewTheViewQueue addOperation:everythingElse];
    [self.renewTheViewQueue addOperation:renderTable];
}


-(void)overrideSharedRequestManager:(id)privateRequestManager{
    
    self.privateRequestManager = privateRequestManager;
    self.privateRequestManagerFlag = YES;
    
    self.isInPopover = YES;
}



#pragma mark - cancel
- (IBAction)cancelTheThing:(id)sender{
    
    // Go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    // Send note to reset eveything back to 0
    //    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:nil];
    
    // Reset eveything back to 0 (which in turn sends an nsnotification)
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
- (IBAction)listAllEquipment:(id)sender{
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    // Show options submenu in popover
    EQREquipOptionsTableVC* optionsVC = [[EQREquipOptionsTableVC alloc] initWithNibName:@"EQREquipOptionsTableVC" bundle:nil];
    self.optionsVC = optionsVC;
    
    // Set self as delegate to receive information about selection
    self.optionsVC.delegate = self;
    
    // Set flags
    self.optionsVC.showAllEquipFlag = requestManager.request.showAllEquipmentFlag;
    self.optionsVC.allowSameDayFlag = requestManager.request.allowSameDayFlag;
    self.optionsVC.allowConflictFlag = requestManager.request.allowConflictFlag;
    self.optionsVC.allowSeriousServiceIssueFlag = requestManager.request.allowSeriousServiceIssueFlag;
    
    optionsVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [optionsVC popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popover.sourceRect = self.listAllEquipButton.frame;
    popover.sourceView = self.view;
    
    [self presentViewController:optionsVC animated:YES completion:^{}];
}


- (void)optionsSelectionMade{
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    // Sync flags
    requestManager.request.showAllEquipmentFlag = self.optionsVC.showAllEquipFlag;
    requestManager.request.allowSameDayFlag = self.optionsVC.allowSameDayFlag;
    requestManager.request.allowConflictFlag = self.optionsVC.allowConflictFlag;
    requestManager.request.allowSeriousServiceIssueFlag = self.optionsVC.allowSeriousServiceIssueFlag;
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
    
    [self renewTheViewWithRequestManager:requestManager];
}


- (IBAction)notesButtonTapped:(id)sender{
    
    EQRNotesVC* notesVC = [[EQRNotesVC alloc] initWithNibName:@"EQRNotesVC" bundle:nil];
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    notesVC.delegate = self;

    CGRect rect1 = [self.editNotesButton.superview.superview convertRect:self.editNotesButton.frame fromView:self.editNotesButton.superview];

    notesVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [notesVC popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popover.sourceRect = rect1;
    popover.sourceView = self.view;
    
    [self presentViewController:notesVC animated:YES completion:^{
        [notesVC initialSetupWithScheduleRequest:requestManager.request];
    }];
}


- (void)retrieveNotesData:(NSString*)noteText{
    
    // Update request
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    requestManager.request.notes = noteText;
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


-(IBAction)miscButtonTapped:(id)sender{
    
    EQRMiscEditVC* miscEditVC = [[EQRMiscEditVC alloc] init];
    miscEditVC.delegate = self;
    self.miscEditVC = miscEditVC;
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    CGRect rect1 = [self.addMiscellaneousButton.superview.superview convertRect:self.editNotesButton.frame fromView:self.addMiscellaneousButton.superview];
    
    miscEditVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [miscEditVC popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popover.sourceRect = rect1;
    popover.sourceView = self.view;
    
    [self presentViewController:miscEditVC animated:YES completion:^{
        [miscEditVC initialSetupWithScheduleTrackingKey:requestManager.request.key_id];
    }];
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
           
           // Refresh the miscEditVC's view
           [self.miscEditVC renewTheViewWithScheduleKey:requestManager.request.key_id];
       }];
    });
}


#pragma mark - allocation of gear items
- (IBAction)receiveContinueAction:(id)sender{
    
    // Show pricing ONLY if it is a public rental
    // AND it is not in kiosk mode.
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
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    // Invalidate the flowlayout to force it to update with the correct inset
    [self.equipCollectionView.collectionViewLayout invalidateLayout];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    // Needs to update the headings...
    [self.equipCollectionView reloadData];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    //____!!!! yuck   !!!!!_____
    // This works and is necessary to overcome a bug in the change
    // in origin of the search bar when rotated...
    // but man does it look ugly....
    // only needs update if search bar is currently active
    if (self.mySearchController.active){
        [self performSelector:@selector(delayedSearchBarResizeWithText:) withObject:self.mySearchController.searchBar.text afterDelay:0.15];
        
        self.mySearchController.active = NO;
    }
}


- (void)delayedSearchBarResizeWithText:(NSString *)searchText{
    
    CGRect thisRect = CGRectMake(self.searchBoxView.bounds.origin.x, self.searchBoxView.bounds.origin.y, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);

    [UIView animateWithDuration:0.3 animations:^{
        self.mySearchController.searchBar.frame = thisRect;
    } completion:^(BOOL finished) {
        self.mySearchController.active = YES;
        [self.mySearchController.searchBar setText:searchText];
    }];
}


#pragma mark - schedule request manager delegate methods
- (void)refreshTheCollectionWithType:(NSString *)type SectionArray:(NSArray *)array{
    
    NSString* typeOfChange = type;
    NSArray* sectionArray = array;
    
    // Abort if in search mode
    if (self.mySearchController.active){
        return;
    }
    
    // Array of index paths to add or delete
    NSMutableArray* arrayOfIndexPaths = [NSMutableArray arrayWithCapacity:1];
    
    int indexPathToDelete;
    // Test whether inserting or deleting
    if ([typeOfChange isEqualToString:@"insert"]){
        // Loop through the sections of the equipment list to identify the index of the section
        for (NSArray* subArray in self.equipTitleArrayWithSections){
            NSString* thisIsCategory = [(EQREquipItem*)[subArray objectAtIndex:0] category];
            
            // Loop through array of chosen sections
            for (NSString* sectionString in sectionArray){
                if ([thisIsCategory isEqualToString:sectionString]){
                    // Found a match, remember the index
                    indexPathToDelete = (int)[self.equipTitleArrayWithSections indexOfObject:subArray];
                    // Loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
        }
        // Do the insert
        [self.equipCollectionView performBatchUpdates:^{
            [self.equipCollectionView insertItemsAtIndexPaths:arrayOfIndexPaths];
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRUpdateHeaderCellsInEquipSelection object:nil];
        }];
    }else if([typeOfChange isEqualToString:@"delete"]) {
        // Loop through the sections of the equipment list to identify the index of the section
        for (NSArray* subArray in self.equipTitleArrayWithSections){
            NSString* thisIsCategory = [(EQREquipItem*)[subArray objectAtIndex:0] category];
            // Loop through array of chosen sections
            for (NSString* sectionString in sectionArray){
                if ([thisIsCategory isEqualToString:sectionString]){
                    // Found a match, remember the index
                    indexPathToDelete = (int)[self.equipTitleArrayWithSections indexOfObject:subArray];
                    
                    // Loop through all items to build an array of indexpaths
                    [(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPathToDelete] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:idx inSection:indexPathToDelete];
                        [arrayOfIndexPaths addObject:newIndexPath];
                    }];
                }
            }
        }
        // Do the deletions
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
- (void)allocateGearList{
    
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
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (self.mySearchController.active){
        [self hideTheButtons];
    }
    
    
    NSString *searchString = [self.mySearchController.searchBar text];
    
    if ([searchString isEqualToString:@""]){
        searchString = @" ";
    }
    NSString *scope = nil;
    [self filterContentForSearchText:searchString scope:scope];
    [self.equipCollectionView reloadData];
}

#pragma mark - UISearchBarDelegate
// Workaround for bug: -updateSearchResultsForSearchController:
// is not called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.mySearchController];
}

- (void)hideTheButtons{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.editNotesButton.alpha = 0.3;
        self.addMiscellaneousButton.alpha = 0.3;
        self.listAllEquipButton.alpha = 0.3;
    }];
    
    [self.editNotesButton setEnabled:NO];
    [self.addMiscellaneousButton setEnabled:NO];
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
        self.listAllEquipButton.alpha = 1.0;
    }];
    
    [self.editNotesButton setEnabled:YES];
    [self.addMiscellaneousButton setEnabled:YES];
    [self.listAllEquipButton setEnabled:YES];
}

#pragma mark - UISearchControllerDelegate methods
-(void)didPresentSearchController:(UISearchController *)searchController {
    // Somewhere after searchBarTextDidBeginEditing: and willPresentSearchController,
    // the frame for the searchbar changes to
    // width of the device's screen size. Super annoying
    self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
}

-(void)didDismissSearchController:(UISearchController *)searchController {
    self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
}


#pragma mark - Content Filtering

//Basically, a predicate is an expression that returns a Boolean value (true or false). You specify the search criteria in the format of NSPredicate and use it to filter data in the array. As the search is on the name of recipe, we specify the predicate as “name contains[c] %@”. The “name” refers to the name property of the Recipe object. NSPredicate supports a wide range of filters including: BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS. Here we choose to use the “contains” filter. The operator “[c]” means the comparison is case-insensitive.

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"short_name contains[c] %@", searchText];
    self.searchResultArrayOfEquipTitles = [self.equipTitleArray filteredArrayUsingPredicate:resultPredicate];
}


#pragma mark - view collection data source protocol methods
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    EQRHeaderCellTemplate* cell = [self.equipCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Remove subviews
    for (UIView* thisSubview in cell.contentView.subviews){
        [thisSubview removeFromSuperview];
    }
    
    // Test whether the section is collapsed or expanded
    BOOL iAmHidden = NO;
    
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    [cell setDelegate:requestManager];
    
    // Test if in search mode, and tap out
    if (self.mySearchController.active){
        [cell initialSetupWithTitle:@"Search results" isHidden:NO isSearchResult:YES];
        return  cell;
    }
    
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeHidden){
        if ([sectionString isEqualToString:[(EQREquipItem*)[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:0] category]]){
            
            // Found a match in the array of hidden sections
            iAmHidden = YES;
            
            break;
        }
    }
    
    // Cell's initial setup method with label
    [cell initialSetupWithTitle:[self.equipTitleCategoriesList objectAtIndex:indexPath.section]
                       isHidden:iAmHidden
                 isSearchResult:NO];
    return cell;
}


// DO THIS EVERYWHERE A CELL IS REGISTERED TO OBSERVE NOTIFICATIONS!!!
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    [[NSNotificationCenter defaultCenter] removeObserver:view];
}


// Cell Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    // Test if in search, tap out with count of search array
    if (self.mySearchController.active){
        return [self.searchResultArrayOfEquipTitles count];
    }
    
    // Test if this section is flagged to be collapsed
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;

    EQREquipItem* sampleItem = [[self.equipTitleArrayWithSections objectAtIndex:section] objectAtIndex:0];
    
    // Loop through array of hidden sections
    for (NSString* objectSection in requestManager.arrayOfEquipSectionsThatShouldBeHidden){
        if ([sampleItem.category isEqualToString:objectSection]){
            return 0;
        }
    }
    // Otherwise... return the count of the array object
    NSArray* tempArray = [self.equipTitleArrayWithSections objectAtIndex:section];
    return [tempArray count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    // Test if in search, tap out with 1
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
    
    // Ensure cell has user interaction enabled
    [cell setUserInteractionEnabled:YES];
    
    // Assign the shared requestManager OR a private reqeust manager as a
    // delegate to the equipItemCell
    EQRScheduleRequestManager* requestManager;
    if (self.privateRequestManagerFlag){
        requestManager = self.privateRequestManager;
    }else{
        requestManager = [EQRScheduleRequestManager sharedInstance];
    }
    requestManager.equipSelectionDelegate = self;
    
    [cell setDelegate: requestManager];
    
    if ([self.equipTitleArray count] > 0){
        //  Determine either search results table or normal table
        if (self.mySearchController.active) {
            [cell initialSetupWithTitle:[[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row]  short_name] andEquipItem:[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row]];
        }else{
            [cell initialSetupWithTitle:[[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]  short_name] andEquipItem:[(NSArray*)[self.equipTitleArrayWithSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        }
    }
    return cell;
}


//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//}


#pragma mark - collection view delegate methods
// For equip item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // If the selected cell has 0 for quantity, add one. otherwise, do nothing
    EQREquipItemCell* selectedCell = (EQREquipItemCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([selectedCell itemQuantity] < 1){
        [selectedCell plusHit:nil];
    }
}


#pragma mark - collection view flow layout delegate methods
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    
    // NEED to know if it appears in a popOver, then DON'T implement this !!!!
    if (self.isInPopover == YES){
        return UIEdgeInsetsMake(4.f, 0.f, 8.f, 0.f);
    } else {
        UIEdgeInsets edgeInsets;
        
        // Test if in portrait or landscape view
        // A better implementation of this is here:
        //  http://stackoverflow.com/questions/13556554/change-uicollectionviewcell-size-on-different-device-orientations
        //u Uses two different flowlayout objects, one for each orientation
        
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
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [self.miscEditVC setDelegate:nil];
}


- (void)dealloc{
    self.privateRequestManager = nil;
}

#pragma mark - memory warning
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}






@end
