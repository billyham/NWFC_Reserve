//
//  EQRScheduleNestedDayCell.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/25/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRCellTemplate.h"

@interface EQRScheduleNestedDayCell : EQRCellTemplate

-(void)initialSetupWithTitle:(NSString*) titleName joinKeyID:(NSString*)joinKeyID joinTitleKeyID:(NSString*)joinTitleKeyID indexPath:(NSIndexPath*)indexPath;

@end
