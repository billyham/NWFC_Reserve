//
//  EQRScheduleRowCell.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleRowCell.h"
#import "EQRScheduleNestedDayLayout.h"
#import "EQRGlobals.h"
#import "EQRScheduleNestedDayCell.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"


@interface EQRScheduleRowCell()

@property (nonatomic, strong) UICollectionView* myUniqueItemCollectionView;

@property (strong, nonatomic) NSMutableArray* temporaryArrayOfEquipUniqueJoins;


//needs to know it's equipUniqueItem's key_id
//and it's year and month???



@end

@implementation EQRScheduleRowCell


-(void)initialSetupWithTitle:(NSString*) titleName equipKey:(NSString*)uniqueKeyID{
    
    //set ivar
    self.uniqueItem_keyID = uniqueKeyID;
    
    //set background
    self.backgroundColor = [UIColor whiteColor];
    
    //_______does nothing with the titleName_______
//    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 5, 295, 45)];
//    self.titleLabel = thisLabel;
//    
//    self.titleLabel.text = titleName;
//    self.titleLabel.backgroundColor = [UIColor clearColor];
//    
//    [self.contentView addSubview:self.titleLabel];
    

    //create a uicollectionview object programatically
    EQRScheduleNestedDayLayout* thisNestedDayLayout = [[EQRScheduleNestedDayLayout alloc] init];
    
    //set subclass property
    thisNestedDayLayout.uniqueItem_keyID = self.uniqueItem_keyID;
    
    
    CGRect thisRect = CGRectMake(200, 0, 824, 30);
    UICollectionView* thisCollectionView = [[UICollectionView alloc] initWithFrame:thisRect collectionViewLayout:thisNestedDayLayout];
    self.myUniqueItemCollectionView = thisCollectionView;
    
    //register collection view cell
    [self.myUniqueItemCollectionView registerClass:[EQRScheduleNestedDayCell class] forCellWithReuseIdentifier:@"ThisCell"];
    
    
    [self.myUniqueItemCollectionView setDataSource:self];
    [self.myUniqueItemCollectionView setDelegate:self];
    //
    [self.contentView addSubview:self.myUniqueItemCollectionView];
    
    //______*******  ADD CONSTRAINTS TO THE SUB COLLECTION VIEW  ********__________
    
    
    
    self.myUniqueItemCollectionView.backgroundColor = [UIColor clearColor];
    
    //__*******  register its rect in an array that the flow layout can see???   *****____
    
    
}

#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //put schedule_unique_joins here to count
    NSMutableArray* temporaryMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins){
        
        if ([join.equipUniqueItem_foreignKey isEqualToString:self.uniqueItem_keyID]){
            
            [temporaryMuteArray addObject:join];
        }
    }
    
    //assigin to locao ivar
    if (!self.temporaryArrayOfEquipUniqueJoins){
        
        self.temporaryArrayOfEquipUniqueJoins  = [NSMutableArray arrayWithCapacity:1];
    }
    [self.temporaryArrayOfEquipUniqueJoins removeAllObjects];
    [self.temporaryArrayOfEquipUniqueJoins addObjectsFromArray:temporaryMuteArray];
    
    if ([temporaryMuteArray count] > 0){
        
        return [temporaryMuteArray count];
        
    }else{
        
        return 0;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString* CellIdentifier = @"ThisCell";
    EQRScheduleNestedDayCell* cell = [self.myUniqueItemCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    for (UIView* view in cell.contentView.subviews){

        [view removeFromSuperview];
    }

    //get the name from the locally saved array
    NSString* contact_name = [(EQRScheduleTracking_EquipmentUnique_Join*)[self.temporaryArrayOfEquipUniqueJoins objectAtIndex:indexPath.row] contact_name];
    
    [cell initialSetupWithTitle:contact_name];
    
    
    //restrict label to the cell
    cell.contentView.clipsToBounds = YES;
    
    //cell color
    cell.contentView.backgroundColor = [UIColor lightGrayColor];

    return cell;
}


#pragma mark - collection view delegate methods


#pragma mark - collection view flow layout delegate

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    
//    //______this is overridden in the flow layout subclass method______ Grrrr!!
//    CGSize newSize = CGSizeMake(EQRScheduleItemWidthForDay, EQRScheduleItemHeightForDay);
//    
//    return newSize;
//    
//}







@end