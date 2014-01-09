//
//  EQRFirstViewController.h
//  NWFC Reserve
//
//  Created by Japhy Ryder on 11/6/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRReserveTopVCntrllr : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet UICollectionView* classListTable;
@property (nonatomic, strong) IBOutlet UICollectionView* nameListTable;










@end
