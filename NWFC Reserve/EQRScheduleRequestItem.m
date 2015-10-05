//
//  EQRScheduleRequestItem.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/31/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleRequestItem.h"

@implementation EQRScheduleRequestItem


#pragma mark - copying

-(id)copyWithZone:(NSZone *)zone{
    
    EQRScheduleRequestItem* newRequest = [[EQRScheduleRequestItem allocWithZone:zone] init];
    
    newRequest.key_id = [self.key_id copy];
    newRequest.contact_foreignKey = [self.contact_foreignKey copy];
    newRequest.classSection_foreignKey = [self.classSection_foreignKey copy];
    newRequest.classTitle_foreignKey = [self.classTitle_foreignKey copy];
    newRequest.request_date_begin = [self.request_date_begin copy];
    newRequest.request_date_end = [self.request_date_end copy];
    newRequest.request_time_begin = [self.request_time_begin copy];
    newRequest.request_time_end = [self.request_time_end copy];
    newRequest.time_of_request = [self.time_of_request copy];
    newRequest.renter_type = [self.renter_type copy];
    newRequest.staff_prep_date = [self.staff_prep_date copy];
    newRequest.staff_prep_id = [self.staff_prep_id copy];
    newRequest.staff_checkout_date = [self.staff_checkout_date copy];
    newRequest.staff_checkout_id = [self.staff_checkout_id copy];
    newRequest.staff_checkin_date = [self.staff_checkin_date copy];
    newRequest.staff_checkin_id = [self.staff_checkin_id copy];
    newRequest.staff_shelf_date = [self.staff_shelf_date copy];
    newRequest.staff_shelf_id = [self.staff_shelf_id copy];
    newRequest.staff_confirmation_date = [self.staff_confirmation_date copy];
    newRequest.staff_confirmation_id = [self.staff_confirmation_id copy];
    newRequest.past_due = [self.past_due copy];
    newRequest.payment_due = [self.payment_due copy];
    newRequest.payment_paid = [self.payment_paid copy];
    newRequest.payment_deposit = [self.payment_deposit copy];
    newRequest.payment_type = [self.payment_type copy];
    newRequest.contact_name = [self.contact_name copy];
    newRequest.station_id = [self.station_id copy];
    newRequest.notes = [self.notes copy];
    newRequest.renter_pricing_class = [self.renter_pricing_class copy];
    
    newRequest.title = [self.title copy];
    newRequest.showAllEquipmentFlag = self.showAllEquipmentFlag;
    newRequest.allowSameDayFlag = self.allowSameDayFlag;
    newRequest.allowConflictFlag = self.allowConflictFlag;
    
    
    return newRequest;
}

@end
