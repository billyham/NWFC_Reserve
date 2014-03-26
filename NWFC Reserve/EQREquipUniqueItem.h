//
//  EQREquipUniqueItem.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 2/13/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQREquipUniqueItem : NSObject

@property (strong, nonatomic) NSString* key_id;
@property (strong, nonatomic) NSString* equipTitleItem_foreignKey;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* distinquishing_id;
@property (strong, nonatomic) NSString* status_level;

//properties derived from the matching titleItem
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* subcategory;
@property (strong, nonatomic) NSString* shortname;
@property (strong, nonatomic) NSString* schedule_grouping;


@end
