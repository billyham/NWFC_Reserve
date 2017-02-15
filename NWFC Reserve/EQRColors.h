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
extern NSString *EQRColorButtonBlue;
extern NSString *EQRColorButtonBlueOnGrayBG;  // used for collapse button on itinerary cells
extern NSString* EQRColorEditModeBGBlue;  //edit mode blue
extern NSString* EQRColorVeryLightGrey;

extern NSString* EQRColorCalStudent;
extern NSString* EQRColorCalPublic;
extern NSString* EQRColorCalStaff;
extern NSString* EQRColorCalFaculty;
extern NSString* EQRColorCalYouth;
extern NSString* EQRColorCalInClass;

extern NSString *EQRColorStudentFull;
extern NSString *EQRColorStudentDark;
extern NSString *EQRColorPublicFull;
extern NSString *EQRColorPublicDark;
extern NSString *EQRColorStaffFull;
extern NSString *EQRColorStaffDark;
extern NSString *EQRColorFacultyFull;
extern NSString *EQRColorFacultyDark;
extern NSString *EQRColorYouthFull;
extern NSString *EQRColorYouthDark;
extern NSString *EQRColorInClassFull;
extern NSString *EQRColorInClassDark;

extern NSString *EQRColorButtonGreen;

//extern NSString* EQRColorNeedsPrep;
//extern NSString* EQRColorDonePrep;
extern NSString* EQRColorFilterOn;
extern NSString* EQRColorCoolGreen;  //currently not used 5-15-15

extern NSString* EQRColorStatusNil;
extern NSString* EQRColorStatusGoing;
extern NSString* EQRColorStatusReturning;

extern NSString* EQRColorIssueDescriptive;
extern NSString* EQRColorIssueMinor;
extern NSString* EQRColorIssueSerious;

extern NSString *EQRColorFilterBarAndSearchBarBackground;

extern NSString* EQRColorDemoMode;
extern NSString *EQRColorDemoNavItems;


@interface EQRColors : NSObject

@property (strong, nonatomic) NSDictionary* colorDic;

+(EQRColors*)sharedInstance;
-(void)loadColors;

@end
