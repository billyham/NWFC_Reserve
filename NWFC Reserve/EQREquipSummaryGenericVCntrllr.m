//
//  EQREquipSummaryGenericVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREquipSummaryGenericVCntrllr.h"
#import "EQREquipSummaryVCntrllr.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQRContactNameItem.h"
#import "EQREquipItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQREquipUniqueItem.h"
#import "EQRCheckPageRenderer.h"
#import "EQRDataStructure.h"
#import "EQRModeManager.h"
#import "EQRMiscJoin.h"
#import "EQRColors.h"

@interface EQREquipSummaryGenericVCntrllr ()

@property (nonatomic, strong) NSString* rentorNameAtt;
@property (nonatomic, strong) NSString* rentorPhoneAtt;
@property (nonatomic, strong) NSString* rentorEmailAtt;

@property (nonatomic, strong) IBOutlet UITextView* summaryTextView;
@property (nonatomic, strong) NSMutableAttributedString* summaryTotalAtt;

@property (strong, nonatomic) IBOutlet UIButton* printAndConfirmButton;
@property (strong, nonatomic) IBOutlet UIButton* editPhoneButton;
@property (strong, nonatomic) IBOutlet UIButton* editEmailButton;
@property (strong, nonatomic) IBOutlet UIButton *changeContactButton;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomLayoutGuideConstraint;

@property (strong, nonatomic) IBOutlet UILabel* contactName;
@property (strong, nonatomic) IBOutlet UILabel* contactPhone;
@property (strong, nonatomic) IBOutlet UILabel* contactEmail;

@property (strong, nonatomic) UIPopoverController* phonePopover;
@property (strong, nonatomic) UIPopoverController* emailPopover;
@property (strong, nonatomic) UIPopoverController *myContactPicker;

@end

@implementation EQREquipSummaryGenericVCntrllr


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
    
    //add the cancel button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTheThing:)];
    
    //add button to the current navigation item
    [self.navigationItem setRightBarButtonItem:cancelButton];
    
    //load the request to populate the ivars
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    NSString* contactCondensedName = requestManager.request.contact_name;
    EQRContactNameItem* contactItem = requestManager.request.contactNameItem;
    
    // Error handling if contact_name is nil
    if (contactCondensedName == nil){
        contactCondensedName = @"NA";
    }
    
    NSDateFormatter* pickUpFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pickUpFormatter setLocale:usLocale];
    [pickUpFormatter setDateFormat:@"EEE, MMM d, yyyy, h:mm aaa"];
    
    // Save values to properties
    self.rentorNameAtt = requestManager.request.contact_name;
    self.rentorPhoneAtt = contactItem.phone;
    self.rentorEmailAtt = contactItem.email;

    // Validate and email address and disguise it for secure display
    NSString* emailForDisplay = [EQRDataStructure emailValidationAndSecureForDisplay:self.rentorEmailAtt];
    if (emailForDisplay == nil){
        self.contactEmail.font = [UIFont boldSystemFontOfSize:14];
        self.contactEmail.text = @"(Please provide an email address)";
        self.contactEmail.textColor = [UIColor redColor];
    }else{
        self.contactEmail.font = [UIFont systemFontOfSize:14];
        self.contactEmail.text = emailForDisplay;
        self.contactEmail.textColor = [UIColor blackColor];
    }
    
    // Validate and phone and disguise it for secure display
    NSString* phoneForDisplay = [EQRDataStructure phoneValidationAndSecureForDisplay:self.rentorPhoneAtt];
    if (phoneForDisplay == nil){
        self.contactPhone.font = [UIFont boldSystemFontOfSize:14];
        self.contactPhone.text = @"(Please provide a phone number)";
        self.contactPhone.textColor = [UIColor redColor];
    }else{
        self.contactPhone.font = [UIFont systemFontOfSize:14];
        self.contactPhone.text = phoneForDisplay;
        self.contactPhone.textColor = [UIColor blackColor];
    }
    
    // Name
    self.contactName.text = self.rentorNameAtt;

    
    // Body text
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"viewDidLoad";
    queue.maxConcurrentOperationCount = 5;
    
    UIFont* smallFont = [UIFont boldSystemFontOfSize:10];
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
    
    // Begin an attributed string
    self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    NSMutableAttributedString *datesAttr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSBlockOperation *dates = [NSBlockOperation blockOperationWithBlock:^{
        //_______PICKUP DATE_____
        NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
        NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"\rPick Up: " attributes:arrayAtt6];
        [datesAttr appendAttributedString:pickupHead];
        
        NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
        NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestManager.request.request_date_begin]  attributes:arrayAtt7];
        [datesAttr appendAttributedString:pickupAtt];
        
        //______RETURN DATE________
        NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
        NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"            Return: " attributes:arrayAtt8];
        [datesAttr appendAttributedString:returnHead];
        
        NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
        NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestManager.request.request_date_end]  attributes:arrayAtt9];
        [datesAttr appendAttributedString:returnAtt];
    }];
    
    
    NSMutableAttributedString *equipmentAttr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSBlockOperation *equipment = [NSBlockOperation blockOperationWithBlock:^{
        //________EQUIP LIST________
        
        NSDictionary* arrayAtt10 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
        NSAttributedString* equipHead = [[NSAttributedString alloc] initWithString:@"\r\r\rEquipment Items:\r" attributes:arrayAtt10];
        [equipmentAttr appendAttributedString:equipHead];
        
        // Cycle through scheduleTracking_equip_joins
        // Add structure to the array
        //________!!!!!!!!!!!  THIS WILL CAUSE A CRASH WHEN USING THE DESIRABLE VERSION OF THE METHOD   !!!!!!!!!!____________
        //________!!!!!!!!!!!  BECAUSE THERE IS NO VALUE FOR scheduleGrouping or distinguishing_ID in the join objects  !!!!!!!!!____________
        NSArray* arrayOfEquipmentJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArrayTheOldWay:requestManager.request.arrayOfEquipmentJoins];
        
        //  Cycle through subarrays and decompose scheduleTracking_EquipmentUniue_Joins to dictionaries with EquipTitleItems and quantities
        NSMutableArray* topArrayOfDecomposedEquipTitlesAndJoins = [NSMutableArray arrayWithCapacity:1];
        for (NSArray* arrayFun in arrayOfEquipmentJoinsWithStructure){
            
            NSArray* subArrayOfDecomposedEquipTitlesAndJoins = [EQRDataStructure decomposeJoinsToEquipTitlesWithQuantities:arrayFun];
            
            [topArrayOfDecomposedEquipTitlesAndJoins addObject:subArrayOfDecomposedEquipTitlesAndJoins];
        }
        
        
        for (NSArray* innerArray in topArrayOfDecomposedEquipTitlesAndJoins){
            
            // Print equipment category
            NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:smallFont forKey:NSFontAttributeName];
            NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r", [(EQREquipItem*) [(NSDictionary*)[innerArray objectAtIndex:0] objectForKey:@"equipTitleObject" ] schedule_grouping]] attributes:arrayAtt11];
            
            [equipmentAttr appendAttributedString:thisHereAttString];
            
            for (NSDictionary* innerSubDictionary in innerArray){
                
                NSString* quantityFollowedByShortname = [NSString stringWithFormat:@"%@ x %@",
                                                         [innerSubDictionary objectForKey:@"quantity"],
                                                         [(EQREquipItem*)[innerSubDictionary objectForKey:@"equipTitleObject"] shortname]
                                                         ];
                
                NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
                NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", quantityFollowedByShortname] attributes:arrayAtt11];
                
                [equipmentAttr appendAttributedString:thisHereAttString];
            }
        }
    }];
    
    
    NSMutableAttributedString *miscAttr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSBlockOperation *misc = [NSBlockOperation blockOperationWithBlock:^{

        // Gather any misc joins
        NSArray* omegaArray = @[ @[@"scheduleTracking_foreignKey", requestManager.request.key_id] ];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *tempMiscMuteArray) {
          
            // If miscJoins exist...
            if ([tempMiscMuteArray count] > 0){
                
                // Print miscellaneous section
                NSDictionary* arrayAtt13 = @{NSFontAttributeName:smallFont};
                NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r",@"Miscellaneous"] attributes:arrayAtt13];
                [miscAttr appendAttributedString:thisHereString];
                
                for (EQRMiscJoin* miscJoin in tempMiscMuteArray){
                    
                    NSDictionary* arrayAtt14 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
                    NSAttributedString* thisHereAttStringAgain = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", miscJoin.name] attributes:arrayAtt14];
                    
                    [miscAttr appendAttributedString:thisHereAttStringAgain];
                }
            }
        }];
    }];
    
    
    NSMutableAttributedString *notesAttr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSBlockOperation *notes = [NSBlockOperation blockOperationWithBlock:^{
       //_______Notes___________
       if (requestManager.request.notes){
           if (![requestManager.request.notes isEqualToString:@""]){
               
               NSDictionary* arrayAtt15 = @{NSFontAttributeName:smallFont};
               NSAttributedString* thisHereString = [[NSAttributedString alloc] initWithString:@"\r   Notes\r" attributes:arrayAtt15];
               [notesAttr appendAttributedString:thisHereString];
               
               NSDictionary* arrayAtt16 = @{NSFontAttributeName:normalFont};
               NSAttributedString* thisHereString2 = [[NSAttributedString alloc] initWithString:requestManager.request.notes attributes:arrayAtt16];
               [notesAttr appendAttributedString:thisHereString2];
           }
       }
    }];
    
    
    NSBlockOperation *render = [NSBlockOperation blockOperationWithBlock:^{
        [self.summaryTotalAtt appendAttributedString:datesAttr];
        [self.summaryTotalAtt appendAttributedString:equipmentAttr];
        [self.summaryTotalAtt appendAttributedString:miscAttr];
        [self.summaryTotalAtt appendAttributedString:notesAttr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.summaryTextView.attributedText = self.summaryTotalAtt;
        });
        
    }];
    [render addDependency:dates];
    [render addDependency:equipment];
    [render addDependency:misc];
    [render addDependency:notes];
    

    [queue addOperation:dates];
    [queue addOperation:equipment];
    [queue addOperation:misc];
    [queue addOperation:notes];
    [queue addOperation:render];
}


-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    self.navigationItem.title = @"Summary";
    
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
    
    
    // Add constraints
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
    
    // Drop exisiting constraints
    //_____THIS IS NECESSARY BECAUSE NIBS REALLY HATE IT IF YOU LEAVE OUT ANY CONSTRAINTS __
    //_____THESE WERE ONLY TEMPORARY TO SATISIFY THE NIB FROM SCREAMING ERROR MESSAGES____
    [[self.mainSubView superview] removeConstraints:[NSArray arrayWithObjects:self.topLayoutGuideConstraint, self.bottomLayoutGuideConstraint, nil]];
    
    //add replacement constraints
    [[self.mainSubView superview] addConstraints:constraint_POS_V];
    [[self.mainSubView superview] addConstraints:constraint_POS_VB];
    
        
    [super viewWillAppear:animated];
}


#pragma mark - cancel

-(IBAction)cancelTheThing:(id)sender{
    
    // Go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    // Send note to reset eveything back to 0
    //    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:nil];
    
    // Reset eveything back to 0 (which in turn sends an nsnotification)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager dismissRequest:YES];
    
}


#pragma mark - edit buttons

-(IBAction)editPhoneNumber:(id)sender{
    
    EQREnterPhoneVC* phoneVC = [[EQREnterPhoneVC alloc] initWithNibName:@"EQREnterPhoneVC" bundle:nil];
    phoneVC.delegate = self;
    
    self.phonePopover = [[UIPopoverController alloc] initWithContentViewController:phoneVC];
    self.phonePopover.delegate = self;
    [self.phonePopover setPopoverContentSize:CGSizeMake(320.f, 200.f)];
    
    CGRect thisRect = [self.editPhoneButton.superview.superview convertRect:self.editPhoneButton.frame fromView:self.editPhoneButton.superview];
    
    [self.phonePopover presentPopoverFromRect:thisRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
}


-(void)phoneEntered:(NSString*)phoneNumber{
    
    // Update local objects
    self.contactPhone.text = phoneNumber;
    self.contactPhone.textColor = [UIColor blackColor];
    self.contactPhone.font = [UIFont systemFontOfSize:14];
    self.rentorPhoneAtt = phoneNumber;
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    //____yikes!
    requestManager.request.contactNameItem.phone = phoneNumber;
    
    // Make change to contact db
    NSArray* topArray = @[ @[@"key_id", requestManager.request.contact_foreignKey],
                           @[@"phone", phoneNumber] ];

    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQAlterPhoneInContact.php" parameters:topArray completion:^(id object) {
            [self.phonePopover dismissPopoverAnimated:YES];
            self.phonePopover = nil;
        }];
    });
}


-(IBAction)editEmailAddress:(id)sender{
    
    EQREnterEmail* emailVC = [[EQREnterEmail alloc] initWithNibName:@"EQREnterEmail" bundle:nil];
    emailVC.delegate = self;
    
    self.emailPopover = [[UIPopoverController alloc] initWithContentViewController:emailVC];
    self.emailPopover.delegate = self;
    [self.emailPopover setPopoverContentSize:CGSizeMake(320.f, 200.f)];
    
    CGRect thisRect = [self.editEmailButton.superview.superview convertRect:self.editEmailButton.frame fromView:self.editEmailButton.superview];
    
    [self.emailPopover presentPopoverFromRect:thisRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
}


-(void)emailEntered:(NSString *)email{
    
    // Update local objects
    self.contactEmail.text = email;
    self.contactEmail.textColor = [UIColor blackColor];
    self.contactEmail.font = [UIFont systemFontOfSize:14];
    self.rentorEmailAtt = email;
    EQRScheduleRequestManager *requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.contactNameItem.email = email;
    
    // Update database
    NSArray* topArray = @[ @[@"key_id", requestManager.request.contact_foreignKey],
                           @[@"email", email] ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryForStringwithAsync:@"EQAlterEmailInContact.php" parameters:topArray completion:^(id object) {
            [self.emailPopover dismissPopoverAnimated:YES];
            self.emailPopover = nil;
        }];
    });
}


-(IBAction)changeContact:(id)sender{
    
    EQRContactPickerVC* contactPickerVC = [[EQRContactPickerVC alloc] initWithNibName:@"EQRContactPickerVC" bundle:nil];
    contactPickerVC.delegate = self;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:contactPickerVC];
    [navController setNavigationBarHidden:YES];
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myContactPicker = popOver;
    self.myContactPicker.delegate = self;
    
    //set the size
    [self.myContactPicker setPopoverContentSize:CGSizeMake(320, 550)];
    
    //get coordinates in proper view
    
    //present popOver
    [self.myContactPicker presentPopoverFromRect:self.changeContactButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
    
}


-(void)retrieveSelectedNameItem{
    
}

-(void)retrieveSelectedNameItemWithObject:(id)contactObject{
    
    EQRContactNameItem* nameItem = (EQRContactNameItem *)contactObject;
    
    self.contactName.text = nameItem.first_and_last;
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.contactNameItem = nameItem;
    requestManager.request.contact_name = nameItem.first_and_last;
    requestManager.request.contact_foreignKey = nameItem.key_id;
    
    
    //change contact information
    //save values to ivar
    self.rentorNameAtt = requestManager.request.contact_name;
    self.rentorPhoneAtt = nameItem.phone;
    self.rentorEmailAtt = nameItem.email;
    
    //validate and email address and disguise it for secure display
    NSString* emailForDisplay = [EQRDataStructure emailValidationAndSecureForDisplay:self.rentorEmailAtt];
    if (emailForDisplay == nil){
        self.contactEmail.font = [UIFont boldSystemFontOfSize:14];
        self.contactEmail.text = @"(Please provide an email address)";
        self.contactEmail.textColor = [UIColor redColor];
    }else{
        self.contactEmail.font = [UIFont systemFontOfSize:14];
        self.contactEmail.text = emailForDisplay;
        self.contactEmail.textColor = [UIColor blackColor];
    }
    
    //validate and phone and disguise it for secure display
    NSString* phoneForDisplay = [EQRDataStructure phoneValidationAndSecureForDisplay:self.rentorPhoneAtt];
    if (phoneForDisplay == nil){
        self.contactPhone.font = [UIFont boldSystemFontOfSize:14];
        self.contactPhone.text = @"(Please provide a phone number)";
        self.contactPhone.textColor = [UIColor redColor];
    }else{
        self.contactPhone.font = [UIFont systemFontOfSize:14];
        self.contactPhone.text = phoneForDisplay;
        self.contactPhone.textColor = [UIColor blackColor];
    }
    
    //dismiss popover
    [self.myContactPicker dismissPopoverAnimated:YES];
    self.myContactPicker = nil;
}



#pragma mark - confirm button

-(IBAction)confirm:(id)sender{
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager justConfirm];
    
//    [self justConfirm];
    
    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    
    //go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
    [requestManager dismissRequest:NO];
    
}


#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    if (popoverController == self.phonePopover){
        
        self.phonePopover = nil;
        
    }else if (popoverController == self.emailPopover){
        
        self.emailPopover = nil;
        
    }else if (popoverController == self.myContactPicker){
        
        self.myContactPicker = nil;
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
