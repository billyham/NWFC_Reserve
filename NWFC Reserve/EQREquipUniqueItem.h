//
//  EQREquipUniqueItem.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 2/13/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQREquipUniqueItem : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* equipTitleItem_foreignKey;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* distinquishing_id;
@property (strong, nonatomic) NSString* status_level;

//properties derived from the matching titleItem
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* subcategory;
@property (strong, nonatomic) NSString* shortname;
@property (strong, nonatomic) NSString* schedule_grouping;

//properties used for check in/out DistIDPickerVC to hide unavailable uniqueItems
@property BOOL unavailableFlag;

//properties derived from the matching schedule_equip_join
//@property (strong, nonatomic) NSString* prep_flag;
//@property (strong, nonatomic) NSString* checkout_flag;
//@property (strong, nonatomic) NSString* checkin_flag;
//@property (strong, nonatomic) NSString* shelf_flag;
////the schedule_equip_join key_id but renamed so it doesn't get saved as the unique_item's key_id
//@property (strong, nonatomic) NSString* tracking_unique_join_key_id;


@end
