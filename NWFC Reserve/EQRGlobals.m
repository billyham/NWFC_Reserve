//
//  EQRGlobals.m
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRGlobals.h"

NSString* ApplicationKey = @"3j654FP00o91wer";

//Notification selectors
NSString* EQRVoidScheduleItemObjects = @"EQRVoidScheduleItemObjects";
NSString* EQRRefreshEquipTable = @"EQRRefreshEquipTable";
NSString* EQRRefreshScheduleTable = @"EQRRefreshScheduleTable";
NSString* EQRButtonHighlight = @"EQRButtonHighlight";
NSString* EQRButtonUnHighlight = @"EQRButtonUnHighlight";
NSString* EQRPresentRequestEditor = @"EQRPresentRequestEditor";
NSString* EQRAChangeWasMadeToTheSchedule = @"EQRAChangeWasMadeToTheSchedule";
NSString* EQREquipUniqueToBeDeleted = @"EQREquipUniqueToBeDeleted";
NSString* EQREquipUniqueToBeDeletedCancel = @"EQREquipUniqueToBeDeletedCancel";



//Timing
float EQRHighlightTappingTime = 0.125;
float EQRResizingCollectionViewTime = 0.3;
float EQRRentorTypeLeadingSpace = 80;

//Schedule sizes
float EQRScheduleItemWidthForDay = 26;
float EQRScheduleItemHeightForDay = 30;
float EQRScheduleLengthOfEquipUniqueLabel = 200;

//Schedule view by category or subcategory or something else...
NSString* EQRScheduleGrouping = @"schedule_grouping";  //choose category or subcategory or schedule_grouping

BOOL EQRDisableTimeLimitForRequest = YES;


@implementation EQRGlobals

@end
