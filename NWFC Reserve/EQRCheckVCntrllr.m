//
//  EQRCheckVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckVCntrllr.h"
#import "EQRCheckRowCell.h"
#import "EQRCheckRowMiscItemCell.h"
#import "EQRMiscJoin.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRGlobals.h"
//#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import <CoreImage/CoreImage.h>
#import "EQREquipUniqueItem.h"
//#import "EQRCheckPageRenderer.h"
#import "EQRCheckPrintPage.h"
#import "EQRStaffUserManager.h"
#import "EQRCheckHeaderCell.h"
#import "EQRDataStructure.h"
#import "EQRStaffUserManager.h"
#import "EQRStaffUserPickerViewController.h"
#import "EQRModeManager.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQREquipSelectionGenericVCntrllr.h"
#import "EQRScheduleRequestManager.h"
#import "EQRContactNameItem.h"
#import "EQRColors.h"
#import "EQRSigCaptureMainVC.h"
#import "EQRPricingWidgetCheckInVC.h"
#import "EQRPriceMatrixVC.h"
#import "EQRTransaction.h"
#import "EQRAlternateWrappperPriceMatrix.h"


@interface EQRCheckVCntrllr ()<AVCaptureMetadataOutputObjectsDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, EQRPriceMatrixDelegate, EQRSigCaptureDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequestItem;
@property (strong, nonatomic) EQRItineraryCellContent2VC *cellContent;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet UIView *rightSubView;
@property (strong, nonatomic) IBOutlet UIView *rightSubviewTopBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* mainSubTopGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* mainSubBottomGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tableTopGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tablebottomGuideConstraint;

@property (strong, nonatomic) IBOutlet UIView *updateView;
@property (strong, nonatomic) IBOutlet UITextView* updateLabel;

@property (strong, nonatomic) IBOutlet UILabel* nameTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *renterTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *classTitleLabel;
@property (strong, nonatomic) NSString* notesText;
@property (strong, nonatomic) IBOutlet UITextView* noteView;
@property (strong, nonatomic) IBOutlet UILabel *xLabel;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) NSString* myProperty;

@property (strong, nonatomic) IBOutlet UICollectionView* myEquipCollection;
@property CGPoint myEquipCollectionContentOffset;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipJoins;
@property (strong, nonatomic) NSMutableArray* arrayOfMiscJoins;
@property (strong, nonatomic) NSArray* arrayOfEquipJoinsWithStructure;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedMiscJoins;

@property NSInteger indexOfLastReturnedItem;
@property (strong, nonatomic) EQRWebData *webDataForFullyComplete;
@property (strong, nonatomic) EQRWebData *webDataForContactComplete;
@property (strong, nonatomic) EQRWebData *webDataForEquipJoins;
@property (strong, nonatomic) EQRWebData *webDataForMiscJoins;
@property BOOL didLoadFullyCompleteFlag;
@property BOOL didLoadContactCompleteFlag;
@property BOOL didLoadEquipJoinsFlag;
@property BOOL didLoadMiscJoinsFlag;
@property double timeOfLastCallback;
@property (strong, nonatomic) EQRContactNameItem *tempContact;

// Pricing widget
@property (strong, nonatomic) EQRTransaction *myTransaction;
@property (strong, nonatomic) IBOutlet UIView *priceMatrixSubView;
@property (strong, nonatomic) EQRPricingWidgetCheckInVC *priceWidget;

// SearchController
@property (strong, nonatomic) UISearchController *mySearchController;
@property (strong, nonatomic) IBOutlet UIView *searchBoxView;
@property (strong, nonatomic) NSArray *searchResultArrayOfEquipTitles;
//@property (strong, nonatomic) NSArray *verticalConstraintsForSearchBar;
//@property (strong, nonatomic) NSArray *horizontalConstraintsForSearchBar;

// For staff user picker
//@property (strong, nonatomic) UIPopoverController* myStaffUserPicker;
@property (strong, nonatomic) EQRStaffUserPickerViewController *staffUserPicker;

// For qr code reader
@property(nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) NSMutableSet* setOfAlreadyCapturedQRs;

// For dist id picker
//@property (strong, nonatomic) UIPopoverController* distIDPopover;
@property (strong, nonatomic) EQRDistIDPickerTableVC* distIDPickerVC;

// For add item popover
@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
//@property (strong, nonatomic) UIPopoverController* myEquipSelectionPopover;
@property (strong, nonatomic) IBOutlet UIButton* addButton;



@end

@implementation EQRCheckVCntrllr

#pragma mark - methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)initialSetup:(NSString *)scheduleKey mark:(BOOL)markedForReturning switch:(NSUInteger)switchNum cellContent:(EQRItineraryCellContent2VC *)cellContent{
    
    self.didLoadFullyCompleteFlag = NO;
    self.didLoadContactCompleteFlag = NO;
    self.myScheduleRequestItem = nil;
    self.tempContact = nil;
    
    self.scheduleRequestKeyID = scheduleKey;
    self.marked_for_returning = markedForReturning;
    self.switch_num = switchNum;
    self.cellContent = cellContent;
    
    //figure out the literal column name in the database to use
    if (!self.marked_for_returning){
        
        if (self.switch_num == 1){
            self.myProperty = @"prep_flag";
        }else {
            self.myProperty = @"checkout_flag";
        }
    }else{
        if (self.switch_num == 1){
            self.myProperty = @"checkin_flag";
        }else {
            self.myProperty = @"shelf_flag";
        }
    }
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    self.webDataForFullyComplete = webData;
    self.webDataForFullyComplete.delegateDataFeed = self;
    NSArray *firstArray = @[@"key_id", self.scheduleRequestKeyID];
    NSArray *topArray = @[firstArray];
    SEL thisSelector = @selector(addRequestObject:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       
        [self.webDataForFullyComplete queryWithAsync:@"EQGetScheduleRequestFullyComplete.php" parameters:topArray class:@"EQRScheduleRequestItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            self.didLoadFullyCompleteFlag = YES;
            if (self.didLoadContactCompleteFlag){
                self.didLoadFullyCompleteFlag = NO;
                self.didLoadContactCompleteFlag = NO;
                
                //only continue if a valid request got returned
                if (self.myScheduleRequestItem){
                    [self initialSetupStage2];
                }
            }
        }];
    });
    
    //do asynchronous call to a different implementation of webdata for the contact info
    EQRWebData *webData2 = [EQRWebData sharedInstance];
    self.webDataForContactComplete = webData2;
    self.webDataForContactComplete.delegateDataFeed = self;
    SEL thisSelector2 = @selector(addContactComplete:);
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue2, ^{
        [self.webDataForContactComplete queryWithAsync:@"EQGetContactCompleteWithScheduleRequestKey.php" parameters:topArray class:@"EQRContactNameItem" selector:thisSelector2 completion:^(BOOL isLoadingFlagUp) {
            self.didLoadContactCompleteFlag = YES;
            if (self.didLoadFullyCompleteFlag){
                self.didLoadFullyCompleteFlag = NO;
                self.didLoadContactCompleteFlag = NO;
                
                //only continue if a valid request got returned
                if (self.myScheduleRequestItem){
                    [self initialSetupStage2];
                }
            }
        }];
    });
}


-(void)initialSetupStage2{
    //force out of search mode
    self.mySearchController.active = NO;
    
    self.didLoadEquipJoinsFlag = NO;
    self.didLoadMiscJoinsFlag = NO;
    
    //stop existing xml stream
    [self.webDataForEquipJoins stopXMLParsing];
    [self.webDataForMiscJoins stopXMLParsing];
    
    //_____!!!!! not sure why this is here, adding items and deleting items look better without it.  !!!!!____
    //empty the existing collection view
//    self.arrayOfEquipJoinsWithStructure = nil;
//    [self.myEquipCollection reloadData];
    
    //dim the collection view to indicate it's loading data
    self.myEquipCollection.alpha = 0.3;
    self.updateView.alpha = 0.0;
    //prevent scrolling because that costs time
    self.myEquipCollection.userInteractionEnabled = NO;
    
    //remove any existing delaytimer
    self.timeOfLastCallback = 0;
    
    //set notes text
    self.noteView.text = self.notesText;
    
    //set name label
    self.myScheduleRequestItem.contactNameItem = self.tempContact;
    if (self.myScheduleRequestItem.contactNameItem){
        self.nameTextLabel.text = self.myScheduleRequestItem.contactNameItem.first_and_last;
    }
    
    // Set renter type and class
    self.renterTypeLabel.text = [self.myScheduleRequestItem.renter_type capitalizedString];
    if (self.myScheduleRequestItem.title){
        self.classTitleLabel.text = self.myScheduleRequestItem.title;
        self.classTitleLabel.hidden = NO;
    }
    
    // Set name on nav bar?
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"MMM d";
    NSString *pickupDateAsString = [dateFormatter stringFromDate:self.myScheduleRequestItem.request_date_begin];
    NSString *returnDateAsString = [dateFormatter stringFromDate:self.myScheduleRequestItem.request_date_end];
    NSString *typeLabel;
    if (self.marked_for_returning){
        typeLabel = [NSString stringWithFormat:@"%@ - Returning", returnDateAsString];
    }else{
        if (self.switch_num == 1){
            typeLabel = [NSString stringWithFormat:@"%@ - Prep", pickupDateAsString];
        }else{
            typeLabel = [NSString stringWithFormat:@"%@ - Checking Out", pickupDateAsString];
        }
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@, %@",self.myScheduleRequestItem.contactNameItem.first_and_last, typeLabel];
    
    // Set X Label on signed agreement
    if (self.myScheduleRequestItem.pdf_timestamp){
        self.xLabel.hidden = NO;
    }
    
    
    //initiate the nsmutable arrays if necessary
    if (!self.arrayOfEquipJoins){
        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfEquipJoins removeAllObjects];
    
    if (!self.arrayOfMiscJoins){
        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfMiscJoins removeAllObjects];
    
//    self.indexOfLastReturnedItem = -1;
    
//    [self renewTheArrayWithScheduleTracking_foreignKey:self.scheduleRequestKeyID];
//    [self.myEquipCollection reloadData];

    //populate arrays using schedule key
    EQRWebData* webData = [EQRWebData sharedInstance];
    self.webDataForEquipJoins = webData;
    self.webDataForEquipJoins.delegateDataFeed = self;
    
    NSArray* ayeArray = @[@"scheduleTracking_foreignKey", self.scheduleRequestKeyID];
    NSArray* bigArray = @[ayeArray];
    SEL equipJoinSelector = @selector(addEquipJoinToArray:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [self.webDataForEquipJoins queryWithAsync:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:bigArray class:@"EQRScheduleTracking_EquipmentUnique_Join" selector:equipJoinSelector completion:^(BOOL isLoadingFlagUp) {
            
            self.didLoadEquipJoinsFlag = isLoadingFlagUp;
            
            if (self.didLoadMiscJoinsFlag){
                self.didLoadMiscJoinsFlag = NO;
                self.didLoadEquipJoinsFlag = NO;
                
                //this delay has no real effect
                [self performSelector:@selector(initialSetupStage3) withObject:nil afterDelay:0];
            }
        }];
    });

    EQRWebData *webData2 = [EQRWebData sharedInstance];
    self.webDataForMiscJoins = webData2;
    self.webDataForMiscJoins.delegateDataFeed = self;
    SEL miscJoinsSelector = @selector(addMiscJoinToArray:);
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue2, ^{
       
        [self.webDataForMiscJoins queryWithAsync:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:bigArray class:@"EQRMiscJoin" selector:miscJoinsSelector completion:^(BOOL isLoadingFlagUp) {
            
            self.didLoadMiscJoinsFlag = isLoadingFlagUp;
            
            if (self.didLoadEquipJoinsFlag){
                self.didLoadEquipJoinsFlag = NO;
                self.didLoadMiscJoinsFlag = NO;
                
                //this delay has no real effect
                [self performSelector:@selector(initialSetupStage3) withObject:nil afterDelay:0];
            }
        }];
    });
}


-(void)initialSetupStage3{
    //expand the array
    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
    [self.myEquipCollection reloadData];
    
    //content height minus the window height will result in the maximum offset value
    float differenceBetweenHeights = self.myEquipCollection.contentSize.height - self.myEquipCollection.frame.size.height;
    //but it can't be a negative number
    if (differenceBetweenHeights < 0){
        differenceBetweenHeights = 0;
    }
    if (self.myEquipCollectionContentOffset.y > differenceBetweenHeights){
        self.myEquipCollectionContentOffset = CGPointMake(0, differenceBetweenHeights);
    }
    //move the colleciton view scroll to the place before add or delete was used
    [self.myEquipCollection setContentOffset:self.myEquipCollectionContentOffset];
    
    //un-dim the collection view
    self.myEquipCollection.alpha = 1.0;
    self.updateView.alpha = 1.0;
    self.myEquipCollection.userInteractionEnabled = YES;
    
    
    //____set up private request manager______
    
    //create private request manager as ivar
    if (!self.privateRequestManager){
        
        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
    }
    
    //set the request as ivar in requestManager
    self.privateRequestManager.request = self.myScheduleRequestItem;
    self.privateRequestManager.request.arrayOfEquipmentJoins = self.arrayOfEquipJoins;
    
    //important methods that initiate requestManager ivar arrays
//    [self.privateRequestManager resetEquipListAndAvailableQuantites];
//    [self.privateRequestManager retrieveAllEquipUniqueItems];  !! THIS IS NOT HOW THE METHODS WORKS ANYMORE
    
    //pricing info
    if ([self.privateRequestManager.request.renter_type isEqualToString:EQRRenterPublic]){
        self.priceMatrixSubView.hidden = NO;
        [self getTransactionInfo];
    }else{
        self.priceMatrixSubView.hidden = YES;
    }
    
}


//-(void)renewTheArrayWithScheduleTracking_foreignKey:(NSString*)scheduleRequestKeyID{
//    
//
//    NSMutableArray* altMuteArray = [NSMutableArray arrayWithCapacity:1];
//
//    
//    //initiate the nsmutable array if necessary
//    if (!self.arrayOfEquipJoins){
//        self.arrayOfEquipJoins = [NSMutableArray arrayWithCapacity:1];
//    }
//    [self.arrayOfEquipJoins removeAllObjects];
//    
//    [self.arrayOfEquipJoins addObjectsFromArray:altMuteArray];
//    
//
//    //gather any misc joins
//    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
//    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", scheduleRequestKeyID];
//    NSArray* omegaArray = @[alphaArray];
//    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
//        for (id object in muteArray2){
//            [tempMiscMuteArray addObject:object];
//        }
//    }];
//    
//    //initiate the nsmutable array if necessary
//    if (!self.arrayOfMiscJoins){
//        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
//    }
//    [self.arrayOfMiscJoins removeAllObjects];
//
//    [self.arrayOfMiscJoins addObjectsFromArray:tempMiscMuteArray];
//    
//    
//    
//    //add nested structure to the array of equip items
//    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
//}


- (void)viewDidLoad{
    [super viewDidLoad];

    //register collection view cells
    [self.myEquipCollection registerClass:[EQRCheckRowCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.myEquipCollection registerClass:[EQRCheckRowMiscItemCell class] forCellWithReuseIdentifier:@"CellForMiscJoin"];
    
    //register for header cell
    [self.myEquipCollection registerClass:[EQRCheckHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SupplementaryCell"];
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //receive change in state from row items
    [nc addObserver:self selector:@selector(updateArrayOfJoins:) name:EQRUpdateCheckInOutArrayOfJoins object:nil];
    //receive notes from cell's content VCs when delete button is tapped
    [nc addObserver:self selector:@selector(addJoinKeyIDToBeDeletedArray:) name:EQRJoinToBeDeletedInCheckInOut object:nil];
    [nc addObserver:self selector:@selector(removeJoinKeyIDToBeDeletedArray:) name:EQRJoinToBeDeletedInCheckInOutCancel object:nil];
    //receive notes from cell's content when distIDPicker is tapped
    [nc addObserver:self selector:@selector(distIDPickerTapped:) name:EQRDistIDPickerTapped object:nil];
    
    
    //cancel bar button
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
//    
//    [self.navigationItem setRightBarButtonItem:rightButton];


    //QR Code if application options bool is set in globals
    if (EQRIncludeQRCodeReader == YES){
        
        [self initiateQRCodeSteps];
    }
    
    //instantiate mutableArray for deletion ivar
    if (!self.arrayOfToBeDeletedEquipIDs){
        self.arrayOfToBeDeletedEquipIDs = [NSMutableArray arrayWithCapacity:1];
    } else {
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    }
    
    //instantiate mutableArray for deletion miscJoins
    if (!self.arrayOfToBeDeletedMiscJoins){
        self.arrayOfToBeDeletedMiscJoins = [NSMutableArray arrayWithCapacity:1];
    } else {
        [self.arrayOfToBeDeletedMiscJoins removeAllObjects];
    }
    
    //derive the current user name
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* logText = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    
    //uibar buttons
    //create fixed spaces
    UIBarButtonItem* twentySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    twentySpace.width = 20;
    UIBarButtonItem* thirtySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    thirtySpace.width = 30;
    
    //wrap buttons in barbuttonitem
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    
    NSArray* arrayOfLeftButtons = [NSArray arrayWithObjects:leftBarButton, nil];
    
    //set leftBarButton item on SELF
    [self.navigationItem setLeftBarButtonItems:arrayOfLeftButtons];
    
    //right button
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:logText style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];

    
    // price widget
    EQRPricingWidgetCheckInVC *priceWidget = [[EQRPricingWidgetCheckInVC alloc] initWithNibName:@"EQRPricingWidgetCheckInVC" bundle:nil];
    self.priceWidget = priceWidget;
    CGRect tempRect = CGRectMake(0, 0, self.priceMatrixSubView.frame.size.width, self.priceMatrixSubView.frame.size.height);
    priceWidget.view.frame = tempRect;
    
    [self.priceMatrixSubView addSubview:self.priceWidget.view];
    
    //set button target
    [self.priceWidget.editButton addTarget:self action:@selector(showPricingButton:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)placeSearchBox{
    
    //searchcontroller setup
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.mySearchController.searchResultsUpdater = self;
    self.mySearchController.searchBar.delegate = self;
    self.mySearchController.delegate = self;

    
    self.mySearchController.dimsBackgroundDuringPresentation = NO;
    self.mySearchController.hidesNavigationBarDuringPresentation = NO;
    
    //    UISearchContainerViewController *searchContainer = [[UISearchContainerViewController alloc] initWithSearchController:self.mySearchController];
    //
    
    
//    [self addChildViewController:self.mySearchController];
    
    // This applies to the searchbox before entry, it has no effect to the searchbox after entry
    self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);


    [self.searchBoxView addSubview:self.mySearchController.searchBar];
    

    // So far this isn't doing anything.
//    self.mySearchController.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
//    NSDictionary *viewDictionary = @{@"searchBoxView":self.searchBoxView, @"searchBar":self.mySearchController.searchBar};
//    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBar]" options:0 metrics:nil views:viewDictionary];
//    NSArray *constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[searchBar]-0-|" options:0 metrics:nil views:viewDictionary];
//    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBar]" options:0 metrics:nil views:viewDictionary];
//    NSArray *constraint_POS_HB = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[searchBar]-0-|" options:0 metrics:nil views:viewDictionary];
//    [[self.searchBoxView superview] addConstraints:constraint_POS_V];
//    [[self.searchBoxView superview] addConstraints:constraint_POS_VB];
//    [[self.searchBoxView superview] addConstraints:constraint_POS_H];
//    [[self.searchBoxView superview] addConstraints:constraint_POS_HB];
    
    
//    [self.mySearchController didMoveToParentViewController:self];
    
    
    //    UISearchContainerViewController *searchContainer = [[UISearchContainerViewController alloc] initWithSearchController:self.mySearchController];
    //    [self.searchBoxView addSubview:searchContainer.view];
    
    
    self.mySearchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    //what does this do?
    self.definesPresentationContext = YES;
}


-(void)viewWillAppear:(BOOL)animated{
    
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
    
 
    
    //add constraints
    //______this MUST be added programmatically because you CANNOT specify the topLayoutGuide of a VC in a nib______
    
    self.myEquipCollection.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    //drop exisiting constraints
    //_____THIS IS NECESSARY BECAUSE NIBS REALLY HATE IT IF YOU LEAVE OUT ANY CONSTRAINTS __
    //_____THESE WERE ONLY TEMPORARY TO SATISIFY THE NIB FROM SCREAMING ERROR MESSAGES____
    [[self.mainSubView superview] removeConstraints:[NSArray arrayWithObjects:self.mainSubTopGuideConstraint, self.mainSubBottomGuideConstraint, nil]];
    
    //add replacement constraints
    [[self.mainSubView superview] addConstraints:constraint_POS_V];
    [[self.mainSubView superview] addConstraints:constraint_POS_VB];
    
    //reassign constraint ivars!!
    self.mainSubTopGuideConstraint = [constraint_POS_V objectAtIndex:0];
    self.mainSubBottomGuideConstraint = [constraint_POS_VB objectAtIndex:0];
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{

    //this doesn't really help...
//    [UIView animateWithDuration:0.1 animations:^{
//        self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
//    }];
    
    [self placeSearchBox];
}


#pragma mark - test at printing

//-(void)printMe{
//    
//    //_______PRINTING_________!
//    
//    UIPrintInteractionController* printIntCont = [UIPrintInteractionController sharedPrintController];
//    
//    UIPrintInfo* printInfo = [UIPrintInfo printInfo] ;
//    printInfo.jobName = @"NWFC Reserve App: Request";
//    printInfo.outputType = UIPrintInfoOutputGrayscale;
//    
//    //assign printinfo to int cntrllr
//    printIntCont.printInfo = printInfo;
//    
//    //create page renderer
//    EQRCheckPageRenderer* pageRenderer = [[EQRCheckPageRenderer alloc] init];
//    
//    //assign properties
//    pageRenderer.headerHeight = 300.f;
//    pageRenderer.footerHeight = 500.f;
//    
//    //assign page renderer to int cntrllr
//    printIntCont.printPageRenderer = pageRenderer;
//    
//    
//    
//}


#pragma mark - QR Code reader methods

-(void)initiateQRCodeSteps{
    
    self.session = [[AVCaptureSession alloc] init];

    //sweep out the array of captured codes
    if (!self.setOfAlreadyCapturedQRs){
        
        self.setOfAlreadyCapturedQRs = [[NSMutableSet alloc] initWithCapacity:1];
    }
    
    [self.setOfAlreadyCapturedQRs removeAllObjects];
    
    
    // Get the Camera Device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	AVCaptureDevice *camera = nil; //[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for(camera in devices) {
        if(camera.position == AVCaptureDevicePositionBack) {
            break;
        }
    }
	
	// Create a AVCaptureInput with the camera device
	NSError *error=nil;
	AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if (cameraInput == nil) {
        
		NSLog(@"Error to create camera capture:%@",error);
        
        //exit or it will crash
        return;
	}
    
 	// Add the input and output
	[self.session addInput:cameraInput];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    
    // see what types are supported (do this after adding otherwise the output reports nothing supported
    NSSet *potentialDataTypes = [NSSet setWithArray:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode39Code]];
    
    NSMutableArray *supportedMetaDataTypes = [NSMutableArray array];
    for(NSString *availableMetadataObject in output.availableMetadataObjectTypes) {
        if([potentialDataTypes containsObject:availableMetadataObject]) {
            [supportedMetaDataTypes addObject:availableMetadataObject];
        }
    }
    
    [output setMetadataObjectTypes:supportedMetaDataTypes];
    
    // Get called back everytime something is recognised
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	
	// Start the session running
	[self.session startRunning];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    //test if in search, tap out
    if (self.mySearchController.active){
        return;
    }
    
    for(AVMetadataMachineReadableCodeObject *recognizedObject in metadataObjects) {
        
        BOOL alreadyInArray = NO;
        
        //check to see if the string value already has been captured
        for (NSString* stringObject in self.setOfAlreadyCapturedQRs){
            
            if ([stringObject isEqualToString:recognizedObject.stringValue]){
                
                alreadyInArray = YES;
                break;
            }
        }
        
        if (alreadyInArray == YES){
            
            //advance to the next cycle if the item has already been scanned
            continue;
        }
        
        //otherwise... add to the set of found objects
        [self.setOfAlreadyCapturedQRs addObject:recognizedObject.stringValue];
        
        //derive just the equipItem key
        NSRange eqrRange = [recognizedObject.stringValue rangeOfString:@"eqr"];
        
        //will return NSNotFound for location and 0 for length if it doesn't find the string
        if (eqrRange.location == NSNotFound){
            
            //try capital letters
            eqrRange = [recognizedObject.stringValue rangeOfString:@"EQR"];
            
            if (eqrRange.location == NSNotFound){
                
                //present a message that an object was scanned but not recognized by the system???
                
                //exit the method
                continue;
            }
        }
        
        //derive the titleItem key
        NSInteger locationOfTitleKey = eqrRange.location + 3;
        NSInteger lengthOfTitleKey = [recognizedObject.stringValue length] - locationOfTitleKey;
        NSRange titleEqrRange = NSMakeRange(locationOfTitleKey, lengthOfTitleKey);
        
        //valuable sub strings
        NSString* uniqueItemSubString = [recognizedObject.stringValue substringToIndex:eqrRange.location];
        NSString* titleItemSubString = [recognizedObject.stringValue substringWithRange:titleEqrRange];
        
//        NSLog(@"this is the substring: %@", uniqueItemSubString);
//        NSLog(@"this is the title key, perhaps: %@", titleItemSubString);

        //_____!!!!  a modal view that asks for a quantity for the generic title scananed?...
        
        //__1__ Matching uniqueKey, just flip switch
          //continue to next scanned item
        
        //__2__ (Matching title key but not unique key, will replace existing title item (unflipped switch) with a different unique...  ?)
          //__4__ __A__ Generic item, matching title key and will flip switch
          //continue to next scanned item
        
        //__3__ No matching title key,
          //__confirm in DB, otherwise show error & continue to next scanned item
          //__is NOT generic, will add to list
          //__is GENERIC...
            //__4__ __B__ Generic item, no matching title, will add to list

        
        
        //__1__ respond to an exact equipUnique key id match
        BOOL foundAMatchingEquipKey = NO;
        for (EQRScheduleTracking_EquipmentUnique_Join* joinObject in self.arrayOfEquipJoins){
            
            if ([joinObject.equipUniqueItem_foreignKey isEqualToString:uniqueItemSubString]){
                
                //                        NSLog(@"FOUND A EquipKey MATCH");

                foundAMatchingEquipKey = YES;
                
                //________move collection view to row with new object.
                //________when cell is not in view (because at the bottom of a long list) the switch doesn't receive the notification and get flipped
                [self.arrayOfEquipJoinsWithStructure enumerateObjectsUsingBlock:^(NSArray* subArray, NSUInteger idx, BOOL *stop) {
                   
                    [subArray enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* joinObj, NSUInteger subIdx, BOOL *stop) {
                        
                        if (joinObj == joinObject){
                            
//                            NSLog(@"found a match in subarray, %@", joinObject.name);
                            
                            NSIndexPath* matchingIndexPath = [NSIndexPath indexPathForRow:subIdx inSection:idx];
                            
                            [self.myEquipCollection scrollToItemAtIndexPath:matchingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        }
                    }];
                }];
                
                //alert matching row cell content with a notification
                NSDictionary* newDic = [NSDictionary dictionaryWithObject:uniqueItemSubString forKey:@"keyID"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:EQRQRCodeFlipsSwitchInRowCellContent object:nil userInfo:newDic];
                //send note with delay
                [self performSelector:@selector(delayedNotification:) withObject:newDic afterDelay:0.25f];
                
                //add text to the display update
                [self showUpdateDisplay:[NSString stringWithFormat:@"Checked: %@ #%@", joinObject.name, joinObject.distinquishing_id]];
                
                //found the match so break out of this sub loop
                break;
            }
        }
        
        if (foundAMatchingEquipKey == YES){
            
            //advance to the next cycle
            continue;
        }
        
        
        //___2__ respond to a matching title key id match
        //replace an existing unique item with the scanned item???
        //___________!!!!!!   THIS IS NO GOOD, IF YOU HAVE TWO BATTERIES TO SCAN IN, THIS METHOD PREVENTS THE SECOND FROM GETTING FLIPPED  !!!!______
        BOOL foundAMatchingTitleKey = NO;
        for (EQRScheduleTracking_EquipmentUnique_Join* joinObject in self.arrayOfEquipJoins){
            
            if ([joinObject.equipTitleItem_foreignKey isEqualToString:titleItemSubString]){
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                
                //should also test the the item has not already been give a YES value for the 'myProperty' value
                //otherwise it continues to the next segment, adding it as a new item to the order
                if ([joinObject respondsToSelector:NSSelectorFromString(self.myProperty)]){
                    
                    SEL thisSelector = NSSelectorFromString(self.myProperty);
                    NSString* thisLiteralProperty = [joinObject performSelector:thisSelector];
                    if ([thisLiteralProperty isEqualToString:@""] || thisLiteralProperty == nil){
                        
#pragma clang diagnostic pop
                        
                        //found a matching title key in the ivar array
                        foundAMatchingTitleKey = YES;
                        
                        //____ !!!  could be a GENERIC item   !!!____
                        //__4__ __A__ Generic item, matching title key and will flip switch

                        
                        //do stuff, replace existing unqiueItem with NEW uniqueItem
                        
                        //change the data layer
                        
                        //change the local ivar
                        
                        //change the row cell content distinguishing id, and flip switch
                        
                        break;
                    }
                }
            }
        }
        
        if (foundAMatchingTitleKey == YES){
            
            //exit the method
//            continue;
        }
        
        
        //__3__ respond to a new titleItem by adding it the the order (in the case of batteries)
        
        BOOL foundACatalogTitleKey = NO;
        EQRWebData* webData = [EQRWebData sharedInstance];
        NSArray* firstyArray = [NSArray arrayWithObjects:@"key_id", titleItemSubString, nil];
        NSArray* topyArray = [NSArray arrayWithObject:firstyArray];
        
        //confirm that the title key object exists
        
        NSString* resultString = [webData queryForStringWithLink:@"EQConfirmExistenceOfEquipTitleKey.php" parameters:topyArray];
        if ([resultString isEqualToString:@"1"]){
            
            foundACatalogTitleKey = YES;
            
        } else {
            
            //____show error message that the item wasn't found in the database
            //advance to the next cycle
            continue;
        }
        
        
        
        //evaluate if generic...
        if ([uniqueItemSubString isEqualToString:@"NA"]){
            
            //__4__ __B__ Generic item, no matching title, but title confirmed in DB and will add to list
            
            //check available quantity for this title, return error if none
            //derive a legitimate uniqueKey and assign to uniqueItemSubString to use in the following code...
            //use privateRequestManager... check the title for availability,
            //important methods that initiate requestManager ivar arrays
            
            //allocate method MUST be called only ONCE after the other two methods. or the count gets screwed up.  
            [self.privateRequestManager resetEquipListAndAvailableQuantites];
            [self.privateRequestManager retrieveAllEquipUniqueItems:^(NSMutableArray *muteArray) {
                //TODO: retrieveAllEquipUniqueItems async
            }];
            [self.privateRequestManager allocateGearListWithDates:nil];
            
            BOOL isAvailable = [self.privateRequestManager confirmAvailabilityOfTitleItem:titleItemSubString];
            if (isAvailable){
                
                //... then use methods: addEquipItem, justConfirm
                EQREquipItem* titleItemObject  = [[EQREquipItem alloc] init];
                titleItemObject.key_id = titleItemSubString;
                [self.privateRequestManager addNewRequestEquipJoin:titleItemObject];
                
                //assign a valid equipUniqueItem to the array of joins in the request
                NSString* tempReturn = [self.privateRequestManager retrieveAnAvailableUniqueKeyFromTitleKey:titleItemSubString];
                
                if (tempReturn == nil){
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Scan Error" message:@"Scan Failed, an error occurred when trying to select this item" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *alertOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
                    
                    [alert addAction:alertOk];
                    [self presentViewController:alert animated:YES completion:^{ }];
                    
                    //advance the cycle
                    continue;
                    
                }else{
                    
                    //otherwise assign key to 
                    uniqueItemSubString = tempReturn;
                    
                    //set a delayed method to remove the particular code from the alreadyInArray after 2 seconds to allow multiple scans
                    [self performSelector:@selector(removeGenericQRCodeFromAlreadySet:) withObject:recognizedObject.stringValue afterDelay:2.0];
                }
                
            }else{
                
                //____send alert that item is not available____                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"Gear is no longer available for this date range" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *alertOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
                
                [alert addAction:alertOk];
                [self presentViewController:alert animated:YES completion:^{ }];
                
                //advance the cycle
                continue;
            }
        }
        
        
        //confirm that the unique key object exists!!!
        //________create a new join item to add to the local ivar
        EQRScheduleTracking_EquipmentUnique_Join* newJoinToAdd = [[EQRScheduleTracking_EquipmentUnique_Join alloc] init];
        NSArray* fourthArray = [NSArray arrayWithObjects:@"key_id", uniqueItemSubString, nil];
        NSArray* tipTopArray = [NSArray arrayWithObject:fourthArray];
        [webData queryWithLink:@"EQGetEquipmentUnique.php" parameters:tipTopArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] > 0){
                
                //only continue with a confirmed Unique Item present
                //change the data layer
                //create a new schedule_equip_join object
                //retrieve the key_id of the join?
                
                
                newJoinToAdd.name = [(EQREquipUniqueItem*)[muteArray objectAtIndex:0] name];
                newJoinToAdd.distinquishing_id = [(EQREquipUniqueItem*) [muteArray objectAtIndex:0] distinquishing_id];
                newJoinToAdd.scheduleTracking_foreignKey = self.scheduleRequestKeyID;
                newJoinToAdd.equipTitleItem_foreignKey = titleItemSubString;
                newJoinToAdd.equipUniqueItem_foreignKey = uniqueItemSubString;
                
                //create the join object in the database and retrieve key_id
                NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.scheduleRequestKeyID, nil];
                NSArray* secondArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", uniqueItemSubString, nil];
                NSArray* thirdArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", titleItemSubString, nil];
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
                
                NSString* returnString = [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:topArray];
                
                newJoinToAdd.key_id = returnString;
                
                //2 arrays to update
                //add join object to array property
                [self.arrayOfEquipJoins addObject:newJoinToAdd];
                self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
                
                [self.myEquipCollection reloadData];
                
                //move collection view to row with new object.
                //when cell is not in view (because at the bottom of a long list) the switch doesn't receive the notification and get flipped
                [self.arrayOfEquipJoinsWithStructure enumerateObjectsUsingBlock:^(NSArray* subArray, NSUInteger idx, BOOL *stop) {
                    
                    [subArray enumerateObjectsUsingBlock:^(EQRScheduleTracking_EquipmentUnique_Join* joinObj, NSUInteger subIdx, BOOL *stop) {
                        
                        if (joinObj == newJoinToAdd){
                            
                            NSIndexPath* matchingIndexPath = [NSIndexPath indexPathForRow:subIdx inSection:idx];
                            
                            [self.myEquipCollection scrollToItemAtIndexPath:matchingIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                        }
                    }];
                }];
                
                //flip the switch in the row cell
                //alert matching row cell content with a notification
                NSDictionary* newDic = [NSDictionary dictionaryWithObject:uniqueItemSubString forKey:@"keyID"];
                
                [self performSelector:@selector(delayedNotification:) withObject:newDic afterDelay:0.25];
                
                //add text to the display update
                [self showUpdateDisplay:[NSString stringWithFormat:@"Added: %@ #%@", newJoinToAdd.name, newJoinToAdd.distinquishing_id]];
                
            }else{
                
                //can't find this uniqueKey in the database
                //exit and alert user
                //____!!!!!!  NEED TO INCLUDE THE TITLE ITEM NAME  !!!!!_______
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Found" message:@"Cannot find this item in the database" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *alertOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {  }];
                
                [alert addAction:alertOk];
                [self presentViewController:alert animated:YES completion:^{  }];
            }
        }];
    }
}

-(void)delayedNotification:(NSDictionary*)myUserDic{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRQRCodeFlipsSwitchInRowCellContent object:nil userInfo:myUserDic];
}


-(void)removeGenericQRCodeFromAlreadySet:(NSString*)QRCodeString{
    
    if (self.setOfAlreadyCapturedQRs){
        if ([self.setOfAlreadyCapturedQRs count] > 0){
            [self.setOfAlreadyCapturedQRs removeObject:QRCodeString];
        }
    }
}


-(void)showUpdateDisplay:(NSString*)updateText{

    //add new text to the existing display text
    self.updateLabel.text = [self.updateLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@    \n", updateText]];
    
    //lower collectionView to reveal update display
    self.tableTopGuideConstraint.constant = 150.f;
    
    [self.myEquipCollection setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
       
        //scroll update label to bottom
        [self.updateLabel scrollRangeToVisible:NSMakeRange(0,[self.updateLabel.text length])];
        
        //generally use the topmost view
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - equip list buttons

-(IBAction)deleteMarkedItemsButton:(id)sender{
    
    //save the current content offset
    self.myEquipCollectionContentOffset = self.myEquipCollection.contentOffset;
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"deleteMarkedItemsButton";
    queue.maxConcurrentOperationCount = 2;
    
    
    NSBlockOperation *deleteScheduleEquipJoin = [NSBlockOperation blockOperationWithBlock:^{
        // Delete the marked scheduleTracking_equip_joins
        EQRWebData* webData = [EQRWebData sharedInstance];
        for (NSString* thisKeyID in self.arrayOfToBeDeletedEquipIDs){
            // Delete Equip Join with the join key_id
            NSArray* beeArray = @[ @[@"key_id", thisKeyID] ];
            [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoin.php" parameters:beeArray];
        }
    }];
    
    
    NSBlockOperation *deleteMiscJoin = [NSBlockOperation blockOperationWithBlock:^{
        // Delete the marked miscJoin
        EQRWebData* webData = [EQRWebData sharedInstance];
        for (NSString* thisKeyID in self.arrayOfToBeDeletedMiscJoins){
            // Delete Misc Join with the join key_id
            NSArray* beeArray = @[ @[@"key_id", thisKeyID] ];
            [webData queryForStringWithLink:@"EQDeleteMiscJoin.php" parameters:beeArray];
        }
    }];
    
    
    NSBlockOperation *updateArraysAndRender = [NSBlockOperation blockOperationWithBlock:^{
        //empty the arrays
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
        [self.arrayOfToBeDeletedMiscJoins removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //renew the array of equipment
            [self initialSetupStage2];
            
            //if the collection view is emptied of all items, the structured array is never updated and the collection view never gets reloaded.
            if ([self.arrayOfEquipJoins count] < 1){
                self.arrayOfEquipJoinsWithStructure = nil;
                [self.myEquipCollection reloadData];
            }
        });
        
        //send note to schedule that a change has been saved
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    }];
    [updateArraysAndRender addDependency:deleteScheduleEquipJoin];
    [updateArraysAndRender addDependency:deleteMiscJoin];
    
    
    [queue addOperation:deleteScheduleEquipJoin];
    [queue addOperation:deleteMiscJoin];
    [queue addOperation:updateArraysAndRender];
}


#pragma mark - navigation buttons
-(void)cancelAction{

    [self.webDataForEquipJoins stopXMLParsing];
    [self.webDataForMiscJoins stopXMLParsing];
    self.webDataForMiscJoins.delegateDataFeed = nil;
    self.webDataForEquipJoins.delegateDataFeed = nil;
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
-(IBAction)markAsComplete:(id)sender{
    
    // Check that a user has logged in
    EQRStaffUserManager* staffManager = [EQRStaffUserManager sharedInstance];
    if (!staffManager.currentStaffUser){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Current User" message:@"Please log in as a user before marking an item complete or incomplete" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {  }];
        
        [alert addAction: alertOk];
        [self presentViewController:alert animated:YES completion:^{ }];
        
        return;
    }
    
    //2 strings to use in message text
    NSString *userName = staffManager.currentStaffUser.first_and_last;
    NSString *typeOfMark;
    if ([self.myProperty isEqualToString:@"prep_flag"]){
        typeOfMark = @"Prepped";
    }else if ([self.myProperty isEqualToString:@"checkout_flag"]){
        typeOfMark = @"Checked Out";
    }else if ([self.myProperty isEqualToString:@"checkin_flag"]){
        typeOfMark = @"Checked in";
    }else if ([self.myProperty isEqualToString:@"shelf_flag"]) {
        typeOfMark = @"Shelved";
    }else{
        typeOfMark = @"Error in TypeOfMark";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Mark as %@", typeOfMark] message:[NSString stringWithFormat:@"Stamped with staff signature: %@", userName] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self confirmMarkAsComplete];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {  }];
    
    [alert addAction: alertOk];
    [alert addAction:alertCancel];
    [self presentViewController:alert animated:YES completion:^{  }];
}


-(void)confirmMarkAsComplete{
    
    // make special note if any of the joins in the ivar array are not complete
    BOOL foundOutstandingItem = NO;
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in self.arrayOfEquipJoins){
        if ([join respondsToSelector:NSSelectorFromString(self.myProperty)]){
            SEL thisSelector = NSSelectorFromString(self.myProperty);
            NSString* thisLiteralProperty = [join performSelector:thisSelector];
            if (([thisLiteralProperty isEqualToString:@""]) || (thisLiteralProperty == nil)){
                foundOutstandingItem = YES;
            }
        }
    }
    
    // make special note if any of the joins in the ivar array are not complete **NOW for MiscJoins**
    for (EQRMiscJoin* join in self.arrayOfMiscJoins){
        if ([join respondsToSelector:NSSelectorFromString(self.myProperty)]){
            SEL thisSelector = NSSelectorFromString(self.myProperty);
            NSString* thisLiteralProperty = [join performSelector:thisSelector];
            if (([thisLiteralProperty isEqualToString:@""]) || (thisLiteralProperty == nil)){
                foundOutstandingItem = YES;
            }
        }
    }
    
    [self.cellContent dismissedCheckInOut:self.scheduleRequestKeyID complete:@"complete" returning:self.marked_for_returning switch:self.switch_num outstanding:foundOutstandingItem];

    [self dismissViewControllerAnimated:YES completion:^{  }];
}


#pragma clang diagnostic pop
-(IBAction)printMeForReal:(id)sender{
    [self printPageWithScheduleRequestItemKey:self.scheduleRequestKeyID];
}


-(void)printPageWithScheduleRequestItemKey:(NSString*)scheduleKey{
    
    //get complete scheduleRequest item info
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", scheduleKey, nil];
    NSArray* secondRequestArray = [NSArray arrayWithObjects:firstRequestArray, nil];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       [webData queryForStringwithAsync:@"EQGetScheduleRequestInComplete.php" parameters:secondRequestArray completion:^(EQRScheduleRequestItem *chosenItem) {
           
           if (!chosenItem){
               NSLog(@"EQRCheckVCntrllr > printPageWithScheduleRequestItemKey fails, no request");
               return;
           }
           
           //add the notes
           chosenItem.notes = self.notesText;
           
           //add contact information
           NSString* email;
           NSString* phone;
           if (self.myScheduleRequestItem.contactNameItem){
               email = self.myScheduleRequestItem.contactNameItem.email;
               phone = self.myScheduleRequestItem.contactNameItem.phone;
               
               chosenItem.contactNameItem = self.myScheduleRequestItem.contactNameItem;
           }
           
           //create printable page view controller
           EQRCheckPrintPage* pageForPrint = [[EQRCheckPrintPage alloc] initWithNibName:@"EQRCheckPrintPage" bundle:nil];
           
           //add the request item to the view controller
           [pageForPrint initialSetupWithScheduleRequestItem:chosenItem forPDF:NO];
           
           //assign ivar variables
           pageForPrint.rentorNameAtt = chosenItem.contact_name;
           pageForPrint.rentorEmailAtt = email;
           pageForPrint.rentorPhoneAtt = phone;
           
           //show the view controller
           [self presentViewController:pageForPrint animated:YES completion:^{ }];
       }];
    });
}


-(IBAction)markAsIncomplete:(id)sender{
    
    //MUST CHECK THAT THE USER HAS LOGGED IN FIRST:
    EQRStaffUserManager* staffManager = [EQRStaffUserManager sharedInstance];
    if (!staffManager.currentStaffUser){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Current User" message:@"Please log in as a user before marking an item complete or incomplete" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {  }];
        
        [alert addAction:alertOk];
        [self presentViewController:alert animated:YES completion:^{  }];
        
        return;
    }

    [self.cellContent dismissedCheckInOut:self.scheduleRequestKeyID complete:@"incomplete" returning:self.marked_for_returning switch:self.switch_num outstanding:[NSNumber numberWithBool:0]];
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
}


#pragma mark - receive messages from row content

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)updateArrayOfJoins:(NSNotification*)note{
    
    NSString* joinKeyID = [[note userInfo] objectForKey:@"joinKeyID"];
    NSString* joinProperty = [[note userInfo] objectForKey:@"joinProperty"];
    NSString* verdict = [[note userInfo] objectForKey: @"markedAsYes"];
    BOOL isContentForMiscJoin = [[[note userInfo] objectForKey:@"isContentForMiscJoin"] boolValue];
    
    if (isContentForMiscJoin == NO){
        for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in self.arrayOfEquipJoins){
            
            if ([joinItem.key_id isEqualToString:joinKeyID]){
                
                //gotta cutoff the "_flag" at the end or else is will capitalize the "F"
                NSUInteger thisLength = [joinProperty length];
                NSRange newRange = NSMakeRange(0, thisLength - 5);
                NSString* joinSubstring = [joinProperty substringWithRange:newRange];
                
                NSString* joinPropertyWithCap = [joinSubstring capitalizedString];
                NSString* joinPropertySetMethod = [NSString stringWithFormat:@"set%@_flag:", joinPropertyWithCap];
                SEL mySelector = NSSelectorFromString(joinPropertySetMethod);
                
                if ([joinItem respondsToSelector:mySelector]){
                    
                    [joinItem performSelector:mySelector withObject:verdict];
                }
                break;
            }
        }
        
    }else{
        
        for (EQRMiscJoin* miscJoin in self.arrayOfMiscJoins){
            
            if ([miscJoin.key_id isEqualToString:joinKeyID]){
                
                //gotta cutoff the "_flag" at the end or else is will capitalize the "F"
                NSUInteger thisLength = [joinProperty length];
                NSRange newRange = NSMakeRange(0, thisLength - 5);
                NSString* joinSubstring = [joinProperty substringWithRange:newRange];
                
                NSString* joinPropertyWithCap = [joinSubstring capitalizedString];
                NSString* joinPropertySetMethod = [NSString stringWithFormat:@"set%@_flag:", joinPropertyWithCap];
                SEL mySelector = NSSelectorFromString(joinPropertySetMethod);
                
                if ([miscJoin respondsToSelector:mySelector]){
                    
                    [miscJoin performSelector:mySelector withObject:verdict];
                }
                break;
            }
        }
    }
}
#pragma clang diagnostic pop



-(void)addJoinKeyIDToBeDeletedArray:(NSNotification*)note{
    
    BOOL isContentForMiscJoin = [[note.userInfo objectForKey:@"isContentForMiscJoin"] boolValue];
    
    if (isContentForMiscJoin == NO){
        [self.arrayOfToBeDeletedEquipIDs addObject:[note.userInfo objectForKey:@"key_id"]];
    }else{
        [self.arrayOfToBeDeletedMiscJoins addObject:[note.userInfo objectForKey:@"key_id"]];
    }
    
}

-(void)removeJoinKeyIDToBeDeletedArray:(NSNotification*)note{
    
    BOOL isContentForMiscJoin = [[note.userInfo objectForKey:@"isContentForMiscJoin"] boolValue];
    
    NSString* stringToBeRemoved;
    
    if (isContentForMiscJoin == NO){
        for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
            
            if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
                
                stringToBeRemoved = thisString;
            }
        }
        [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
        
    }else{
        
        for (NSString* thisString in self.arrayOfToBeDeletedMiscJoins){
            
            if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
                
                stringToBeRemoved = thisString;
            }
        }
        [self.arrayOfToBeDeletedMiscJoins removeObject:stringToBeRemoved];
    }
}


-(void)distIDPickerTapped:(NSNotification*)note{
    
    // Get cell's equipUniqueKey and IndexPath and button's frame?? UIButton??
//    NSString* joinKey_ID = [[note userInfo] objectForKey:@"joinKey_id"];
    NSString* equipTitleItem_foreignKey = [[note userInfo] objectForKey:@"equipTitleItem_foreignKey"];
    NSString* equipUniqueItem_foreignKey = [[note userInfo] objectForKey:@"equipUniqueItem_foreignKey"];
//    NSIndexPath* thisIndexPath = [[note userInfo] objectForKey:@"indexPath"];
    CGRect buttonRect = [(UIButton*)[[note userInfo] objectForKey:@"distButton"] frame];
    UIButton* thisButton = (UIButton*)[[note userInfo] objectForKey:@"distButton"];
    
    
    EQRDistIDPickerTableVC* distIDPickerVC = [[EQRDistIDPickerTableVC alloc] initWithNibName:@"EQRDistIDPickerTableVC" bundle:nil];
    self.distIDPickerVC = distIDPickerVC;
    
    // Initial setup
    [distIDPickerVC initialSetupWithOriginalUniqueKeyID:equipUniqueItem_foreignKey equipTitleKey:equipTitleItem_foreignKey scheduleItem:self.myScheduleRequestItem];
    distIDPickerVC.delegate = self;
    
    CGRect fixedRect2 = [thisButton.superview.superview convertRect:buttonRect fromView:thisButton.superview];
    CGRect fixedRect3 = [thisButton.superview.superview.superview convertRect:fixedRect2 fromView:thisButton.superview.superview];
    CGRect fixedrect4 = [thisButton.superview.superview.superview.superview convertRect:fixedRect3 fromView:thisButton.superview.superview.superview];
    CGRect fixedRect5 = [thisButton.superview.superview.superview.superview.superview convertRect:fixedrect4 fromView:thisButton.superview.superview.superview.superview];
    CGRect fixedRect6 = [thisButton.superview.superview.superview.superview.superview.superview convertRect:fixedRect5 fromView:thisButton.superview.superview.superview.superview.superview];
    CGRect fixedRect7 = [thisButton.superview.superview.superview.superview.superview.superview.superview convertRect:fixedRect6 fromView:thisButton.superview.superview.superview.superview.superview.superview];
    
    distIDPickerVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [distIDPickerVC popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popover.sourceRect = fixedRect7;
    popover.sourceView = self.view;
    popover.delegate = self;
    
    [self presentViewController:distIDPickerVC animated:YES completion:^{ }];
}


-(void)distIDSelectionMadeWithOriginalEquipUniqueKey:(NSString*)originalKeyID equipUniqueItem:(id)distEquipUniqueItem{
    
    //____!!!!!! INDEXPATH IS MEANINGLESS! BECAUSE THAT'S THE PATH IN THE STRUCTRED ARRAY, BUT WE NEED TO UPDATE THE
    //____!!!!!! UNSTRUCTURED ARRAY AS WELL  !!!____
    // Retrieve key id of selected equipUniqueItem AND indexPath of the collection cell that initiated the distID picker
    // Tell content of the cell to use replace the dist ID
    // Update the data model > schedule_equip_join has new unique_foreignKey
    
    // Extract the unique's key as a string
    NSString* thisIsTheKey = [(EQREquipUniqueItem*)distEquipUniqueItem key_id];
    NSString* thisIsTheDistID = [(EQREquipUniqueItem*)distEquipUniqueItem distinquishing_id];
    NSString* thisIsTheIssueShortName = [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name];
    NSString* thisIsTheStatusLevel = [(EQREquipUniqueItem*)distEquipUniqueItem status_level];
    
    EQRScheduleTracking_EquipmentUnique_Join* saveThisJoin;
    
    // Update local ivar arrays
    for (EQRScheduleTracking_EquipmentUnique_Join* joinObj in self.arrayOfEquipJoins){
        
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
    self.arrayOfEquipJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfEquipJoins withMiscJoins:self.arrayOfMiscJoins];
    
    // Renew the collection view
    [self.myEquipCollection reloadData];
    
    // Update the data layer
    NSArray* topArray = @[ @[@"key_id", [saveThisJoin key_id]],
                           @[@"equipUniqueItem_foreignKey", [saveThisJoin equipUniqueItem_foreignKey]],
                           @[@"equipTitleItem_foreignKey", [saveThisJoin equipTitleItem_foreignKey]] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQAlterScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnString) {
            if (!returnString){
                NSLog(@"EQRCheckVC > distIDSelectionMade..., failed to alter schedule equip join");
            }
            
            // Send note to schedule that a change has been saved
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        }];
    });
    
    [self.distIDPickerVC setDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:^{ }];
    
    // Gracefully dealloc all the objects in the content VC
    [self.distIDPickerVC resetDistIdPicker];
}


#pragma mark - popover delegate methods
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    
    if ([popoverPresentationController presentedViewController] == self.distIDPickerVC){
        NSLog(@"popover found a match to distIDPickerVC");
        [self.distIDPickerVC setDelegate:nil];
        
        // Gracefully dealloc all the objects in the content VC
        [self.distIDPickerVC resetDistIdPicker];
    }
}


#pragma mark - handle add equip item
-(IBAction)addEquipItem:(id)sender{
    
    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    [genericEquipVCntrllr overrideSharedRequestManager:self.privateRequestManager];
    
    // Save the current content offset to return to the same place
    self.myEquipCollectionContentOffset = self.myEquipCollection.contentOffset;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:genericEquipVCntrllr];
    
    navController.modalPresentationStyle = UIModalPresentationPageSheet;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(continueAddEquipItem:)];
    [genericEquipVCntrllr.navigationItem setLeftBarButtonItem:leftButton];
    [genericEquipVCntrllr.navigationItem setRightBarButtonItem:rightButton];
    
    [self presentViewController:navController animated:YES completion:^{
        // Need to reprogram the target of the save button
        [genericEquipVCntrllr.continueButton removeTarget:genericEquipVCntrllr action:NULL forControlEvents:UIControlEventAllEvents];
        [genericEquipVCntrllr.continueButton addTarget:self action:@selector(continueAddEquipItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
}


- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


-(IBAction)continueAddEquipItem:(id)sender{
    
    // Replaces the uniqueItem key from "1" to an accurate value
    [self.privateRequestManager justConfirm];
    
    [self dismissViewControllerAnimated:YES completion:^{ }];

    // Renew the list of joins by going to the data layer
    [self initialSetupStage2];
    
    [self.myEquipCollection setContentOffset:self.myEquipCollectionContentOffset];
}


#pragma mark - staff picker method
-(void)showStaffUserPicker{
    
    EQRStaffUserPickerViewController* staffUserPicker = [[EQRStaffUserPickerViewController alloc] initWithNibName:@"EQRStaffUserPickerViewController" bundle:nil];
    self.staffUserPicker = staffUserPicker;
    
    staffUserPicker.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [staffUserPicker popoverPresentationController];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popover.barButtonItem = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
    
    [self presentViewController:staffUserPicker animated:YES completion:^{
        // Set target of continue button
        [staffUserPicker.continueButton addTarget:self action:@selector(dismissStaffUserPicker) forControlEvents:UIControlEventTouchUpInside];
    }];
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


#pragma mark - capture signature
- (IBAction)captureSig:(id)sender{
    
    UIStoryboard *captureStoryboard = [UIStoryboard storyboardWithName:@"SigCapture" bundle:nil];
    UINavigationController *newView = [captureStoryboard instantiateViewControllerWithIdentifier:@"main"];
    newView.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:newView animated:YES completion:^{
        
        // This is ugly, it assumes the subclass type of VC at the root of the nav controller
        [(EQRSigCaptureMainVC*)[[newView viewControllers] objectAtIndex:0] setDelegate:self];
        [(EQRSigCaptureMainVC*)[[newView viewControllers] objectAtIndex:0] loadTheDataWithRequestItem:self.myScheduleRequestItem];
    }];
}


-(void)pdfHasCompletedWithName:(NSString *)pdfName timestamp:(NSDate *)pdfTimestamp{
    if (pdfTimestamp){
        // Update view with sig confirmation
        self.xLabel.hidden = NO;
        
        // Update local request with pdf timestamp and name
        self.myScheduleRequestItem.pdf_name = pdfName;
        self.myScheduleRequestItem.pdf_timestamp = pdfTimestamp;
        
        // Update database with pdf timestamp and name
        NSString *dateAsString = [EQRDataStructure dateAsString:self.myScheduleRequestItem.pdf_timestamp];
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        webData.delegateDataFeed = self;
        NSArray *firstArray = @[@"key_id", self.myScheduleRequestItem.key_id];
        NSArray *secondArray = @[@"pdf_name", self.myScheduleRequestItem.pdf_name];
        NSArray *thirdArray = @[@"pdf_timestamp", dateAsString];
        NSArray *topArray = @[firstArray, secondArray, thirdArray];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
           
            [webData queryForStringwithAsync:@"EQAlterPDFInScheduleRequest.php" parameters:topArray completion:^(NSString *object) {
            }];
        });
    }
}


#pragma mark - price matrix
- (IBAction)showPricingButton:(id)sender{
    
    UIStoryboard *captureStoryboard = [UIStoryboard storyboardWithName:@"Pricing" bundle:nil];
    EQRAlternateWrappperPriceMatrix *newView = [captureStoryboard instantiateViewControllerWithIdentifier:@"price_alternate_wrapper"];
    newView.delegate = self;
    
    newView.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:newView animated:YES completion:^{
        
        // Provide VC with request information
        [newView provideScheduleRequest:self.privateRequestManager.request];
    }];
    //    newView.edgesForExtendedLayout = UIRectEdgeAll;
    //    [self.navigationController pushViewController:newView animated:YES];
}


#pragma mark - EQRPriceMatrixVC delegate method
-(void)aChangeWasMadeToPriceMatrix{
    [self getTransactionInfo];
}


- (void)getTransactionInfo{
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.privateRequestManager.request.key_id];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQGetTransactionWithScheduleRequestKey.php" parameters:topArray completion:^(EQRTransaction *transaction) {
            
            if (transaction){
                self.myTransaction = transaction;
                // Found a matching transaction for this schedule Request, go on...
                [self populatePricingWidget];
            }else{
                // No matching transaction, create a fresh one.
                [self.priceWidget deleteExistingData];
            }
        }];
    });
}


- (void)populatePricingWidget{
    if (self.myTransaction){
        [self.priceWidget initialSetupWithTransaction:self.myTransaction];
    }else{
        [self.priceWidget deleteExistingData];
    }
}


#pragma mark - webdata delegate methods
- (void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    // Abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"inside EQRCheckVC, cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
}


-(void)addRequestObject:(id)currentThing{
    if (!currentThing){
        return;
    }
    // Set reqeust item property
    self.myScheduleRequestItem = currentThing;
    
    // Set notes for display
    self.notesText = self.myScheduleRequestItem.notes;
}


- (void)addContactComplete:(id)currentThing{
    if (!currentThing){
        return;
    }
    // Set property
    self.tempContact = currentThing;
}


- (void)addEquipJoinToArray:(id)currentThing{
    float delayTime = 0.0;
    [self performSelector:@selector(addEquipJoinToArrayAfterDelay:) withObject:currentThing afterDelay:delayTime];
}


-(void)addMiscJoinToArray:(id)currentThing{
    if (!currentThing){
        return;
    }
    
    [self.arrayOfMiscJoins addObject:currentThing];
    [self genericAddItemToArray:currentThing];
}


- (void)addEquipJoinToArrayAfterDelay:(id)currentThing{
    if (!currentThing){
        return;
    }
    
    [self.arrayOfEquipJoins addObject:currentThing];
    [self genericAddItemToArray:currentThing];
}


-(void)genericAddItemToArray:(id)currentThing{
    if (!currentThing){
        return;
    }

    NSMutableArray *newSubArray = [NSMutableArray arrayWithCapacity:1];
    
    if (self.arrayOfEquipJoinsWithStructure){
        if ([self.arrayOfEquipJoinsWithStructure count] > 0){
            [newSubArray addObjectsFromArray:[self.arrayOfEquipJoinsWithStructure objectAtIndex:0]];
            [newSubArray addObject:currentThing];
            self.arrayOfEquipJoinsWithStructure = [NSArray arrayWithObject:newSubArray];
        }else{  //if no sub array exists yet
            [newSubArray addObject:currentThing];
            self.arrayOfEquipJoinsWithStructure = [NSArray arrayWithObject:newSubArray];
        }
    }else{  // If the main array doesn't exist yet
        [newSubArray addObject:currentThing];
        self.arrayOfEquipJoinsWithStructure = [NSArray arrayWithObject:newSubArray];
    }
    
    
    //________!!!!!!!!!!!   USE THIS TO TURN OFF ANIMATED INSERTIONS   !!!!!!!!!!_________
    [self.myEquipCollection reloadData];
    //_____________
    
    //________THIS WORKS BUT IT DOESN'T REALLY HELP AND IT ADDS A SMALL AMOUNT OF TIME______
//    [self.myEquipCollection performBatchUpdates:^{
//    
//        if ([self.myEquipCollection numberOfSections] == 0){
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
//            [self.myEquipCollection insertSections:indexSet];
//        }
//        
//        //insert row in the collection view
//        NSIndexPath *thisIndexPath = [NSIndexPath indexPathForRow:[newSubArray count] - 1 inSection:0];
//        NSMutableArray *tempArray = [NSMutableArray arrayWithObject:thisIndexPath];
//        [self.myEquipCollection insertItemsAtIndexPaths:tempArray];
//        
//    } completion:^(BOOL finished) {
//        NSLog(@"finished batch updates");
//    }];
    
}


#pragma mark - UISearchResultsUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.mySearchController.searchBar text];
    
    if ([searchString isEqualToString:@""]){
        searchString = @" ";
    }
    
    NSString *scope = nil;
    [self filterContentForSearchText:searchString scope:scope];
    [self.myEquipCollection reloadData];
}


#pragma mark - UISearchBarDelegate
// Workaround for bug: -updateSearchResultsForSearchController: is not
// called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.mySearchController];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{

//#ifdef __IPHONE_11_0
//    if (@available(iOS 11.0, *)) {
//        self.navigationItem.searchController = self.mySearchController;
//    }
//#endif
    
    //change background color
    EQRColors *colors = [EQRColors sharedInstance];
    self.rightSubviewTopBar.backgroundColor = [colors.colorDic objectForKey:EQRColorFilterBarAndSearchBarBackground];
    self.searchBoxView.backgroundColor = [colors.colorDic objectForKey:EQRColorFilterBarAndSearchBarBackground];
    self.mySearchController.searchBar.tintColor = [UIColor whiteColor];
    self.mySearchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.mySearchController.searchBar.barTintColor = [colors.colorDic objectForKey:EQRColorFilterBarAndSearchBarBackground];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{

//#ifdef __IPHONE_11_0
//    if (@available(iOS 11.0, *)) {
//        [self.searchBoxView addSubview:self.mySearchController.view];
//        self.navigationItem.searchController = nil;
//    }
//#endif
    
    //change background color
    self.rightSubviewTopBar.backgroundColor = [UIColor whiteColor];
    self.searchBoxView.backgroundColor = [UIColor whiteColor];
    self.mySearchController.searchBar.tintColor = nil;
    self.mySearchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
}


#pragma mark - UISearchControllerDelegate methods
- (void)didPresentSearchController:(UISearchController *)searchController {
    // Somewhere after searchBarTextDidBeginEditing: and willPresentSearchController, the frame for the searchbar changes to
    // width of the device's screen size. Super annoying
    self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
}


- (void)didDismissSearchController:(UISearchController *)searchController {
    self.mySearchController.searchBar.frame = CGRectMake(0, 0, self.searchBoxView.frame.size.width, self.searchBoxView.frame.size.height);
}


#pragma mark - Content Filtering
//Basically, a predicate is an expression that returns a Boolean value (true or false). You specify the search criteria in the format of NSPredicate and use it to filter data in the array. As the search is on the name of recipe, we specify the predicate as “name contains[c] %@”. The “name” refers to the name property of the Recipe object. NSPredicate supports a wide range of filters including: BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS. Here we choose to use the “contains” filter. The operator “[c]” means the comparison is case-insensitive.

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchResultArrayOfEquipTitles = [self.arrayOfEquipJoins filteredArrayUsingPredicate:resultPredicate];
}


#pragma mark - datasource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    //test if in search, tap out with 1
    if (self.mySearchController.active){
        return 1;
    }else{
        return [self.arrayOfEquipJoinsWithStructure count];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //test if in search, tap out with count of search array
    if (self.mySearchController.active){
        return [self.searchResultArrayOfEquipTitles count];
    }
    
    return  [[self.arrayOfEquipJoinsWithStructure objectAtIndex:section] count];
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //__1__ An equipUniqueJoin item
    //__2__ A MiscJoin Item
    
    //_______determine either search results table or normal table
    if (self.mySearchController.active) {
        
        EQRCheckRowCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell.backgroundColor = [UIColor whiteColor];
        
        //tell the cell's contentVC to be marked for deletion or not
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
            
            if ([keyToDelete isEqualToString:[[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row] key_id]]){
                
                toBeDeleted = YES;
                break;
            }
        }
        
        //cell setup
        [cell initialSetupWithEquipUnique:[self.searchResultArrayOfEquipTitles objectAtIndex:indexPath.row]
                                   marked:self.marked_for_returning
                               switch_num:self.switch_num
                        markedForDeletion:toBeDeleted
                                indexPath:indexPath];
        
        return cell;
    }
    
    if ([[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] respondsToSelector:@selector(schedule_grouping)]){
        
        EQRCheckRowCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell.backgroundColor = [UIColor whiteColor];
        
        //tell the cell's contentVC to be marked for deletion or not
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
            
            if ([keyToDelete isEqualToString:[[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id]]){
                
                toBeDeleted = YES;
                break;
            }
        }
        
        //cell setup
        [cell initialSetupWithEquipUnique:[(NSArray*)[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]
                                   marked:self.marked_for_returning
                               switch_num:self.switch_num
                        markedForDeletion:toBeDeleted
                                indexPath:indexPath];
        
        
        return cell;
        
    }else{  //a misc item
        
        EQRCheckRowMiscItemCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:@"CellForMiscJoin" forIndexPath:indexPath];
        
        //remove subviews
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //and reset the cell's background color...
        cell.backgroundColor = [UIColor whiteColor];
        
        //tell the cell's contentVC to be marked for deletion or not
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedMiscJoins){
            
            if ([keyToDelete isEqualToString:[[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id]]){
                
                toBeDeleted = YES;
                break;
            }
        }
        
        //cell setup
        [cell initialSetupWithMiscJoin:[(NSArray*)[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]
                                   marked:self.marked_for_returning
                               switch_num:self.switch_num
                        markedForDeletion:toBeDeleted
                                indexPath:indexPath];
        
        return cell;
    }
};


#pragma mark - section header data source methods
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SupplementaryCell";
    EQRCheckHeaderCell* cell = [self.myEquipCollection dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews?????
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    //test if in search mode, and tap out
    if (self.mySearchController.active){
        [cell initialSetupWithCategoryText:@"Search Results"];
        return  cell;
    }
    
    if ([[[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:0] respondsToSelector:@selector(schedule_grouping)]){
        NSString* categoryStringValue = [(EQRScheduleTracking_EquipmentUnique_Join*)[(NSArray*)[self.arrayOfEquipJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] schedule_grouping];
        
        [cell initialSetupWithCategoryText:categoryStringValue];
    }else{
        
        [cell initialSetupWithCategoryText:@"Miscellaneous"];
    }
    
    return cell;
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.privateRequestManager = nil;
}


#pragma mark - memory warning
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
