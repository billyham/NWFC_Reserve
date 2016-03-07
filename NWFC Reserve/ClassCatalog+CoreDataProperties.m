//
//  ClassCatalog+CoreDataProperties.m
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ClassCatalog+CoreDataProperties.h"

@implementation ClassCatalog (CoreDataProperties)

@dynamic key_id;
@dynamic course_id;
@dynamic title;
@dynamic description_long;
@dynamic instructor_name;
@dynamic instructor_foreign_key;
@dynamic max_attendance;
@dynamic price_tuition;
@dynamic price_psu_credit;
@dynamic price_psu_rec_fee;
@dynamic prerequisite;
@dynamic allocated_gear;
@dynamic projects;
@dynamic dates;
@dynamic textbooks;
@dynamic location;
@dynamic decommissioned;

@end
