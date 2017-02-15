//
//  EQRInboxRightVC.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRInboxRightVC.h"
#import "EQRInboxLeftTableVC.h"
#import "EQRStaffUserManager.h"
#import "EQRWebData.h"
#import "EQRStaffUserPickerViewController.h"
#import "EQRContactNameItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRDataStructure.h"
#import "EQRGlobals.h"
#import "EQRModeManager.h"
#import "EQRTextEmailStudent.h"
#import "EQREquipItem.h"
#import "EQREditorDateVCntrllr.h"
#import "EQREditorExtendedDateVC.h"
#import "EQREditorEquipListCell.h"
#import "EQREditorHeaderCell.h"
#import "EQREquipUniqueItem.h"
#import "EQREquipSelectionGenericVCntrllr.h"
#import "EQRScheduleRequestManager.h"
#import "EQRColors.h"
#import "EQRMiscJoin.h"
#import "EQRPriceMatrixVC.h"
#import "EQRAlternateWrappperPriceMatrix.h"
#import "EQRTextElement.h"
#import "EQRPricingWidgetVC.h"
#import "EQRTransaction.h"
#import "EQRCheckPrintPage.h"

@interface EQRInboxRightVC () <EQRWebDataDelegate, EQRPriceMatrixDelegate>

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequest;
@property (strong, nonatomic) EQRTransaction *myTransaction;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tableTopGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tablebottomGuideConstraint;

@property (strong, nonatomic) IBOutlet UICollectionView* myTable;
@property (strong, nonatomic) IBOutlet UIView* rightView;
@property (strong, nonatomic) IBOutlet UIView* leftView;

@property (strong, nonatomic) IBOutlet UILabel* timeOfRequestValue;
@property (strong, nonatomic) IBOutlet UILabel* firstLastNameValue;
@property (strong, nonatomic) IBOutlet UILabel* typeValue;
@property (strong, nonatomic) IBOutlet UILabel* classValue;
@property (strong, nonatomic) IBOutlet UILabel* pickUpTimeValue;
@property (strong, nonatomic) IBOutlet UILabel* returnTimeValue;

@property (strong, nonatomic) IBOutlet UIView* viewEditLeft;
@property (strong, nonatomic) IBOutlet UIButton* nameValueField;
@property (strong, nonatomic) IBOutlet UIButton* typeValueField;
@property (strong, nonatomic) IBOutlet UIButton* classValueField;
@property (strong, nonatomic) IBOutlet UIButton *removeClassButton;
@property (strong, nonatomic) IBOutlet UIButton* pickUpTimeValueField;
@property (strong, nonatomic) IBOutlet UIButton* returnTimeValueField;
@property (strong, nonatomic) IBOutlet UITextView* notesView;

@property (strong, nonatomic) IBOutlet UIView *priceMatrixSubView;
@property (strong, nonatomic) EQRPricingWidgetVC *priceWidget;

@property (strong, nonatomic) IBOutlet UIView* addButtonView;
@property (strong, nonatomic) IBOutlet UIView* doneButtonView;

@property (strong, nonatomic) NSArray* arrayOfJoins;
@property (strong, nonatomic) NSMutableArray *arrayOfMiscJoins;
@property (strong, nonatomic) NSArray* arrayOfJoinsWithStructure;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedMiscJoins;

//popOver controllers
@property (strong, nonatomic) UIPopoverController* myStaffUserPicker;
@property (strong, nonatomic) UIPopoverController* myDayDatePicker;
@property (strong, nonatomic) UIPopoverController* myContactPicker;
@property (strong, nonatomic) UIPopoverController* myRenterTypePicker;
@property (strong, nonatomic) UIPopoverController* myClassPicker;
@property (strong, nonatomic) UIPopoverController* distIDPopover;
@property (strong, nonatomic) UIPopoverController* myNotesPopover;

//popOver root VCs
@property (strong, nonatomic) EQREditorDateVCntrllr* myDayDateVC;
@property (strong, nonatomic) EQRContactPickerVC* myContactVC;
@property (strong, nonatomic) EQREditorRenterVCntrllr* myRenterTypeVC;
@property (strong, nonatomic) EQRClassPickerVC* myClassPickerVC;

//navigation controllers
@property (strong, nonatomic) UINavigationController* contactNavController;

//items for the add equip item function
@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
@property (strong, nonatomic) UIPopoverController* myAddEquipPopover;

//alerts
@property (strong, nonatomic) UIAlertView *confirmationAlert;
@property (strong, nonatomic) UIAlertView *sendEmailAlert;

@property (strong, nonatomic) NSString *myEmailSignature;
@property BOOL inEditModeFlag;
@property BOOL aChangeWasMade;

//queues
@property (strong, nonatomic) NSOperationQueue *renewTheViewQueue;


@end

@implementation EQRInboxRightVC

@synthesize delegateForRightSide;


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
    
    //add right side buttons in nav item
//    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(sendEmail)]];
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    //receive changes to the schedule to update the existing view
    [nc addObserver:self selector:@selector(raiseFlagThatAChangeHasBeenMade:) name:EQRAChangeWasMadeToTheSchedule object:nil];
    [nc addObserver:self selector:@selector(raiseFlagThatDatabaseChanged:) name:EQRAChangeWasMadeToTheDatabaseSource object:nil];
    
    //register to receive delete instructions from equipList cells
//    [nc addObserver:self selector:@selector(addEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeleted object:nil];
//    [nc addObserver:self selector:@selector(removeEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeletedCancel object:nil];
    
    //set local flags
    self.inEditModeFlag = NO;
    
    //derive the current user name
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* logText = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    
    //uibar buttons
    //create fixed spaces
    UIBarButtonItem* twentySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    twentySpace.width = 20;
    UIBarButtonItem* thirtySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    thirtySpace.width = 30;
    
    //right buttons
    UIBarButtonItem* editModeBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditMode)];
    
    UIBarButtonItem* composeEmailBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeEmail)];
    
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:logText style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
    UIBarButtonItem* confirmBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    
    UIBarButtonItem* printBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(printMeForReal:)];
    
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, thirtySpace, editModeBarButton, twentySpace, composeEmailBarButton, twentySpace, confirmBarButton, twentySpace, printBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];
    
    //register cells
    [self.myTable registerClass:[EQREditorEquipListCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.myTable registerClass:[EQREditorMiscListCell class] forCellWithReuseIdentifier:@"CellForMiscJoin"];
    [self.myTable registerClass:[EQREditorHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SuppCell"];
    
    //initialize array of to be deleted joins
    if (!self.arrayOfToBeDeletedEquipIDs){
        self.arrayOfToBeDeletedEquipIDs = [NSMutableArray arrayWithCapacity:1];
    } else {
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    }
    
    if (!self.arrayOfToBeDeletedMiscJoins){
        self.arrayOfToBeDeletedMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }else{
        [self.arrayOfToBeDeletedMiscJoins removeAllObjects];
    }
    
    //initially hide everything
    [self.leftView setHidden:YES];
    [self.rightView setHidden:YES];
    [self.viewEditLeft setHidden:YES];
    [self.addButtonView setHidden:YES];
    [self.doneButtonView setHidden:YES];
    
    //get shared email signature
    [self getEmailSignatureFromDB];
    
    EQRPricingWidgetVC *priceWidget = [[EQRPricingWidgetVC alloc] initWithNibName:@"EQRPricingWidgetVC" bundle:nil];
    self.priceWidget = priceWidget;
    CGRect tempRect = CGRectMake(0, 0, self.priceMatrixSubView.frame.size.width, self.priceMatrixSubView.frame.size.height);
    priceWidget.view.frame = tempRect;
    
    [self.priceMatrixSubView addSubview:self.priceWidget.view];
    
    //set button target
    [self.priceWidget.editButton addTarget:self action:@selector(showPricingButton:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    [self.splitViewController setDelegate:self];
}


-(void)viewWillAppear:(BOOL)animated{
    
    if (self.aChangeWasMade == YES){
        
        self.aChangeWasMade = NO;
        
        if (self.myScheduleRequest == nil){
            //do nothing when no item is currently loaded into the rightView
        }else{
            [self retrieveRequestItemWithRequestKeyID:self.myScheduleRequest.key_id];
        }
    }
    
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
    
    //drop exisiting constraints
    //_____THIS IS NECESSARY BECAUSE NIBS REALLY HATE IT IF YOU LEAVE OUT ANY CONSTRAINTS __
    //_____THESE WERE ONLY TEMPORARY TO SATISIFY THE NIB FROM SCREAMING ERROR MESSAGES____
    [[self.mainSubView superview] removeConstraints:[NSArray arrayWithObjects:self.topLayoutGuideConstraint, self.bottomLayoutGuideConstraint, nil]];
    
    //add replacement constraints
    [[self.mainSubView superview] addConstraints:constraint_POS_V];
    [[self.mainSubView superview] addConstraints:constraint_POS_VB];
    
    //reassign constraint ivars!!
    self.topLayoutGuideConstraint = [constraint_POS_V objectAtIndex:0];
    self.bottomLayoutGuideConstraint = [constraint_POS_VB objectAtIndex:0];
    
    
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated{
    
    //set title on bar button item
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];

    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
}


-(void)viewDidLayoutSubviews{
    
    //can query topLayoutGuide or bottomLayoutGuide from within this method
    
//    NSLog(@"this is bottomLayoutGuide length: %5.2f", self.bottomLayoutGuide.length);
//    
//    NSLog(@"this is the CONTAINER view's bottomLayoutGuide length: %5.2f", self.splitViewController.navigationController.bottomLayoutGuide.length);
}


-(void)retrieveRequestItemWithRequestKeyID:(NSString*)keyID{
    
    if (keyID == nil){
        return;
    }
    
    //use this when a change to dates may have occured in the scheduleRequest
    NSArray* topArray = @[ @[@"key_id", keyID] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQGetScheduleRequestInComplete.php" parameters:topArray completion:^(EQRScheduleRequestItem *thisItem) {
           
           if (!thisItem){
               NSLog(@"InboxRightVC > retrieveRequestItemWith... no request items returned");
               return;
           }
           [self renewTheViewWithRequest:thisItem];
       }];
    });
}


-(void)renewTheViewWithRequest:(EQRScheduleRequestItem*)request{
    
    self.myScheduleRequest = request;
    
    // Empty out fields
    self.firstLastNameValue.text = @"";
    self.typeValue.text = @"";
    self.timeOfRequestValue.text = @"";
    self.pickUpTimeValue.text = @"";
    self.returnTimeValue.text = @"";
    [self.nameValueField setTitle:self.firstLastNameValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.typeValueField setTitle:self.typeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.pickUpTimeValueField setTitle:self.pickUpTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.returnTimeValueField setTitle:self.returnTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    self.classValue.text = @"";
    [self.classValueField setTitle:self.classValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    self.notesView.text = @"";
    self.arrayOfJoinsWithStructure = @[];
    [self.myTable reloadData];
    self.priceMatrixSubView.hidden = YES;
    
    if (!request) {
        // Make subviews invisible
        [self exitEditMode];
        [self.rightView setHidden:YES];
        [self.leftView setHidden:YES];
        return;
    }
    
    // Make subviews visible if not otherwise
    [self.rightView setHidden:NO];
    [self.leftView setHidden:NO];
    
    
    if (!self.renewTheViewQueue){
        self.renewTheViewQueue = [[NSOperationQueue alloc] init];
        self.renewTheViewQueue.name = @"renewTheViewQueue";
        self.renewTheViewQueue.maxConcurrentOperationCount = 1;
    }
    [self.renewTheViewQueue cancelAllOperations];
    
    
    NSBlockOperation *nameAndDates = [NSBlockOperation blockOperationWithBlock:^{
        // Date formats
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"EEE, MMM d, yyyy";
        
        NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        timeFormatter.dateFormat = @"h:mm aaa";
        
        NSDateFormatter* submitFormatter = [[NSDateFormatter alloc] init];
        submitFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        submitFormatter.dateFormat = @"EEEE, MMM d, yyyy, h:mm aaa";
        
        NSString* pickUpDateString = [dateFormatter stringFromDate:self.myScheduleRequest.request_date_begin];
        NSString* pickUpTimeString = [timeFormatter stringFromDate:self.myScheduleRequest.request_time_begin];
        NSString* returnDateString = [dateFormatter stringFromDate:self.myScheduleRequest.request_date_end];
        NSString* returnTimeString = [timeFormatter stringFromDate:self.myScheduleRequest.request_time_end];
        NSString* timeOfRequest = [submitFormatter stringFromDate:self.myScheduleRequest.time_of_request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Set label values
            self.firstLastNameValue.text = self.myScheduleRequest.contact_name;
            self.typeValue.text = self.myScheduleRequest.renter_type;
            
            self.timeOfRequestValue.text = timeOfRequest;
            self.pickUpTimeValue.text = [NSString stringWithFormat:@"%@ - %@", pickUpDateString, pickUpTimeString];
            self.returnTimeValue.text = [NSString stringWithFormat:@"%@ - %@", returnDateString, returnTimeString];
            
            //copy values to edit field values
            [self.nameValueField setTitle:self.firstLastNameValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
            [self.typeValueField setTitle:self.typeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
            [self.pickUpTimeValueField setTitle:self.pickUpTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
            [self.returnTimeValueField setTitle:self.returnTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
        });
        
    }];
    
    
    NSBlockOperation *class = [NSBlockOperation blockOperationWithBlock:^{
        // Get class name using key
        if (([self.myScheduleRequest.classTitle_foreignKey isEqualToString:EQRErrorCode88888888]) ||
            ([self.myScheduleRequest.classTitle_foreignKey isEqualToString:@""]) ||
            (!self.myScheduleRequest.classTitle_foreignKey)) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.classValue.text = @"(No Class Selected)";
                [self.classValueField setTitle:self.classValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
            });
            
        }else{
            NSArray* topArray = @[ @[@"key_id", self.myScheduleRequest.classTitle_foreignKey] ];
            
            EQRWebData* webData = [EQRWebData sharedInstance];
            NSString *catalogTitle = [webData queryForStringWithLink:@"EQGetClassCatalogTitleWithKey.php" parameters:topArray];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.classValue.text = catalogTitle;
                [self.classValueField setTitle:self.classValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
            });
        }
    }];
    
    
    NSBlockOperation *notes = [NSBlockOperation blockOperationWithBlock:^{
        // Set text in notes
        NSArray* justTopArray = @[ @[@"key_id", self.myScheduleRequest.key_id] ];
        NSMutableArray* tempMuteArrayJustKey = [NSMutableArray arrayWithCapacity:1];
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:justTopArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            
            for (EQRScheduleRequestItem* requestItem in muteArray){
                [tempMuteArrayJustKey addObject:requestItem];
            }
        }];
        
        if ([tempMuteArrayJustKey count] > 0){
            self.myScheduleRequest.notes = [[tempMuteArrayJustKey objectAtIndex:0] notes];
        }else{
            NSLog(@"InboxRightVC > renewTheViewWithRequest failed to find a matching request key id");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.notesView.text = self.myScheduleRequest.notes;
            
            // Turn off editable
            self.notesView.editable = NO;
        });
    }];
    
    
    NSBlockOperation *equipment = [NSBlockOperation blockOperationWithBlock:^{
        // Equipment joins
        NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
        
        NSArray* topArray = @[ @[@"scheduleTracking_foreignKey", self.myScheduleRequest.key_id] ];
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
            for (id join in muteArray){
                [tempMuteArray addObject:join];
            }
        }];
        self.arrayOfJoins = [NSArray arrayWithArray:tempMuteArray];
        self.myScheduleRequest.arrayOfEquipmentJoins = [NSMutableArray arrayWithArray:tempMuteArray];
    }];
    
    
    NSBlockOperation *misc = [NSBlockOperation blockOperationWithBlock:^{
        // Misc joins
        NSArray* omegaArray = @[ @[@"scheduleTracking_foreignKey", self.myScheduleRequest.key_id] ];
        
        if (!self.arrayOfMiscJoins){
            self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
        }
        [self.arrayOfMiscJoins removeAllObjects];
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray) {
            if (!muteArray) return NSLog(@"EQRInboxRightVC > renewTheViewWithRequest, array of misc items is nil");
            
            if ([muteArray count] > 0){
                [self.arrayOfMiscJoins addObjectsFromArray:muteArray];
            }
            self.myScheduleRequest.arrayOfMiscJoins = [NSMutableArray arrayWithArray:self.arrayOfMiscJoins];
        }];
    }];
    
    
    NSBlockOperation *renderTable = [NSBlockOperation blockOperationWithBlock:^{
        self.arrayOfJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfJoins withMiscJoins:self.arrayOfMiscJoins];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Refresh the data in table
            [self.myTable reloadData];
        });
    }];
    [renderTable addDependency:equipment];
    [renderTable addDependency:misc];
    
    
    NSBlockOperation *updatePrivateRequestManager = [NSBlockOperation blockOperationWithBlock:^{
        // Private request manager as ivar
        if (!self.privateRequestManager){
            self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
        }
        
        //set the request as ivar in requestManager
        self.privateRequestManager.request = self.myScheduleRequest;
        
        //two important methods that initiate requestManager ivar arrays
        [self.privateRequestManager resetEquipListAndAvailableQuantites];
        [self.privateRequestManager retrieveAllEquipUniqueItems:^(NSMutableArray *muteArray) {
            //        TODO: retrieveAllEquipUniqueItems async
        }];
//        NSLog(@"PRIVATE REQUEST MANAGER UPDATED");
    }];
    [updatePrivateRequestManager addDependency:nameAndDates];
    [updatePrivateRequestManager addDependency:class];
    [updatePrivateRequestManager addDependency:notes];
    [updatePrivateRequestManager addDependency:renderTable];
    
    
    NSBlockOperation *price = [NSBlockOperation blockOperationWithBlock:^{
        // Pricing info
        if ([self.myScheduleRequest.renter_type isEqualToString:EQRRenterPublic]){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.priceMatrixSubView.hidden = NO;
                [self getTransactionInfo];
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.priceMatrixSubView.hidden = YES;
            });
        }
    }];
    

    [self.renewTheViewQueue addOperation:nameAndDates];
    [self.renewTheViewQueue addOperation:class];
    [self.renewTheViewQueue addOperation:notes];
    [self.renewTheViewQueue addOperation:equipment];
    [self.renewTheViewQueue addOperation:misc];
    [self.renewTheViewQueue addOperation:renderTable];
    [self.renewTheViewQueue addOperation:updatePrivateRequestManager];
    [self.renewTheViewQueue addOperation:price];
}


-(void)getTransactionInfo{
    
    NSArray *topArray = @[ @[@"scheduleTracking_foreignKey", self.myScheduleRequest.key_id] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQGetTransactionWithScheduleRequestKey.php" parameters:topArray completion:^(EQRTransaction *transaction) {
            
            if (transaction){
                self.myTransaction = transaction;
                
                //found a matching transaction for this schedule Request, go on...
                [self populatePricingWidget];
                
            }else{
                
                //no matching transaction, create a fresh one.
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

-(void)raiseFlagThatAChangeHasBeenMade:(NSNotification*)note{
    
    self.aChangeWasMade = YES;
}

-(void)raiseFlagThatDatabaseChanged:(NSNotification *)note{
    
    [self getEmailSignatureFromDB];
}


#pragma mark - data layer updates

-(void)updateScheduleRequest{
    
    //update SQL with new request information
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //must not include nil objects in array
    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
    if (!self.myScheduleRequest.contact_foreignKey) self.myScheduleRequest.contact_foreignKey = EQRErrorCode88888888;
    if (!self.myScheduleRequest.classSection_foreignKey) self.myScheduleRequest.classSection_foreignKey = EQRErrorCode88888888;
    if ([self.myScheduleRequest.classSection_foreignKey isEqualToString:@""]) self.myScheduleRequest.classSection_foreignKey = EQRErrorCode88888888;
    if (!self.myScheduleRequest.classTitle_foreignKey) self.myScheduleRequest.classTitle_foreignKey = EQRErrorCode88888888;
    if (!self.myScheduleRequest.request_date_begin) self.myScheduleRequest.request_date_begin = [NSDate date];
    if (!self.myScheduleRequest.request_date_end) self.myScheduleRequest.request_date_end = [NSDate date];
    if (!self.myScheduleRequest.contact_name) self.myScheduleRequest.contact_name = EQRErrorCode88888888;
    if (!self.myScheduleRequest.time_of_request) self.myScheduleRequest.time_of_request = [NSDate date];
    if (!self.myScheduleRequest.notes) self.myScheduleRequest.notes = @"";
    
    //convert date values to strings
    NSString* date_begin = [EQRDataStructure dateAsStringSansTime:self.myScheduleRequest.request_date_begin];
    NSString* date_end = [EQRDataStructure dateAsStringSansTime:self.myScheduleRequest.request_date_end];
    NSString* time_begin = [EQRDataStructure timeAsString:self.myScheduleRequest.request_time_begin];
    NSString* time_end = [EQRDataStructure timeAsString:self.myScheduleRequest.request_time_end];
    NSString* timeStamp_string = [EQRDataStructure dateAsString:self.myScheduleRequest.time_of_request];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequest.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", self.myScheduleRequest.contact_foreignKey, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", self.myScheduleRequest.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", self.myScheduleRequest.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", date_begin, nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", date_end, nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", time_begin, nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", time_end, nil];
    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", self.myScheduleRequest.contact_name, nil];
    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", self.myScheduleRequest.renter_type, nil];
    NSArray* eleventhArray = [NSArray arrayWithObjects:@"time_of_request", timeStamp_string, nil];
    NSArray* twelfthArray = [NSArray arrayWithObjects:@"notes", self.myScheduleRequest.notes, nil];
    
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
    
    [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
//    NSLog(@"this is the returnID: %@", returnID);
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
}



#pragma mark - button methods


-(void)composeEmail{
    
    if (!self.myScheduleRequest) return;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Send Email" message:@"Message options:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Student Confirmation", @"Send Blank Email", nil];
    
    self.sendEmailAlert = alertView;
    
    [alertView show];
}


-(void)sendEmail{
    // Check that an email address exists for the contact
    NSArray* topArray = @[ @[@"key_id", self.myScheduleRequest.contact_foreignKey] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQGetContactCompleteWithKey.php" parameters:topArray completion:^(EQRContactNameItem *contactItem) {
            
            if (!contactItem) return NSLog(@"EQRInboxRightVC > sendEmail fails to return contactItem");
            
            NSString* contactEmail = contactItem.email;
            
            if ([contactEmail isEqualToString:@""]) NSLog(@"email is empty string");
            if (contactEmail == nil) NSLog(@"email is nil");
            if (!contactEmail)   NSLog(@"email is non existent");
            
            NSString* messageTitle = @"";
            NSString* messageBody = @"";
            
            if (self.myEmailSignature){
                messageBody = self.myEmailSignature;
            }
            
            NSArray* messageRecipients = [NSArray arrayWithObjects: contactEmail, nil];
            
            MFMailComposeViewController* mfVC = [[MFMailComposeViewController alloc] init];
            mfVC.mailComposeDelegate = self;
            
            [mfVC setSubject:messageTitle];
            [mfVC setMessageBody:messageBody isHTML:NO];
            [mfVC setToRecipients:messageRecipients];
            
            [self presentViewController:mfVC animated:YES completion:^{
                
            }];

        }];
    });
}


-(IBAction)confirm:(id)sender{
    
    if (!self.myScheduleRequest) return;
    
    //MUST CHECK THAT THE USER HAS LOGGED IN FIRST:
    EQRStaffUserManager* staffManager = [EQRStaffUserManager sharedInstance];
    if (!staffManager.currentStaffUser){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Current User" message:@"Please log in as a user before marking an item complete or incomplete" delegate:[self presentingViewController] cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [alert show];
        }];
        
        return;
    }
    
    //2 strings to use in message text
    NSString *userName = staffManager.currentStaffUser.first_and_last;
    
    UIAlertView *alertConfirmation = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Mark as Confirmed"] message:[NSString stringWithFormat:@"Stamped with staff signature: %@", userName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    self.confirmationAlert = alertConfirmation;
    
    [alertConfirmation show];
}

-(void)confirmedTheConfirm{
    
    // Staff user id
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* staffUserKeyID = staffUserManager.currentStaffUser.key_id;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray* topArray = @[ @[@"key_id", self.myScheduleRequest.key_id],
                           @[@"staff_id", staffUserKeyID],
                           @[@"staff_confirmation_date", dateString]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQSetConfirmation.php" parameters:topArray completion:^(NSString *returnValue) {
            
            [self composeEmail];
            
            // Hide right side to indicate completion
//            [self.rightView setHidden:YES];
//            [self.leftView setHidden:YES];
            [self exitEditMode];
        }];
    });
}


-(IBAction)confirmWithEmail:(id)sender{
    
    if (!self.myScheduleRequest) return;
    
    NSArray* topArray = @[ @[@"key_id", self.myScheduleRequest.contact_foreignKey] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQGetContactCompleteWithKey.php" parameters:topArray completion:^(EQRContactNameItem *contactItem) {
            if (!contactItem) return NSLog(@"EQRInboxRightVC > confirmWithEmail, failure to retrieve contactItem");
            
            NSString* contactEmail = contactItem.email;
            
            if ([contactEmail isEqualToString:@""]) NSLog(@"email is empty string");
            if (contactEmail == nil) NSLog(@"email is nil");
            if (!contactEmail) NSLog(@"email is non existent");
            
            // Compose message body
            EQRTextEmailStudent* emailBody = [[EQRTextEmailStudent alloc] init];
            
            emailBody.request_keyID = self.myScheduleRequest.key_id;
            emailBody.renterEmail = contactItem.email;
            emailBody.renterFirstName = contactItem.first_name;
            emailBody.pickupDateAsDate = self.myScheduleRequest.request_date_begin;
            emailBody.pickupTimeAsDate = self.myScheduleRequest.request_time_begin;
            emailBody.returnDateAsDate = self.myScheduleRequest.request_date_end;
            emailBody.returnTimeAsDate = self.myScheduleRequest.request_time_end;
            emailBody.notes = self.myScheduleRequest.notes;
            emailBody.emailSignature = self.myEmailSignature;
            
            // Get staff name
            EQRStaffUserManager* staffUser = [EQRStaffUserManager sharedInstance];
            emailBody.staffFirstName = staffUser.currentStaffUser.first_name;
            
            // Decompose array of joins to title items with quantities
            emailBody.arrayOfEquipTitlesAndQtys = [EQRDataStructure decomposeJoinsToEquipTitlesWithQuantities:self.arrayOfJoins];
            
            NSString* finalSubjectLine = [emailBody composeEmailSubjectLine];
            // Nuts, have to convert the attributed string to a regular string
            [emailBody composeEmailText:^(NSMutableAttributedString *muteAttString) {
                
                if(!muteAttString){
                    NSLog(@"EQRInboxRightVC > confirmWithEmail failed to composeEmailText");
                }
                
                NSString* messageBody = [muteAttString string];
                NSString* messageTitle = finalSubjectLine;
                NSArray* messageRecipients = [NSArray arrayWithObjects: contactEmail, nil];
                
                [self launchEmailClientWithBody:messageBody Title:messageTitle Recipients:messageRecipients];
            }];
        }];
    });
}


-(void)launchEmailClientWithBody:(NSString *)messageBody
                           Title:(NSString *)messageTitle
                      Recipients:(NSArray *)messageRecipients{
    MFMailComposeViewController* mfVC = [[MFMailComposeViewController alloc] init];
    mfVC.mailComposeDelegate = self;
    
    [mfVC setSubject:messageTitle];
    [mfVC setMessageBody:messageBody isHTML:NO];
    [mfVC setToRecipients:messageRecipients];
    
    [self presentViewController:mfVC animated:YES completion:^{
        
    }];
    
}


-(IBAction)printMeForReal:(id)sender{
    
    if (!self.myScheduleRequest) return;
    
    [self printPageWithScheduleRequestItemKey:self.myScheduleRequest.key_id];
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
               NSLog(@"EQRInboxRightVC > printPageWithScheduleRequestItemKey fails to load scheduleRequestItem");
               return;
           }
           
           //add the notes
           chosenItem.notes = self.myScheduleRequest.notes;
           
           //add contact information
           NSString* email;
           NSString* phone;
           if (self.myScheduleRequest.contactNameItem){
               email = self.myScheduleRequest.contactNameItem.email;
               phone = self.myScheduleRequest.contactNameItem.phone;
               chosenItem.contactNameItem = self.myScheduleRequest.contactNameItem;
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
           [self presentViewController:pageForPrint animated:YES completion:^{
           }];
       }];
    });
}


-(IBAction)emailNoConfirmation:(id)sender{

    if (!self.myScheduleRequest) return;
    
}

-(void)getEmailSignatureFromDB{
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    NSArray *firstArray = @[@"context", @"emailSignature"];
    NSArray *topArray = @[firstArray];
    
    SEL thisSelector = @selector(receiveTextElementForEmailSignature:);
    
    [webData queryWithAsync:@"EQGetTextElementsWithContext.php" parameters:topArray class:@"EQRTextElement" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
//        if (isLoadingFlagUp){
//            NSLog(@"%@", self.myEmailSignature);
//        }
    }];
}


#pragma mark - WebData delegate


-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"inside EQRInboxRight, cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
    
}

-(void)receiveTextElementForEmailSignature:(id)currentThing{
    
    //____!!!!!!!  manage if there is more than one  !!!!_____
    
    if (currentThing){

        self.myEmailSignature = [(EQRTextElement *)currentThing text];
    }
    
    //do nothing if currentThing is nil, it leaves property as nil
}

-(void)addMiscJoin:(id)currentThing{
    if (!currentThing){
        return;
    }
    [self.arrayOfMiscJoins addObject:currentThing];
}

-(void)toggleEditMode{
    
    if (self.inEditModeFlag == YES){
        
        [self exitEditMode];
        
    }else{
        
        [self enterEditMode];
    }
}


#pragma mark - edit mode methods

-(void)enterEditMode{
    
    if (!self.myScheduleRequest) return;
    
    //if called but already in edit more, ignore
    if (self.inEditModeFlag == YES){
        return;
    }
    
    //update flag
    self.inEditModeFlag = YES;
    
    //show edit text fields
    [self.viewEditLeft setHidden:NO];
    
    //show the add & done buttons
    [self.addButtonView setHidden:NO];
    [self.doneButtonView setHidden:NO];
    
    //alter table to reveal add and done buttons
    self.tablebottomGuideConstraint.constant = 50.f;
    self.tableTopGuideConstraint.constant = 50.f;
    
    //lower main sub view to reveal save button
//    self.topLayoutGuideConstraint.constant = 50;
    
    //animate changes in the constraints (specifically the constraints added to mainSubView)
    [self.mainSubView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        //generally, use the the top most view
        [self.view layoutIfNeeded];
    }];
    
   //show delete button in cells (and show distIDPicker button)
    for (EQREditorEquipListCell* thisCell in [self.myTable visibleCells]){
        
        [thisCell enterEditMode];
    }
    
    //make notes view hot to touch
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openNotesEditor)];
    [self.notesView addGestureRecognizer:tapGest];
    
    //background color for notes
    EQRColors* colors = [EQRColors sharedInstance];
    self.notesView.backgroundColor = [colors.colorDic objectForKey:EQRColorEditModeBGBlue];
    
}


-(void)exitEditMode{
    
    //if called but not in edit more, ignore
    if (self.inEditModeFlag == NO){
        return;
    }
    
    //update flag
    self.inEditModeFlag = NO;
    
    //hide edit text fields
    [self.viewEditLeft setHidden:YES];
    
    //alter table to hide add and done buttons
    self.tablebottomGuideConstraint.constant = 0;
    self.tableTopGuideConstraint.constant = 0;
    
    //animate changes in the constraints (specifically the constraints added to mainSubView)
    [self.mainSubView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        //genearlly, use the top most view
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        //hide the add and done buttons after the change to the constraint is complete
        [self.addButtonView setHidden:YES];
        [self.doneButtonView setHidden:YES];
    }];
  
    //hide delete button in cells (and hide distIDPicker button)
    for (EQREditorEquipListCell* thisCell in [self.myTable visibleCells]){
        
        [thisCell leaveEditMode];
    }
    
    //remove tap gesture on notes
    for (UIGestureRecognizer* gest in [self.notesView gestureRecognizers]){
        
        if ([gest class] == [UITapGestureRecognizer class]){
            
            [self.notesView removeGestureRecognizer:gest];
        }
    }
    
    //background color for notes
    EQRColors* colors = [EQRColors sharedInstance];
    self.notesView.backgroundColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];
}


-(IBAction)doneButton:(id)sender{
    
    if (!self.myScheduleRequest) return;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"doneButton";
    queue.maxConcurrentOperationCount = 2;
    
    
    NSBlockOperation *deleteScheduleEquipJoin = [NSBlockOperation blockOperationWithBlock:^{
        // Delete scheduleTracking_equip_joins
        EQRWebData* webData = [EQRWebData sharedInstance];
        for (NSString* thisKeyID in self.arrayOfToBeDeletedEquipIDs){
            
            for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in self.arrayOfJoins){
                
                if ([thisKeyID isEqualToString:thisJoin.equipUniqueItem_foreignKey]){
                    
                    // Delete Equip Joins with join key_id
                    NSArray* beeArray = @[ @[@"key_id", thisJoin.key_id] ];
                    [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoin.php" parameters:beeArray];
                }
            }
        }
    }];
    
    
    NSBlockOperation *deleteMiscJoin = [NSBlockOperation blockOperationWithBlock:^{
        // Delete miscJoin items
        EQRWebData* webData = [EQRWebData sharedInstance];
        for (NSString* thisKeyID in self.arrayOfToBeDeletedMiscJoins){
            
            for (EQRMiscJoin* thisJoin in self.arrayOfMiscJoins){
                
                if ([thisKeyID isEqualToString:thisJoin.key_id]){
                    
                    // Delete Misc Join with join key_id
                    NSArray* beeArray = @[ @[@"key_id", thisJoin.key_id] ];
                    [webData queryForStringWithLink:@"EQDeleteMiscJoin.php" parameters:beeArray];
                }
            }
        }
    }];
    
    
    NSBlockOperation *updateArraysAndRender = [NSBlockOperation blockOperationWithBlock:^{
        // Empty the arrays
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
        [self.arrayOfToBeDeletedMiscJoins removeAllObjects];
        
        //send note to schedule that a change has been saved
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //need to update ivar arrays
            [self renewTheViewWithRequest:self.myScheduleRequest];
        });
    }];
    [updateArraysAndRender addDependency:deleteScheduleEquipJoin];
    [updateArraysAndRender addDependency:deleteMiscJoin];
    
    
    [queue addOperation:deleteScheduleEquipJoin];
    [queue addOperation:deleteMiscJoin];
    [queue addOperation:updateArraysAndRender];
}


-(IBAction)changeNameTextField:(id)sender{
    
    EQRContactPickerVC* contactVC = [[EQRContactPickerVC alloc] initWithNibName:@"EQRContactPickerVC" bundle:nil];
    self.myContactVC = contactVC;
    
    //place contact VC in a nav controller
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:self.myContactVC];
    self.contactNavController = navVC;
    //hide nav controller nav bar
    [self.contactNavController setNavigationBarHidden:YES];
    
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:self.contactNavController];
    self.myContactPicker = popOver;
    self.myContactPicker.delegate = self;
    
    //set the size
    [self.myContactPicker setPopoverContentSize:CGSizeMake(320, 550)];
    
    //convert coordinates of textField frame to self.view
    UIView* originalRect = self.nameValueField;
    CGRect step1Rect = [originalRect.superview.superview convertRect:originalRect.frame fromView:originalRect.superview];
    CGRect step2Rect = [originalRect.superview.superview.superview convertRect:step1Rect fromView:originalRect.superview.superview];
    
    //present the popOver
    [self.myContactPicker presentPopoverFromRect:step2Rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight | UIPopoverArrowDirectionLeft animated:YES];
    
    
    //actions to perform AFTER presenting the popOver
    
    //assign self as delegate of name picker
    self.myContactVC.delegate = self;

}




-(IBAction)changeTypeTextField:(id)sender{
    
    EQREditorRenterVCntrllr* renterTypeVC = [[EQREditorRenterVCntrllr alloc] initWithNibName:@"EQREditorRenterVCntrllr" bundle:nil];
    self.myRenterTypeVC = renterTypeVC;
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:self.myRenterTypeVC];
    self.myRenterTypePicker = popOver;
    self.myRenterTypePicker.delegate = self;
    
    //set the size
    [self.myRenterTypePicker setPopoverContentSize:CGSizeMake(300.f, 500.f)];
    
    //convert coordinates of textField frame to self.view
    UIView* originalRect = self.typeValueField;
    CGRect step1Rect = [originalRect.superview.superview convertRect:originalRect.frame fromView:originalRect.superview];
    CGRect step2Rect = [originalRect.superview.superview.superview convertRect:step1Rect fromView:originalRect.superview.superview];
    
    
    //present the popover
    [self.myRenterTypePicker presentPopoverFromRect:step2Rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
    
    //tell it what renter type to have pre selected
    [self.myRenterTypeVC initialSetupWithRenterTypeString:self.myScheduleRequest.renter_type];
    
    //assign self as delegate
    self.myRenterTypeVC.delegate = self;
    
}

-(IBAction)changeClassTextField:(id)sender{
    
    EQRClassPickerVC* classPickerVC = [[EQRClassPickerVC alloc] initWithNibName:@"EQRClassPickerVC" bundle:nil];
    self.myClassPickerVC = classPickerVC;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:self.myClassPickerVC];
    [navController setNavigationBarHidden:YES];
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myClassPicker = popOver;
    self.myClassPicker.delegate = self;
    
    //set the size
    [self.myClassPicker setPopoverContentSize:CGSizeMake(300.f, 500.f)];
    
    //convert coordinates of textField frame to self.view
    UIView* originalRect = self.classValueField;
    CGRect step1Rect = [originalRect.superview.superview convertRect:originalRect.frame fromView:originalRect.superview];
    CGRect step2Rect = [originalRect.superview.superview.superview convertRect:step1Rect fromView:originalRect.superview.superview];
    
    
    //present the popover
    [self.myClassPicker presentPopoverFromRect:step2Rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
    
    //assign as delegate
    self.myClassPickerVC.delegate = self;
    
}

-(IBAction)removeClassButton:(id)sender{
    
    [self initiateRetrieveClassItem:nil];
}


-(IBAction)changeDateTextFields:(id)sender{
    
    //datDatePicker shared nib
    EQREditorDateVCntrllr* datePickerVC = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    self.myDayDateVC = datePickerVC;
    
    //create the popover and assign to ivar
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:datePickerVC];
    self.myDayDatePicker = popOver;
    self.myDayDatePicker.delegate = self;
    
    self.myDayDatePicker.popoverContentSize = CGSizeMake(320.f, 570.f);
    
    //convert coordinates of textField frame to self.view
    UIView* originalRect = self.pickUpTimeValueField;
    CGRect step1Rect = [originalRect.superview.superview convertRect:originalRect.frame fromView:originalRect.superview];
    CGRect step2Rect = [originalRect.superview.superview.superview convertRect:step1Rect fromView:originalRect.superview.superview];
    
    
    //present the popover
    [self.myDayDatePicker presentPopoverFromRect:step2Rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //methods AFTER adding the popover to the view
    
    //enter dates into datepicker
    NSDate* combinedPickupDate = [EQRDataStructure dateFromCombinedDay:self.myScheduleRequest.request_date_begin And8HourShiftedTime:self.myScheduleRequest.request_time_begin];
    NSDate* combinedReturnDate = [EQRDataStructure dateFromCombinedDay:self.myScheduleRequest.request_date_end And8HourShiftedTime:self.myScheduleRequest.request_time_end];
    
    self.myDayDateVC.pickupDateField.date = combinedPickupDate;
    self.myDayDateVC.returnDateField.date = combinedReturnDate;
    
    //assign target for datDatePicker's actions
    [self.myDayDateVC.saveButton addTarget:self action:@selector(receiveNewPickupDate) forControlEvents:UIControlEventTouchUpInside];
    [self.myDayDateVC.showOrHideExtendedButton addTarget:self action:@selector(showExtendedDate:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)showExtendedDate:(id)sender{
    
    //change to Extended view
    EQREditorExtendedDateVC* myDateViewController = [[EQREditorExtendedDateVC alloc] initWithNibName:@"EQREditorExtendedDateVC" bundle:nil];
    CGSize thisSize = CGSizeMake(600.f, 570.f);
    
    [self.myDayDatePicker setPopoverContentSize:thisSize animated:YES];
    [self.myDayDatePicker setContentViewController:myDateViewController animated:YES];
    
    [myDateViewController.saveButton addTarget:self action:@selector(receiveNewPickupDate)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(returnToStandardDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //need to set the date and time
    myDateViewController.pickupDateField.date = [self.myDayDateVC retrievePickUpDate];
    myDateViewController.pickupTimeField.date = [self.myDayDateVC retrievePickUpDate];
    myDateViewController.returnDateField.date = [self.myDayDateVC retrieveReturnDate];
    myDateViewController.returnTimeField.date = [self.myDayDateVC retrieveReturnDate];
    
    //assign content VC as ivar (necessary, because VCs always need to be retained)
    self.myDayDateVC = myDateViewController;
}


-(void)returnToStandardDate:(id)sender{
    
    //change to regular day view
    EQREditorDateVCntrllr* myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    CGSize thisSize = CGSizeMake(320.f, 570.f);
    
    [self.myDayDatePicker setPopoverContentSize:thisSize animated:YES];
    [self.myDayDatePicker setContentViewController:myDateViewController animated:YES];
    
    [myDateViewController.saveButton addTarget:self action:@selector(receiveNewPickupDate)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(showExtendedDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //need to set the date
    myDateViewController.pickupDateField.date = [self.myDayDateVC retrievePickUpDate];
    myDateViewController.returnDateField.date = [self.myDayDateVC retrieveReturnDate];
    
    //assign content VC as ivar
    self.myDayDateVC = myDateViewController;
}

#pragma mark - Pricing Matrix 

-(IBAction)showPricingButton:(id)sender{
    
    UIStoryboard *captureStoryboard = [UIStoryboard storyboardWithName:@"Pricing" bundle:nil];
    EQRAlternateWrappperPriceMatrix *newView = [captureStoryboard instantiateViewControllerWithIdentifier:@"price_alternate_wrapper"];
    newView.delegate = self;
    
    newView.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:newView animated:YES completion:^{
        
        //provide VC with request information
        [newView provideScheduleRequest:self.myScheduleRequest];
        
        
    }];
    
    
//    
//    newView.edgesForExtendedLayout = UIRectEdgeAll;
//    [self.navigationController pushViewController:newView animated:YES];
}

// EQRPriceMatrixVC delegate method

-(void)aChangeWasMadeToPriceMatrix{
    
    [self getTransactionInfo];
}



#pragma mark - handle add equip item


-(IBAction)addEquipItem:(id)sender{
    
    if (!self.myScheduleRequest) return;

    EQREquipSelectionGenericVCntrllr* genericEquipVCntrllr = [[EQREquipSelectionGenericVCntrllr alloc] initWithNibName:@"EQREquipSelectionGenericVCntrllr" bundle:nil];
    
    //need to specify a privateRequestManager for the equip selection v cntrllr
    //also sets ivar isInPopover to YES
    [genericEquipVCntrllr overrideSharedRequestManager:self.privateRequestManager];
    
    //    genericEquipVCntrllr.edgesForExtendedLayout = UIRectEdgeNone;
    //    [self.navigationController pushViewController:genericEquipVCntrllr animated:NO];
    
    UIPopoverController* popOverMe = [[UIPopoverController alloc] initWithContentViewController:genericEquipVCntrllr];
    self.myAddEquipPopover = popOverMe;
    self.myAddEquipPopover.delegate = self;
    
    //must manually set the size, cannot be wider than 600px!!!!???? But seems to work ok at 800 anyway???
    self.myAddEquipPopover.popoverContentSize = CGSizeMake(700, 600);
    
    CGRect rect1 = [self.addButtonView.superview.superview convertRect:self.addButtonView.frame fromView:self.addButtonView.superview];
    
    [self.myAddEquipPopover presentPopoverFromRect:rect1 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated: YES];
    
    //need to reprogram the target of the save button
    [genericEquipVCntrllr.continueButton removeTarget:genericEquipVCntrllr action:NULL forControlEvents:UIControlEventAllEvents];
    [genericEquipVCntrllr.continueButton addTarget:self action:@selector(continueAddEquipItem:) forControlEvents:UIControlEventTouchUpInside];
}


-(IBAction)continueAddEquipItem:(id)sender{
    
    //replaces the uniqueItem key from "1" to an accurate value
    [self.privateRequestManager justConfirm];
    
    [self.myAddEquipPopover dismissPopoverAnimated:YES];
    self.myAddEquipPopover = nil;
    
    
    //renew the list of joins by going to the data layer
    [self renewTheViewWithRequest:self.myScheduleRequest];
}



#pragma mark - receive shared nib actions

-(void)receiveNewPickupDate{
    
    //retrieve date from picker
    NSDate* newPickupDate = [self.myDayDateVC retrievePickUpDate];
    NSDate* newReturnDate = [self.myDayDateVC retrieveReturnDate];
    
    
    //update date in ivar myScheduleRequest
    self.myScheduleRequest.request_date_begin = [EQRDataStructure dateByStrippingOffTime:newPickupDate];
    self.myScheduleRequest.request_time_begin = [EQRDataStructure timeByStrippingOffDate:newPickupDate];
    self.myScheduleRequest.request_date_end = [EQRDataStructure dateByStrippingOffTime:newReturnDate];
    self.myScheduleRequest.request_time_end = [EQRDataStructure timeByStrippingOffDate:newReturnDate];
    
    //renew the view
    [self renewTheViewWithRequest:self.myScheduleRequest];
    
    //_____!!!!!!  update data layer   !!!!!!______
    [self updateScheduleRequest];
    
    //dismiss the popover
    [self.myDayDatePicker dismissPopoverAnimated:YES];
    self.myDayDatePicker = nil;
//    self.myDayDateVC = nil;
    
    
}


//ContactPickerVC delegate method
-(void)retrieveSelectedNameItem{
    
    EQRContactNameItem* thisNameItem = [self.myContactVC retrieveContactItem];
    
    //update view objets
    //______or send renewTheView message____
    [self.nameValueField setTitle:thisNameItem.first_and_last forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    self.firstLastNameValue.text = thisNameItem.first_and_last;
    
    //udpate myScheduleRequest
    self.myScheduleRequest.contactNameItem = thisNameItem;
    self.myScheduleRequest.contact_name = thisNameItem.first_and_last;
    self.myScheduleRequest.contact_foreignKey = thisNameItem.key_id;
    
    //____!!!!!   update data layer   !!!!!______
    [self updateScheduleRequest];
    
    //release self as delegate 
    self.myContactVC.delegate = nil;
    
    //dismiss the popover
    [self.myContactPicker dismissPopoverAnimated:YES];
    self.myContactPicker = nil;
    
    //i think this is unnecessary if the popover is set to nil
    //release mycontactVC
//    self.myContactVC = nil;
}


-(void)initiateRetrieveRenterItem{
    
    NSString* thisRenterType = [self.myRenterTypeVC retrieveRenterType];
    
    //update view objects
    self.typeValue.text = thisRenterType;
    [self.typeValueField setTitle:thisRenterType forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    
    //update my Schedule Request
    self.myScheduleRequest.renter_type = thisRenterType;
    
    //update data layer
    [self updateScheduleRequest];
    
    //release self as delegate
    self.myRenterTypePicker.delegate = nil;
    
    //dismiss popover
    [self.myRenterTypePicker dismissPopoverAnimated:YES];
    self.myRenterTypePicker = nil;
    
    //update pricing view
    if ([self.myScheduleRequest.renter_type isEqualToString:EQRRenterPublic]){
        self.priceMatrixSubView.hidden = NO;
        [self getTransactionInfo];
    }else{
        self.priceMatrixSubView.hidden = YES;
    }
}


-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem;{
    
    //can be nil... no class assigned to request
//    EQRClassItem* thisClassItem = [self.myClassPickerVC retrieveClassItem];
    
    //update view objects
    //    [self.classField setHidden:NO];
    if (!selectedClassItem){
        
        self.classValue.text = @"(No Class Selected)";
        [self.classValueField setTitle:@"(No Class Selected)" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        
        //update schedule request
        self.myScheduleRequest.classItem = nil;
        self.myScheduleRequest.classSection_foreignKey = nil;
        self.myScheduleRequest.classTitle_foreignKey = nil;
        
    }else{
        
        //update view objects
        self.classValue.text = selectedClassItem.section_name;
        [self.classValueField setTitle:selectedClassItem.section_name forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
        
        //update schedule request
        self.myScheduleRequest.classItem = selectedClassItem;
        self.myScheduleRequest.classSection_foreignKey = selectedClassItem.key_id;
        self.myScheduleRequest.classTitle_foreignKey = selectedClassItem.catalog_foreign_key;
    }
    
    //update data layer
    [self updateScheduleRequest];
    
    //release self as delegate
    self.myClassPicker.delegate = nil;
    
    //dismiss popover
    [self.myClassPicker dismissPopoverAnimated:YES];
    self.myClassPicker = nil;
}


#pragma mark - EditorEquipDelegate methods

-(void)tagEquipUniqueToDelete:(NSString*)key_id{
    
    [self.arrayOfToBeDeletedEquipIDs addObject:key_id];
}


-(void)tagEquipUniqueToCancelDelete:(NSString*)key_id{
    
    NSString* stringToBeRemoved;
    
    for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
        
        if ([thisString isEqualToString:key_id]){
            
            stringToBeRemoved = thisString;
            break;
        }
    }
    
    [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
}


#pragma mark - EditorMiscListCell  Delegate methods

-(void)tagMiscJoinToDelete:(NSString*)key_id{
    
    [self.arrayOfToBeDeletedMiscJoins addObject:key_id];
}

-(void)tagMiscJoinToCancelDelete:(NSString*)key_id{
    
    NSString* stringToBeRemoved;
    for (NSString *thisString in self.arrayOfToBeDeletedMiscJoins){
        if ([thisString isEqualToString:key_id]){
            stringToBeRemoved = thisString;
            break;
        }
    }
    [self.arrayOfToBeDeletedMiscJoins removeObject:stringToBeRemoved];
}


#pragma mark - Distingishing ID Picker Button

//an equipCell delegate method
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
    CGRect fixedRect6 = [thisButton.superview.superview.superview.superview.superview.superview convertRect:fixedRect5 fromView:thisButton.superview.superview.superview.superview.superview];
    CGRect fixedRect7 = [thisButton.superview.superview.superview.superview.superview.superview.superview convertRect:fixedRect6 fromView:thisButton.superview.superview.superview.superview.superview.superview];
    
    
    //present popover
    [self.distIDPopover presentPopoverFromRect:fixedRect7 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


//distIDPicker Delegate method
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
    for (EQRScheduleTracking_EquipmentUnique_Join* joinObj in self.arrayOfJoins){
        
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
    self.arrayOfJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfJoins withMiscJoins:self.arrayOfMiscJoins];
    
    // Renew the collection view
    [self.myTable reloadData];
    
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
            if (!returnString){
                NSLog(@"EQRInboxRightVC > distIDSelectionMade..., failed to alter schedule equip joing");
            }
            
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
    [thisNotes initialSetupWithScheduleRequest:self.myScheduleRequest];
}


-(void)retrieveNotesData:(NSString*)noteText{
    
    //update notes view
    self.notesView.text = noteText;
    
    //update ivar request
    self.myScheduleRequest.notes = noteText;
    
    //update data layer
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequest.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"notes", noteText, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryForStringWithLink:@"EQAlterNotesInScheduleRequest.php" parameters:topArray];
    
    //dismiss popover
    [self.myNotesPopover dismissPopoverAnimated:YES];
    self.myNotesPopover = nil;
}



//#pragma mark - equip item deletion notification methods


#pragma mark - alert view delegate  / compose email

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //0 is cancel, 1 is use template, 2 is blank email
    
    
    if (alertView == self.sendEmailAlert){
        switch (buttonIndex) {
            case 0:
                break;
                
            case 1:
                [self confirmWithEmail:self];
                break;
                
            case 2:
                [self sendEmail];
                break;
                
            default:
                break;
        }
    }
    
    if (alertView == self.confirmationAlert){
        
        if (buttonIndex == 1){
            [self confirmedTheConfirm];
        }
    }
    
}


#pragma mark - staff user

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


#pragma mark - mail compose delegate methods

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    switch (result) {
            
        case MFMailComposeResultCancelled:
            
            
            break;
            
        case MFMailComposeResultFailed:
            
            break;
            
        case MFMailComposeResultSaved:
            
            break;
            
        case MFMailComposeResultSent:
            
            break;
            
        default:
            break;
    }
    
    //dismiss email compose
    [self dismissViewControllerAnimated:YES completion:^{
        
        //hide right side to indicate completion
//        [self.rightView setHidden:YES];
//        [self.leftView setHidden:YES];
        [self exitEditMode];
    }];
}


#pragma mark - split view delegate methods

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc{
    
//    NSLog(@"inside willHide split view delegate method");
    
    barButtonItem.title = @"Requests";
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    self.popover = pc;
    
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    
    [self.navigationItem setLeftBarButtonItem:nil];
    
    self.popover = nil;
}


#pragma mark - collectionView datasource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return [self.arrayOfJoinsWithStructure count];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [(NSArray*)[self.arrayOfJoinsWithStructure objectAtIndex:section] count];
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //__1__ An equipUniqueJoin item
    //__2__ A MiscJoin Item
    
    if ([[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] respondsToSelector:@selector(schedule_grouping)]){
        
        EQREditorEquipListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //set self as cell's delegate
        cell.delegate = self;
        
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
            
            if ([keyToDelete isEqualToString:[[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] equipUniqueItem_foreignKey]]){
                
                toBeDeleted = YES;
            }
        }
        
        [cell initialSetupWithJoinObject:[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] deleteFlag:toBeDeleted editMode:self.inEditModeFlag];
        
        return cell;
        
    }else{
        
        EQREditorMiscListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellForMiscJoin" forIndexPath:indexPath];
        
        for (UIView* view in cell.contentView.subviews){
            
            [view removeFromSuperview];
        }
        
        //set self as cell's delegate
        cell.delegate = self;
        
        BOOL toBeDeleted = NO;
        for (NSString* keyToDelete in self.arrayOfToBeDeletedMiscJoins){
            
            if ([keyToDelete isEqualToString:[[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id]]){
                
                toBeDeleted = YES;
            }
        }
        
        [cell initialSetupWithMiscJoin:[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] deleteFlag:toBeDeleted editMode:self.inEditModeFlag];
        
        return cell;
    }
}


-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SuppCell";
    
    EQREditorHeaderCell* cell = [self.myTable dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    if ([[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:0] respondsToSelector:@selector(schedule_grouping)]){
        [cell initialSetupWithTitle: [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] schedule_grouping]];
        return cell;
    }else{
        [cell initialSetupWithTitle:@"Miscellaneous"];
        return cell;
    }
}



#pragma mark - collection view delegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

#pragma mark - collection view flow layout delegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //width is equal to the collectionView's width
    return CGSizeMake(self.myTable.frame.size.width, 35.f);
    
}


#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
 
    //there are 8 different popovers!

    if (popoverController == self.myStaffUserPicker){
        
        self.myStaffUserPicker = nil;
        
    }else if (popoverController == self.myDayDatePicker){
        
        self.myDayDatePicker = nil;
        
    }else if (popoverController == self.myContactPicker){
        
        self.myContactPicker = nil;
        
    }else if (popoverController == self.myRenterTypePicker){
        
        self.myRenterTypePicker = nil;
        
    }else if (popoverController == self.myClassPicker){
        
        self.myClassPicker = nil;
        
    }else if (popoverController == self.myAddEquipPopover){
        
        self.myAddEquipPopover = nil;
        
    }else if (popoverController == self.popover){
        
        self.popover = nil;
        
    }else if (popoverController == self.distIDPopover){
        
        self.distIDPopover = nil;
        
    }else if (popoverController == self.myNotesPopover){
        
        self.myNotesPopover = nil;
    }
}



#pragma mark - table delegate methods

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    
//    header.textLabel.textColor = [UIColor blackColor];
//    header.textLabel.font = [UIFont boldSystemFontOfSize:12];
//    CGRect headerFrame = header.frame;
//    header.textLabel.frame = headerFrame;
//    header.textLabel.textAlignment = NSTextAlignmentLeft;
//    
//}
//
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//
//}

-(void)dealloc{
    
    self.privateRequestManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
