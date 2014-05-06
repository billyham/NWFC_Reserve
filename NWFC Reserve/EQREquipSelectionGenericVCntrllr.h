//
//  EQREquipSelectionGenericVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/6/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

@protocol EQREquipSelectionGenericDelegate;

#import <UIKit/UIKit.h>

@interface EQREquipSelectionGenericVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>{
    
    __weak id <EQREquipSelectionGenericDelegate> delegate;
    
}

@property (nonatomic, strong) IBOutlet UICollectionView* equipCollectionView;


@end


@protocol  QREquipSelectionGenericDelegate <NSObject>



@end