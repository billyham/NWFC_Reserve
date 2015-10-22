//
//  EQRItineraryRowCell2.h
//  Gear
//
//  Created by Ray Smith on 7/7/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRCellTemplate.h"
#import "EQRScheduleRequestItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRItineraryCellContent2VC.h"

@interface EQRItineraryRowCell2 : UICollectionViewCell

@property (strong, nonatomic) EQRItineraryCellContent2VC *contentVC;


//@property NSInteger totalJoinCoint;
//@property NSInteger unTickedJoinCountForButton1;
//@property NSInteger unTickedJoinCountForButton2;



-(void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem;
//-(BOOL)checkForJoinWarnings:(EQRScheduleTracking_EquipmentUnique_Join *)join;
-(void)updateButtonLabels:(EQRScheduleRequestItem *)requestItem;


@end
