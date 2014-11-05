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

@interface EQRInboxRightVC ()

@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequest;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomLayoutGuideConstraint;

@property (strong, nonatomic) IBOutlet UITableView* myTable;
@property (strong, nonatomic) IBOutlet UIView* rightView;
@property (strong, nonatomic) IBOutlet UIView* leftView;

@property (strong, nonatomic) IBOutlet UILabel* timeOfRequestValue;
@property (strong, nonatomic) IBOutlet UILabel* firstLastNameValue;
@property (strong, nonatomic) IBOutlet UILabel* typeValue;
@property (strong, nonatomic) IBOutlet UILabel* classValue;
@property (strong, nonatomic) IBOutlet UILabel* pickUpTimeValue;
@property (strong, nonatomic) IBOutlet UILabel* returnTimeValue;

@property (strong, nonatomic) NSArray* arrayOfJoins;
@property (strong, nonatomic) NSArray* arrayOfJoinsWithStructure;

@property (strong, nonatomic) UIPopoverController* myStaffUserPicker;


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
    
    
    //derive the current user name
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    NSString* logText = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    
    //right button
    UIBarButtonItem* staffUserBarButton = [[UIBarButtonItem alloc] initWithTitle:logText style:UIBarButtonItemStylePlain target:self action:@selector(showStaffUserPicker)];
    
    //array that shit
    NSArray* arrayOfRightButtons = [NSArray arrayWithObjects:staffUserBarButton, nil];
    
    //set rightBarButton item in SELF
    [self.navigationItem setRightBarButtonItems:arrayOfRightButtons];
    
    //register cells
    [self.myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.myTable registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"SuppCell"];
    
    //initially hide everything
    [self.leftView setHidden:YES];
    [self.rightView setHidden:YES];
        
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
    
    
    
    NSArray *constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[mainSubView]-49-[bottomGuide]"
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
    
    
    
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated{
    
    //set title on bar button item
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];

    NSString* newUserString = [NSString stringWithFormat:@"Logged in as %@", staffUserManager.currentStaffUser.first_name];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:newUserString];
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

-(void)sendEmail{
    
    
    NSString* messageTitle = @"subject title";
    NSString* messageBody = @"body";
    NSArray* messageRecipients = [NSArray arrayWithObjects: @"dave@nwfilm.org", nil];
    
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
    return cell;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.arrayOfJoinsWithStructure objectAtIndex:section] objectAtIndex:0] schedule_grouping];
}


#pragma mark - table delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
