//
//  EQRGlobals.m
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRGlobals.h"

NSString* EQRApplicationKey = @"3j654FP00o91wer";
BOOL EQRUseICloud = NO;

//renter type strings
NSString* EQRRenterStudent = @"student";
NSString* EQRRenterFaculty = @"faculty";
NSString* EQRRenterStaff = @"staff";
NSString* EQRRenterPublic = @"public";
NSString* EQRRenterYouth = @"youth";
NSString* EQRRenterInClass = @"in class";

//______******* if any change is made to these, be sure to update existing renter_type rows in BOTH
//______******* scheduleTracking AND scheduleTracking_uniqueItem_join tables

//exception codes
NSString* EQRErrorCode88888888 = @"88888888";


//Notification selectors
NSString* EQRVoidScheduleItemObjects = @"EQRVoidScheduleItemObjects";
NSString* EQRRefreshEquipTable = @"EQRRefreshEquipTable";
NSString* EQRRefreshScheduleTable = @"EQRRefreshScheduleTable";
NSString* EQRButtonHighlight = @"EQRButtonHighlight";
NSString* EQRButtonUnHighlight = @"EQRButtonUnHighlight";
NSString* EQRPresentScheduleRowQuickView = @"EQRPresentScheduleQuickView";
NSString* EQRPresentItineraryQuickView = @"EQRPresentItineraryQuickView";
NSString* EQRPresentRequestEditorFromSchedule = @"EQRPresentRequestEditorFromSchedule";
NSString* EQRPresentRequestEditorFromItinerary = @"EQRPresentRequestEditorFromItinerary";
NSString* EQRPresentCheckInOut = @"EQRPresentCheckInOut";
NSString* EQRUpdateCheckInOutArrayOfJoins = @"EQRUpdateCheckInOutArrayOfJoins";
NSString* EQRMarkItineraryAsCompleteOrNot = @"EQRMarkItineraryAsCompleteOrNot";
NSString* EQRAChangeWasMadeToTheSchedule = @"EQRAChangeWasMadeToTheSchedule";
//NSString* EQREquipUniqueToBeDeleted = @"EQREquipUniqueToBeDeleted";
//NSString* EQREquipUniqueToBeDeletedCancel = @"EQREquipUniqueToBeDeletedCancel";
NSString* EQRJoinToBeDeletedInCheckInOut = @"EQRJoinToBeDeletedInCheckInOut";
NSString* EQRJoinToBeDeletedInCheckInOutCancel = @"EQRJoinToBeDeletedInCheckInOutCancel";
NSString* EQRLongPressOnNestedDayCell = @"EQRLongPressOnNestedDayCell";
NSString* EQRPartialRefreshToItineraryArray = @"EQRPartialRefreshToItineraryArray";
NSString* EQRQRCodeFlipsSwitchInRowCellContent = @"EQRQRCodeFlipsSwitchInRowCellContent";
NSString* EQRRefreshViewWhenOrientationRotates = @"EQRRefreshViewWhenOrientationRotates";
NSString* EQRDistIDPickerTapped = @"EQRDistIDPickerTapped";

//Timing
float EQRHighlightTappingTime = 0.125;
float EQRResizingCollectionViewTime = 0.3;

//Top View column size
float EQRRentorTypeLeadingSpace = 80;

//Schedule sizes
float EQRScheduleItemWidthForDay = 26;
float EQRScheduleItemWidthForDayNarrow = 18;
float EQRScheduleItemHeightForDay = 30;
float EQRScheduleLengthOfEquipUniqueLabel = 200;

//Schedule view by category or subcategory or something else...
NSString* EQRScheduleGrouping = @"schedule_grouping";  //choose category or subcategory or schedule_grouping

//application options
BOOL EQRDisableTimeLimitForRequest = YES;
BOOL EQRIncludeQRCodeReader = YES;
BOOL EQRAllowHardcodedPassword = YES;
NSString* EQRHardcodedPassword = @"super8";

//service issue thresholds
NSInteger EQRThresholdForDescriptiveNote = 2;
NSInteger EQRThresholdForMinorIssue = 3;
NSInteger EQRThresholdForSeriousIssue = 5;


@implementation EQRGlobals

@end
