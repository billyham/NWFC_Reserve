//
//  EQRItineraryRowGoingCell.m
//  Gear
//
//  Created by Ray Smith on 10/29/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryRowGoingCell.h"

@implementation EQRItineraryRowGoingCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)initialSetupWithRequestItem:(EQRScheduleRequestItem*) requestItem {
    EQRItineraryCellContent2VC *content = [[EQRItineraryCellContent2VC alloc] initWithNibName:@"EQRItineraryCellContentGoing2" bundle:nil];
    self.contentVC = content;
    
    [super initialSetupWithRequestItem:requestItem];
}

@end
