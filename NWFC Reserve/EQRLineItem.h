//
//  EQRLineItem.h
//  Gear
//
//  Created by Ray Smith on 9/25/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRLineItem : NSObject

@property (nonatomic, strong) NSString *key_id;
@property (nonatomic, strong) NSString *transaction_foreignKey;
@property (nonatomic, strong) NSString *equipUniqueItem_foreignKey;
@property (nonatomic, strong) NSString *cost;
@property (nonatomic, strong) NSString *renter_pricing_class;
@property (nonatomic, strong) NSString *add_on_title;
@property (nonatomic, strong) NSString *add_on_description;
@property (nonatomic, strong) NSString *is_add_on;

//non database properties
@property (nonatomic, strong) NSString *equipName;
@property (nonatomic, strong) NSString *equipDist_id;



@end
