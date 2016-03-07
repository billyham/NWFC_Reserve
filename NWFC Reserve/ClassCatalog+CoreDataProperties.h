//
//  ClassCatalog+CoreDataProperties.h
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ClassCatalog.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClassCatalog (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *key_id;
@property (nullable, nonatomic, retain) NSNumber *course_id;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *description_long;
@property (nullable, nonatomic, retain) NSString *instructor_name;
@property (nullable, nonatomic, retain) NSNumber *instructor_foreign_key;
@property (nullable, nonatomic, retain) NSNumber *max_attendance;
@property (nullable, nonatomic, retain) NSNumber *price_tuition;
@property (nullable, nonatomic, retain) NSNumber *price_psu_credit;
@property (nullable, nonatomic, retain) NSNumber *price_psu_rec_fee;
@property (nullable, nonatomic, retain) NSString *prerequisite;
@property (nullable, nonatomic, retain) NSString *allocated_gear;
@property (nullable, nonatomic, retain) NSString *projects;
@property (nullable, nonatomic, retain) NSString *dates;
@property (nullable, nonatomic, retain) NSString *textbooks;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSNumber *decommissioned;

@end

NS_ASSUME_NONNULL_END
