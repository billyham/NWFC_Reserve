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

@interface EQRInboxRightVC ()

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequest;

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
@property (strong, nonatomic) IBOutlet UIButton* pickUpTimeValueField;
@property (strong, nonatomic) IBOutlet UIButton* returnTimeValueField;
@property (strong, nonatomic) IBOutlet UITextView* notesView;

@property (strong, nonatomic) IBOutlet UIView* addButtonView;
@property (strong, nonatomic) IBOutlet UIView* doneButtonView;

@property (strong, nonatomic) NSArray* arrayOfJoins;
@property (strong, nonatomic) NSArray* arrayOfJoinsWithStructure;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;

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

@property BOOL inEditModeFlag;
@property BOOL aChangeWasMade;


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
    
    //array that shit
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, thirtySpace, editModeBarButton, twentySpace, composeEmailBarButton,
                                    twentySpace, confirmBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];
    
    //register cells
    [self.myTable registerClass:[EQREditorEquipListCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.myTable registerClass:[EQREditorHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SuppCell"];

    //remnants when collectionView was a table
//    [self.myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
//    [self.myTable registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"SuppCell"];
    
    //initialize array of to be deleted joins
    if (!self.arrayOfToBeDeletedEquipIDs){
        
        self.arrayOfToBeDeletedEquipIDs = [NSMutableArray arrayWithCapacity:1];
        
    } else {
        
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    }
    
    //initially hide everything
    [self.leftView setHidden:YES];
    [self.rightView setHidden:YES];
    [self.viewEditLeft setHidden:YES];
    [self.addButtonView setHidden:YES];
    [self.doneButtonView setHidden:YES];
        
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
            
            EQRScheduleRequestItem* thisItem = [self retrieveRequestItemWithRequestKeyID:self.myScheduleRequest.key_id];
            
            if (thisItem){
                
                [self renewTheViewWithRequest:thisItem];
            }
        }
    }
    
    //update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        self.navigationItem.prompt = @"";
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        
    }else{
        
        //set prompt
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
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


-(EQRScheduleRequestItem*)retrieveRequestItemWithRequestKeyID:(NSString*)keyID{
    
    if (keyID == nil){
        //error handling if no keyID is sent
        return nil;
    }
    
    //use this when a change to dates may have occured in the scheduleRequest
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", keyID, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    __block EQRScheduleRequestItem* thisItem = nil;
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
    
        if ([muteArray count] == 0){
            
            //error handling when no item are returned
            NSLog(@"InboxRightVC > retrieveRequestItemWith... no request items returned");
            
        }else if ([muteArray count] == 1){
            
            thisItem = [muteArray objectAtIndex:0];
            
        }else if ([muteArray count] > 1){
            
            //error handling when more than one request item is returned for the same keyid
            NSLog(@"InboxRightVC > retrieveRequestItemWith... got two requests for one key id");
        }
        
    }];

    return thisItem;
}


-(void)renewTheViewWithRequest:(EQRScheduleRequestItem*)request{
    
    //set reqeustItem (error handling if nil)
    self.myScheduleRequest = request;

    //set label values
    self.firstLastNameValue.text = self.myScheduleRequest.contact_name;
    self.typeValue.text = self.myScheduleRequest.renter_type;
//    self.classValue.text = self.myScheduleRequest.classTitle_foreignKey;
    
    //date formats
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"EEEE, MMM d";
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    timeFormatter.dateFormat = @"h:mm aaa";
    
    NSDateFormatter* submitFormatter = [[NSDateFormatter alloc] init];
    submitFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    submitFormatter.dateFormat = @"EEEE, MMM d, h:mm aaa";
    
    NSString* pickUpDateString = [dateFormatter stringFromDate:self.myScheduleRequest.request_date_begin];
    NSString* pickUpTimeString = [timeFormatter stringFromDate:self.myScheduleRequest.request_time_begin];
    NSString* returnDateString = [dateFormatter stringFromDate:self.myScheduleRequest.request_date_end];
    NSString* returnTimeString = [timeFormatter stringFromDate:self.myScheduleRequest.request_time_end];
    NSString* timeOfRequest = [submitFormatter stringFromDate:self.myScheduleRequest.time_of_request];
    
    self.timeOfRequestValue.text = timeOfRequest;
    self.pickUpTimeValue.text = [NSString stringWithFormat:@"%@ - %@", pickUpDateString, pickUpTimeString];
    self.returnTimeValue.text = [NSString stringWithFormat:@"%@ - %@", returnDateString, returnTimeString];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //get class name using key
    if (([self.myScheduleRequest.classTitle_foreignKey isEqualToString:EQRErrorCode88888888]) ||
        ([self.myScheduleRequest.classTitle_foreignKey isEqualToString:@""]) ||
        (!self.myScheduleRequest.classTitle_foreignKey)) {
        
        [self.classValue setHidden:YES];
        
    }else{
        
        NSArray* first2Array = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequest.classTitle_foreignKey, nil];
        NSArray* top2Array = [NSArray arrayWithObjects:first2Array, nil];
        self.classValue.text = [webData queryForStringWithLink:@"EQGetClassCatalogTitleWithKey.php" parameters:top2Array];
        
        [self.classValue setHidden:NO];
    }
    
    //copy values to edit field values
    [self.nameValueField setTitle:self.firstLastNameValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.typeValueField setTitle:self.typeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.classValueField setTitle:self.classValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.pickUpTimeValueField setTitle:self.pickUpTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.returnTimeValueField setTitle:self.returnTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    
    //set text in notes
    NSArray* justKeyArray = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequest.key_id, nil];
    NSArray* justTopArray = [NSArray arrayWithObjects:justKeyArray, nil];
    NSMutableArray* tempMuteArrayJustKey = [NSMutableArray arrayWithCapacity:1];
    [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:justTopArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
       
        for (EQRScheduleRequestItem* requestItem in muteArray){
            
            [tempMuteArrayJustKey addObject:requestItem];
        }
    }];
    
    //error handling if no items are returned
    if ([tempMuteArrayJustKey count] > 0){
        
        self.myScheduleRequest.notes = [[tempMuteArrayJustKey objectAtIndex:0] notes];
    }else{
        NSLog(@"InboxRightVC > renewTheViewWithRequest failed to find a matching request key id");
    }
    
    //set notes text
    self.notesView.text = self.myScheduleRequest.notes;
    
    //turn off editable
    self.notesView.editable = NO;
    
    //get table of joins
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.myScheduleRequest.key_id, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
        
        for (id join in muteArray){
            
            [tempMuteArray addObject:join];
        }
    }];
    
    
    //_____******   error checking when no joins exist   *******____
    
    self.arrayOfJoins = [NSArray arrayWithArray:tempMuteArray];
    
    //add structure to that array
    self.arrayOfJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfJoins];
    
    //refresh the data in table
    [self.myTable reloadData];
    
    //make subview visible
    [self.rightView setHidden:NO];
    [self.leftView setHidden:NO];
    
    
    
    //____set up private request manager______
    
    //create private request manager as ivar
    if (!self.privateRequestManager){
        
        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
    }
    
    //set the request as ivar in requestManager
    self.privateRequestManager.request = self.myScheduleRequest;
    
    //two important methods that initiate requestManager ivar arrays
    [self.privateRequestManager resetEquipListAndAvailableQuantites];
    [self.privateRequestManager retrieveAllEquipUniqueItems];
}

-(void)raiseFlagThatAChangeHasBeenMade:(NSNotification*)note{
    
    self.aChangeWasMade = YES;
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
                         nil];
    
    NSString* returnID = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
    NSLog(@"this is the returnID: %@", returnID);
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
}



#pragma mark - button methods


-(void)composeEmail{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Send Email" message:@"Message options:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Student Confirmation", @"Send Blank Email", nil];
    
    [alertView show];
}


-(void)sendEmail{
    
    //check that an email address exists for the contact
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequest.contact_foreignKey, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    [webData queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
        
        for (id contact in muteArray){
            
            [tempMuteArray addObject:contact];
        }
        
    }];
    
    if ([tempMuteArray count] < 1){
        
        //_____******* error handling when no contact object is returned
    }
    
    EQRContactNameItem* contactItem = [tempMuteArray objectAtIndex:0];
    
    NSString* contactEmail = contactItem.email;
    
    //_______******* error handling when no email exists for the contact
    if ([contactEmail isEqualToString:@""]){
        
        NSLog(@"email is empty string");
    }
    if (contactEmail == nil){
        
        NSLog(@"email is nil");
    }
    if (!contactEmail){
        
        NSLog(@"email is non existent");
    }
    
    
    NSString* messageTitle = @"";
    NSString* messageBody = @"";
    NSArray* messageRecipients = [NSArray arrayWithObjects: contactEmail, nil];
    
    MFMailComposeViewController* mfVC = [[MFMailComposeViewController alloc] init];
    mfVC.mailComposeDelegate = self;
    
    [mfVC setSubject:messageTitle];
    [mfVC setMessageBody:messageBody isHTML:NO];
    [mfVC setToRecipients:messageRecipients];
    
    [self presentViewController:mfVC animated:YES completion:^{
        
        
    }];
    
    
    
}


-(IBAction)confirm:(id)sender{
    
    //get staff user id
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* staffUserKeyID = staffUserManager.currentStaffUser.key_id;
    
    //assign date and key_id to webdata
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequest.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"staff_id", staffUserKeyID, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"staff_confirmation_date", dateString, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
    
    NSString* returnKey = [webData queryForStringWithLink:@"EQSetConfirmation.php" parameters:topArray];
    
    NSLog(@"this is the return key id: %@", returnKey);
    
    //hide right side to indicate completion
    [self.rightView setHidden:YES];
    [self.leftView setHidden:YES];
    [self exitEditMode];
}


-(IBAction)confirmWithEmail:(id)sender{
    
    
    //check that an email address exists for the contact
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequest.contact_foreignKey, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    [webData queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
       
        for (id contact in muteArray){
            
            [tempMuteArray addObject:contact];
        }
        
    }];
    
    if ([tempMuteArray count] < 1){
        
        //_____******* error handling when no contact object is returned
    }
    
    EQRContactNameItem* contactItem = [tempMuteArray objectAtIndex:0];
    
    NSString* contactEmail = contactItem.email;

    //_______******* error handling when no email exists for the contact
    if ([contactEmail isEqualToString:@""]){
        
        NSLog(@"email is empty string");
    }
    if (contactEmail == nil){
        
        NSLog(@"email is nil");
    }
    if (!contactEmail){
        
        NSLog(@"email is non existent");
    }
    
    
    
    
    //_______compose message body________
    EQRTextEmailStudent* emailBody = [[EQRTextEmailStudent alloc] init];
    
    emailBody.renterEmail = contactItem.email;
    emailBody.renterFirstName = contactItem.first_name;
    emailBody.pickupDateAsDate = self.myScheduleRequest.request_date_begin;
    emailBody.pickupTimeAsDate = self.myScheduleRequest.request_time_begin;
    emailBody.returnDateAsDate = self.myScheduleRequest.request_date_end;
    emailBody.returnTimeAsDate = self.myScheduleRequest.request_time_end;
    
    //get staff name
    EQRStaffUserManager* staffUser = [EQRStaffUserManager sharedInstance];
    emailBody.staffFirstName = staffUser.currentStaffUser.first_name;
    
    //decompose array of joins to title items with quantities
    emailBody.arrayOfEquipTitlesAndQtys = [EQRDataStructure decomposeJoinsToEquipTitlesWithQuantities:self.arrayOfJoins];
    
//    NSLog(@"this is the count of equipTitle objects: %lu", (unsigned long)[emailBody.arrayOfEquipTitlesAndQtys count]);
    
    NSString* finalSubjectLine = [emailBody composeEmailSubjectLine];
    //_______!!!!!!  Nuts, have to convert the attributed string to a regular string   !!!!_______
    NSString* finalBodyText = [[emailBody composeEmailText] string];
    

    NSString* messageTitle = finalSubjectLine;
    NSString* messageBody = finalBodyText;
    NSArray* messageRecipients = [NSArray arrayWithObjects: contactEmail, nil];
    
    MFMailComposeViewController* mfVC = [[MFMailComposeViewController alloc] init];
    mfVC.mailComposeDelegate = self;
    
    [mfVC setSubject:messageTitle];
    [mfVC setMessageBody:messageBody isHTML:NO];
    [mfVC setToRecipients:messageRecipients];
    
    [self presentViewController:mfVC animated:YES completion:^{
        
    }];
    
    
}



-(IBAction)emailNoConfirmation:(id)sender{
    
    
    
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
    self.notesView.backgroundColor = [colors.colorDic objectForKey:EQRVeryNiceBlue];
    
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
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //_______*********  delete the deleted scheduleTracking_equip_joins
    for (NSString* thisKeyID in self.arrayOfToBeDeletedEquipIDs){
        
        for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in self.arrayOfJoins){
            
            if ([thisKeyID isEqualToString:thisJoin.equipUniqueItem_foreignKey]){
                
                //found a matching equipUnique item
                
                //send php message to delete with the join key_id
                NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", thisJoin.key_id, nil];
                NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
                NSString* returnString = [webData queryForStringWithLink:@"EQRDeleteScheduleEquipJoin.php" parameters:beeArray];
                
                NSLog(@"this is the return string: %@", returnString);
            }
            
        }
    }
    
    //empty the arrays
    [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    
    //need to update ivar arrays
    [self renewTheViewWithRequest:self.myScheduleRequest];
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
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:self.myClassPickerVC];
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
    
}


-(void)initiateRetrieveClassItem{
    
    //can be nil... no class assigned to request
    EQRClassItem* thisClassItem = [self.myClassPickerVC retrieveClassItem];
    
    //update view objects
    //    [self.classField setHidden:NO];
    if (!thisClassItem){
        
        //update view objects
        [self.classValue setHidden:YES];
        self.classValue.text = nil;
        [self.classValueField setTitle:nil forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
        
        //update schedule request
        self.myScheduleRequest.classItem = nil;
        self.myScheduleRequest.classSection_foreignKey = nil;
        self.myScheduleRequest.classTitle_foreignKey = nil;
        
    }else{
        
        //update view objects
        [self.classValue setHidden:NO];
        self.classValue.text = thisClassItem.section_name;
        [self.classValueField setTitle:thisClassItem.section_name forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
        
        //update schedule request
        self.myScheduleRequest.classItem = thisClassItem;
        self.myScheduleRequest.classSection_foreignKey = thisClassItem.key_id;
        self.myScheduleRequest.classTitle_foreignKey = thisClassItem.catalog_foreign_key;
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
        }
    }
    
    [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
}


#pragma mark - Distingishing ID Picker Button

//an equipCell delegate method
-(void)distIDPickerTapped:(NSDictionary*)infoDictionary{
    
    //get cell's equipUniqueKey, titleKey, buttonRect and button
    NSString* equipTitleItem_foreignKey = [infoDictionary objectForKey:@"equipTitleItem_foreignKey"];
    NSString* equipUniqueItem_foreignKey = [infoDictionary objectForKey:@"equipUniqueItem_foreignKey"];
    CGRect buttonRect = [(UIButton*)[infoDictionary objectForKey:@"distButton"] frame];
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
    
    //    CGRect fixedRect1 = [thisButton.superview convertRect:buttonRect fromView:thisButton];
    CGRect fixedRect2 = [thisButton.superview.superview convertRect:buttonRect fromView:thisButton.superview];
    CGRect fixedRect3 = [thisButton.superview.superview.superview convertRect:fixedRect2 fromView:thisButton.superview.superview];
    CGRect fixedrect4 = [thisButton.superview.superview.superview.superview convertRect:fixedRect3 fromView:thisButton.superview.superview.superview];
    CGRect fixedRect5 = [thisButton.superview.superview.superview.superview.superview convertRect:fixedrect4 fromView:thisButton.superview.superview.superview.superview];
    
    //present popover
    [self.distIDPopover presentPopoverFromRect:fixedRect5 inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


//distIDPicker Delegate method
-(void)distIDSelectionMadeWithOriginalEquipUniqueKey:(NSString*)originalKeyID equipUniqueItem:(id)distEquipUniqueItem{
    
    //retrieve key id of selected equipUniqueItem AND indexPath of the collection cell that initiated the distID picker
    //tell content of the cell to use replace the dist ID
    //update the data model > schedule_equip_join has new unique_foreignKey
    
    //extract the unique's key as a string
    NSString* thisIsTheKey = [(EQREquipUniqueItem*)distEquipUniqueItem key_id];
    NSString* thisIsTheDistID = [(EQREquipUniqueItem*)distEquipUniqueItem distinquishing_id];
    //    NSLog(@"this is the issue_service_name text: %@", [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name]);
    NSString* thisIsTheIssueShortName = [(EQREquipUniqueItem*)distEquipUniqueItem issue_short_name];
    NSString* thisIsTheStatusLevel = [(EQREquipUniqueItem*)distEquipUniqueItem status_level];
    
    
    EQRScheduleTracking_EquipmentUnique_Join* saveThisJoin;
    
    //update local ivar arrays
    for (EQRScheduleTracking_EquipmentUnique_Join* joinObj in self.arrayOfJoins){
        
        if ([joinObj.equipUniqueItem_foreignKey isEqualToString:originalKeyID]){
            
            [joinObj setEquipUniqueItem_foreignKey:thisIsTheKey];
            [joinObj setDistinquishing_id:thisIsTheDistID];
            
            //_____need to know what service issues are a part of this new equipUnique and assign to local var in array______
            [joinObj setIssue_short_name:thisIsTheIssueShortName];
            [joinObj setStatus_level:thisIsTheStatusLevel];
            
            saveThisJoin = joinObj;
            break;
        }
    }
    self.arrayOfJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfJoins];
    
    //renew the collection view
    [self.myTable reloadData];
    
    
    //update the data layer
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", [saveThisJoin key_id], nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", [saveThisJoin equipUniqueItem_foreignKey], nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", [saveThisJoin equipTitleItem_foreignKey], nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, thirdArray, nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryForStringWithLink:@"EQAlterScheduleEquipJoin.php" parameters:topArray];
    //    NSLog(@"this is the return string: %@", returnString);
    
    
    //remove the popover
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController setDelegate:nil];
    
    [self.distIDPopover dismissPopoverAnimated:YES];
    
    //gracefully dealloc all the objects in the content VC
    [(EQRDistIDPickerTableVC*)self.distIDPopover.contentViewController killThisThing];
    
    self.distIDPopover = nil;
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
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



#pragma mark - equip item deletion notification methods

//-(void)addEquipUniqueToBeDeletedArray:(NSNotification*)note{
//    
//    [self.arrayOfToBeDeletedEquipIDs addObject:[note.userInfo objectForKey:@"key_id"]];
//}
//
//
//-(void)removeEquipUniqueToBeDeletedArray:(NSNotification*)note{
//    
//    NSString* stringToBeRemoved;
//    
//    for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
//        
//        if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
//            
//            stringToBeRemoved = thisString;
//        }
//    }
//    
//    [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
//}


#pragma mark - alert view delegate  / compose email

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //0 is cancel, 1 is use template, 2 is blank email
    
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
        [self.rightView setHidden:YES];
        [self.leftView setHidden:YES];
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
    
    NSString* CellIdentifier = @"Cell";
    EQREditorEquipListCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
}


-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SuppCell";
    
    EQREditorHeaderCell* cell = [self.myTable dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    [cell initialSetupWithTitle: [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] schedule_grouping]];
    
    return cell;
}


#pragma mark - table datasource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    return [self.arrayOfJoinsWithStructure count];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    
//    return [(NSArray*)[self.arrayOfJoinsWithStructure objectAtIndex:section] count];
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    
//    NSString* stringWithDistID = [NSString stringWithFormat:@"%@  # %@",[(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name], [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] distinquishing_id ]];
//
//    cell.textLabel.text = stringWithDistID;
//    cell.textLabel.font = [UIFont systemFontOfSize:13];
//    
//    return cell;
//}
//
//
//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    
//    return [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:section] objectAtIndex:0] schedule_grouping];
//}


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
