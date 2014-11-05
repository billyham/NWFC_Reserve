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

@interface EQREquipSummaryGenericVCntrllr ()

@property (strong, nonatomic) IBOutlet UIButton* printAndConfirmButton;
@property (strong, nonatomic) IBOutlet UIView* mainSubView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* topLayoutGuideConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* bottomLayoutGuideConstraint;

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
    
    //nsattributedstrings
    UIFont* smallFont = [UIFont boldSystemFontOfSize:10];
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
    
    //begin the total attribute string
    self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];

    
    
    
//    //________NAME_________
    NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* nameHead = [[NSAttributedString alloc] initWithString:@"Name\r" attributes:arrayAttA];
    
    //initiate the total attributed string
    [self.summaryTotalAtt appendAttributedString:nameHead];
    
    //assign the name
    NSDictionary* arrayAtt = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    
    //________contactNameItem maybe nil. error handling when that's the case
    NSAttributedString* nameAtt;
    if (contactItem != nil){
        nameAtt = [[NSAttributedString alloc] initWithString:contactItem.first_and_last attributes:arrayAtt];
    }else{
        nameAtt = [[NSAttributedString alloc] initWithString:contactCondensedName attributes:arrayAtt];
    }
    [self.summaryTotalAtt appendAttributedString:nameAtt];


//    //____EMAIL____
//    //add to the attributed string
//    NSDictionary* arrayAtt2 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
//    NSAttributedString* emailHead = [[NSAttributedString alloc] initWithString:@"\r\rContact Email:\r" attributes:arrayAtt2];
//    
//    //concatentate to the att string
//    [self.summaryTotalAtt appendAttributedString:emailHead];
//    
//    NSDictionary* arrayAtt3 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
//    NSAttributedString* emailAtt;
//    if (contactItem != nil){
//        emailAtt = [[NSAttributedString alloc] initWithString:contactItem.email attributes:arrayAtt3];
//    }else{
//        emailAtt = [[NSAttributedString alloc] initWithString:@"NA" attributes:arrayAtt3];
//    }
//    [self.summaryTotalAtt appendAttributedString:emailAtt];
//    
//    //____PHONE______
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
    NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"\r\r\rPick Up: " attributes:arrayAtt6];
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
    
    //cycle through array of equipItems and build a string
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    
    
    
    //two options, 1. equip uniques or 2. equip titles
    //_________NOPE, the unqiue IDs haven't been established yet, it happens when confirm is tapped_____
    // 1.
    //    for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in requestManager.request.arrayOfEquipmentJoins){
    //
    //        NSArray* thisArray1 = [NSArray arrayWithObjects:@"key_id", joinItem.equipUniqueItem_foreignKey, Nil];
    //        NSArray* thisArray2 = [NSArray arrayWithObject:thisArray1];
    //        [webData queryWithLink:@"EQGetEquipmentUnique.php" parameters:thisArray2 class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
    //
    //            //add the text of the equip item names to the textField's attributed string
    //            for (EQREquipUniqueItem* equipItemObj in muteArray){
    //
    //                NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    //                NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@\r", equipItemObj.name, equipItemObj.distinquishing_id] attributes:arrayAtt11];
    //
    //                [self.summaryTotalAtt appendAttributedString:thisHereAttString];
    //            }
    //
    //        }];
    //
    //    }
    
    // 2. first, cycle through scheduleTracking_equip_joins
    //add structure to the array
    NSArray* arrayOfEquipmentJoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:requestManager.request.arrayOfEquipmentJoins];
    
    for (NSArray* innerArray in arrayOfEquipmentJoinsWithStructure){
        
        //print equipment category
        NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:smallFont forKey:NSFontAttributeName];
        NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r   %@\r", [(EQRScheduleTracking_EquipmentUnique_Join*)[innerArray objectAtIndex:0] schedule_grouping]] attributes:arrayAtt11];
        
        [self.summaryTotalAtt appendAttributedString:thisHereAttString];
        
        for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in innerArray){
            
            NSArray* thisArray1 = [NSArray arrayWithObjects:@"key_id", joinItem.equipTitleItem_foreignKey, Nil];
            NSArray* thisArray2 = [NSArray arrayWithObject:thisArray1];
            [webData queryWithLink:@"EQGetEquipmentTitles.php" parameters:thisArray2 class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
                
                //add the text of the equip item names to the textField's attributed string
                for (EQREquipItem* equipItemObj in muteArray){
                    
                    NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
                    NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", equipItemObj.shortname] attributes:arrayAtt11];
                    
                    [self.summaryTotalAtt appendAttributedString:thisHereAttString];
                }
                
            }];
            
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
    [requestManager dismissRequest];
    
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
        [requestManager dismissRequest];
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
    [requestManager dismissRequest];
    
}


//-(void)justConfirm{
//        
//    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
//    EQRScheduleRequestItem* request = requestManager.request;
//    
////    NSLog(@"this is the contact_foreignKey: %@", [NSString stringWithFormat:@"%@", request.contact_foreignKey]);
//    
//    //must not include nil objects in array
//    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
//    if (!request.contact_foreignKey) request.contact_foreignKey = @"88888888";
//    if (!request.classSection_foreignKey) request.classSection_foreignKey = @"88888888";
//    if (!request.classTitle_foreignKey) request.classTitle_foreignKey = @"88888888";
//    if (!request.request_date_begin) request.request_date_begin = [NSDate date];
//    if (!request.request_date_end) request.request_date_end = [NSDate date];
//    if (!request.contact_name) request.contact_name = @"88888888";
//    
//    //format the nsdates to a mysql compatible string
//    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
//    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [dateFormatForDate setLocale:usLocale];
//    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
//    NSString* dateBeginString = [dateFormatForDate stringFromDate:request.request_date_begin];
//    NSString* dateEndString = [dateFormatForDate stringFromDate:request.request_date_end];
//    
//    //format the time
//    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
//    [dateFormatForTime setLocale:usLocale];
//    [dateFormatForTime setDateFormat:@"HH:mm"];
//    NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:request.request_date_begin];
//    NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:request.request_date_end];
//    NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
//    NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
//    
//    //time of request
//    NSDate* timeRequest = [NSDate date];
//    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
//    [timeStampFormatter setLocale:usLocale];
//    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString* timeRequestString = [timeStampFormatter stringFromDate:timeRequest];
//    
//    
//    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", request.key_id,nil];
//    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", request.contact_foreignKey, nil];
//    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", request.classSection_foreignKey,nil];
//    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", request.classTitle_foreignKey,nil];
//    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
//    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
//    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", timeBeginString, nil];
//    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", timeEndString, nil];
//    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", request.contact_name, nil];
//    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", request.renter_type, nil];
//    NSArray* eleventhArray = [NSArray arrayWithObjects:@"time_of_request", timeRequestString, nil];
//    
//    NSArray* bigArray = [NSArray arrayWithObjects:
//                         firstArray,
//                         secondArray,
//                         thirdArray,
//                         fourthArray,
//                         fifthArray,
//                         sixthArray,
//                         seventhArray,
//                         eighthArray,
//                         ninthArray,
//                         tenthArray,
//                         eleventhArray,
//                         nil];
//    
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    
//    NSString* returnID = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
//    NSLog(@"this is the returnID: %@", returnID);
//    
//    
//    //___________************  Use this moment to allocate a uniqueItem object (key_id and/or dist ID) *****_______
//    
//    // replace the equipUniqueItem_foreignKey in the equipJoins in the requestManager's array
//    
//    // use the requestManager's array of all equipItems: requestManager.arrayOfEquipUniqueItems
//    // compare against: requestManager.arrayOfEquipUniqueItemsByDateCollision
//    // derive available key_ids or distinquishing ids
//    
//    //start by identifying uniqueIds and making an array for each with the all key_ids
//    //subtract from each array the selected key_ids
//    //sort the array by distinguishing ids and select the lowest one for the join
//    
//    NSMutableArray* tempListOfUniqueItemsJustRequested = [NSMutableArray arrayWithCapacity:1];
//    
//    //compare this transaction's selections with the array of unqiue item collisions
//    
//    for (EQRScheduleTracking_EquipmentUnique_Join* join in requestManager.request.arrayOfEquipmentJoins){
//        
//        //add to nested array  only if it hasn't been added already
//        BOOL addFlag = YES;
//        
//        NSMutableArray* listOfAllUniqueKeys = [NSMutableArray arrayWithCapacity:1];
//        
//        for (NSMutableArray* arrayOfUniqueKeys in requestManager.arrayOfEquipUniqueItemsWithSubArrays){
//            
//            if ([[(EQREquipUniqueItem*)[arrayOfUniqueKeys objectAtIndex:0] equipTitleItem_foreignKey] isEqualToString:join.equipTitleItem_foreignKey]){
//                
//                
//                
//                for (NSMutableArray* innerArray in tempListOfUniqueItemsJustRequested){
//                    
////                    NSLog(@"this is a titleForeignKey: %@", [(EQREquipUniqueItem*)[innerArray objectAtIndex:0] equipTitleItem_foreignKey]);
////                    NSLog(@"this is another titleForeignKey: %@", join.equipTitleItem_foreignKey);
//                    
//                    if ([[(EQREquipUniqueItem*)[innerArray objectAtIndex:0] equipTitleItem_foreignKey] isEqualToString:join.equipTitleItem_foreignKey]){
//                        
//                        //found a match to an existing item, so don't add
//                        addFlag = NO;
//                        
//                        break;
//                    }
//                }
//                
//                [listOfAllUniqueKeys addObjectsFromArray:arrayOfUniqueKeys];
//                
//                //stop inner loop
//                break;
//            }
//        }
//        
//        //add to array of arrays
//        if (addFlag){
//            
//            [tempListOfUniqueItemsJustRequested addObject:listOfAllUniqueKeys];
//        }
//    }
//    //______the result is a nested array of just the titleItems requested, with sub_arrays of ALL uniqueItems
//    //tempListOfUniqueItemsJustRequested
//    
////    for (id obj in tempListOfUniqueItemsJustRequested){
////        
////        NSLog(@"count of objects in inner array: %u", (int)[obj count]);
////    }
//    
//    
//    
//    
//    //____now remove the unique items that have date collisions
//    //the top array
//    for (NSMutableArray* selectedUniqueList in tempListOfUniqueItemsJustRequested){
//        
//        NSMutableArray* arrayOfUniquesToRemove = [NSMutableArray arrayWithCapacity:1];
//        
//        //the inner array
//        for (EQREquipUniqueItem* selectedUniqueItem in selectedUniqueList){
//            
////            NSLog(@"this is the count of requestManager.arrayOfEquipUniqueItemsByDateCollision: %u", (int)[requestManager.arrayOfEquipUniqueItemsByDateCollision count]);
//            
//            
//            for (EQREquipUniqueItem* unItem in requestManager.arrayOfEquipUniqueItemsByDateCollision){
//                
////                NSLog(@"this is the selectedUniqueItem.key_id: %@  and this is the unItem.key_id: %@", selectedUniqueItem.key_id,unItem.key_id );
//                
//                if ([selectedUniqueItem.key_id isEqualToString:unItem.key_id]){
//                    
//                    //on a match, remove item from the tempList by adding to the list of objects to remove
//                    [arrayOfUniquesToRemove addObject:selectedUniqueItem];
//                }
//            }
//            
//            
//        }
//        
//        //here is where we deduct the list of deductions
//        [selectedUniqueList removeObjectsInArray:arrayOfUniquesToRemove];
//    }
//    //____the result is a modified nested array with the date collision uniques removed
//    
////    for (id obj in tempListOfUniqueItemsJustRequested){
////        
////        NSLog(@"NEW count of objects in inner array: %u", (int)[obj count]);
////    }
//    
//    
//    //geez.... now for each title item, find the matching array of uniques, and assign the key_id from the top of the stack and then pop the stack
//    
//    for (EQRScheduleTracking_EquipmentUnique_Join* joinMe in requestManager.request.arrayOfEquipmentJoins){
//        
//        for (NSMutableArray* uniqueArrayMe in tempListOfUniqueItemsJustRequested){
//            
//            //____an array may be left empty after the last function, avoid tyring to interate through
//            //____it or app will crash
//            if ([uniqueArrayMe count] > 0){
//                
//                NSMutableArray* kickMeOffTheTeam = [NSMutableArray arrayWithCapacity:1];
//                BOOL foundAMatchFlag = NO;
//                
//                if ([[(EQREquipUniqueItem*)[uniqueArrayMe objectAtIndex:0] equipTitleItem_foreignKey] isEqualToString:joinMe.equipTitleItem_foreignKey]) {
//                    
//                    joinMe.equipUniqueItem_foreignKey =[(EQREquipUniqueItem*)[uniqueArrayMe objectAtIndex:0] key_id];
//                    
//                    foundAMatchFlag = YES;
//                    
//                    //remove the EQREquipUniqueItem at index 0
//                    [kickMeOffTheTeam addObject:[uniqueArrayMe objectAtIndex:0]];
//                    
//                }
//                
//                if (foundAMatchFlag){
//                    
//                    //remove the uniqueItem From the array
//                    [uniqueArrayMe removeObjectsInArray:kickMeOffTheTeam];
//                    
//                    break;
//                }
//            }
//            
//        }
//    }
//    
//    
//    //input array of scheduleTracking_equipUniqueItem_joins
//    for (EQRScheduleTracking_EquipmentUnique_Join* join in requestManager.request.arrayOfEquipmentJoins){
//        
//        NSArray* firstArrayForJoin = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", join.scheduleTracking_foreignKey, nil];
//        NSArray* secondArrayForJoin = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", join.equipUniqueItem_foreignKey, nil];
//        NSArray* thirdArrayForJoin = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", join.equipTitleItem_foreignKey, nil];
//        NSArray* bigArrayForJoin = [NSArray arrayWithObjects:
//                                    firstArrayForJoin,
//                                    secondArrayForJoin,
//                                    thirdArrayForJoin,
//                                    nil];
//        
//        NSString* returnID2 = [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:bigArrayForJoin];
//        NSLog(@"this is the schedule_equip_join return key_id: %@", returnID2);
//    }
//}


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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
