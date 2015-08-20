//
//  EQRClassCatalog.h
//  Gear
//
//  Created by Ray Smith on 8/20/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRClassCatalog : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* course_id;
@property (strong, nonatomic) NSString* title;
//need to change the name of this from 'description' cuz it conflicts with the system??
@property (strong, nonatomic) NSString* description_long;
@property (strong, nonatomic) NSString* instructor_name;
@property (strong, nonatomic) NSString* instructor_foreign_key;
@property (strong, nonatomic) NSString* max_attendance;
@property (strong, nonatomic) NSString* price_tuition;
@property (strong, nonatomic) NSString* price_psu_credit;
@property (strong, nonatomic) NSString* price_psu_rec_fee;
@property (strong, nonatomic) NSString* prerequisite;
@property (strong, nonatomic) NSString* allocated_gear;
@property (strong, nonatomic) NSString* projects;
@property (strong, nonatomic) NSString* dates;
@property (strong, nonatomic) NSString* textbooks;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* decommissioned;


@end
