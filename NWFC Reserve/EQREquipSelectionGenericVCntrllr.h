//
//  EQREquipSelectionGenericVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/6/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "EQREquipItemCell.h"


@interface EQREquipSelectionGenericVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>{
    
    
}

@property (nonatomic, strong) IBOutlet UICollectionView* equipCollectionView;
@property (nonatomic, strong) IBOutlet UIButton* continueButton;

-(void)overrideSharedRequestManager:(id)privateRequestManager;


@end


