//
//  EQRXMLParserHelper.m
//  Gear
//
//  Created by Ray Smith on 10/14/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRXMLParserHelper.h"

@interface EQRXMLParserHelper()

@property (nonatomic, weak) NSSet *validElements;

@end

@implementation EQRXMLParserHelper

+ (NSSet *)generateStandardElements {
    NSSet *set = [NSSet setWithObjects:
                  @"name",
                  @"subcategory",
                  @"category",
                  @"schedule_grouping",
                  @"description_short",
                  @"hide_from_public",
                  @"hide_from_student",
                  @"count_of_available",
                  @"equipTitleItem_foreignKey",
                  @"status_level",
                  @"distinquishing_id",
                  @"first_name",
                  @"last_name",
                  @"first_and_last",
                  @"phone",
                  @"email",
                  @"section_name",
                  @"key_id",
                  @"term",
                  @"catalog_foreign_key",
                  @"instructor_foreign_key",
                  @"contact_foreignKey",
                  @"equipUniqueItem_foreignKey",
                  @"scheduleTracking_foreignKey",
                  @"contact_name",
                  @"renter_type",
                  @"prep_flag",
                  @"checkout_flag",
                  @"checkin_flag",
                  @"shelf_flag",
                  @"classSection_foreignKey",
                  @"classTitle_foreignKey",
                  @"staff_confirmation_id",
                  @"staff_prep_id",
                  @"staff_checkout_id",
                  @"staff_checkin_id",
                  @"staff_shelf_id",
                  @"notes",
                  @"title",
                  @"issue_short_name",
                  @"status_level_numeric",
                  @"text",
                  @"context",
                  @"page",
                  @"distinguishing_id",
                  @"price_commercial",
                  @"price_artist",
                  @"price_staff",
                  @"price_nonprofit",
                  @"price_student",
                  @"price_deposit",
                  @"cost",
                  @"deposit",
                  @"rental_days_for_pricing",
                  @"renter_pricing_class",
                  @"subtotal",
                  @"total_due",
                  @"total_paid",
                  @"deposit_due",
                  @"deposit_paid",
                  @"discount_value",
                  @"discount_type",
                  @"discount_total",
                  @"payment_staff_foreignKey",
                  @"pdf_name",
                  @"EquipTitleItem_foreignKey",
                  @"description_long",
                  @"short_name",
                  @"category_for_ratesheet",
                  nil];
    return set;
}

+ (NSSet *)generateMiscElements {
    NSSet *set = [NSSet setWithObjects:
                  @"request_date_begin",
                  @"request_date_end",
                  @"request_time_begin",
                  @"request_time_end",
                  @"time_of_request",
                  @"staff_confirmation_date",
                  @"staff_prep_date",
                  @"staff_checkout_date",
                  @"staff_checkin_date",
                  @"staff_shelf_date",
                  @"payment_timestamp",
                  @"pdf_timestamp",
                  nil];
    return set;
}

+ (NSSet *)generateValidElementsFromSets:(NSArray *)arrayOfSets {
    NSMutableSet *setOfSets = [NSMutableSet setWithCapacity:1];
    NSSet *miscSet = [self generateMiscElements];
    for (NSSet *subSet in arrayOfSets) {
        [setOfSets unionSet:subSet];
    }
    [setOfSets unionSet: miscSet];
    
    return [NSSet setWithSet:setOfSets];
}

+ (BOOL)isValidElement:(NSString *)element inSet:(NSSet *)set {
    return [set containsObject:element];
}

+ (BOOL)assignCurrentValue:(NSString *)currentValue toCurrentThing:(id)currentThing forProp:(NSString *)prop forStandardSet:(NSSet *)set {
    
    if (![set containsObject:prop]) {
        return NO;
    }
    
    SEL propSelector = NSSelectorFromString(prop);
    if ([currentThing respondsToSelector:propSelector]) {
        NSString *propCap = [[prop substringToIndex:1] capitalizedString];
        NSString *propBody = [prop substringFromIndex:1];
        NSString *propSetter = [NSString stringWithFormat:@"set%@%@:", propCap, propBody];
        SEL propSetterSelector = NSSelectorFromString(propSetter);
        
        // Concatenate with item's previous value if it exists
        
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *previousValue = [currentThing performSelector:propSelector];
#       pragma clang diagnostic pop

        NSString *combinedValue;
        if (previousValue != nil){
            combinedValue = [NSString stringWithFormat:@"%@%@", previousValue, currentValue];
        } else {
            combinedValue = currentValue;
        }
        
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [currentThing performSelector:propSetterSelector withObject:combinedValue];
#       pragma clang diagnostic pop
    }
    return YES;
}







@end
