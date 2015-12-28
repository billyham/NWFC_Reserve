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
@property (strong, nonatomic) NSString* equipTitleItem_foreignKey;
@property (strong, nonatomic) NSString* prep_flag;
@property (strong, nonatomic) NSString* checkout_flag;
@property (strong, nonatomic) NSString* checkin_flag;
@property (strong, nonatomic) NSString* shelf_flag;
@property (nonatomic, strong) NSString *cost;
@property (nonatomic, strong) NSString *deposit;

@property int itemQuantity;

//from scheduleTracking record
@property (strong, nonatomic) NSString* contact_name;
@property (strong, nonatomic) NSDate* request_date_begin;
@property (strong, nonatomic) NSDate* request_date_end;
@property (strong, nonatomic) NSDate* request_time_begin;
@property (strong, nonatomic) NSDate* request_time_end;
@property (strong, nonatomic) NSString* renter_type;

//from equipUniqueItem record
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* distinquishing_id;
@property (strong, nonatomic) NSString* status_level;
//
////from equipTitleItem record
//or more likely the method to create structured array for something like quickViewPage2
//@property (strong, nonatomic) NSString* subcategory;
@property (strong, nonatomic) NSString* schedule_grouping;
//this is only used in EQRPageConstructor
@property (strong, nonatomic) NSString* category;


//properties from service issues
@property (strong, nonatomic) NSString* issue_short_name;

//ScheduleRequestManager will use to tag joins if they conflict
@property BOOL scheduleSameDayFlag;
@property BOOL scheduleCollisionFlag;

//EQREditorEquipListCell will use this to mark to be deleted
//@property BOOL markedForDeletion;

@property BOOL hasAStoredCostValue;
@property BOOL hasAStoredDepositValue;



@end
