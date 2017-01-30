//
//  EQRScheduleRowQuickViewVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 7/21/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRQuickViewPage1VCntrllr.h"
#import "EQRWebData.h"
#import "EQRScheduleRequestItem.h"
#import "EQRContactNameItem.h"
#import "EQRGlobals.h"

typedef void (^CompletionWithString)(NSString *name);

@interface EQRQuickViewPage1VCntrllr ()

@property (strong, nonatomic) NSDictionary* myUserData;
@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequestItem;
@property (strong, nonatomic) NSString* combinedDateAndTimeBegin;
@property (strong, nonatomic) NSString* combinedDateAndTimeEnd;

@property (strong, nonatomic) NSString* staff_confirmation_name;
@property (strong, nonatomic) NSString* staff_prep_name;
@property (strong, nonatomic) NSString* staff_checkout_name;
@property (strong, nonatomic) NSString* staff_checkin_name;
@property (strong, nonatomic) NSString* staff_shelf_name;
@property (strong, nonatomic) NSString* classCatalogTitle;

@end

@implementation EQRQuickViewPage1VCntrllr

#pragma mark - initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)initialSetupWithDic:(NSDictionary*)dictionary{
    
    //assign dictionary to ivar
    self.myUserData = [NSDictionary dictionaryWithDictionary:dictionary];
    
    //convert items in note's userInfo
    NSDate* pickupDateAsDate = [dictionary objectForKey:@"request_date_begin"];
    NSDate* returnDateAsDate = [dictionary objectForKey:@"request_date_end"];
    NSDate* pickupTimeAsDate = [dictionary objectForKey:@"request_time_begin"];
    NSDate* returnTimeAsDate = [dictionary objectForKey:@"request_time_end"];
    
    NSString* key_id = [dictionary objectForKey:@"key_ID"];
    
    //convert dates to strings
    self.combinedDateAndTimeBegin = [self convertDateToString:pickupDateAsDate withTime:pickupTimeAsDate];
    self.combinedDateAndTimeEnd = [self convertDateToString:returnDateAsDate withTime:returnTimeAsDate];

    
    //________acquire more information with a webData call usin the scheduleRequest Key_id
    //confirmation date and contact_name
    //prep date and name
    //check out date and name
    //check in date and name
    //shelf date and name
    //notes
    
    
    //____abort if no key_id exists
    if (key_id == nil) return;
    
    
    //assign info from userInfo to self.myScheduleRequestItem
    EQRScheduleRequestItem *newRequestItem = [[EQRScheduleRequestItem alloc] init];
    newRequestItem.key_id = key_id;
    if ([self.myUserData objectForKey:@"notes"]) newRequestItem.notes = [self.myUserData objectForKey:@"notes"];
    if ([self.myUserData objectForKey:@"classTitle_foreignKey"]) newRequestItem.classTitle_foreignKey = [self.myUserData objectForKey:@"classTitle_foreignKey"];
    if ([self.myUserData objectForKey:@"staff_confirmation_id"]) newRequestItem.staff_confirmation_id = [self.myUserData objectForKey:@"staff_confirmation_id"];
    if ([self.myUserData objectForKey:@"staff_confirmation_date"]) newRequestItem.staff_confirmation_date = [self.myUserData objectForKey:@"staff_confirmation_date"];
    if ([self.myUserData objectForKey:@"staff_prep_id"]) newRequestItem.staff_prep_id = [self.myUserData objectForKey:@"staff_prep_id"];
    if ([self.myUserData objectForKey:@"staff_prep_date"]) newRequestItem.staff_prep_date = [self.myUserData objectForKey:@"staff_prep_date"];
    if ([self.myUserData objectForKey:@"staff_checkout_id"]) newRequestItem.staff_checkout_id = [self.myUserData objectForKey:@"staff_checkout_id"];
    if ([self.myUserData objectForKey:@"staff_checkout_date"]) newRequestItem.staff_checkout_date = [self.myUserData objectForKey:@"staff_checkout_date"];
    if ([self.myUserData objectForKey:@"staff_checkin_id"]) newRequestItem.staff_checkin_id = [self.myUserData objectForKey:@"staff_checkin_id"];
    if ([self.myUserData objectForKey:@"staff_checkin_date"]) newRequestItem.staff_checkin_date = [self.myUserData objectForKey:@"staff_checkin_date"];
    if ([self.myUserData objectForKey:@"staff_shelf_id"]) newRequestItem.staff_shelf_id = [self.myUserData objectForKey:@"staff_shelf_id"];
    if ([self.myUserData objectForKey:@"staff_shelf_date"]) newRequestItem.staff_shelf_date = [self.myUserData objectForKey:@"staff_shelf_date"];
    
    self.myScheduleRequestItem = newRequestItem;

    
//    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", key_id, nil];
//    NSArray* secondArray = [NSArray arrayWithObject:firstArray];
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
//    [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:secondArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
//        
//        //should just be one object...
//        for (EQRScheduleRequestItem* object in muteArray){
//            
//            [tempMuteArray addObject:object];
//        }
//    }];
//    
//    if ([tempMuteArray count] > 0){
//        
//        self.myScheduleRequestItem = [tempMuteArray objectAtIndex:0];
//        
//    } else {
//        
//        //______error handling when no item is returned
//    }
    
    
    //also get class title if a titleKey exists
    if (self.myScheduleRequestItem.classTitle_foreignKey){
        
        if ((![self.myScheduleRequestItem.classTitle_foreignKey isEqualToString:@""]) && (![self.myScheduleRequestItem.classTitle_foreignKey isEqualToString:EQRErrorCode88888888])){
            
            EQRWebData* webData = [EQRWebData sharedInstance];
            NSArray* ayaArray = [NSArray arrayWithObjects:@"key_id", self.myScheduleRequestItem.classTitle_foreignKey, nil];
            NSArray* beeArray = [NSArray arrayWithObjects:ayaArray, nil];

            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                [webData queryForStringwithAsync:@"EQGetClassCatalogTitleWithKey.php" parameters:beeArray completion:^(NSString *catalogTitle) {
                    
                    self.classCatalogTitle = catalogTitle;
                    [self renderClassTitle];
                }];
            });
        }
    }
    //_______asynchronously???
}

-(void)renderClassTitle{
    if ((![self.classCatalogTitle isEqualToString:@""]) && (![self.classCatalogTitle isEqualToString:EQRErrorCode88888888])){
        
        self.classTitle.hidden = NO;
        
        self.classTitle.text = self.classCatalogTitle;
    }
}

-(NSString*)convertDateToString:(NSDate*)date withTime:(NSDate*)time{
    
    //error handling
    if (date == nil){
        
        return @"";
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    [dateFormatter setDateFormat:@"EEE, MMM d"];  // 'at' h:mm aaa
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setLocale:usLocale];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    //adjust the time by adding 9 hours... or 8 hours
    float secondsForOffset = 0;    //this is 9 hours = 32400, this is 8 hours = 28800;
    NSDate* newTime = [time dateByAddingTimeInterval:secondsForOffset];
    
    NSString* returnString = [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:date], [timeFormatter stringFromDate:newTime]];
    
    return  returnString;
}


-(NSString*)convertDateToString:(NSDate*)date{
    
    //error handling
    if (date == nil){
        
        return @"";
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    [dateFormatter setDateFormat:@"MMM-d-yyyy"];  // 'at' h:mm aaa
    
    return [dateFormatter stringFromDate:date];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    //assign values to quickView's ivars
    self.contactName.text = [self.myUserData objectForKey:@"contact_name"];
    self.pickUpDate.text = self.combinedDateAndTimeBegin;
    self.returnDate.text = self.combinedDateAndTimeEnd;
    
    //using additional data that this object retrieved...
    
    //set notes view text
    self.notesView.text = self.myScheduleRequestItem.notes;
    
    //retrieve the contact names from their ids
    self.staff_confirmation_name = @"";
    if ((![self.myScheduleRequestItem.staff_confirmation_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_confirmation_id != nil)) {
        
        [self retrieveNameWithID:self.myScheduleRequestItem.staff_confirmation_id completion:^(NSString *name) {
            self.staff_confirmation_name = name;
            [self renderConfirmation];
        }];
    }
    
    self.staff_prep_name = @"";
    if ((![self.myScheduleRequestItem.staff_prep_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_prep_id != nil)) {
        
        [self retrieveNameWithID:self.myScheduleRequestItem.staff_prep_id completion:^(NSString *name) {
            self.staff_prep_name = name;
            [self renderPrep];
        }];
    }
    
    self.staff_checkout_name = @"";
    if ((![self.myScheduleRequestItem.staff_checkout_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_checkout_id != nil)) {
        
        [self retrieveNameWithID:self.myScheduleRequestItem.staff_checkout_id completion:^(NSString *name) {
            self.staff_checkout_name = name;
            [self renderCheckout];
        }];
    }
    
    self.staff_checkin_name = @"";
    if ((![self.myScheduleRequestItem.staff_checkin_id isEqualToString:@""])&& (self.myScheduleRequestItem.staff_checkin_id != nil)) {
        
        [self retrieveNameWithID:self.myScheduleRequestItem.staff_checkin_id completion:^(NSString *name) {
            self.staff_checkin_name = name;
            [self renderCheckin];
        }];
    }
    
    self.staff_shelf_name = @"";
    if ((![self.myScheduleRequestItem.staff_shelf_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_shelf_date != nil)) {
        
        [self retrieveNameWithID:self.myScheduleRequestItem.staff_shelf_id completion:^(NSString *name) {
            self.staff_shelf_name = name;
            [self renderShelf];
        }];
    }
    
    //set class title if it exists
    [self renderClassTitle];
    
    // Render staff timestamps and names if they exist
    [self renderConfirmation];
    [self renderPrep];
    [self renderCheckout];
    [self renderCheckin];
    [self renderShelf];
    
    //put notes field on top
    [self.view bringSubviewToFront:self.notesView];
    
}

-(void)renderConfirmation{
    if (self.myScheduleRequestItem.staff_confirmation_date){
        self.confirmedLabel.alpha = 1.0;
        
        self.confirmedValue.text = [NSString stringWithFormat:@"%@ %@",
                                    [self convertDateToString:self.myScheduleRequestItem.staff_confirmation_date],
                                    self.staff_confirmation_name];
    }
}

-(void)renderPrep{
    if (self.myScheduleRequestItem.staff_prep_date){
        self.preppedLabel.alpha = 1.0;
        
        self.preppedValue.text = [NSString stringWithFormat:@"%@ %@",
                                  [self convertDateToString:self.myScheduleRequestItem.staff_prep_date],
                                  self.staff_prep_name];
    }
}

-(void)renderCheckout{
    if (self.myScheduleRequestItem.staff_checkout_date){
        self.pickedUpLabel.alpha = 1.0;
        
        self.pickedUpValue.text = [NSString stringWithFormat:@"%@ %@",
                                   [self convertDateToString:self.myScheduleRequestItem.staff_checkout_date],
                                   self.staff_checkout_name];
    }
}

-(void)renderCheckin{
    if (self.myScheduleRequestItem.staff_checkin_date){
        self.returnedLabel.alpha = 1.0;
        
        self.returnedValue.text = [NSString stringWithFormat:@"%@ %@",
                                   [self convertDateToString:self.myScheduleRequestItem.staff_checkin_date],
                                   self.staff_checkin_name];
    }
}

-(void)renderShelf{
    if (self.myScheduleRequestItem.staff_shelf_date){
        self.shelvedLabel.alpha = 1.0;
        
        self.shelvedValue.text = [NSString stringWithFormat:@"%@ %@",
                                  [self convertDateToString:self.myScheduleRequestItem.staff_shelf_date],
                                  self.staff_shelf_name];
    }
}


-(void)retrieveNameWithID:(NSString*)key_id completion:(CompletionWithString)cb{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", key_id, nil];
    NSArray* topArray = [NSArray arrayWithObject:firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        [webData queryForStringwithAsync:@"EQGetContactNameWithKey.php" parameters:topArray completion:^(EQRContactNameItem *contactNameItem) {
//            NSLog(@"name object: %@", contactNameItem);
            if (contactNameItem){
                // Derive first name and last initial
                NSString* firstName = contactNameItem.first_name;
                NSString* lastName = contactNameItem.last_name;
                
                cb([NSString stringWithFormat:@" – %@ %@", firstName, [lastName substringToIndex:1]]);
            } else {
                cb(@"");
            }
        }];
    });
}


//-(IBAction)editRequest:(id)sender{
//    
//    
//    
//    
//}


#pragma mark - uiscrollview delegate methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView{
    
    //make change to data model, save notes to db
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"notes", self.notesView.text, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"key_id", [self.myUserData objectForKey:@"key_ID"], nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
    [webData queryForStringWithLink:@"EQAlterNotesInScheduleRequest.php" parameters:topArray];
    
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
