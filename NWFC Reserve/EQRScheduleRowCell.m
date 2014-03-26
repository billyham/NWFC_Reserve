//
//  EQRScheduleRowCell.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleRowCell.h"
#import "EQRScheduleFlowLayout.h"
#import "EQRGlobals.h"
#import "EQRScheduleNestedDayCell.h"
#import "EQRScheduleRequestManager.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"


@interface EQRScheduleRowCell()

@property (nonatomic, strong) UICollectionView* myUniqueItemCollectionView;

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
    EQRScheduleFlowLayout* thisFlowLayout = [[EQRScheduleFlowLayout alloc] init];
    thisFlowLayout.itemSize = CGSizeMake(50, 30);
    thisFlowLayout.sectionInset = UIEdgeInsetsZero;
    thisFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGRect thisRect = CGRectMake(200, 5, 558, 30);
    UICollectionView* thisCollectionView = [[UICollectionView alloc] initWithFrame:thisRect collectionViewLayout:thisFlowLayout];
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
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in requestManager.arrayOfMonthScheduleTracking_EquipUnique_Joins){
        
        if ([join.equipUniqueItem_foreignKey isEqualToString:self.uniqueItem_keyID]){
            
            return 1;
        }
    }
    
    return 0;
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

    [cell initialSetupWithTitle:@"Monkey Butt"];
    
    
    //restrict label to the cell
    cell.contentView.clipsToBounds = YES;
    
    //cell color
    cell.contentView.backgroundColor = [UIColor lightGrayColor];

    return cell;
}


#pragma mark - collection view delegate methods


#pragma mark - collection view flow layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //______this is overridden in the flow layout subclass method______ Grrrr!!
    CGSize newSize = CGSizeMake(EQRScheduleItemWidthForDay, EQRScheduleItemHeightForDay);
    
    return newSize;
    
}







@end
