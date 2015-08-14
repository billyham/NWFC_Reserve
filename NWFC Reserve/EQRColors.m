//
//  EQRColors.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRColors.h"

NSString *EQRColorSelectionYellow = @"EQRColorSelectionYellow";
NSString* EQRColorSelectionBlue = @"EQRColorSelectionBlue";
NSString* EQRColorEditModeBGBlue = @"EQRColorEditModeBGBlue";
NSString* EQRColorVeryLightGrey = @"EQRColorVeryLightGrey";

NSString* EQRColorCalStudent = @"EQRColorCalStudent";
NSString* EQRColorCalPublic = @"EQRColorCalPublic";
NSString* EQRColorCalStaff = @"EQRColorCalStaff";
NSString* EQRColorCalFaculty = @"EQRColorCalFaculty";
NSString* EQRColorCalYouth = @"EQRColorCalYouth";
NSString* EQRColorCalInClass = @"EQRColorCalInClass";

NSString *EQRColorStudentFull = @"EQRColorStudentFull";
NSString *EQRColorStudentDark = @"EQRColorStudentDark";
NSString *EQRColorPublicFull = @"EQRColorPublicFull";
NSString *EQRColorPublicDark = @"EQRColorPublicDark";
NSString *EQRColorStaffFull = @"EQRColorStaffFull";
NSString *EQRColorStaffDark = @"EQRColorStaffDark";
NSString *EQRColorFacultyFull = @"EQRColorFacultyFull";
NSString *EQRColorFacultyDark = @"EQRColorFacultyDark";
NSString *EQRColorYouthFull = @"EQRColorYouthFull";
NSString *EQRColorYouthDark = @"EQRColorYouthDark";
NSString *EQRColorInClassFull = @"EQRColorInClassFull";
NSString *EQRColorInClassDark = @"EQRColorInClassDark";

NSString *EQRColorButtonGreen = @"EQRColorButtonGreen";

//NSString* EQRColorNeedsPrep = @"EQRColorNeedsPrep";
//NSString* EQRColorDonePrep = @"EQRColorDonePrep";
NSString* EQRColorFilterOn = @"EQRColorFilterOn";
NSString* EQRColorCoolGreen = @"EQRColorCoolGreen";

NSString* EQRColorStatusNil = @"EQRColorStatusNil";
NSString* EQRColorStatusGoing = @"EQRColorStatusGoing";
NSString* EQRColorStatusReturning = @"EQRColorStatusReturning";

NSString* EQRColorIssueDescriptive = @"EQRColorIssueDescriptive";
NSString* EQRColorIssueMinor = @"EQRColorIssueMinor";
NSString* EQRColorIssueSerious = @"EQRColorIssueSerious";

NSString *EQRColorFilterBarAndSearchBarBackground = @"EQRColorFilterBarAndSearchBarBackground";

NSString* EQRColorDemoMode = @"EQRColorDemoMode";

@implementation EQRColors


-(UIColor *)colorFromR:(float)red G:(float)green B:(float)blue{
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}


+(EQRColors*)sharedInstance{
    
    static EQRColors* myInstance = nil;
    
    if (!myInstance){
        
        myInstance = [[EQRColors alloc] init];
    }
    
    return myInstance;
}

//better implementation of a singleton...
//https://github.com/raywenderlich/objective-c-style-guide#spacing

/*
 Singleton objects should use a thread-safe pattern for creating their shared instance.
 
 + (instancetype)sharedInstance {
 static id sharedInstance = nil;
 
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 sharedInstance = [[self alloc] init];
 });
 
 return sharedInstance;
 }
 */


-(void)loadColors{
    
    if (!self.colorDic){
        self.colorDic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIColor yellowColor], EQRColorSelectionYellow,
                         [UIColor colorWithRed:0.7 green:0.9 blue:0.9 alpha:1.0], EQRColorSelectionBlue,
                         [UIColor colorWithRed:0.9 green:0.95 blue:0.98 alpha:1.0], EQRColorEditModeBGBlue,
                         [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0], EQRColorVeryLightGrey,
                         [UIColor colorWithRed:0.77 green:0.87 blue:0.97 alpha:0.5], EQRColorCalStudent,
                         [UIColor colorWithRed:0.97 green:0.32 blue:0.52 alpha:0.5], EQRColorCalPublic,
                         [UIColor colorWithRed:0.82 green:0.62 blue:0.52 alpha:0.5], EQRColorCalStaff,
                         [UIColor colorWithRed:0.92 green:0.62 blue:0.42 alpha:0.5], EQRColorCalFaculty,
                         [UIColor colorWithRed:0.72 green:0.97 blue:0.72 alpha:0.5], EQRColorCalYouth,
                         [UIColor colorWithRed:0.97 green:0.87 blue:0.32 alpha:0.5], EQRColorCalInClass,
                         [UIColor colorWithRed:1.0 green:0.0 blue:0.3 alpha:1.0], EQRColorFilterOn,
                         [UIColor colorWithRed:0.57 green:0.77 blue:0.77 alpha:1.0], EQRColorStatusGoing,
                         [UIColor colorWithRed:0.77 green:0.57 blue:0.57 alpha:1.0], EQRColorStatusReturning,
                         [UIColor colorWithRed:222 green:235 blue:234 alpha:1], EQRColorCoolGreen,
                         [UIColor grayColor], EQRColorIssueDescriptive,
                         [UIColor colorWithRed:0.88 green:0.65 blue:0.2 alpha:1.0], EQRColorIssueMinor,
                         [UIColor redColor], EQRColorIssueSerious,
                         [UIColor grayColor], EQRColorFilterBarAndSearchBarBackground,
                         [UIColor colorWithRed:1.0 green:0.9 blue:0.85 alpha:1.0], EQRColorDemoMode,
                         [self colorFromR:229 G:243 B:252], EQRColorStudentFull,
                         [self colorFromR:131 G:196 B:242], EQRColorStudentDark,
                         [self colorFromR:246 G:223 B:238], EQRColorPublicFull,
                         [self colorFromR:236 G:133 B:201], EQRColorPublicDark,
                         [self colorFromR:243 G:224 B:206], EQRColorFacultyFull,
                         [self colorFromR:229 G:157 B:86], EQRColorFacultyDark,
                         [self colorFromR:232 G:221 B:208], EQRColorStaffFull,
                         [self colorFromR:193 G:150 B:93], EQRColorStaffDark,
                         [self colorFromR:213 G:254 B:243], EQRColorYouthFull,
                         [self colorFromR:47 G:223 B:188], EQRColorYouthDark,
                         [self colorFromR:252 G:242 B:225], EQRColorInClassFull,
                         [self colorFromR:239 G:185 B:80], EQRColorInClassDark,
                         [self colorFromR:15 G:219 B:116], EQRColorButtonGreen,
                         nil];
    }
}


@end
