//
//  EQRQuickViewPage3VCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/11/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRQuickViewPage3VCntrllr.h"
#import "EQRWebData.h"
#import "EQRScheduleRequestItem.h"

@interface EQRQuickViewPage3VCntrllr ()

@property (strong, nonatomic) NSString* mykeyID;


@end

@implementation EQRQuickViewPage3VCntrllr

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
    // Do any additional setup after loading the view from its nib.
}


-(void)initialSetupWithKeyID:(NSString*)keyID{
    
    self.mykeyID = keyID;
    
    
}


-(IBAction)duplicate:(id)sender{
    
    
    //____show request editor and launch edit date popover?
     
    
    //webdata query
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.mykeyID, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        for (EQRScheduleRequestItem* item in muteArray){
            
            [tempMuteArray addObject:item];
        }
    }];
    
    if ([tempMuteArray count] < 1){
        
        NSLog(@"error, no items returned for schedule request key id: %@", self.mykeyID);
        return;
    }
    
    //a complete schedule reqeust object, the one to be copied
    EQRScheduleRequestItem* currentRequestItem = [tempMuteArray objectAtIndex:0];
    
    
    //get a new schedule request key_id, the proper way...
    NSString* myDeviceName = [[UIDevice currentDevice] name];
    
    NSArray* firstArray2  = [NSArray arrayWithObjects:@"myDeviceName", myDeviceName, nil];
    NSArray* topArray2 = [NSArray arrayWithObjects:firstArray2, nil];
    
    NSString* newKeyID = [webData queryForStringWithLink:@"EQRegisterScheduleRequest" parameters:topArray2];
    
    //time of request
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:[NSDate date]];
    
    //set the properties of the newly registered schedule request
    NSArray* oneArray = [NSArray arrayWithObjects:@"key_id", newKeyID, nil];
    NSArray* twoArray = [NSArray arrayWithObjects:@"contact_foreignKey", currentRequestItem.contact_foreignKey, nil];
    NSArray* threeArray = [NSArray arrayWithObjects:@"classSection_foreignKey", currentRequestItem.classSection_foreignKey, nil];
    NSArray* fourArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", currentRequestItem.classTitle_foreignKey, nil];
    NSArray* fiveArray = [NSArray arrayWithObjects:@"contact_name", currentRequestItem.contact_name, nil];
    NSArray* sixArray = [NSArray arrayWithObjects:@"renter_type", currentRequestItem.renter_type, nil];
    NSArray* sevenArray = [NSArray arrayWithObjects:@"time_of_request", timeRequestString, nil];
    
    NSArray* topMostArray = [NSArray arrayWithObjects:
                             oneArray,
                             twoArray,
                             threeArray,
                             fourArray,
                             fiveArray,
                             sixArray,
                             sevenArray,
                             nil];
    
    NSString* returnString = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:topMostArray];
    
    NSLog(@"this is the returnString: %@", returnString);
    
    //with key_id, contact_foreignKey, classSection_foreignKey, classTitle_foreignKey, request_date_begin, request_date_end, request_time_begin, request_time_end, contact_name, renter_type, time_of_request
    //EQSetNewScheduleRequest
    
    
    
    
    
    //loop with scheduleTracking_foreignKey, equipUniqueItem_foreignKey, equipTitleItem_foreignKey
    //EQSetNewScheduleEquipJoin
    
}


-(IBAction)split:(id)sender{
    
    
}


-(IBAction)print:(id)sender{
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
