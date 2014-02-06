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


@interface EQREquipSummaryVCntrllr ()

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
    
    
    
    //nsattributedstrings
    
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
    
    //________NAME_________
    NSDictionary* arrayAtt = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    self.rentorNameAtt = [[NSAttributedString alloc] initWithString:[contactItem.first_and_last substringFromIndex:2] attributes:arrayAtt];
    
    //initiate the total attributed string
    self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithAttributedString:self.rentorNameAtt];
    
    //____EMAIL____
    //add to the attributed string
    NSDictionary* arrayAtt2 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* emailHead = [[NSAttributedString alloc] initWithString:@"\r\rContact Email:\r" attributes:arrayAtt2];
    
    //concatentate to the att string
    [self.summaryTotalAtt appendAttributedString:emailHead];
    
    NSDictionary* arrayAtt3 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* emailAtt = [[NSAttributedString alloc] initWithString:[contactItem.email substringFromIndex:2] attributes:arrayAtt3];
    [self.summaryTotalAtt appendAttributedString:emailAtt];
    
    //____PHONE______
    NSDictionary* arrayAtt4 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* phoneHead = [[NSAttributedString alloc] initWithString:@"\r\rContact Phone:\r" attributes:arrayAtt4];
    [self.summaryTotalAtt appendAttributedString:phoneHead];
    
    NSDictionary* arrayAtt5 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* phoneAtt = [[NSAttributedString alloc] initWithString:[contactItem.phone substringFromIndex:2] attributes:arrayAtt5];
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
    
    NSDictionary* arrayAtt10 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* equipHead = [[NSAttributedString alloc] initWithString:@"\r\r\rEquipment Items:\r\r" attributes:arrayAtt10];
    [self.summaryTotalAtt appendAttributedString:equipHead];
    
    //cycle through array of equipItems and build a string
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //first, cycle through scheduleTracking_equip_joins
    for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in requestManager.request.arrayOfEquipmentJoins){
    
        NSArray* thisArray1 = [NSArray arrayWithObjects:@"key_id", [joinItem.equipTitleItem_foreignKey substringFromIndex:2], Nil];
        NSArray* thisArray2 = [NSArray arrayWithObject:thisArray1];
        [webData queryWithLink:@"EQGetEquipmentTitles.php" parameters:thisArray2 class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
            
            //add the text of the equip item names to the textField's attributed string
            for (EQREquipItem* equipItemObj in muteArray){
                
                NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
                NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r\r", [equipItemObj.shortname substringFromIndex:2]] attributes:arrayAtt11];
                
                [self.summaryTotalAtt appendAttributedString:thisHereAttString];
            }
            
        }];
        
    }
    
    
    self.summaryTextView.attributedText = self.summaryTotalAtt;
}


-(IBAction)confirmAndPrint:(id)sender{
    
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
    
    NSLog(@"this is the contact_foreignKey: %@", [NSString stringWithFormat:@"%ld", (long)[request.contact_foreignKey integerValue]]);
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", request.key_id,nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", [NSString stringWithFormat:@"%ld", (long)[request.contact_foreignKey integerValue]], nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", request.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", request.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", request.request_date_begin,nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", request.request_date_end,nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", @"",nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", @"",nil];
    NSArray* bigArray = [NSArray arrayWithObjects:
                         firstArray,
                         secondArray,
                         thirdArray,
                         fourthArray,
                         fifthArray,
                         sixthArray,
                         seventhArray,
                         eighthArray,
                         nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSString* returnID = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
    NSLog(@"this is the returnID: %@", returnID);
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
