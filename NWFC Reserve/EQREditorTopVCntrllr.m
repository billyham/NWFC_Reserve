//
//  EQREditorTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorTopVCntrllr.h"
#import "EQREditorEquipListCell.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleRequestItem.h"
#import "EQREditorDateVCntrllr.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"

@interface EQREditorTopVCntrllr ()

@property (strong, nonatomic) EQRScheduleRequestItem* myRequestItem;

@property (strong, nonatomic) IBOutlet UITextField* nameTextField;
@property (strong, nonatomic) IBOutlet UITextField* renterTypeField;
@property (strong ,nonatomic) IBOutlet UIPickerView* renterTypePicker;
@property (strong, nonatomic) NSString* renterTypeString;
@property (strong, nonatomic) NSDate* pickUpDateDate;
@property (strong, nonatomic) NSDate* returnDateDate;
@property (strong, nonatomic) IBOutlet UITextField* pickupDateField;
@property (strong, nonatomic) IBOutlet UITextField* returnDateField;
@property (strong, nonatomic) IBOutlet UICollectionView* equipList;
@property (strong, nonatomic) EQREditorDateVCntrllr* myDateViewController;
@property (strong, nonatomic) UIPopoverController* theDatePopOver;

@property (strong, nonatomic) NSDictionary* myUserInfo;
@property (strong, nonatomic) NSArray* arrayOfSchedule_Unique_Joins;
@property (strong, nonatomic) NSArray* arrayOfEquipUniqueItems;

@end

@implementation EQREditorTopVCntrllr

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
    
    //set ivar flag
    self.saveButtonTappedFlag = NO;
    
    //register collection view cell
    [self.equipList registerClass:[EQREditorEquipListCell class] forCellWithReuseIdentifier:@"Cell"];

    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    //set title
    self.navigationItem.title = @"Editor Request";
    
    //get scheduleTrackingRequest info and...
    //get array of schedule_equipUnique_joins
    //user self.scheduleRequestKeyID
    
    
    

    
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d h:mm a";
    
    //set labels with provided dictionary
    //must do this AFTER loading the view
    self.nameTextField.text =[self.myUserInfo objectForKey:@"contact_name"];
    self.renterTypeString = [self.myUserInfo objectForKey:@"renter_type"];

    //set date labels
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    //set the renterpicker to the correct value
    if ([self.myRequestItem.renter_type isEqualToString:@"student"]){
        
        [self.renterTypePicker selectRow:0 inComponent:0 animated:NO];
        
    }else if([self.myRequestItem.renter_type isEqualToString:@"public"]){
        
        [self.renterTypePicker selectRow:1 inComponent:0 animated:NO];
        
    }else if([self.myRequestItem.renter_type isEqualToString:@"faculty"]){
        
        [self.renterTypePicker selectRow:2 inComponent:0 animated:NO];
        
    }else if([self.myRequestItem.renter_type isEqualToString:@"staff"]){
        
        [self.renterTypePicker selectRow:3 inComponent:0 animated:NO];
        
    }else if([self.myRequestItem.renter_type isEqualToString:@"youth"]){
        
        [self.renterTypePicker selectRow:4 inComponent:0 animated:NO];
    }
    
    
//    NSLog(@"this is the scheduleRequest key id: %@", [self.myUserInfo objectForKey:@"key_ID"]);
    
    //have the requestManager establish the list of available equipment
    NSDictionary* datesDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.pickUpDateDate, @"request_date_begin",
                              self.returnDateDate, @"request_date_end",
                              nil];
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //_______*******  THIS IS CRASHING BECAUSE THE DATE INFO IS NOT PRESENT_________**********
//    [requestManager allocateGearListWithDates:datesDic];
    

    
    
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.myUserInfo = userInfo;
    
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    dateFormatter.dateFormat = @"yyyy-MM-dd";
    // HH:mm:ss
    
    //set dates
    self.pickUpDateDate = [self.myUserInfo objectForKey:@"request_date_begin"];
    self.returnDateDate = [self.myUserInfo objectForKey:@"request_date_end"];
        
    //instantiate myRequestItem
    self.myRequestItem = [[EQRScheduleRequestItem alloc] init];
    
    //and populate its ivars
//    self.myRequestItem.key_id = [self.myUserInfo objectForKey:@"key_ID"];
    self.myRequestItem.renter_type = [self.myUserInfo objectForKey:@"renter_type"];
    self.myRequestItem.contact_name = [self.myUserInfo objectForKey:@"contact_name"];
    self.myRequestItem.request_date_begin = self.pickUpDateDate;
    self.myRequestItem.request_date_end = self.returnDateDate;
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* arrayWithKey = [NSArray arrayWithObjects:@"key_id",[userInfo objectForKey:@"key_ID"], nil];
    NSArray* topArrayWithKey = [NSArray arrayWithObject:arrayWithKey];
    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:topArrayWithKey class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        //____ERROR HANDLING WHEN NOTHING IS RETURNED_______
        if ([muteArray count] > 0){
            self.myRequestItem.key_id = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] key_id];
            self.myRequestItem.contact_foreignKey =  [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] contact_foreignKey];
            self.myRequestItem.classSection_foreignKey = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] classSection_foreignKey];
            self.myRequestItem.time_of_request = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] time_of_request];
        }
    }];
    
//    NSLog(@"this is the contact foreign key: %@", self.myRequestItem.contact_foreignKey);
    

    //_________**********  LOAD REQUEST EDITOR COLLECTION VIEW WITH EquipUniqueItem_Joins  *******_____________
    
    
    //populate...
    //arrayOfSchedule_Unique_Joins
    
    
    
}


-(void)saveAction{
    
    self.saveButtonTappedFlag = YES;
    
    //update SQL with new request information
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSLog(@"this is the classSection_foreignKey: %@", self.myRequestItem.classSection_foreignKey);
    
    //must not include nil objects in array
    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
    if (!self.myRequestItem.contact_foreignKey) self.myRequestItem.contact_foreignKey = @"88888888";
    if (!self.myRequestItem.classSection_foreignKey) self.myRequestItem.classSection_foreignKey = @"88888888";
    if ([self.myRequestItem.classSection_foreignKey isEqualToString:@""]) self.myRequestItem.classSection_foreignKey = @"88888888";
    if (!self.myRequestItem.classTitle_foreignKey) self.myRequestItem.classTitle_foreignKey = @"88888888";
    if (!self.myRequestItem.request_date_begin) self.myRequestItem.request_date_begin = [NSDate date];
    if (!self.myRequestItem.request_date_end) self.myRequestItem.request_date_end = [NSDate date];
    if (!self.myRequestItem.contact_name) self.myRequestItem.contact_name = @"88888888";
    if (!self.myRequestItem.time_of_request) self.myRequestItem.time_of_request = [NSDate date];

    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatForDate stringFromDate:self.myRequestItem.request_date_begin];
    NSString* dateEndString = [dateFormatForDate stringFromDate:self.myRequestItem.request_date_end];
    
    //format the time
    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
    [dateFormatForTime setLocale:usLocale];
    [dateFormatForTime setDateFormat:@"HH:mm"];
    NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:self.myRequestItem.request_date_begin];
    NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:self.myRequestItem.request_date_end];
    NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
    NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
    
    //time of request
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:self.myRequestItem.time_of_request];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myRequestItem.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", self.myRequestItem.contact_foreignKey, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", self.myRequestItem.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", self.myRequestItem.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", timeBeginString, nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", timeEndString, nil];
    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", self.myRequestItem.contact_name, nil];
    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", self.myRequestItem.renter_type, nil];
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
    

    //send note to schedule that a change has been saved
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - handle date view controller

-(IBAction)showDateVCntrllr:(id)sender{
    
    self.myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    
    UIPopoverController* popOverC = [[UIPopoverController alloc] initWithContentViewController:self.myDateViewController];
    self.theDatePopOver = popOverC;
    
    [self.theDatePopOver presentPopoverFromRect:self.pickupDateField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //update dates labels
    self.myDateViewController.pickupDateField.date = self.pickUpDateDate;
    self.myDateViewController.returnDateField.date = self.returnDateDate;
    
    //update requestItem date properties
    self.myRequestItem.request_date_begin = self.pickUpDateDate;
    self.myRequestItem.request_date_end = self.returnDateDate;
    
    [self.myDateViewController.saveButton addTarget:self action:@selector(dateSaveButton:) forControlEvents:UIControlEventAllTouchEvents];
}


-(IBAction)dateSaveButton:(id)sender{
    
    //set dates in the view
    NSDateFormatter* dateFormatterLookinNice = [[NSDateFormatter alloc] init];
    dateFormatterLookinNice.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatterLookinNice.dateFormat = @"EEE, MMM d h:mm a";
    
    self.pickUpDateDate = self.myDateViewController.pickupDateField.date;
    self.returnDateDate = self.myDateViewController.returnDateField.date;
    
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
    self.myRequestItem.request_date_begin = self.pickUpDateDate;
    self.myRequestItem.request_date_end = self.returnDateDate;

    
    
    //remove popover
    [self.theDatePopOver dismissPopoverAnimated:YES];
    
}


#pragma mark - picker view datasource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return 5;
}


#pragma mark - picker view delegate methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (row == 0){
        
        NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
        return [[NSAttributedString alloc] initWithString:@"student" attributes:arrayAttA];
        
    } else if(row == 1){
        
        NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
        return [[NSAttributedString alloc] initWithString:@"public" attributes:arrayAttA];
        
    }else if(row == 2){
        
        NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
        return [[NSAttributedString alloc] initWithString:@"faculty" attributes:arrayAttA];
        
    }else if (row == 3){
        
        NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
        return [[NSAttributedString alloc] initWithString:@"staff" attributes:arrayAttA];
        
    }else if (row == 4){
        
        NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
        return [[NSAttributedString alloc] initWithString:@"youth" attributes:arrayAttA];
        
    }else{
        
        NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
        return [[NSAttributedString alloc] initWithString:@"NA" attributes:arrayAttA];
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 25.f;  //30.f
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    
    return 200.f;  //210.f
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    switch (row) {
        case 0:
            self.myRequestItem.renter_type = @"student";
            break;
            
        case 1:
            self.myRequestItem.renter_type = @"public";
            break;
            
        case 2:
            self.myRequestItem.renter_type = @"faculty";
            break;
            
        case 3:
            self.myRequestItem.renter_type = @"staff";
            break;
            
        case 4:
            self.myRequestItem.renter_type = @"youth";
            break;
            
        default:
            self.myRequestItem.renter_type = @"";
            break;
    }
}



#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 1;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    
    EQREditorEquipListCell* cell = [self.equipList dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    return cell;
}



#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
