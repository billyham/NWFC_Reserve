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
#import "EQREditorDateVCntrllr.h"

@interface EQREditorTopVCntrllr ()

@property (strong, nonatomic) IBOutlet UITextField* nameTextField;
@property (strong, nonatomic) IBOutlet UITextField* renterTypeField;
@property (strong, nonatomic) NSDate* pickUpDateDate;
@property (strong, nonatomic) NSDate* returnDateDate;
@property (strong, nonatomic) IBOutlet UITextField* pickupDateField;
@property (strong, nonatomic) IBOutlet UITextField* returnDateField;
@property (strong, nonatomic) IBOutlet UICollectionView* equipList;
@property (strong, nonatomic) EQREditorDateVCntrllr* myDateViewController;

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
    
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    //set local ivars with provided dictionary
    //must do this AFTER loading the view
    self.nameTextField.text =[self.myUserInfo objectForKey:@"contact_name"];
    self.renterTypeField.text = [self.myUserInfo objectForKey:@"renter_type"];
    self.pickUpDateDate = [dateFormatter dateFromString:[self.myUserInfo objectForKey:@"request_date_begin"]];
    self.returnDateDate = [dateFormatter dateFromString:[self.myUserInfo objectForKey:@"request_date_end"]];
    
    NSLog(@"this is the scheduleRequest key id: %@", [self.myUserInfo objectForKey:@"key_ID"]);
    
    //have the requestManager establish the list of available equipment
    
    NSDictionary* datesDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.pickUpDateDate, @"request_date_begin",
                              self.returnDateDate, @"request_date_end",
                              nil];
    
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    [requestManager allocateGearListWithDates:datesDic];
    
    
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.myUserInfo = userInfo;
    

    
}


-(void)saveAction{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - handle date view controller

-(void)showDateVCntrllr{
    
    self.myDateViewController = [[EQREditorDateVCntrllr alloc] initWithNibName:@"EQREditorDateVCntrllr" bundle:nil];
    
    [self.navigationController presentViewController:self.myDateViewController animated:YES completion:^{
        
        self.myDateViewController.pickupDateField.date = self.pickUpDateDate;
        self.myDateViewController.returnDateField.date = self.returnDateDate;
        
    }];
    
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
