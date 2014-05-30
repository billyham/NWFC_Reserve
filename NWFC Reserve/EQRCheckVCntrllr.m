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
#import "EQRGlobals.h"

@interface EQRCheckVCntrllr ()

@property (strong, nonatomic) IBOutlet UILabel* nameTextLabel;
@property (strong, nonatomic) NSDictionary* myUserInfo;

@property (strong, nonatomic) NSString* myProperty;

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
    
    //figure out the literal column name in the database to use
    if (!self.marked_for_returning){
        
        if (self.switch_num == 1){
            
            self.myProperty = @"prep_flag";
            
        }else {
            
            self.myProperty = @"checkout_flag";
        }
    }else{
        
        if (self.switch_num == 1){
            
            self.myProperty = @"checkin_flag";
            
        }else {
            
            self.myProperty = @"shelf_flag";
        }
    }
    
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
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //receive change in state from row items
    [nc addObserver:self selector:@selector(updateArrayOfJoins:) name:EQRUpdateCheckInOutArrayOfJoins object:nil];
    
    
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
    

    
    //make special note if any of the joins in the ivar array are not complete
    BOOL foundOutstandingItem = NO;
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in self.arrayOfEquipJoins){
        
        if ([join respondsToSelector:NSSelectorFromString(self.myProperty)]){
         
            SEL thisSelector = NSSelectorFromString(self.myProperty);
            
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString* thisLiteralProperty = [join performSelector:thisSelector];
#pragma clang diagnostic pop
            
            if (([thisLiteralProperty isEqualToString:@""]) || (thisLiteralProperty == nil)){
                
                foundOutstandingItem = YES;
                
            }
        }
        
    }
    
    
    NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.scheduleRequestKeyID, @"scheduleKey",
                             @"complete", @"comleteOrIncomplete",
                             [NSNumber numberWithBool:self.marked_for_returning], @"marked_for_returning",
                             [NSNumber numberWithInteger:self.switch_num], @"switch_num",
                             self.myProperty, @"propertyToUpdate",
                             [NSNumber numberWithBool:foundOutstandingItem], @"foundOutstandingItem",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRMarkItineraryAsCompleteOrNot object:nil userInfo:thisDic];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}


-(IBAction)markAsIncomplete:(id)sender{
    
    NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.scheduleRequestKeyID, @"scheduleKey",
                             @"incomplete", @"comleteOrIncomplete",
                             [NSNumber numberWithBool:self.marked_for_returning], @"marked_for_returning",
                             [NSNumber numberWithInteger:self.switch_num], @"switch_num",
                             self.myProperty, @"propertyToUpdate",
                             [NSNumber numberWithBool:0], @"foundOutstandingItem",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRMarkItineraryAsCompleteOrNot object:nil userInfo:thisDic];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#pragma mark - receive messages from row content

-(void)updateArrayOfJoins:(NSNotification*)note{
    
    NSString* joinKeyID = [[note userInfo] objectForKey:@"joinKeyID"];
    NSString* joinProperty = [[note userInfo] objectForKey:@"joinProperty"];
    NSString* verdict = [[note userInfo] objectForKey: @"markedAsYes"];
    
    for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in self.arrayOfEquipJoins){
        
        if ([joinItem.key_id isEqualToString:joinKeyID]){
            
            //gotta cutoff the "_flag" at the end or else is will capitalize the "F"
            NSUInteger thisLength = [joinProperty length];
            NSRange newRange = NSMakeRange(0, thisLength - 5);
            NSString* joinSubstring = [joinProperty substringWithRange:newRange];
            
            NSString* joinPropertyWithCap = [joinSubstring capitalizedString];
            NSString* joinPropertySetMethod = [NSString stringWithFormat:@"set%@_flag:", joinPropertyWithCap];
            SEL mySelector = NSSelectorFromString(joinPropertySetMethod);
            
            if ([joinItem respondsToSelector:mySelector]){
                
                [joinItem performSelector:mySelector withObject:verdict];
            }
        }
    }
}

#pragma clang diagnostic pop



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



#pragma mark - memory warning


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
