//
//  EQRItineraryRowCell.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRCellTemplate.h"
#import "EQRScheduleRequestItem.h"

@interface EQRItineraryRowCell : EQRCellTemplate

-(void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem;

@end