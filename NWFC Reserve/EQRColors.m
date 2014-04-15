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
                         nil];
    }
}


@end