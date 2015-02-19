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

@property (strong, nonatomic) IBOutlet UIButton* printAndConfirmButton;
@property (strong, nonatomic) IBOutlet UIButton* editPhoneButton;
@property (strong, nonatomic) IBOutlet UIButton* editEmailButton;

@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomLayoutGuideConstraint;

@property (strong, nonatomic) IBOutlet UILabel* contactName;
@property (strong, nonatomic) IBOutlet UILabel* contactPhone;
@property (strong, nonatomic) IBOutlet UILabel* contactEmail;

@property (strong, nonatomic) UIPopoverController* phonePopover;
@property (strong, nonatomic) UIPopoverController* emailPopover;

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
    
    //    NSString* contactKeyID = requestManager.request.contact_foreignKey;
    NSString* contactCondensedName = requestManager.request.contact_name;
    EQRContactNameItem* contactItem = requestManager.request.contactNameItem;
    
    //error handling if contact_name is nil
    if (contactCondensedName == nil){
        contactCondensedName = @"NA";
    }
    
    NSDateFormatter* pickUpFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pickUpFormatter setLocale:usLocale];
//    [pickUpFormatter setDateStyle:NSDateFormatterLongStyle];
//    [pickUpFormatter setTimeStyle:NSDateFormatterShortStyle];
    [pickUpFormatter setDateFormat:@"EEE, MMM d, yyyy, h:mm aaa"];
    
    //save values to ivar
    self.rentorNameAtt = requestManager.request.contact_name;
    self.rentorPhoneAtt = contactItem.phone;
    self.rentorEmailAtt = contactItem.email;

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
    
    //name
    self.contactName.text = self.rentorNameAtt;

    //nsattributedstrings
    UIFont* smallFont = [UIFont boldSystemFontOfSize:10];
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
    
    //begin the total attribute string
    self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];

    
    
    
//    //________NAME_________
//    NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//    NSAttributedString* nameHead = [[NSAttributedString alloc] initWithString:@"Name\r" attributes:arrayAttA];
//    
//    //initiate the total attributed string
//    [self.summaryTotalAtt appendAttributedString:nameHead];
//    
//    //assign the name
//    NSDictionary* arrayAtt = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
//    
//    //________contactNameItem maybe nil. error handling when that's the case
//    NSAttributedString* nameAtt;
//    if (contactItem != nil){
//        nameAtt = [[NSAttributedString alloc] initWithString:contactItem.first_and_last attributes:arrayAtt];
//    }else{
//        nameAtt = [[NSAttributedString alloc] initWithString:contactCondensedName attributes:arrayAtt];
//    }
//    [self.summaryTotalAtt appendAttributedString:nameAtt];


    //____EMAIL____
    //add to the attributed string
//    NSDictionary* arrayAtt2 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//    NSAttributedString* emailHead = [[NSAttributedString alloc] initWithString:@"\r\rContact Email:\r" attributes:arrayAtt2];
//    
//    //concatentate to the att string
//    [self.summaryTotalAtt appendAttributedString:emailHead];
//    
////    NSDictionary* arrayAtt3 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
//    NSDictionary* arrayAtt3 = @{NSFontAttributeName:boldFont, NSLinkAttributeName:@"http://www.hamagain.com"};
//    NSAttributedString* emailAtt;
//    if (contactItem != nil){
//        emailAtt = [[NSAttributedString alloc] initWithString:contactItem.email attributes:arrayAtt3];
//    }else{
//        emailAtt = [[NSAttributedString alloc] initWithString:@"NA" attributes:arrayAtt3];
//    }
//    [self.summaryTotalAtt appendAttributedString:emailAtt];
    
    //____PHONE______
//    NSDictionary* arrayAtt4 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//    NSAttributedString* phoneHead = [[NSAttributedString alloc] initWithString:@"\r\rContact Phone:\r" attributes:arrayAtt4];
//    [self.summaryTotalAtt appendAttributedString:phoneHead];
//    
//    NSDictionary* arrayAtt5 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
//    NSAttributedString* phoneAtt;
//    if (contactItem != nil){
//        phoneAtt = [[NSAttributedString alloc] initWithString:contactItem.phone attributes:arrayAtt5];
//    }else {
//        phoneAtt = [[NSAttributedString alloc] initWithString:@"NA" attributes:arrayAtt5];
//        
//    }
//    [self.summaryTotalAtt appendAttributedString:phoneAtt];
    
    //_______PICKUP DATE_____
    NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"\rPick Up: " attributes:arrayAtt6];
    [self.summaryTotalAtt appendAttributedString:pickupHead];
    
    NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestManager.request.request_date_begin]  attributes:arrayAtt7];
    [self.summaryTotalAtt appendAttributedString:pickupAtt];
    
    //______RETURN DATE________
    NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"            Return: " attributes:arrayAtt8];
    [self.summaryTotalAtt appendAttributedString:returnHead];
    
    NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestManager.request.request_date_end]  attributes:arrayAtt9];
    [self.summaryTotalAtt appendAttributedString:returnAtt];
    
    //________EQUIP LIST________
    
    NSDictionary* arrayAtt10 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* equipHead = [[NSAttributedString alloc] initWithString:@"\r\r\rEquipment Items:\r" attributes:arrayAtt10];
    [self.summaryTotalAtt appendAttributedString:equipHead];
        
    // 2. first, cycle through scheduleTracking_equip_joins
    //add structure to the array
    NSArray* arrayOfEquipmentJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:requestManager.request.arrayOfEquipmentJoins];
    
    //  3. cycle through subarrays and decompose scheduleTracking_EquipmentUniue_Joins to dictionaries with EquipTitleItems and quantities
    NSMutableArray* topArrayOfDecomposedEquipTitlesAndJoins = [NSMutableArray arrayWithCapacity:1];
    for (NSArray* arrayFun in arrayOfEquipmentJoinsWithStructure){
        
        NSArray* subArrayOfDecomposedEquipTitlesAndJoins = [EQRDataStructure decomposeJoinsToEquipTitlesWithQuantities:arrayFun];
        
        [topArrayOfDecomposedEquipTitlesAndJoins addObject:subArrayOfDecomposedEquipTitlesAndJoins];
    }
    
    
    for (NSArray* innerArray in topArrayOfDecomposedEquipTitlesAndJoins){
        
        //print equipment category
        NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:smallFont forKey:NSFontAttributeName];
        NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r", [(EQREquipItem*) [(NSDictionary*)[innerArray objectAtIndex:0] objectForKey:@"equipTitleObject" ] schedule_grouping]] attributes:arrayAtt11];
        
        [self.summaryTotalAtt appendAttributedString:thisHereAttString];
        
        for (NSDictionary* innerSubDictionary in innerArray){
            
            NSString* quantityFollowedByShortname = [NSString stringWithFormat:@"%@ x %@",
                                                     [innerSubDictionary objectForKey:@"quantity"],
                                                     [(EQREquipItem*)[innerSubDictionary objectForKey:@"equipTitleObject"] shortname]
                                                     ];
            
            NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
            NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", quantityFollowedByShortname] attributes:arrayAtt11];
                    
            [self.summaryTotalAtt appendAttributedString:thisHereAttString];
        }
    }
    
    
    
    //______Misc Join List_______
    //gather any misc joins
    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", requestManager.request.key_id];
    NSArray* omegaArray = @[alphaArray];
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
        for (id object in muteArray2){
            [tempMiscMuteArray addObject:object];
        }
    }];

    //if miscJoins exist...
    if ([tempMiscMuteArray count] > 0){
        
        //print miscellaneous section
        NSDictionary* arrayAtt13 = @{NSFontAttributeName:smallFont};
        NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r",@"Miscellaneous"] attributes:arrayAtt13];
        [self.summaryTotalAtt appendAttributedString:thisHereString];
        
        for (EQRMiscJoin* miscJoin in tempMiscMuteArray){
            
            NSDictionary* arrayAtt14 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
            NSAttributedString* thisHereAttStringAgain = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", miscJoin.name] attributes:arrayAtt14];
            
            [self.summaryTotalAtt appendAttributedString:thisHereAttStringAgain];
        }
    }
    
    //_______Notes___________
    if (requestManager.request.notes){
        if (![requestManager.request.notes isEqualToString:@""]){
            
            NSDictionary* arrayAtt15 = @{NSFontAttributeName:smallFont};
            NSAttributedString* thisHereString = [[NSAttributedString alloc] initWithString:@"\r   Notes\r" attributes:arrayAtt15];
            [self.summaryTotalAtt appendAttributedString:thisHereString];
            
            NSDictionary* arrayAtt16 = @{NSFontAttributeName:normalFont};
            NSAttributedString* thisHereString2 = [[NSAttributedString alloc] initWithString:requestManager.request.notes attributes:arrayAtt16];
            [self.summaryTotalAtt appendAttributedString:thisHereString2];
        }
    }
    
    
    
    
    self.summaryTextView.attributedText = self.summaryTotalAtt;
}


-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    self.navigationItem.title = @"Summary";
    
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        
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
    
        
    [super viewWillAppear:animated];
}


#pragma mark - cancel

-(IBAction)cancelTheThing:(id)sender{
    
    //go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //send note to reset eveything back to 0
    //    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:nil];
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
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
    
    //update local objects
    self.contactPhone.text = phoneNumber;
    self.contactPhone.textColor = [UIColor blackColor];
    self.contactPhone.font = [UIFont systemFontOfSize:14];
    self.rentorPhoneAtt = phoneNumber;
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    //____yikes!
    requestManager.request.contactNameItem.phone = phoneNumber;
    
    //make change to contact db
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = @[@"key_id", requestManager.request.contact_foreignKey];
    NSArray* secondArray = @[@"phone", phoneNumber];
    NSArray* topArray = @[firstArray, secondArray];
    [webData queryForStringWithLink:@"EQAlterPhoneInContact.php" parameters:topArray];
    
    [self.phonePopover dismissPopoverAnimated:YES];
    self.phonePopover = nil;
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
    
    //update local objects
    self.contactEmail.text = email;
    self.contactEmail.textColor = [UIColor blackColor];
    self.contactEmail.font = [UIFont systemFontOfSize:14];
    self.rentorEmailAtt = email;
    EQRScheduleRequestManager *requestManager = [EQRScheduleRequestManager sharedInstance];
    requestManager.request.contactNameItem.email = email;
    
    //make change to db
    EQRWebData *webData = [EQRWebData sharedInstance];
    NSArray* firstArray = @[@"key_id", requestManager.request.contact_foreignKey];
    NSArray* secondArray = @[@"email", email];
    NSArray* topArray = @[firstArray, secondArray];
    [webData queryForStringWithLink:@"EQAlterEmailInContact.php" parameters:topArray];
    
    [self.emailPopover dismissPopoverAnimated:YES];
    self.emailPopover = nil;
}





#pragma mark - confirm button

-(IBAction)confirmAndPrint:(id)sender{
    
    BOOL successOrNah = [self justPrint];
    
    if (successOrNah){
        
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        [requestManager justConfirm];
        
//        [self justConfirm];
        
        //go back to first page in nav
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        //reset eveything back to 0 (which in turn sends an nsnotification)
        [requestManager dismissRequest:NO];
    }
}


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


-(BOOL)justPrint{
    
    //_______PRINTING_________!
    
    UIPrintInteractionController* printIntCont = [UIPrintInteractionController sharedPrintController];
    
    UIViewPrintFormatter* viewPrintFormatter = [self.summaryTextView viewPrintFormatter];
    //add contect insets to printFormatter
    UIEdgeInsets myInsets = UIEdgeInsetsMake (0, 90, 0, 20);
    viewPrintFormatter.contentInsets = myInsets;
    
    
    UIPrintInfo* printInfo = [UIPrintInfo printInfo] ;
    printInfo.jobName = @"NWFC Reserve App: confirmation";
    printInfo.outputType = UIPrintInfoOutputGrayscale;
    //assign printinfo to int cntrllr
    printIntCont.printInfo = printInfo;
    
    
    //assign formatter to int cntrllr
//    printIntCont.printFormatter = viewPrintFormatter;
    
    //... or... create page renderer
    EQRCheckPageRenderer* pageRenderer = [[EQRCheckPageRenderer alloc] init];
    
    //assign renderer properties
    pageRenderer.headerHeight = 210.f;
    pageRenderer.footerHeight = 300.f;
    
    //add info to renderer properties
    pageRenderer.name_text_value = self.rentorNameAtt;
    pageRenderer.phone_text_value = self.rentorPhoneAtt;
    pageRenderer.email_text_value = self.rentorEmailAtt;
    
    
    //add printer formatter object to the page renderer
    [pageRenderer addPrintFormatter:viewPrintFormatter startingAtPageAtIndex:0];
    
    //assign page renderer to int cntrllr
    printIntCont.printPageRenderer = pageRenderer;
    
    

    
    
    
    __block BOOL successOrNot;
    
    [printIntCont presentFromRect:self.printAndConfirmButton.frame inView:self.view animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController,BOOL completed, NSError *error){
        
        //unless the printing in cancelled...
        
        if (completed){
            
            //            //go back to first page in nav
            //            [self.navigationController popToRootViewControllerAnimated:YES];
            //
            //            //reset eveything back to 0 (which in turn sends an nsnotification)
            //            [requestManager dismissRequest];
            
            successOrNot = YES;
            
        } else {
            
            successOrNot = NO;
        }
    }];
    
    return successOrNot;
}


#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    if (popoverController == self.phonePopover){
        
        self.phonePopover = nil;
        
    }else{
        
        self.emailPopover = nil;
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
