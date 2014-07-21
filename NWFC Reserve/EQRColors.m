//
//  EQRColors.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRColors.h"

NSString* EQRColorLightBlue = @"EQRColorLightBlue";
NSString* EQRColorVeryLightGrey = @"EQRColorVeryLightGrey";
NSString* EQRColorCalStudent = @"EQRColorCalStudent";
NSString* EQRColorCalPublic = @"EQRColorCalPublic";
NSString* EQRColorCalStaff = @"EQRColorCalStaff";
NSString* EQRColorCalFaculty = @"EQRColorCalFaculty";
NSString* EQRColorCalYouth = @"EQRColorCalYouth";
NSString* EQRColorNeedsPrep = @"EQRColorNeedsPrep";
NSString* EQRColorDonePrep = @"EQRColorDonePrep";
NSString* EQRColorFilterOn = @"EQRColorFilterOn";

NSString* EQRColorStatusNil = @"EQRColorStatusNil";
NSString* EQRColorStatusGoing = @"EQRColorStatusGoing";
NSString* EQRColorStatusReturning = @"EQRColorStatusReturning";

@implementation EQRColors


+(EQRColors*)sharedInstance{
    
    static EQRColors* myInstance = nil;
    
    if (!myInstance){
        
        myInstance = [[EQRColors alloc] init];
    }
    
    return myInstance;
}


-(void)loadColors{
    
    if (!self.colorDic){
        self.colorDic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIColor colorWithRed:0.7 green:0.9 blue:0.9 alpha:1.0], EQRColorLightBlue,
                         [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0], EQRColorVeryLightGrey,
                         [UIColor colorWithRed:0.77 green:0.87 blue:0.97 alpha:0.5], EQRColorCalStudent,
                         [UIColor colorWithRed:0.97 green:0.32 blue:0.52 alpha:0.5], EQRColorCalPublic,
                         [UIColor colorWithRed:0.82 green:0.62 blue:0.52 alpha:0.5], EQRColorCalStaff,
                         [UIColor colorWithRed:0.97 green:0.87 blue:0.32 alpha:0.5], EQRColorCalFaculty,
                         [UIColor colorWithRed:0.72 green:0.97 blue:0.72 alpha:0.5], EQRColorCalYouth,
                         [UIColor colorWithRed:1.0 green:0.0 blue:0.3 alpha:1.0], EQRColorFilterOn,
                         [UIColor colorWithRed:0.57 green:0.77 blue:0.77 alpha:1.0], EQRColorStatusGoing,
                         [UIColor colorWithRed:0.77 green:0.57 blue:0.57 alpha:1.0], EQRColorStatusReturning,
                         nil];
    }
}


@end
