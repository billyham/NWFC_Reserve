//
//  ClassSection+CoreDataProperties.h
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ClassSection.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClassSection (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *key_id;
@property (nullable, nonatomic, retain) NSNumber *section_name;
@property (nullable, nonatomic, retain) NSNumber *catalog_foreign_key;
@property (nullable, nonatomic, retain) NSString *section_date;
@property (nullable, nonatomic, retain) NSString *term;
@property (nullable, nonatomic, retain) NSString *section_identifier;

@end

NS_ASSUME_NONNULL_END
