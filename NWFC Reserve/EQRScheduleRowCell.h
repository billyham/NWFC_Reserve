//
//  EQRScheduleRowCell.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRCellTemplate.h"
#import "EQRScheduleCellContentVCntrllr.h"


@interface EQRScheduleRowCell : EQRCellTemplate <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString* uniqueItem_keyID;
@property (strong, nonatomic) EQRScheduleCellContentVCntrllr* cellContentVC;
@property (nonatomic, strong) UICollectionView* myUniqueItemCollectionView;



-(void)initialSetupWithTitle:(NSString*) titleName equipKey:(NSString*)uniqueKeyID indexPath:(NSIndexPath*)indexPath dateForShow:(NSDate*)dateForShow;
-(void)signalToAssignNarrow;

@end
