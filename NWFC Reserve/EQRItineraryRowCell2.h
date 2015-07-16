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





-(void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem;
-(void)checkForJoinWarnings:(EQRScheduleTracking_EquipmentUnique_Join *)join;


@end
