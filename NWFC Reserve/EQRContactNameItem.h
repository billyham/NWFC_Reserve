//
//  EQRContactNameItem.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/25/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRContactNameItem : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* first_name;
@property (strong, nonatomic) NSString* last_name;
@property (strong, nonatomic) NSString* first_and_last;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSString* city;
@property (strong, nonatomic) NSString* state;
@property (strong, nonatomic) NSString* zip;
@property (strong, nonatomic) NSString* current_student;
@property (strong, nonatomic) NSString* student_id;


@end
