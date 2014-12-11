//
//  EQRCheckRowCell.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "EQREquipUniqueItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"

@interface EQRCheckRowCell : UICollectionViewCell


-(void)initialSetupWithEquipUnique:(EQRScheduleTracking_EquipmentUnique_Join*)equipJoin
                            marked:(BOOL)mark_for_returning
                        switch_num:(NSUInteger)switch_num
                 markedForDeletion:(BOOL)deleteFlag
                         indexPath:(NSIndexPath*)indexPath;


@end
