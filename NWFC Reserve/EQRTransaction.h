//
//  EQRTransaction.h
//  Gear
//
//  Created by Ray Smith on 9/29/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRTransaction : NSObject

@property (nonatomic, strong) NSString *key_id;
@property (nonatomic, strong) NSString *scheduleTracking_foreignKey;
@property (nonatomic, strong) NSString *rental_days_for_pricing;
@property (nonatomic, strong) NSString *subtotal;
@property (nonatomic, strong) NSString *total_due;
@property (nonatomic, strong) NSString *total_paid;
@property (nonatomic, strong) NSString *deposit_due;
@property (nonatomic, strong) NSString *deposit_paid;
@property (nonatomic, strong) NSString *payment_type;
@property (nonatomic, strong) NSDate *payment_timestamp;
@property (nonatomic, strong) NSString *payment_staff_foreignKey;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *has_discount;
@property (nonatomic, strong) NSString *discount_type;
@property (nonatomic, strong) NSString *discount_value;
@property (nonatomic, strong) NSString *discount_total;
@property (nonatomic, strong) NSString *discount_description;
@property (nonatomic, strong) NSString *renter_pricing_class;

//from Contact
@property (nonatomic, strong) NSString *first_and_last;
@property (nonatomic, strong) NSString *first_name;

@property BOOL hasAStoredRentalDaysForPricingValue;

@end
