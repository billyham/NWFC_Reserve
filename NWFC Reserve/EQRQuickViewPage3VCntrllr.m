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
#import "EQRGlobals.h"
#import "EQREditorTopVCntrllr.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRCheckPrintPage.h"


@interface EQRQuickViewPage3VCntrllr ()

@property (strong, nonatomic) NSString* mykeyID;
@property (strong, nonatomic) NSMutableDictionary* userInfo;


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


-(void)initialSetupWithKeyID:(NSString*)keyID andUserInfoDic:(NSDictionary*)userInfo{
    
    self.mykeyID = keyID;
    
    if (!self.userInfo){
        
        self.userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    [self.userInfo removeAllObjects];
    
    self.userInfo  = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    
    
}


-(IBAction)duplicate:(id)sender{
    
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
    
    NSString* newKeyID = [webData queryForStringWithLink:@"EQRegisterScheduleRequest.php" parameters:topArray2];
    NSLog(@"this is the newKeyId: %@", newKeyID);
    
    //time of request
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:[NSDate date]];
    
    NSString* date_begin_string = [timeStampFormatter stringFromDate:currentRequestItem.request_date_begin];
    NSString* date_end_string = [timeStampFormatter stringFromDate:currentRequestItem.request_date_end];
    NSString* time_begin_string = [timeStampFormatter stringFromDate:currentRequestItem.request_time_begin];
    NSString* time_end_string = [timeStampFormatter stringFromDate:currentRequestItem.request_time_end];
    
    //set the properties of the newly registered schedule request
    NSArray* oneArray = [NSArray arrayWithObjects:@"key_id", newKeyID, nil];
    NSArray* twoArray = [NSArray arrayWithObjects:@"contact_foreignKey", currentRequestItem.contact_foreignKey, nil];
    NSArray* threeArray = [NSArray arrayWithObjects:@"classSection_foreignKey", currentRequestItem.classSection_foreignKey, nil];
    NSArray* fourArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", currentRequestItem.classTitle_foreignKey, nil];
    NSArray* fiveArray = [NSArray arrayWithObjects:@"contact_name", currentRequestItem.contact_name, nil];
    NSArray* sixArray = [NSArray arrayWithObjects:@"renter_type", currentRequestItem.renter_type, nil];
    NSArray* sevenArray = [NSArray arrayWithObjects:@"time_of_request", timeRequestString, nil];
    NSArray* eightArray = [NSArray arrayWithObjects:@"request_date_begin", date_begin_string, nil];
    NSArray* nineArray = [NSArray arrayWithObjects:@"request_date_end", date_end_string, nil];
    NSArray* tenArray = [NSArray arrayWithObjects:@"request_time_begin", time_begin_string, nil];
    NSArray* elevenArray = [NSArray arrayWithObjects:@"request_time_end", time_end_string, nil];
    
    NSArray* topMostArray = [NSArray arrayWithObjects:
                             oneArray,
                             twoArray,
                             threeArray,
                             fourArray,
                             fiveArray,
                             sixArray,
                             sevenArray,
                             eightArray,
                             nineArray,
                             tenArray,
                             elevenArray,
                             nil];
    
    NSString* returnString = [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:topMostArray];
    
    NSLog(@"this is the returnString: %@", returnString);
    


    //Get all of the equipment joins
    
    NSArray* aArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.mykeyID, nil];
    NSArray* zArray = [NSArray arrayWithObjects:aArray, nil];
    NSMutableArray* tempMuteArray3 = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetScheduleEquipJoins.php" parameters:zArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
        
        for (EQRScheduleTracking_EquipmentUnique_Join* join in muteArray){
            
            [tempMuteArray3 addObject:join];
        }
    }];
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in tempMuteArray3){
        
        NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", newKeyID, nil];
        NSArray* beeArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", join.equipUniqueItem_foreignKey, nil];
        NSArray* ceeArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", join.equipTitleItem_foreignKey, nil];
        NSArray* zeeArray = [NSArray arrayWithObjects:ayeArray, beeArray, ceeArray, nil];
        
        NSString* resultFromNestedJoins = [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:zeeArray];
        NSLog(@"resut from nested joins: %@", resultFromNestedJoins);
    }
    
    
    //replace the key_id in the userInfo
    [self.userInfo setValue:newKeyID forKey:@"key_ID"];
    
    //the date should change...
    //show request editor
    if (self.fromItinerary == YES){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentRequestEditorFromItinerary object:nil userInfo:self.userInfo];
        
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentRequestEditorFromSchedule object:nil userInfo:self.userInfo];
    }
}


-(IBAction)split:(id)sender{
    
    
}


-(IBAction)print:(id)sender{
    
    //get complete scheduleRequest item info
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", self.mykeyID, nil];
    NSArray* secondRequestArray = [NSArray arrayWithObjects:firstRequestArray, nil];
    __block EQRScheduleRequestItem* chosenItem;
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:secondRequestArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        if ([muteArray count] > 0){
            
            chosenItem = [muteArray objectAtIndex:0];
        } else {
            
            NSLog(@"no request found for key id: %@. Abort printing.", self.mykeyID);
            return;
        }
    }];
    
    //also gather contact info
    NSArray* alphaArray = [NSArray arrayWithObjects:@"key_id", chosenItem.contact_foreignKey, nil];
    NSArray* betaArray = [NSArray arrayWithObjects:alphaArray, nil];
    [webData queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:betaArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
       
        if ([muteArray count] > 0){
            
            chosenItem.contactNameItem = [muteArray objectAtIndex:0];
            
        }else {
            
            //error handling if no contact object is returned
            NSLog(@"QuickViewPage3VC > print  no contact returned with contact foreign key");
        }
    }];
    
    //also get notes (and other info)
    NSArray* deltaArray = [NSArray arrayWithObjects:firstRequestArray, nil];
    [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:deltaArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        if ([muteArray count] > 0){
            
            chosenItem.notes = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] notes];
            
        }else {
            
            //error handling if no contact object is returned
            NSLog(@"QuickViewPage3VC > print  getScheduleRequestQuickViewData failed");
        }
    }];
    
    //create printable page view controller
    EQRCheckPrintPage* pageForPrint = [[EQRCheckPrintPage alloc] initWithNibName:@"EQRCheckPrintPage" bundle:nil];
    
    //add the request item to the view controller
    [pageForPrint initialSetupWithScheduleRequestItem:chosenItem];
    
    //assign ivar variables
    pageForPrint.rentorNameAtt = chosenItem.contact_name;
    pageForPrint.rentorEmailAtt = chosenItem.contactNameItem.email;
    pageForPrint.rentorPhoneAtt = chosenItem.contactNameItem.phone;
    
    
    //show the view controller
    [self presentViewController:pageForPrint animated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
