//
//  EQREquipItem.h
//  NWFC Reserve
//
//  Created by Ray Smith on 11/12/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQREquipItem : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* shortname;
@property (strong, nonatomic) NSString* price_commercial;
@property (strong, nonatomic) NSString *price_staff;
@property (strong, nonatomic) NSString* price_artist;
@property (strong, nonatomic) NSString* price_nonprofit;
@property (strong, nonatomic) NSString* price_student;
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* subcategory;
//
//need to change the name of this from 'description' cuz it conflicts with the system??
@property (strong, nonatomic) NSString* description_long;
//
@property (strong, nonatomic) NSString* description_short;
@property (strong, nonatomic) NSString* price_deposit;
@property (strong, nonatomic) NSString* hide_from_public;
@property (strong, nonatomic) NSString* hide_from_student;
@property (strong, nonatomic) NSString* schedule_grouping;

// Non-database properties
@property (strong, nonatomic) NSString *count_of_available;

@end
