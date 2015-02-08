//
//  EQRClassItem.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/26/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRClassItem : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* section_name;
@property (strong, nonatomic) NSString* catalog_foreign_key;
@property (strong, nonatomic) NSString* section_date;
@property (strong, nonatomic) NSString* term;
@property (strong, nonatomic) NSString* instructor_foreign_key;
//@property (strong, nonatomic) NSString* instructor_name;

//non-database properties
@property (strong, nonatomic) NSString* first_and_last;

@end
