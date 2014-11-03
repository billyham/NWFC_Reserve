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
@property (strong, nonatomic) NSDate* pickupDateAsDate;
@property (strong, nonatomic) NSDate* pickupTimeAsDate;
@property (strong, nonatomic) NSDate* returnDateAsDate;
@property (strong, nonatomic) NSDate* returnTimeAsDate;
@property (strong, nonatomic) NSString* staffFirstName;
//@property (strong, nonatomic) NSString* emailSignature;

@property (strong,nonatomic) NSArray* arrayOfEquipTitlesAndQtys;


-(NSString*)composeEmailSubjectLine;
-(NSMutableAttributedString*)composeEmailText;

@end