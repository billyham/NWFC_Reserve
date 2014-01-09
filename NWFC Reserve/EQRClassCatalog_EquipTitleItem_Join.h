//
//  EQRScheduleTracking_EquipUniqueItem_Join.h
//  NWFC Reserve
//
//  Created by Ray Smith on 1/1/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRClassCatalog_EquipTitleItem_Join : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* classCatalog_foreignKey;
@property (strong, nonatomic) NSString* equipTitleItem_foreignKey;

@end
