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

@protocol EQREditorEquipCellDelegate;


@interface EQREditorEquipListCell : EQRCellTemplate{
    
    __weak id <EQREditorEquipCellDelegate> delegate;
}

@property (weak, nonatomic) id <EQREditorEquipCellDelegate> delegate;
@property BOOL toBeDeletedFlag;
@property (strong, nonatomic) EQREditorEquipListContentVC* myContentVC;

-(void)initialSetupWithJoinObject:(EQRScheduleTracking_EquipmentUnique_Join*)joinObject deleteFlag:(BOOL)deleteFlag editMode:(BOOL)editModeFlag;
-(void)enterEditMode;
-(void)leaveEditMode;

@end


@protocol EQREditorEquipCellDelegate <NSObject>

-(void)tagEquipUniqueToDelete:(NSString*)key_id;
-(void)tagEquipUniqueToCancelDelete:(NSString*)key_id;
-(void)distIDPickerTapped:(NSDictionary*)infoDictionary;

@end