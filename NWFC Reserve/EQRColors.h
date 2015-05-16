//
//  EQRColors.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *EQRColorSelectionYellow;
extern NSString* EQRColorSelectionBlue;  //selected equipList cell bg, selected schedule nav bar cell bg
extern NSString* EQRColorEditModeBGBlue;  //edit mode blue
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
extern NSString* EQRColorCoolGreen;  //currently not used 5-15-15

extern NSString* EQRColorStatusNil;
extern NSString* EQRColorStatusGoing;
extern NSString* EQRColorStatusReturning;

extern NSString* EQRColorIssueDescriptive;
extern NSString* EQRColorIssueMinor;
extern NSString* EQRColorIssueSerious;

extern NSString* EQRColorDemoMode;


@interface EQRColors : NSObject

@property (strong, nonatomic) NSDictionary* colorDic;

+(EQRColors*)sharedInstance;
-(void)loadColors;

@end
