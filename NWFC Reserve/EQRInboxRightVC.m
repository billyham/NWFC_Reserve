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


@interface EQRInboxRightVC ()

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequest;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* tablebottomGuideConstraint;

@property (strong, nonatomic) IBOutlet UITableView* myTable;
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
@property (strong, nonatomic) IBOutlet UITextField* typeValueField;
@property (strong, nonatomic) IBOutlet UITextField* classValueField;
@property (strong, nonatomic) IBOutlet UIButton* pickUpTimeValueField;
@property (strong, nonatomic) IBOutlet UIButton* returnTimeValueField;

@property (strong, nonatomic) IBOutlet UIView* addButtonView;

@property (strong, nonatomic) NSArray* arrayOfJoins;
@property (strong, nonatomic) NSArray* arrayOfJoinsWithStructure;

//popOver controllers
@property (strong, nonatomic) UIPopoverController* myStaffUserPicker;
@property (strong, nonatomic) UIPopoverController* myDayDatePicker;
@property (strong, nonatomic) UIPopoverController* myContactPicker;

//popOver root VCs
@property (strong, nonatomic) EQREditorDateVCntrllr* myDayDateVC;
@property (strong, nonatomic) EQRContactPickerVC* myContactVC;


@property BOOL inEditModeFlag;


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
    [self.myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.myTable registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"SuppCell"];
    
    //initially hide everything
    [self.leftView setHidden:YES];
    [self.rightView setHidden:YES];
    [self.viewEditLeft setHidden:YES];
    [self.addButtonView setHidden:YES];
        
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    [self.splitViewController setDelegate:self];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
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
    self.typeValueField.text = self.typeValue.text;
    self.classValueField.text = self.classValue.text;
    [self.pickUpTimeValueField setTitle:self.pickUpTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    [self.returnTimeValueField setTitle:self.returnTimeValue.text forState:(UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted)];
    
    
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
    
    //show the add button
    [self.addButtonView setHidden:NO];
    
    //raise table to reveal add button
    self.tablebottomGuideConstraint.constant = 50.f;
    
    //lower main sub view to reveal save button
    self.topLayoutGuideConstraint.constant = 50;
    
    
    
    //animate changes in the constraints (specifically the constraints added to mainSubView)
    [self.mainSubView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        //generally, use the the top most view
        [self.view layoutIfNeeded];
    }];
    
    
   
    
    
    
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
    
    //lower table to hide add button (NOT ANIMATE-ABLE?)
    self.tablebottomGuideConstraint.constant = 0;
    
    //raise main sub view to hide save button
    self.topLayoutGuideConstraint.constant = 0;
    
    //hide the add button after the change to the constraint is complete
    [self.addButtonView setHidden:NO];
    
    
    
    //animate changes in the constraints (specifically the constraints added to mainSubView)
    [self.mainSubView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        //genearlly, use the top most view
        [self.view layoutIfNeeded];
    }];
    
  
}


-(IBAction)addItemButton:(id)sender{
    
    
}


-(IBAction)doneButton:(id)sender{
    
    
    
}


-(IBAction)changeNameTextField:(id)sender{
    
    EQRContactPickerVC* contactVC = [[EQRContactPickerVC alloc] initWithNibName:@"EQRContactPickerVC" bundle:nil];
    self.myContactVC = contactVC;
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:self.myContactVC];
    self.myContactPicker = popOver;
    
    //set the size
    [self.myContactPicker setPopoverContentSize:CGSizeMake(300, 500)];
    
    //present the popOver
    [self.myContactPicker presentPopoverFromRect:self.nameValueField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
    //actions to perform AFTER presenting the popOver
    
    //assign self as delegate of name picker
    self.myContactVC.delegate = self;

}




-(IBAction)changeTypeTextField:(id)sender{
    
    
}

-(IBAction)changeClassTextField:(id)sender{
    
    
}


-(IBAction)changeDateTextFields:(id)sender{
    
    //datDatePicker shared nib
    EQREditorDateVCntrllr* datePickerVC = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    self.myDayDateVC = datePickerVC;
    
    //create the popover and assign to ivar
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:datePickerVC];
    self.myDayDatePicker = popOver;
    self.myDayDatePicker.popoverContentSize = CGSizeMake(320.f, 570.f);
    
    
    //present the popover
    [self.myDayDatePicker presentPopoverFromRect:self.pickUpTimeValueField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //methods AFTER adding the popover to the view
    
    //enter dates into datepicker
    NSDate* combinedPickupDate = [EQRDataStructure dateFromCombinedDay:self.myScheduleRequest.request_date_begin And8HourShiftedTime:self.myScheduleRequest.request_time_begin];
    NSDate* combinedReturnDate = [EQRDataStructure dateFromCombinedDay:self.myScheduleRequest.request_date_end And8HourShiftedTime:self.myScheduleRequest.request_time_end];
    
    self.myDayDateVC.pickupDateField.date = combinedPickupDate;
    self.myDayDateVC.returnDateField.date = combinedReturnDate;
    
    //assign target for datDatePicker's actions
    [self.myDayDateVC.saveButton addTarget:self action:@selector(receiveNewPickupDate) forControlEvents:UIControlEventTouchUpInside];

    
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
    
    //dismiss the popover
    [self.myDayDatePicker dismissPopoverAnimated:YES];
    self.myDayDateVC = nil;
    
}


//ContactPickerVC delegate method
-(void)retrieveSelectedNameItem{
    
    EQRContactNameItem* thisNameItem = [self.myContactVC retrieveContactItem];
    
    //update view objets
    self.nameValueField.titleLabel.text = thisNameItem.first_and_last;
    self.firstLastNameValue.text = thisNameItem.first_and_last;
    
    //udpate myScheduleRequest
    self.myScheduleRequest.contactNameItem = thisNameItem;
    self.myScheduleRequest.contact_name = thisNameItem.first_and_last;
    self.myScheduleRequest.contact_foreignKey = thisNameItem.key_id;
    
    //____!!!!!   update data layer   !!!!!______
    
    //dismiss the popover
    [self.myContactPicker dismissPopoverAnimated:YES];
}



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
    
    NSLog(@"inside willHide split view delegate method");
    
    barButtonItem.title = @"Requests";
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    self.popover = pc;
    
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    
    [self.navigationItem setLeftBarButtonItem:nil];
    
    self.popover = nil;
}



#pragma mark - table datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.arrayOfJoinsWithStructure count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [(NSArray*)[self.arrayOfJoinsWithStructure objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString* stringWithDistID = [NSString stringWithFormat:@"%@  # %@",[(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name], [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] distinquishing_id ]];

    cell.textLabel.text = stringWithDistID;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:section] objectAtIndex:0] schedule_grouping];
}


#pragma mark - table delegate methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [UIColor blackColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:12];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
