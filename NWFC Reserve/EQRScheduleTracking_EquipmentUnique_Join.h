//
//  EQRScheduleTracking_EquipmentUnique_Join.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 1/21/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRScheduleTracking_EquipmentUnique_Join : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* scheduleTracking_foreignKey;
@property (strong, nonatomic) NSString* equipUniqueItem_foreignKey;

@property int itemQuantity;

@end
