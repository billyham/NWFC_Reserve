//
//  EQREquipSummaryVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 1/31/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREquipSummaryVCntrllr.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQRContactNameItem.h"
#import "EQREquipItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQREquipUniqueItem.h"


@interface EQREquipSummaryVCntrllr ()

@property (strong, nonatomic) IBOutlet UIButton* printAndConfirmButton;

@end

@implementation EQREquipSummaryVCntrllr

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
	
    //load the request to populate the ivars
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];

//    NSString* contactKeyID = requestManager.request.contact_foreignKey;
    EQRContactNameItem* contactItem = requestManager.request.contactNameItem;
    
    NSDateFormatter* pickUpFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pickUpFormatter setLocale:usLocale];
    [pickUpFormatter setDateStyle:NSDateFormatterLongStyle];
    [pickUpFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    
    //nsattributedstrings
    
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
    
    //________NAME_________
    NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* nameHead = [[NSAttributedString alloc] initWithString:@"Name\r" attributes:arrayAttA];

    //initiate the total attributed string
    self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithAttributedString:nameHead];
    
    //assign the name
    NSDictionary* arrayAtt = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* nameAtt = [[NSAttributedString alloc] initWithString:contactItem.first_and_last attributes:arrayAtt];
    [self.summaryTotalAtt appendAttributedString:nameAtt];
    
    
    //____EMAIL____
    //add to the attributed string
    NSDictionary* arrayAtt2 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* emailHead = [[NSAttributedString alloc] initWithString:@"\r\rContact Email:\r" attributes:arrayAtt2];
    
    //concatentate to the att string
    [self.summaryTotalAtt appendAttributedString:emailHead];
    
    NSDictionary* arrayAtt3 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* emailAtt = [[NSAttributedString alloc] initWithString:contactItem.email attributes:arrayAtt3];
    [self.summaryTotalAtt appendAttributedString:emailAtt];
    
    //____PHONE______
    NSDictionary* arrayAtt4 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* phoneHead = [[NSAttributedString alloc] initWithString:@"\r\rContact Phone:\r" attributes:arrayAtt4];
    [self.summaryTotalAtt appendAttributedString:phoneHead];
    
    NSDictionary* arrayAtt5 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* phoneAtt = [[NSAttributedString alloc] initWithString:contactItem.phone attributes:arrayAtt5];
    [self.summaryTotalAtt appendAttributedString:phoneAtt];
    
    //_______PICKUP DATE_____
    NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"\r\rPick Up Date:\r" attributes:arrayAtt6];
    [self.summaryTotalAtt appendAttributedString:pickupHead];
    
    NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestManager.request.request_date_begin]  attributes:arrayAtt7];
    [self.summaryTotalAtt appendAttributedString:pickupAtt];
    
    //______RETURN DATE________
    NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"\r\rReturn Date:\r" attributes:arrayAtt8];
    [self.summaryTotalAtt appendAttributedString:returnHead];
    
    NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:requestManager.request.request_date_end]  attributes:arrayAtt9];
    [self.summaryTotalAtt appendAttributedString:returnAtt];
    
    //________EQUIP LIST________
    
    NSDictionary* arrayAtt10 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* equipHead = [[NSAttributedString alloc] initWithString:@"\r\r\rEquipment Items:\r\r" attributes:arrayAtt10];
    [self.summaryTotalAtt appendAttributedString:equipHead];
    
    //cycle through array of equipItems and build a string
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //first, cycle through scheduleTracking_equip_joins
    for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in requestManager.request.arrayOfEquipmentJoins){
    
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
    
    
    self.summaryTextView.attributedText = self.summaryTotalAtt;
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
        
        [self justConfirm];
        
        //go back to first page in nav
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        //reset eveything back to 0 (which in turn sends an nsnotification)
        EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
        [requestManager dismissRequest];
    }
}


-(IBAction)confirm:(id)sender{
    
    [self justConfirm];
    
    //go back to first page in nav
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //reset eveything back to 0 (which in turn sends an nsnotification)
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager dismissRequest];
    
}


-(void)justConfirm{
    
    //send all this info to webData with GET
    //    key_id,
    //    contact_foreignKey,
    //    classSection_foreignKey,
    //    classTitle_foreignKey,
    //    request_date_begin,
    //    request_date_end,
    //    request_time_begin,
    //    request_time_end
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    EQRScheduleRequestItem* request = requestManager.request;
    
    NSLog(@"this is the contact_foreignKey: %@", [NSString stringWithFormat:@"%@", request.contact_foreignKey]);
    
    //must not include nil objects in array
    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
    if (!request.contact_foreignKey) request.contact_foreignKey = @"88888888";
    if (!request.classSection_foreignKey) request.classSection_foreignKey = @"88888888";
    if (!request.classTitle_foreignKey) request.classTitle_foreignKey = @"88888888";
    if (!request.request_date_begin) request.request_date_begin = [NSDate date];
    if (!request.request_date_end) request.request_date_end = [NSDate date];
    if (!request.contact_name) request.contact_name = @"88888888";
    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatForDate stringFromDate:request.request_date_begin];
    NSString* dateEndString = [dateFormatForDate stringFromDate:request.request_date_end];
    
    //format the time
    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
    [dateFormatForTime setLocale:usLocale];
    [dateFormatForTime setDateFormat:@"HH:mm"];
    NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:request.request_date_begin];
    NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:request.request_date_end];
    NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
    NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
    
    //time of request
    NSDate* timeRequest = [NSDate date];
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:timeRequest];
    
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", request.key_id,nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", request.contact_foreignKey, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", request.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", request.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", timeBeginString, nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", timeEndString, nil];
    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", request.contact_name, nil];
    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", request.renter_type, nil];
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
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSString* returnID = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
    NSLog(@"this is the returnID: %@", returnID);
    
    
    //___________************  Use this moment to allocate a uniqueItem object (key_id and/or dist ID) *****_______
    
    // replace the equipUniqueItem_foreignKey in the equipJoins in the requestManager's array
    
    // use the requestManager's array of all equipItems: requestManager.arrayOfEquipUniqueItems
    // compare against: requestManager.arrayOfEquipUniqueItemsByDateCollision
    // derive available key_ids or distinquishing ids
    
    
    
    //start by identifying uniqueIds and making an array for each with the all key_ids
    //subtract from each array the selected key_ids
    //sort the array by distinguishing ids and select the lowest one for the join
    
    NSMutableArray* tempArrayOfNestedArraysWithSelectedTitles = [NSMutableArray arrayWithCapacity:1];
    
    
    
    //compare this transaction's selections with the array of unqiue item collisions
    
    
    
    
    //input array of scheduleTracking_equipUniqueItem_joins
    for (EQRScheduleTracking_EquipmentUnique_Join* join in requestManager.request.arrayOfEquipmentJoins){
        
        NSArray* firstArrayForJoin = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", join.scheduleTracking_foreignKey, nil];
        NSArray* secondArrayForJoin = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", join.equipUniqueItem_foreignKey, nil];
        NSArray* thirdArrayForJoin = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", join.equipTitleItem_foreignKey, nil];
        NSArray* bigArrayForJoin = [NSArray arrayWithObjects:
                                    firstArrayForJoin,
                                    secondArrayForJoin,
                                    thirdArrayForJoin,
                                    nil];
        
        NSString* returnID2 = [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:bigArrayForJoin];
        NSLog(@"this is the schedule_equip_join return key_id: %@", returnID2);
    }
}


-(BOOL)justPrint{
    
    //_______PRINTING_________!
    
    UIPrintInteractionController* printIntCont = [UIPrintInteractionController sharedPrintController];
    UIViewPrintFormatter* viewPrintFormatter = [self.summaryTextView viewPrintFormatter];
    
    UIPrintInfo* printInfo = [UIPrintInfo printInfo] ;
    printInfo.jobName = @"NWFC Reserve App: confirmation";
    printInfo.outputType = UIPrintInfoOutputGrayscale;
    
    //assign formatter to int cntrllr
    printIntCont.printFormatter = viewPrintFormatter;
    //assign printinfo to int cntrllr
    printIntCont.printInfo = printInfo;
    
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
