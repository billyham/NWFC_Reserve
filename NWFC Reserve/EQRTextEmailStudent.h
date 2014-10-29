//
//  EQRTextEmailStudent.h
//  Gear
//
//  Created by Ray Smith on 10/29/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRTextEmailStudent : NSObject

@property (strong, nonatomic) NSString* renterEmail;
@property (strong, nonatomic) NSString* renterFirstName;
@property (strong, nonatomic) NSString* dateRange;
@property (strong, nonatomic) NSString* pickupDate;
@property (strong, nonatomic) NSString* pickupTime;
@property (strong, nonatomic) NSString* returnDate;
@property (strong, nonatomic) NSString* returnTime;
@property (strong, nonatomic) NSString* staffFirstName;
@property (strong, nonatomic) NSString* emailSignature;

@property (strong,nonatomic) NSArray* arrayOfEquipTitlesAndQtys;

@property (strong, nonatomic) NSMutableString* finalText;

-(NSString*)composeEmailText;

@end
