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
#import "EQRWebData.h"

@interface EQRItineraryRowCell : EQRCellTemplate <EQRWebDataDelegate>

//async webData properties
@property (strong, nonatomic) EQRWebData *webData;

-(void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem;

//webData DelegateDataFeed methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action;


@end
