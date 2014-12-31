//
//  EQREditorTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorTopVCntrllr.h"
#import "EQREditorEquipListCell.h"
#import "EQREditorHeaderCell.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQREditorDateVCntrllr.h"
#import "EQREditorExtendedDateVC.h"
#import "EQREditorRenterVCntrllr.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQRColors.h"
#import "EQREquipSelectionGenericVCntrllr.h"
#import "EQRDataStructure.h"

@interface EQREditorTopVCntrllr ()

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) IBOutlet UIButton* nameTextField;
@property (strong, nonatomic) NSDate* pickUpDateDate;
@property (strong, nonatomic) NSDate* returnDateDate;
@property (strong, nonatomic) NSDate* pickUpTime;
@property (strong, nonatomic) NSDate* returnTime;

@property (strong, nonatomic) IBOutlet UITextField* pickupDateField;
@property (strong, nonatomic) IBOutlet UITextField* returnDateField;
@property (strong, nonatomic) IBOutlet UICollectionView* equipList;
@property (strong, nonatomic) UIPopoverController* theDatePopOver;

@property (strong, nonatomic) IBOutlet UIButton* renterTypeField;
//@property (strong ,nonatomic) IBOutlet UIPickerView* renterTypePicker;
@property (strong, nonatomic) NSString* renterTypeString;  //I don't think this is used
@property (strong, nonatomic) EQREditorRenterVCntrllr* myRenterViewController;
@property (strong, nonatomic) UIPopoverController* theRenterPopOver;

@property (strong, nonatomic) UIPopoverController* theEquipSelectionPopOver;
@property (strong, nonatomic) IBOutlet UIButton* addEquipItemButton;

@property (strong, nonatomic) NSMutableArray* arrayOfSchedule_Unique_Joins;
@property (strong, nonatomic) NSMutableArray* arrayOfToBeDeletedEquipIDs;
@property (strong, nonatomic) NSArray* arrayOfSchedule_Unique_JoinsWithStructure;

@property (strong, nonatomic) EQREditorDateVCntrllr* myDateVC;
@property (strong, nonatomic) EQRContactPickerVC* myContactVC;

//popOvers
@property (strong, nonatomic) UIPopoverController* myContactPicker;

@end

@implementation EQREditorTopVCntrllr

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
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    //register to receive delete instructions from equipList cells
    [nc addObserver:self selector:@selector(addEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeleted object:nil];
    [nc addObserver:self selector:@selector(removeEquipUniqueToBeDeletedArray:) name:EQREquipUniqueToBeDeletedCancel object:nil];
    
    //set ivar flag
    self.saveButtonTappedFlag = NO;
    
    //register collection view cell
    [self.equipList registerClass:[EQREditorEquipListCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.equipList registerClass:[EQREditorHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SuppCell"];
    
    //initialze ivar arrays
    if (!self.arrayOfSchedule_Unique_Joins){
        
        self.arrayOfSchedule_Unique_Joins = [NSMutableArray arrayWithCapacity:1];
        
    }else {
        
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    }
    
    
    if (!self.arrayOfToBeDeletedEquipIDs){
        
        self.arrayOfToBeDeletedEquipIDs = [NSMutableArray arrayWithCapacity:1];
        
    } else {
        
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    }
    
    //set color of collection view
    EQRColors* eqrColors = [EQRColors sharedInstance];
    self.equipList.backgroundColor = [eqrColors.colorDic objectForKey:EQRColorVeryLightGrey];
    
    //save bar button
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    
    //cancel bar button
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    [self.navigationItem setRightBarButtonItem:rightButton];
    

    
    //set title
    self.navigationItem.title = @"Editor Request";
    
    //get scheduleTrackingRequest info and...
    //get array of schedule_equipUnique_joins
    //user self.scheduleRequestKeyID
    
    
    
    
//    NSLog(@"this is the scheduleRequest key id: %@", [self.myUserInfo objectForKey:@"key_ID"]);
    
    //have the requestManager establish the list of available equipment?????
//    NSDictionary* datesDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                              self.pickUpDateDate, @"request_date_begin",
//                              self.returnDateDate, @"request_date_end",
//                              nil];
    
//    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //_______*******  THIS IS CRASHING BECAUSE THE DATE INFO IS NOT PRESENT_________**********
//    [requestManager allocateGearListWithDates:datesDic];
    
//    NSMutableArray* arrayToReturn = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayToReturnJoins = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"],  nil];
    NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
    
    //get Scheduletracking_equipUnique_joins   formerly used EQGetScheduleEquipJoins.php
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php"
                parameters:secondArray class:@"EQRScheduleTracking_EquipmentUnique_Join"
                completion:^(NSMutableArray *muteArray) {
       
        [arrayToReturnJoins addObjectsFromArray:muteArray];
    }];
    
    [self.arrayOfSchedule_Unique_Joins addObjectsFromArray:arrayToReturnJoins];
    
    //add structure to array
    self.arrayOfSchedule_Unique_JoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfSchedule_Unique_Joins];
    
    //reload collection view
    [self.equipList reloadData];
    
    
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.myUserInfo = userInfo;
    
    //create private request manager as ivar
    if (!self.privateRequestManager){
        
        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
    }
    
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    dateFormatter.dateFormat = @"yyyy-MM-dd";
    // HH:mm:ss
    
    //set dates
    self.pickUpDateDate = [self.myUserInfo objectForKey:@"request_date_begin"];
    self.returnDateDate = [self.myUserInfo objectForKey:@"request_date_end"];
    self.pickUpTime = [self.myUserInfo objectForKey:@"request_time_begin"];
    self.returnTime = [self.myUserInfo objectForKey:@"request_time_end"];
    
    //add times to dates
    self.pickUpDateDate = [self.pickUpDateDate dateByAddingTimeInterval: [self.pickUpTime timeIntervalSinceReferenceDate]];
    self.returnDateDate = [self.returnDateDate dateByAddingTimeInterval:[self.returnTime timeIntervalSinceReferenceDate]];
    
    //______adjust by subtracting 8 hours
    float secondsForOffset = -28800;    //this is 9 hours = 32400, this is 8 hours = 28800;
    self.pickUpDateDate = [self.pickUpDateDate dateByAddingTimeInterval:secondsForOffset];
    self.returnDateDate = [self.returnDateDate dateByAddingTimeInterval:secondsForOffset];
    
    
    
    //instantiate the request item in ivar requestManager
    self.privateRequestManager.request = [[EQRScheduleRequestItem alloc] init];
    
    //two important methods that initiate requestManager ivar arrays
    [self.privateRequestManager resetEquipListAndAvailableQuantites];
    [self.privateRequestManager retrieveAllEquipUniqueItems];
    
    
    //and populate its ivars
//    self.privateRequestManager.request.key_id = [self.myUserInfo objectForKey:@"key_ID"];
    self.privateRequestManager.request.renter_type = [self.myUserInfo objectForKey:@"renter_type"];
    self.privateRequestManager.request.contact_name = [self.myUserInfo objectForKey:@"contact_name"];
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* arrayWithKey = [NSArray arrayWithObjects:@"key_id",[userInfo objectForKey:@"key_ID"], nil];
    NSArray* topArrayWithKey = [NSArray arrayWithObject:arrayWithKey];
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:topArrayWithKey class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        //____ERROR HANDLING WHEN NOTHING IS RETURNED_______
        if ([muteArray count] > 0){
            self.privateRequestManager.request.key_id = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] key_id];
            self.privateRequestManager.request.contact_foreignKey =  [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] contact_foreignKey];
            self.privateRequestManager.request.classSection_foreignKey = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] classSection_foreignKey];
            self.privateRequestManager.request.classTitle_foreignKey = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] classTitle_foreignKey];
            self.privateRequestManager.request.time_of_request = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] time_of_request];
        }
    }];
    
//    NSLog(@"this is the contact foreign key: %@", self.privateRequestManager.request.contact_foreignKey);
    

    //_________**********  LOAD REQUEST EDITOR COLLECTION VIEW WITH EquipUniqueItem_Joins  *******_____________
    
    
    //populate...
    //arrayOfSchedule_Unique_Joins
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    //set labels with provided dictionary
    //must do this AFTER loading the view
    [self.nameTextField setTitle:[self.myUserInfo objectForKey:@"contact_name"] forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
    self.renterTypeString = [self.myUserInfo objectForKey:@"renter_type"];
    
    
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d, h:mm a";
    
    //set date labels
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    //set the renter field....
    [self.renterTypeField setTitle:self.privateRequestManager.request.renter_type forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    
    [super viewWillAppear:animated];
}



-(void)cancelAction{
    
//    [self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


-(IBAction)saveAction:(id)sender{
    
    self.saveButtonTappedFlag = YES;
    
    //update SQL with new request information
    EQRWebData* webData = [EQRWebData sharedInstance];
    
//    NSLog(@"this is the classSection_foreignKey: %@", self.privateRequestManager.request.classSection_foreignKey);
    
    //must not include nil objects in array
    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
    if (!self.privateRequestManager.request.contact_foreignKey) self.privateRequestManager.request.contact_foreignKey = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.classSection_foreignKey) self.privateRequestManager.request.classSection_foreignKey = EQRErrorCode88888888;
    if ([self.privateRequestManager.request.classSection_foreignKey isEqualToString:@""]) self.privateRequestManager.request.classSection_foreignKey = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.classTitle_foreignKey) self.privateRequestManager.request.classTitle_foreignKey = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.request_date_begin) self.privateRequestManager.request.request_date_begin = [NSDate date];
    if (!self.privateRequestManager.request.request_date_end) self.privateRequestManager.request.request_date_end = [NSDate date];
    if (!self.privateRequestManager.request.contact_name) self.privateRequestManager.request.contact_name = EQRErrorCode88888888;
    if (!self.privateRequestManager.request.time_of_request) self.privateRequestManager.request.time_of_request = [NSDate date];

    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatForDate stringFromDate:self.privateRequestManager.request.request_date_begin];
    NSString* dateEndString = [dateFormatForDate stringFromDate:self.privateRequestManager.request.request_date_end];
    
    //format the time
    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
    [dateFormatForTime setLocale:usLocale];
    [dateFormatForTime setDateFormat:@"HH:mm"];
    NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:self.privateRequestManager.request.request_date_begin];
    NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:self.privateRequestManager.request.request_date_end];
    NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
    NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
    
    //time of request
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:self.privateRequestManager.request.time_of_request];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.privateRequestManager.request.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", self.privateRequestManager.request.contact_foreignKey, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", self.privateRequestManager.request.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", self.privateRequestManager.request.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", timeBeginString, nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", timeEndString, nil];
    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", self.privateRequestManager.request.contact_name, nil];
    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", self.privateRequestManager.request.renter_type, nil];
    NSArray* eleventhArray = [NSArray arrayWithObjects:@"time_of_request", timeRequestString, nil];
    
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
    
    
    for (NSArray* arraySample in bigArray){
    NSLog(@"%@", arraySample);
    }
    
    
    NSString* returnID = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
    NSLog(@"this is the returnID: %@", returnID);
    
    
    //_______*********  delete the delted scheduleTracking_equip_joins
    for (NSString* thisKeyID in self.arrayOfToBeDeletedEquipIDs){
        
        for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in self.arrayOfSchedule_Unique_Joins){
         
            if ([thisKeyID isEqualToString:thisJoin.equipUniqueItem_foreignKey]){
                
                //found a matching equipUnique item
                
                //send php message to detele with the join key_id
                NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", thisJoin.key_id, nil];
                NSArray* beeArray = [NSArray arrayWithObject:ayeArray];
                NSString* returnString = [webData queryForStringWithLink:@"EQRDeleteScheduleEquipJoin.php" parameters:beeArray];
                
                NSLog(@"this is the result: %@", returnString);
            }
            
        }
    }
    
    //empty the arrays
    [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
    self.arrayOfSchedule_Unique_JoinsWithStructure = nil;

    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


-(IBAction)deleteRequest:(id)sender{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete Confirmation" message:@"Are you sure want to delete this reservation?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [alertView show];
    
    
    
}


//_______this is repeated in EQRQuickViewPage2VCntrllr.m________
//_______works with an array of ScheduleTracking_EquipUnique_Joins, should also work with array of EquipUniqueItems_____
//#pragma mark - create structured array of equipment
//
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//
//-(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray{
//    
//    //first get array of grouping objects
//    //get title items EQGetEquipmentTitlesAll (except items with hide_from_public set to YES)
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    __block NSMutableSet* tempMuteSetOfGroupingStrings = [NSMutableSet setWithCapacity:1];
//    __block NSMutableDictionary* tempMuteDicOfTitleKeysToGrouping = [NSMutableDictionary dictionaryWithCapacity:1];
//    
//    
//    [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
//        
//        //loop through entire title item array
//        for (EQREquipItem* item in muteArray){
//            
//            //add item's schedule_grouping to the dictionary
//            [tempMuteDicOfTitleKeysToGrouping setValue:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]forKey:item.key_id];
//            
//            BOOL foundTitleDontAdd = NO;
//            
//            for (NSString* titleString in tempMuteSetOfGroupingStrings){
//                
//                //identify items with schedule _grouping already in our muteable array
//                if ([[item performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:titleString]){
//                    
//                    foundTitleDontAdd = YES;
//                }
//            }
//            
//            //advance to next title item
//            if (foundTitleDontAdd == NO){
//                
//                //otherwise add grouping in set
//                [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
//            }
//        }
//    }];
//    
//    NSMutableArray* tempTopArray = [NSMutableArray arrayWithCapacity:1];
//    
//    //loop through ivar array of joins
//    for (EQRScheduleTracking_EquipmentUnique_Join* join in flatArray){
//        
//        //find a matching key_id
//        NSString* groupingString = [tempMuteDicOfTitleKeysToGrouping objectForKey:join.equipTitleItem_foreignKey];
//        
//        //assign to join object
//        join.schedule_grouping = groupingString;
//        
//        BOOL createNewSubArray = YES;
//        
//        for (NSMutableArray* subArray in tempTopArray){
//            
//            if ([join.schedule_grouping isEqualToString:[(EQRScheduleTracking_EquipmentUnique_Join*)[subArray objectAtIndex:0] schedule_grouping]]){
//                
//                createNewSubArray = NO;
//                
//                //add join to this subArray
//                [subArray addObject:join];
//            }
//        }
//        
//        if (createNewSubArray == YES){
//            
//            //create a new array
//            NSMutableArray* newArray = [NSMutableArray arrayWithObject:join];
//            
//            //add the subarray to the top array
//            [tempTopArray addObject:newArray];
//        }
//        
//    }
//    
//    NSArray* arrayToReturn = [NSArray arrayWithArray:tempTopArray];
//    
//    //sort the array alphabetically
//    NSArray* sortedTopArray = [arrayToReturn sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        
//        return [[(EQRScheduleTracking_EquipmentUnique_Join*)[obj1 objectAtIndex:0] schedule_grouping]
//                compare:[(EQRScheduleTracking_EquipmentUnique_Join*)[obj2 objectAtIndex:0] schedule_grouping]];
//    }];
//    
//    return sortedTopArray;
//}
//
//#pragma clang diagnostic pop



#pragma mark - alert view delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //buttonIndex at 0 is cancel

    //handle delete action when delete in confirmed
    if (buttonIndex == 1){
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        //delete the scheduleTracking item
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.privateRequestManager.request.key_id, nil];
        NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
        NSString* scheduleReturn = [webData queryForStringWithLink:@"EQDeleteScheduleItem.php" parameters:secondArray];
        NSLog(@"this is the schedule return: %@", scheduleReturn);
        
        //delete all scheduleTracking_equipUnique_joins
        NSArray* alphaArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey",self.privateRequestManager.request.key_id, nil];
        NSArray* betaArray = [NSArray arrayWithObjects:alphaArray, nil];
        NSString* joinReturn = [webData queryForStringWithLink:@"EQDeleteScheduleEquipJoinWithScheduleKey.php" parameters:betaArray];
        NSLog(@"this is the join return: %@", joinReturn);
        
        //empty the arrays
        [self.arrayOfSchedule_Unique_Joins removeAllObjects];
        [self.arrayOfToBeDeletedEquipIDs removeAllObjects];
        self.arrayOfSchedule_Unique_JoinsWithStructure = nil;
        
        //send note to schedule that a change has been saved
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


#pragma mark - contact picker

-(IBAction)contactButton:(id)sender{
    
    EQRContactPickerVC* contactPickerVC = [[EQRContactPickerVC alloc] initWithNibName:@"EQRContactPickerVC" bundle:nil];
    self.myContactVC = contactPickerVC;
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:self.myContactVC];
    [navController setNavigationBarHidden:YES];
    
    UIPopoverController* popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myContactPicker = popOver;
    
    //set the size
    [self.myContactPicker setPopoverContentSize:CGSizeMake(320, 550)];
    
    //get coordinates in proper view
    
    //present popOver
    [self.myContactPicker presentPopoverFromRect:self.nameTextField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES];
    
    //self as delegate
    self.myContactVC.delegate = self;
    
}


-(void)retrieveSelectedNameItem{
    
    EQRContactNameItem* nameItem = [self.myContactVC retrieveContactItem];
    
    [self.nameTextField setTitle:nameItem.first_and_last forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
    
    //update data (needs to be saved)
    self.privateRequestManager.request.contactNameItem = nameItem;
    self.privateRequestManager.request.contact_name = nameItem.first_and_last;
    self.privateRequestManager.request.contact_foreignKey = nameItem.key_id;
    
    //release as delegate
    self.myContactVC.delegate = nil;
    
    //dismiss popover
    [self.myContactPicker dismissPopoverAnimated:YES];
    
    //release content view controller
    self.myContactVC = nil;
}



#pragma mark - handle date view controller

-(IBAction)showDateVCntrllr:(id)sender{
    
    EQREditorDateVCntrllr* myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    
    UIPopoverController* popOverC = [[UIPopoverController alloc] initWithContentViewController:myDateViewController];
    self.theDatePopOver = popOverC;
    self.theDatePopOver.popoverContentSize = CGSizeMake(320.f, 570.f);

    
    [self.theDatePopOver presentPopoverFromRect:self.pickupDateField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //update dates labels
    myDateViewController.pickupDateField.date = self.pickUpDateDate;
    myDateViewController.returnDateField.date = self.returnDateDate;
    
    //update requestItem date properties
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(showExtendedDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //assign content VC as ivar
    self.myDateVC = myDateViewController;
}


-(IBAction)showExtendedDate:(id)sender{
    
    NSLog(@"showOrHide action fires with class: %@", [[self.theDatePopOver contentViewController] class]);
    
    
    //change to Extended view
    EQREditorExtendedDateVC* myDateViewController = [[EQREditorExtendedDateVC alloc] initWithNibName:@"EQREditorExtendedDateVC" bundle:nil];
    CGSize thisSize = CGSizeMake(600.f, 570.f);
    
    [self.theDatePopOver setPopoverContentSize:thisSize animated:YES];
    [self.theDatePopOver setContentViewController:myDateViewController animated:YES];
    
    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(returnToStandardDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //need to set the date and time
    myDateViewController.pickupDateField.date = self.pickUpDateDate;
    myDateViewController.pickupTimeField.date = self.pickUpDateDate;
    myDateViewController.returnDateField.date = self.returnDateDate;
    myDateViewController.returnTimeField.date = self.returnDateDate;
    
    
    //assign content VC as ivar (necessary, because VCs always need to be retained)
    self.myDateVC = myDateViewController;
}


-(void)returnToStandardDate:(id)sender{
    
    //change to regular day view
    EQREditorDateVCntrllr* myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    CGSize thisSize = CGSizeMake(320.f, 570.f);
    
    [self.theDatePopOver setPopoverContentSize:thisSize animated:YES];
    [self.theDatePopOver setContentViewController:myDateViewController animated:YES];
    
    [myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:)
                              forControlEvents:UIControlEventTouchUpInside];
    [myDateViewController.showOrHideExtendedButton addTarget:self action:@selector(showExtendedDate:) forControlEvents:UIControlEventTouchUpInside];
    
    //need to set the date
    myDateViewController.pickupDateField.date = self.pickUpDateDate;
    myDateViewController.returnDateField.date = self.returnDateDate;
    
    //assign content VC as ivar
    self.myDateVC = myDateViewController;
}


-(IBAction)dateSaveButton:(id)sender{
    
    //set dates in the view
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d, h:mm a";
    
    self.pickUpDateDate = [self.myDateVC retrievePickUpDate];
    self.returnDateDate = [self.myDateVC retrieveReturnDate];
    
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    self.privateRequestManager.request.request_date_begin = self.pickUpDateDate;
    self.privateRequestManager.request.request_date_end = self.returnDateDate;
    
    //remove popover
    [self.theDatePopOver dismissPopoverAnimated:YES];
    
}


#pragma mark - handle renter view controller

-(IBAction)showRenterVCntrllr:(id)sender{
    
    EQREditorRenterVCntrllr* myRenterVC = [[EQREditorRenterVCntrllr alloc] initWithNibName:@"EQREditorRenterVCntrllr" bundle:nil];
    self.myRenterViewController = myRenterVC;
    
    UIPopoverController* popOverC2 = [[UIPopoverController alloc] initWithContentViewController:self.myRenterViewController];
    self.theRenterPopOver= popOverC2;
    
    //set size
    [self.theRenterPopOver setPopoverContentSize:CGSizeMake(300.f, 500.f)];
    
    [self.theRenterPopOver presentPopoverFromRect:self.renterTypeField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //initial setup
    [self.myRenterViewController initialSetupWithRenterTypeString:self.privateRequestManager.request.renter_type];
    
    
    //set self as delegate
    self.myRenterViewController.delegate = self;
    
    
}


-(void)initiateRetrieveRenterItem{
    
//    NSLog(@"this is the chosen renter type: %@", [self.myRenterViewController retrieveRenterType]);
    
    //set new renter type value
    [self.renterTypeField setTitle:[self.myRenterViewController retrieveRenterType] forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    self.privateRequestManager.request.renter_type = [self.myRenterViewController retrieveRenterType];
    
    //remove popover
    [self.theRenterPopOver dismissPopoverAnimated:YES];
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
    self.theEquipSelectionPopOver = popOverMe;
    //must manually set the size, cannot be wider than 600px!!!!???? But seems to work ok at 800 anyway???
    self.theEquipSelectionPopOver.popoverContentSize = CGSizeMake(700, 600);
    
    [self.theEquipSelectionPopOver presentPopoverFromRect:self.addEquipItemButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated: YES];
    

    //need to reprogram the target of the save button
    [genericEquipVCntrllr.continueButton removeTarget:genericEquipVCntrllr action:NULL forControlEvents:UIControlEventAllEvents];
    [genericEquipVCntrllr.continueButton addTarget:self action:@selector(continueAddEquipItem:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)continueAddEquipItem:(id)sender{
    
    //replaces the uniqueItem key from "1" to an accurate value
    [self.privateRequestManager justConfirm];

    [self.theEquipSelectionPopOver dismissPopoverAnimated:YES];
    
    //dealloc the popover or it resumes to show selected items from a previous viewing.. ALSO need to to this in the popover delegate method!!
    //____!!!!!! this does nothing  !!!!!!______
//    self.theEquipSelectionPopOver = nil;
    
    //_________***  need to update self.arrayOfEquipUniqueItems
    //empty arrays first
    [self.arrayOfSchedule_Unique_Joins removeAllObjects];
    self.arrayOfSchedule_Unique_JoinsWithStructure = nil;
    
//    NSMutableArray* arrayToReturn = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayToReturnJoins = [NSMutableArray arrayWithCapacity:1];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", [self.myUserInfo objectForKey:@"key_ID"],  nil];
    NSArray* secondArray = [NSArray arrayWithObjects:firstArray, nil];
    
    //get Scheduletracking_equipUnique_joins
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php"
                parameters:secondArray class:@"EQRScheduleTracking_EquipmentUnique_Join"
                completion:^(NSMutableArray *muteArray) {
        
        [arrayToReturnJoins addObjectsFromArray:muteArray];
        
    }];
    
    [self.arrayOfSchedule_Unique_Joins addObjectsFromArray:arrayToReturnJoins];
    
    //add structure
    self.arrayOfSchedule_Unique_JoinsWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.arrayOfSchedule_Unique_Joins];
    
    //reload collection view
    [self.equipList reloadData];
    
    //____________***
}



#pragma mark - notification methods

-(void)addEquipUniqueToBeDeletedArray:(NSNotification*)note{
    
    [self.arrayOfToBeDeletedEquipIDs addObject:[note.userInfo objectForKey:@"key_id"]];
    
}

-(void)removeEquipUniqueToBeDeletedArray:(NSNotification*)note{
    
    NSString* stringToBeRemoved;
    
    for (NSString* thisString in self.arrayOfToBeDeletedEquipIDs){
        
        if ([thisString isEqualToString:[note.userInfo objectForKey:@"key_id"]]){
            
            stringToBeRemoved = thisString;
        }
    }

    [self.arrayOfToBeDeletedEquipIDs removeObject:stringToBeRemoved];
}






#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        
    return [[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:section] count];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return [self.arrayOfSchedule_Unique_JoinsWithStructure count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    EQREditorEquipListCell* cell = [self.equipList dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    BOOL toBeDeleted = NO;
    for (NSString* keyToDelete in self.arrayOfToBeDeletedEquipIDs){
        
        if ([keyToDelete isEqualToString:[[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] key_id]]){
            
            toBeDeleted = YES;
        }
    }
    
    [cell initialSetupWithJoinObject:[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] deleteFlag:toBeDeleted];
    
    return cell;
}


-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"SuppCell";
    
    EQREditorHeaderCell* cell = [self.equipList dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    [cell initialSetupWithTitle: [(EQREquipUniqueItem*)[[self.arrayOfSchedule_Unique_JoinsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] schedule_grouping]];
    
    return cell;
}


#pragma mark - collection view flow layout delegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //width is equal to the collectionView's width
    return CGSizeMake(self.equipList.frame.size.width, 35.f);
    
}

#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    //release delegate
    self.myContactVC.delegate = self;
    
    //release content view controller
    self.myContactVC = nil;
    
    //release popover
    self.myContactPicker = nil;
}


#pragma mark - change in orientation methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self.equipList reloadData];
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.privateRequestManager = nil;
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
