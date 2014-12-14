//
//  EQRDataStructure.h
//  NWFC Reserve
//
//  Created by Ray Smith on 9/10/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRDataStructure : NSObject

+(EQRDataStructure*)sharedInstance;

//enter array of any object that has values for equipTitleItem_foreignKey, schedule_grouping, and distinquishing_id)
//returns array of arrays, the subarrays are grouped together based on schedule_grouping,
//the subarrays are populated with ScheduleTracking_EquipmentUnique_Joins
+(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray;


//need function to sort a subarray of schedule_equip_joins (or equipUniques) based on ascending distinguishing ids


//enter array of ScheduleTracking_EquipmentUnique_Joins (actually, any object that has a value for equipTitleItem_foreignKey)
//returns array of dictionaries with two items:
//key "equipTitleObject" and value is EquipTitleItem object
//key "quantity" and value is NSNumber
+(NSArray*)decomposeJoinsToEquipTitlesWithQuantities:(NSArray*)EquipJoins;


//enter an NSDate and it returns MYSQL compatible string
+(NSString*)dateAsString:(NSDate*)myDate;
+(NSString*)dateAsStringSansTime:(NSDate*)myDate;
+(NSString*)timeAsString:(NSDate*)myDate;

+(NSDate*)dateFromCombinedDay:(NSDate*)myDay And8HourShiftedTime:(NSDate*)myTime;
//+(NSDate*)dateFromCombinedDay:(NSDate*)myDay AndTime:(NSDate*)myTime;

+(NSDate*)dateByStrippingOffTime:(NSDate*)myDate;
+(NSDate*)timeByStrippingOffDate:(NSDate*)myDate;


@end
