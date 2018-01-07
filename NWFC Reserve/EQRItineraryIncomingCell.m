//
//  EQRItineraryIncomingCell.m
//  Gear
//
//  Created by Ray Smith on 10/29/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryIncomingCell.h"

@implementation EQRItineraryIncomingCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        EQRItineraryCellContent2VC *content = [[EQRItineraryCellContent2VC alloc] initWithNibName:@"EQRItineraryCellContentReturning1" bundle:nil];
        self.contentVC = content;
    }
    return self;
}

- (void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem{
//    EQRItineraryCellContent2VC *content = [[EQRItineraryCellContent2VC alloc] initWithNibName:@"EQRItineraryCellContentReturning1" bundle:nil];
//    self.contentVC = content;
    [super initialSetupWithRequestItem:requestItem];
}


@end
