//
//  EQREditorEquipListCell.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/31/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCellTemplate.h"
#import "EQREditorEquipListContentVC.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"


@interface EQREditorEquipListCell : EQRCellTemplate

@property BOOL toBeDeletedFlag;
@property (strong, nonatomic) EQREditorEquipListContentVC* myContentVC;

-(void)initialSetupWithJoinObject:(EQRScheduleTracking_EquipmentUnique_Join*)joinObject deleteFlag:(BOOL)deleteFlag;

@end
