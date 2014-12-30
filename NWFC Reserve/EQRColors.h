//
//  EQRColors.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* EQRColorLightBlue;
extern NSString* EQRColorVeryLightGrey;

extern NSString* EQRColorCalStudent;
extern NSString* EQRColorCalPublic;
extern NSString* EQRColorCalStaff;
extern NSString* EQRColorCalFaculty;
extern NSString* EQRColorCalYouth;
extern NSString* EQRColorCalInClass;

extern NSString* EQRColorNeedsPrep;
extern NSString* EQRColorDonePrep;
extern NSString* EQRColorFilterOn;
extern NSString* EQRColorCoolGreen;

extern NSString* EQRColorStatusNil;
extern NSString* EQRColorStatusGoing;
extern NSString* EQRColorStatusReturning;

extern NSString* EQRColorIssueDescriptive;
extern NSString* EQRColorIssueMinor;
extern NSString* EQRColorIssueSerious;


@interface EQRColors : NSObject

@property (strong, nonatomic) NSDictionary* colorDic;

+(EQRColors*)sharedInstance;
-(void)loadColors;

@end
