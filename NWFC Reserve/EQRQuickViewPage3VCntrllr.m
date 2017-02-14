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
#import "EQRMiscJoin.h"
#import "EQRCheckPrintPage.h"

@interface EQRQuickViewPage3VCntrllr () 

@property (strong, nonatomic) NSString* mykeyID;
@property (strong, nonatomic) NSMutableDictionary* userInfo;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;

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
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"duplicate";
    queue.maxConcurrentOperationCount = 5;
    
    
    __block EQRScheduleRequestItem *currentRequestItem;
    NSBlockOperation *getScheduleRequestInComplete = [NSBlockOperation blockOperationWithBlock:^{
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.mykeyID, nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleRequestInComplete.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            if ([muteArray count] < 1){
                NSLog(@"EQRQuickViewPage3VC > duplicate, failed to retrieve request item: %@", self.mykeyID);
                return;
            }
            currentRequestItem = [muteArray objectAtIndex:0];
        }];
    }];
    
    
    NSBlockOperation *getScheduleRequestNotes = [NSBlockOperation blockOperationWithBlock:^{
        NSArray* alphaArray = @[@"key_id", self.mykeyID];
        NSArray* omegaArray = @[alphaArray];
        __block NSMutableString* notesReturned = [NSMutableString stringWithString:EQRErrorCode88888888];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleRequestNotes.php" parameters:omegaArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray2) {
            
            if ([muteArray2 count] > 0){
                [notesReturned setString:[(EQRScheduleRequestItem*)[muteArray2 objectAtIndex:0] notes]];
            }
        }];
        
        currentRequestItem.notes = notesReturned;
        
        // Need to save note to userInfo dic
        [self.userInfo setObject:notesReturned forKey:@"notes"];
    }];
    [getScheduleRequestNotes addDependency:getScheduleRequestInComplete];
    
    
    __block NSString *newKeyID;
    NSBlockOperation *registerScheduleRequest = [NSBlockOperation blockOperationWithBlock:^{
       // Get a new schedule request key_id
       NSString* myDeviceName = [[UIDevice currentDevice] name];
       NSArray* firstArray2  = [NSArray arrayWithObjects:@"myDeviceName", myDeviceName, nil];
       NSArray* topArray2 = [NSArray arrayWithObjects:firstArray2, nil];
        
       EQRWebData* webData = [EQRWebData sharedInstance];
       newKeyID = [webData queryForStringWithLink:@"EQRegisterScheduleRequest.php" parameters:topArray2];
    }];
    [registerScheduleRequest addDependency:getScheduleRequestNotes];
    
    
    NSBlockOperation *setNewScheduleRequest = [NSBlockOperation blockOperationWithBlock:^{
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
       
       //_____!!!  need to add notes  !!!_____
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
       NSArray* twelveArray = [NSArray arrayWithObjects:@"notes", currentRequestItem.notes, nil];
       
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
                                twelveArray,
                                nil];
        EQRWebData *webData = [EQRWebData sharedInstance];
       [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:topMostArray];
    }];
    [setNewScheduleRequest addDependency:registerScheduleRequest];
    
    
    __block NSMutableArray* equipJoins = [NSMutableArray arrayWithCapacity:1];
    NSBlockOperation *getScheduleEquipJoins = [NSBlockOperation blockOperationWithBlock:^{
       // Get all of the equipment joins
       NSArray* aArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.mykeyID, nil];
       NSArray* zArray = [NSArray arrayWithObjects:aArray, nil];
       
        EQRWebData *webData = [EQRWebData sharedInstance];
       [webData queryWithLink:@"EQGetScheduleEquipJoins.php" parameters:zArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
           
           for (EQRScheduleTracking_EquipmentUnique_Join* join in muteArray){
               [equipJoins addObject:join];
           }
       }];
    }];
    [getScheduleEquipJoins addDependency:setNewScheduleRequest];

    
    // Observe the nested NSOperationQueue, it holds the current thread until it completes
    NSBlockOperation *setNewScheduleEquipJoin = [NSBlockOperation blockOperationWithBlock:^{
        NSOperationQueue *equipJoinsQueue = [[NSOperationQueue alloc] init];
        equipJoinsQueue.name = @"equipJoinsQueue";
        equipJoinsQueue.maxConcurrentOperationCount = 5;
        
        NSMutableArray *arrayOfEquipJoinsCalls = [NSMutableArray arrayWithCapacity:1];
       for (EQRScheduleTracking_EquipmentUnique_Join* join in equipJoins){
           [arrayOfEquipJoinsCalls addObject:[NSBlockOperation blockOperationWithBlock:^{
               NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", newKeyID, nil];
               NSArray* beeArray = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", join.equipUniqueItem_foreignKey, nil];
               NSArray* ceeArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", join.equipTitleItem_foreignKey, nil];
               NSArray* zeeArray = [NSArray arrayWithObjects:ayeArray, beeArray, ceeArray, nil];
               
               EQRWebData *webData = [EQRWebData sharedInstance];
               [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:zeeArray];
           }]];
       }
        [equipJoinsQueue addOperations:arrayOfEquipJoinsCalls waitUntilFinished:YES];
    }];
    [setNewScheduleEquipJoin addDependency:getScheduleEquipJoins];
    
    
    __block NSMutableArray *miscJoins = [NSMutableArray arrayWithCapacity:1];
    NSBlockOperation *getMiscJoinsWithScheduleTrackingKey = [NSBlockOperation blockOperationWithBlock:^{
        // Get all the Misc Joins
        NSArray* aArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.mykeyID, nil];
        NSArray* zArray = [NSArray arrayWithObjects:aArray, nil];
        
        EQRWebData *webData = [EQRWebData sharedInstance];
       [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:zArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray) {
           
           for (EQRMiscJoin* join in muteArray){
               [miscJoins addObject:join];
           }
       }];
    }];
    [getMiscJoinsWithScheduleTrackingKey addDependency:setNewScheduleRequest];
    
    
    // Observe the nested NSOperationQueue, it holds the current thread until it completes
    NSBlockOperation *setNewMiscJoin = [NSBlockOperation blockOperationWithBlock:^{
        NSOperationQueue *miscJoinsQueue = [[NSOperationQueue alloc] init];
        miscJoinsQueue.name = @"miscJoinsQueue";
        miscJoinsQueue.maxConcurrentOperationCount = 5;
        
        NSMutableArray *arrayOfMiscJoinCalls = [NSMutableArray arrayWithCapacity:1];
        for (EQRMiscJoin* join in miscJoins){
            [arrayOfMiscJoinCalls addObject:[NSBlockOperation blockOperationWithBlock:^{
                NSArray* ayeArray = @[@"scheduleTracking_foreignKey", newKeyID];
                NSArray* beeArray = @[@"name", join.name];
                NSArray* zeeArray = @[ayeArray, beeArray];
                
                EQRWebData *webData = [EQRWebData sharedInstance];
                [webData queryForStringWithLink:@"EQSetNewMiscJoin.php" parameters:zeeArray];
            }]];
        }
        [miscJoinsQueue addOperations:arrayOfMiscJoinCalls waitUntilFinished:YES];
    }];
    [setNewMiscJoin addDependency:getMiscJoinsWithScheduleTrackingKey];
    
    
    NSBlockOperation *showRequestEditor = [NSBlockOperation blockOperationWithBlock:^{
        // Replace the key_id in the userInfo
        [self.userInfo setValue:newKeyID forKey:@"key_ID"];
        
        // Show the request editor to have the user enter new dates and times
        if (self.fromItinerary == YES){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentRequestEditorFromItinerary object:nil userInfo:self.userInfo];
            
        }else{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentRequestEditorFromSchedule object:nil userInfo:self.userInfo];
        }
        
    }];
    [showRequestEditor addDependency:setNewScheduleEquipJoin];
    [showRequestEditor addDependency:setNewMiscJoin];
    
       
    [queue addOperation:getScheduleRequestInComplete];
    [queue addOperation:getScheduleRequestNotes];
    [queue addOperation:registerScheduleRequest];
    [queue addOperation:setNewScheduleRequest];
    [queue addOperation:getScheduleEquipJoins];
    [queue addOperation:setNewScheduleEquipJoin];
    [queue addOperation:getMiscJoinsWithScheduleTrackingKey];
    [queue addOperation:setNewMiscJoin];
    [queue addOperation:showRequestEditor];
}


-(IBAction)split:(id)sender{
    
    
}


-(IBAction)print:(id)sender{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"print";
    queue.maxConcurrentOperationCount = 5;
    
    __block EQRScheduleRequestItem *chosenItem;
    NSBlockOperation *getScheduleRequestInComplete = [NSBlockOperation blockOperationWithBlock:^{
        EQRWebData* webData = [EQRWebData sharedInstance];
        NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", self.mykeyID, nil];
        NSArray* secondRequestArray = [NSArray arrayWithObjects:firstRequestArray, nil];
        
        [webData queryWithLink:@"EQGetScheduleRequestInComplete.php" parameters:secondRequestArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            if ([muteArray count] < 1) {
                NSLog(@"EQRQuickViewPage3 > print, fails to get request inComplete");
                return;
            }
            chosenItem = [muteArray objectAtIndex:0];
        }];
    }];
    
    
    NSBlockOperation *getContactCompleteWithKey = [NSBlockOperation blockOperationWithBlock:^{
        //also gather contact info
        NSArray* alphaArray = [NSArray arrayWithObjects:@"key_id", chosenItem.contact_foreignKey, nil];
        NSArray* betaArray = [NSArray arrayWithObjects:alphaArray, nil];
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:betaArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            if ([muteArray count] < 1){
                NSLog(@"QuickViewPage3VC > print  no contact returned with contact foreign key");
                return;
            }
            chosenItem.contactNameItem = [muteArray objectAtIndex:0];
        }];
    }];
    [getContactCompleteWithKey addDependency:getScheduleRequestInComplete];
    
    
    NSBlockOperation *getScheduleRequestQuickViewData = [NSBlockOperation blockOperationWithBlock:^{
        //also get notes (and other info)
        NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", self.mykeyID, nil];
        NSArray* deltaArray = [NSArray arrayWithObjects:firstRequestArray, nil];
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:deltaArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            if ([muteArray count] < 1){
                NSLog(@"QuickViewPage3VC > print  getScheduleRequestQuickViewData failed");
                return;
            }
            chosenItem.notes = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] notes];
        }];
    }];
    [getScheduleRequestQuickViewData addDependency:getScheduleRequestInComplete];
    
 
    NSBlockOperation *renderPageForPrint = [NSBlockOperation blockOperationWithBlock:^{
        //create printable page view controller
        dispatch_async(dispatch_get_main_queue(), ^{
            EQRCheckPrintPage* pageForPrint = [[EQRCheckPrintPage alloc] initWithNibName:@"EQRCheckPrintPage" bundle:nil];
            
            //add the request item to the view controller
            [pageForPrint initialSetupWithScheduleRequestItem:chosenItem forPDF:NO];
            
            //assign ivar variables
            pageForPrint.rentorNameAtt = chosenItem.contact_name;
            pageForPrint.rentorEmailAtt = chosenItem.contactNameItem.email;
            pageForPrint.rentorPhoneAtt = chosenItem.contactNameItem.phone;
            
            //show the view controller
            [self presentViewController:pageForPrint animated:YES completion:^{
            }];
        });
        
    }];
    [renderPageForPrint addDependency:getContactCompleteWithKey];
    [renderPageForPrint addDependency:getScheduleRequestQuickViewData];
    

    [queue addOperation:getScheduleRequestInComplete];
    [queue addOperation:getContactCompleteWithKey];
    [queue addOperation:getScheduleRequestQuickViewData];
    [queue addOperation:renderPageForPrint];
}

-(IBAction)pdf:(id)sender{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"pdf";
    queue.maxConcurrentOperationCount = 3;
    
    
    __block EQRScheduleRequestItem *chosenItem;
    NSBlockOperation *getScheduleRequestInComplete = [NSBlockOperation blockOperationWithBlock:^{
        // Get complete scheduleRequest item info
        NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", self.mykeyID, nil];
        NSArray* secondRequestArray = [NSArray arrayWithObjects:firstRequestArray, nil];
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleRequestInComplete.php" parameters:secondRequestArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            if ([muteArray count] < 1){
                NSLog(@"EQRQuickViewPage3VC > pdf, failed to retrieve request item");
                return;
            }
            chosenItem = [muteArray objectAtIndex:0];
        }];
    }];
    
    
    NSBlockOperation *getContactCompleteWitKey = [NSBlockOperation blockOperationWithBlock:^{
        // Get contact info
        NSArray* betaArray = @[ @[@"key_id", chosenItem.contact_foreignKey] ];
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetContactCompleteWithKey.php" parameters:betaArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            if ([muteArray count] < 1){
                NSLog(@"QuickViewPage3VC > print  no contact returned with contact foreign key");
                return;
            }
            chosenItem.contactNameItem = [muteArray objectAtIndex:0];
        }];
    }];
    [getContactCompleteWitKey addDependency:getScheduleRequestInComplete];
    
    
    NSBlockOperation *getScheduleRequestQuickViewData = [NSBlockOperation blockOperationWithBlock:^{
        // Get notes (and other info)
        NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", self.mykeyID, nil];
        NSArray* deltaArray = [NSArray arrayWithObjects:firstRequestArray, nil];
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:deltaArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            if ([muteArray count] < 1){
                NSLog(@"QuickViewPage3VC > print  getScheduleRequestQuickViewData failed");
                return;
            }
            chosenItem.notes = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] notes];
        }];
    }];
    [getScheduleRequestQuickViewData addDependency:getScheduleRequestInComplete];
    
    
    NSBlockOperation *renderPDF = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create printable page view controller
            EQRCheckPrintPage* pageForPrint = [[EQRCheckPrintPage alloc] initWithNibName:@"EQRCheckPrintPage" bundle:nil];
            
            //add the request item to the view controller
            //___ Specify for PDF only ___
            [pageForPrint initialSetupWithScheduleRequestItem:chosenItem forPDF:YES];
            
            //assign ivar variables
            pageForPrint.rentorNameAtt = chosenItem.contact_name;
            pageForPrint.rentorEmailAtt = chosenItem.contactNameItem.email;
            pageForPrint.rentorPhoneAtt = chosenItem.contactNameItem.phone;
            
            //show the view controller
            [self presentViewController:pageForPrint animated:YES completion:^{
            }];
        });
    }];
    [renderPDF addDependency:getContactCompleteWitKey];
    [renderPDF addDependency:getScheduleRequestQuickViewData];

    
    [queue addOperation:getScheduleRequestInComplete];
    [queue addOperation:getContactCompleteWitKey];
    [queue addOperation:getScheduleRequestQuickViewData];
    [queue addOperation:renderPDF];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
