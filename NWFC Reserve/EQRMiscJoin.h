//
//  EQRMiscJoin.h
//  Gear
//
//  Created by Ray Smith on 1/31/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRMiscJoin : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* scheduleTracking_foreignKey;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* prep_flag;
@property (strong, nonatomic) NSString* checkout_flag;
@property (strong, nonatomic) NSString* checkin_flag;
@property (strong, nonatomic) NSString* shelf_flag;
@property (strong, nonatomic) NSString *cost;
@property (strong, nonatomic) NSString *deposit;

@property int itemQuantity;

//from scheduleTracking record
@property (strong, nonatomic) NSString* contact_name;
@property (strong, nonatomic) NSDate* request_date_begin;
@property (strong, nonatomic) NSDate* request_date_end;
@property (strong, nonatomic) NSDate* request_time_begin;
@property (strong, nonatomic) NSDate* request_time_end;
@property (strong, nonatomic) NSString* renter_type;

@property BOOL hasAStoredCostValue;
@property BOOL hasAStoredDepositValue;


@end
