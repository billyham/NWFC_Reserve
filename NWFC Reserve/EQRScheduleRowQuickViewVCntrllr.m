//
//  EQRScheduleRowQuickViewVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 7/21/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleRowQuickViewVCntrllr.h"
#import "EQRWebData.h"
#import "EQRScheduleRequestItem.h"
#import "EQRContactNameItem.h"

@interface EQRScheduleRowQuickViewVCntrllr ()

@property (strong, nonatomic) NSDictionary* myUserData;
@property (strong, nonatomic) EQRScheduleRequestItem* myScheduleRequestItem;
@property (strong, nonatomic) NSString* combinedDateAndTimeBegin;
@property (strong, nonatomic) NSString* combinedDateAndTimeEnd;

@property (strong, nonatomic) NSString* staff_confirmation_name;
@property (strong, nonatomic) NSString* staff_prep_name;
@property (strong, nonatomic) NSString* staff_checkout_name;
@property (strong, nonatomic) NSString* staff_checkin_name;
@property (strong, nonatomic) NSString* staff_shelf_name;

@end

@implementation EQRScheduleRowQuickViewVCntrllr

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
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObject:firstArray];
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:secondArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        //should just be one object...
        for (EQRScheduleRequestItem* object in muteArray){
            
            [tempMuteArray addObject:object];
        }
    }];
    
    if ([tempMuteArray count] > 0){
        
        self.myScheduleRequestItem = [tempMuteArray objectAtIndex:0];
    } else {
        
        //______error handling when no item is returned
    }
    
    
    //_______asynchronously???
    
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
    //retrieve the contact names from their ids
    if ((![self.myScheduleRequestItem.staff_confirmation_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_confirmation_id != nil)) {
        self.staff_confirmation_name = [self retrieveNameWithID:self.myScheduleRequestItem.staff_confirmation_id];
    } else {
        self.staff_confirmation_name = @"";
    }
    
    if ((![self.myScheduleRequestItem.staff_prep_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_prep_id != nil)) {
        self.staff_prep_name = [self retrieveNameWithID:self.myScheduleRequestItem.staff_prep_id];
    } else {
        self.staff_prep_name = @"";
    }
    
    if ((![self.myScheduleRequestItem.staff_checkout_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_checkout_id != nil)) {
        self.staff_checkout_name = [self retrieveNameWithID:self.myScheduleRequestItem.staff_checkout_id];
    } else {
        self.staff_checkout_name = @"";
    }
    
    if ((![self.myScheduleRequestItem.staff_checkin_id isEqualToString:@""])&& (self.myScheduleRequestItem.staff_checkin_id != nil)) {
        self.staff_checkin_name = [self retrieveNameWithID:self.myScheduleRequestItem.staff_checkin_id];
    } else {
        self.staff_checkin_name = @"";
    }
    
    if ((![self.myScheduleRequestItem.staff_shelf_id isEqualToString:@""]) && (self.myScheduleRequestItem.staff_shelf_date != nil)) {
        self.staff_shelf_name = [self retrieveNameWithID:self.myScheduleRequestItem.staff_shelf_id];
    } else {
        self.staff_shelf_name = @"";
    }
    
    
    //change alpha of label when the value exists, and add a value with a name
    if (self.myScheduleRequestItem.staff_confirmation_date){
        self.confirmedLabel.alpha = 1.0;
        
        self.confirmedValue.text = [NSString stringWithFormat:@"%@ %@",
                                    [self convertDateToString:self.myScheduleRequestItem.staff_confirmation_date],
                                    self.staff_confirmation_name];
    }
    
    if (self.myScheduleRequestItem.staff_prep_date){
        self.preppedLabel.alpha = 1.0;
        
        self.preppedValue.text = [NSString stringWithFormat:@"%@ %@",
                                  [self convertDateToString:self.myScheduleRequestItem.staff_prep_date],
                                  self.staff_prep_name];
    }
    
    if (self.myScheduleRequestItem.staff_checkout_date){
        self.pickedUpLabel.alpha = 1.0;
        
        self.pickedUpValue.text = [NSString stringWithFormat:@"%@ %@",
                                   [self convertDateToString:self.myScheduleRequestItem.staff_checkout_date],
                                   self.staff_checkout_name];
    }
    
    if (self.myScheduleRequestItem.staff_checkin_date){
        self.returnedLabel.alpha = 1.0;
        
        self.returnedValue.text = [NSString stringWithFormat:@"%@ %@",
                                   [self convertDateToString:self.myScheduleRequestItem.staff_checkin_date],
                                   self.staff_checkin_name];
    }
    
    if (self.myScheduleRequestItem.staff_shelf_date){
        self.shelvedLabel.alpha = 1.0;
        
        self.shelvedValue.text = [NSString stringWithFormat:@"%@ %@",
                                  [self convertDateToString:self.myScheduleRequestItem.staff_shelf_date],
                                  self.staff_shelf_name];
    }
    
}


-(NSString*)retrieveNameWithID:(NSString*)key_id{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", key_id, nil];
    NSArray* topArray = [NSArray arrayWithObject:firstArray];
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    [webData queryWithLink:@"EQGetContactNameWithKey.php" parameters:topArray class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
       
        //return the first item
        if ([muteArray count] > 0){
            
            [tempMuteArray addObject:[muteArray objectAtIndex:0]];
        }
    }];
    
    if ([tempMuteArray count] > 0){
        
        //derive first name and last initial
        NSString* firstName = [(EQRContactNameItem*)[tempMuteArray objectAtIndex:0] first_name];
        NSString* lastName = [(EQRContactNameItem*)[tempMuteArray objectAtIndex:0] last_name];
        
        return [NSString stringWithFormat:@" – %@ %@", firstName, [lastName substringToIndex:1]];
        
    } else {
        
        //error handling when no contact is returned
        return @"";
    }
}


//-(IBAction)editRequest:(id)sender{
//    
//    
//    
//    
//}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
