//
//  Contact+CoreDataProperties.h
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *key_id;
@property (nullable, nonatomic, retain) NSString *first_name;
@property (nullable, nonatomic, retain) NSNumber *last_name;
@property (nullable, nonatomic, retain) NSString *first_and_last;
@property (nullable, nonatomic, retain) NSNumber *email;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *zip;
@property (nullable, nonatomic, retain) NSNumber *current_student;
@property (nullable, nonatomic, retain) NSNumber *student_id;
@property (nullable, nonatomic, retain) NSNumber *rentor_type_staff;
@property (nullable, nonatomic, retain) NSNumber *rentor_type_faculty;
@property (nullable, nonatomic, retain) NSNumber *current_eq_staff;
@property (nullable, nonatomic, retain) NSNumber *current_eq_intern;
@property (nullable, nonatomic, retain) NSNumber *decommissioned;

@end

NS_ASSUME_NONNULL_END
