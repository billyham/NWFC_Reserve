//
//  EQRFirstViewController.h
//  NWFC Reserve
//
//  Created by Japhy Ryder on 11/6/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRContactPickerVC.h"
#import "EQRClassPickerVC.h"

@interface EQRReserveTopVCntrllr : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, EQRContactPickerDelegate, EQRClassPickerDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* rentorTypeListTable;

-(void)retrieveSelectedNameItem;

//EQRClassPickerVC delegate method
-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem;






@end
