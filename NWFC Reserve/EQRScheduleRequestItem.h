//
//  EQRScheduleRequestItem.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/31/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRContactNameItem.h"
#import "EQRClassItem.h"
#import "EQRClassRegistrationItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"

@interface EQRScheduleRequestItem : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* contact_foreignKey;
@property (strong, nonatomic) NSString* classSection_foreignKey;
@property (strong, nonatomic) NSString* classTitle_foreignKey;
@property (strong, nonatomic) NSDate* request_date_begin;
@property (strong, nonatomic) NSDate* request_date_end;
//__________these time properties only get used in the itinerary class
@property (strong, nonatomic) NSDate* request_time_begin;
@property (strong, nonatomic) NSDate* request_time_end;
//___________
@property (strong, nonatomic) NSDate* time_of_request;
@property (strong, nonatomic) NSString* renter_type;
@property (strong, nonatomic) NSString* staff_prep_id;
@property (strong, nonatomic) NSDate* staff_prep_date;
@property (strong, nonatomic) NSString* staff_confirmation_id;
@property (strong, nonatomic) NSDate* staff_confirmation_date;
@property (strong, nonatomic) NSString* staff_checkout_id;
@property (strong, nonatomic) NSDate* staff_checkout_date;
@property (strong, nonatomic) NSString* staff_checkin_id;
@property (strong, nonatomic) NSDate* staff_checkin_date;
@property (strong, nonatomic) NSString* past_due;
@property (strong, nonatomic) NSString* payment_due;
@property (strong, nonatomic) NSString* payment_paid;
@property (strong, nonatomic) NSString* payment_deposit;
@property (strong, nonatomic) NSString* payment_type;
@property (strong, nonatomic) NSString* contact_name;

@property (strong, nonatomic) EQRContactNameItem* contactNameItem;
@property (strong, nonatomic) EQRClassItem* classItem;
@property (strong, nonatomic) EQRClassRegistrationItem* classRegistrationItem;
@property BOOL showAllEquipmentFlag;

@property (strong, nonatomic) NSMutableArray* arrayOfEquipmentJoins;

@property BOOL markedForReturn;

@end
