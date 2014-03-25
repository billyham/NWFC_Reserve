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


@interface EQRScheduleRowCell()

@property (nonatomic, strong) UICollectionView* myUniqueItemCollectionView;

@end

@implementation EQRScheduleRowCell


-(void)initialSetupWithTitle:(NSString*) titleName{
    
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
    thisFlowLayout.itemSize = CGSizeMake(50, 50);
    thisFlowLayout.sectionInset = UIEdgeInsetsZero;
    thisFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGRect thisRect = CGRectMake(200, 5, 558, 60);
    UICollectionView* thisCollectionView = [[UICollectionView alloc] initWithFrame:thisRect collectionViewLayout:thisFlowLayout];
    self.myUniqueItemCollectionView = thisCollectionView;
    
    //register collection view cell
    [self.myUniqueItemCollectionView registerClass:[EQRCellTemplate class] forCellWithReuseIdentifier:@"ThisCell"];
    
    
    [self.myUniqueItemCollectionView setDataSource:self];
    [self.myUniqueItemCollectionView setDelegate:self];
    //
    [self.contentView addSubview:self.myUniqueItemCollectionView];
    
    //______*******  ADD CONSTRAINTS TO THE SUB COLLECTION VIEW  ********__________
    
    
    
    self.myUniqueItemCollectionView.backgroundColor = [UIColor clearColor];
    
}

#pragma mark - collection view data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 3;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString* CellIdentifier = @"ThisCell";
    EQRCellTemplate* cell = [self.myUniqueItemCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    for (UIView* view in cell.contentView.subviews){

        [view removeFromSuperview];
    }

    [cell initialSetupWithTitle:@"Monkey Butt"];
    
    
    //restrict label to the cell
    cell.contentView.clipsToBounds = YES;
    
    //cell color
    cell.contentView.backgroundColor = [UIColor lightGrayColor];

    NSLog(@"row item is happening");


    return cell;
}


#pragma mark - collection view delegate methods


#pragma mark - collection view flow layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //______this is overridden in the flow layout subclass method______ 
    CGSize newSize = CGSizeMake(EQRScheduleItemWidthForDay, EQRScheduleItemHeightForDay);
    
    return newSize;
    
}







@end
