//
//  EQREditorEquipListCell.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/31/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCellTemplate.h"
#import "EQREditorEquipListContentVC.h"

@interface EQREditorEquipListCell : EQRCellTemplate

@property BOOL toBeDeletedFlag;
@property (strong, nonatomic) EQREditorEquipListContentVC* myContentVC;

-(void)initialSetupWithTitle:(NSString*) titleName keyID:(NSString*)keyID deleteFlag:(BOOL)deleteFlag;

@end
