//
//  EQRClassRegistrationItem.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/28/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRClassRegistrationItem : NSObject

@property (strong, nonatomic) NSString* key_iD;
@property (strong, nonatomic) NSString* contact_foreignKey;
@property (strong, nonatomic) NSString* classSection_foreignKey;
@property (strong, nonatomic) NSString* payment_tendered;
@property (strong, nonatomic) NSString* payment_due;
@property (strong, nonatomic) NSString* notes;
@property (strong, nonatomic) NSString* date;


@end
