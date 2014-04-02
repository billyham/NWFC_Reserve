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

@interface EQREditorTopVCntrllr ()

@property (strong, nonatomic) EQRScheduleRequestItem* myRequestItem;

@property (strong, nonatomic) IBOutlet UITextField* nameTextField;
@property (strong, nonatomic) IBOutlet UITextField* renterTypeField;
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
    
    //set labesl with provided dictionary
    //must do this AFTER loading the view
    self.nameTextField.text =[self.myUserInfo objectForKey:@"contact_name"];
    self.renterTypeField.text = [self.myUserInfo objectForKey:@"renter_type"];

    //set date labels
    self.pickupDateField.text = [dateFormatterLookinNice stringFromDate:self.pickUpDateDate];
    self.returnDateField.text = [dateFormatterLookinNice stringFromDate:self.returnDateDate];
    
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
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    // HH:mm:ss
    
    //set dates
    self.pickUpDateDate = [dateFormatter dateFromString:[self.myUserInfo objectForKey:@"request_date_begin_string"]];
    self.returnDateDate = [dateFormatter dateFromString:[self.myUserInfo objectForKey:@"request_date_end_string"]];
    
    NSLog(@"I'M SCREAMING AT YOU!!! %@", [self.myUserInfo objectForKey:@"key_ID"]);
    
    //instantiate myRequestItem
    self.myRequestItem = [[EQRScheduleRequestItem alloc] init];
    
    //and populate its ivars
    self.myRequestItem.renter_type = [self.myUserInfo objectForKey:@"renter_type"];
    self.myRequestItem.contact_name = [self.myUserInfo objectForKey:@"contact_name"];
    self.myRequestItem.request_date_begin = self.pickUpDateDate;
    self.myRequestItem.request_date_end = self.returnDateDate;
    
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    NSArray* arrayWithKey = [NSArray arrayWithObject:[userInfo objectForKey:@"key_ID"]];
//    NSArray* topArrayWithKey = [NSArray arrayWithObject:arrayWithKey];
//    [webData queryWithLink:@"EQGetScheduleRequestComplete.php" parameters:topArrayWithKey class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
//
//        NSLog(@"this is the county count: %u", [muteArray count]);
//        
//        self.myRequestItem.contact_foreignKey =  [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] contact_foreignKey];
//        self.myRequestItem.classSection_foreignKey = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] classSection_foreignKey];
//        self.myRequestItem.time_of_request = [(EQRScheduleRequestItem*)[muteArray objectAtIndex:0] time_of_request];
//    }];
//    
//    NSLog(@"this is the contact foreign key: %@", self.myRequestItem.contact_foreignKey);
}


-(void)saveAction{
    
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
    

    
    
    //remove popover
    [self.theDatePopOver dismissPopoverAnimated:YES];
    
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
