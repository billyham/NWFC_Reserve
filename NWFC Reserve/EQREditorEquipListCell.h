//
//  EQREditorEquipListCell.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/31/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCellTemplate.h"

@interface EQREditorEquipListCell : EQRCellTemplate

@property BOOL toBeDeletedFlag;

-(void)initialSetupWithTitle:(NSString*) titleName keyID:(NSString*)keyID deleteFlag:(BOOL)deleteFlag;

@end
