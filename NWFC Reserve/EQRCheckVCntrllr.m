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

@interface EQRCheckVCntrllr ()

@property (strong, nonatomic) IBOutlet UILabel* nameTextLabel;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) IBOutlet UICollectionView* myEquipCollection;
@property (strong, nonatomic) NSArray* arrayOfEquipJoins;




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

    NSMutableArray* altMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* ayeArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", self.scheduleRequestKeyID, nil];
    NSArray* bigArray = [NSArray arrayWithObject:ayeArray];
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:bigArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
        
        for (EQRScheduleTracking_EquipmentUnique_Join* object in muteArray){
                        
            [altMuteArray addObject:object];
        }
    }];
    
    self.arrayOfEquipJoins = [NSArray arrayWithArray:altMuteArray];
    
    
    

    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    //register collection view cell
    [self.myEquipCollection registerClass:[EQRCheckRowCell class] forCellWithReuseIdentifier:@"Cell"];
    
    //cancel bar button
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
//    
//    [self.navigationItem setRightBarButtonItem:rightButton];



}


#pragma mark - navigation buttons

//-(void)cancelAction{
//    
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//        
//    }];
//    
//}


-(IBAction)markAsComplete:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}


-(IBAction)markAsIncomplete:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}


#pragma mark - datasource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return  [self.arrayOfEquipJoins count];
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
    
    [cell initialSetupWithEquipUnique:[self.arrayOfEquipJoins objectAtIndex:indexPath.row] marked:self.marked_for_returning switch_num:self.switch_num];
    
    return cell;
};



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
