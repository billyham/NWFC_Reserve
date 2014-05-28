//
//  EQRCheckVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckVCntrllr.h"
#import "EQRCheckRowCell.h"
#import "EQRWebData.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQREquipUniqueItem.h"

@interface EQRCheckVCntrllr ()

@property (strong, nonatomic) IBOutlet UILabel* nameTextLabel;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) IBOutlet UICollectionView* myEquipCollection;
@property (strong, nonatomic) NSArray* arrayOfEquipJoins;
@property (strong, nonatomic) NSArray* arrayOfEquipUnique;  //????




@end

@implementation EQRCheckVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.scheduleRequestKeyID = [userInfo objectForKey:@"scheduleKey"];
    self.marked_for_returning = [[userInfo objectForKey:@"marked_for_returning"] boolValue];
    self.switch_num = [[userInfo objectForKey:@"switch_num"] integerValue];
    
    //populate arrays using schedule key
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //______******* SHOULD SIMPLIFY WITH SINGLE CALL TO SQL WITH INNER JOIN... BUT MAKE SURE EQUIP UNIQUES THAT
    //______******* ARE RETURNED ARE ONE-FOR-ONE WITH THE NUMBER OF JOINS (TROUBLE IF TWO JOINS SHARE THE SAME EQUIPUNIQUE

    NSMutableArray* altMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.scheduleRequestKeyID, nil];
    NSArray* bigArray = [NSArray arrayWithObject:ayeArray];
    [webData queryWithLink:@"EQGetUniqueItemKeysForCheckWithScheduleTrackingKey.php" parameters:bigArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
       
        NSLog(@" count of array for smurfs: %u", [muteArray count]);
        
        for (id object in muteArray){
            
            [altMuteArray addObject:object];
        }
    }];
    
    self.arrayOfEquipUnique = [NSArray arrayWithArray:altMuteArray];
    
    NSLog(@" count of self.arrayOfEquipUnique: %u", [self.arrayOfEquipUnique count]);

    
    
    
    //_____********   ALT USING TWO METHODS TO GET BOTH EQUIP UNIQUES AND SCHEDULE_EQUIP_JOINS
//    //get scheduleEquipJoins
//    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", scheduleKey, nil];
//    NSArray* topArray = [NSArray arrayWithObject:firstArray];
//    
//    NSMutableArray* newMute = [NSMutableArray arrayWithCapacity:1];
//    
//    [webData queryWithLink:@"EQGetScheduleEquipJoins.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
//        
//        for (id object in muteArray){
//            
//            [newMute addObject:object];
//        }
//    }];
//
//    self.arrayOfEquipJoins = [NSArray arrayWithArray:newMute];
//
//    
//    //get equipUniques
//    NSMutableArray* muteUniques = [NSMutableArray arrayWithCapacity:1];
//    
//    for (EQRScheduleTracking_EquipmentUnique_Join* join in self.arrayOfEquipJoins){
//        
//        NSArray* firstFirstArray = [NSArray arrayWithObjects:@"key_id", join.equipUniqueItem_foreignKey, nil];
//        NSArray* firstTopArray = [NSArray arrayWithObjects:firstFirstArray, nil];
//        
//        [webData queryWithLink:@"EQGetEquipmentUnique.php" parameters:firstTopArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
//            
//            for (id object in muteArray){
//             
//                [muteUniques addObject:object];
//            }
//        }];
//    }
//    
//    self.arrayOfEquipUnique = [NSArray arrayWithArray:muteUniques];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    //register collection view cell
    [self.myEquipCollection registerClass:[EQRCheckRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    //cancel bar button
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    [self.navigationItem setRightBarButtonItem:rightButton];



}


#pragma mark - navigation buttons

-(void)cancelAction{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


#pragma mark - datasource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return  [self.arrayOfEquipUnique count];
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* CellIdentifier = @"Cell";
    
    EQRCheckRowCell* cell = [self.myEquipCollection dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //remove subviews
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    //and reset the cell's background color...
    cell.backgroundColor = [UIColor whiteColor];
    
    [cell initialSetupWithEquipUnique:[self.arrayOfEquipUnique objectAtIndex:indexPath.row] marked:self.marked_for_returning switch_num:self.switch_num];
    
    return cell;
};



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
