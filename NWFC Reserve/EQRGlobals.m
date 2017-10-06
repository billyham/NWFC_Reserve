//
//  EQRGlobals.m
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRGlobals.h"

// Build spec, defaults to NWFC
BOOL EQRBuildNWDoc = YES;
BOOL EQRBuildPSU = NO;

BOOL EQRSuppressDemoColor = NO;

// Logs
BOOL EQRLogInputStrings = YES;

// Datastore Settings
BOOL EQRUseCoreData = NO;
NSString *EQRCloudKitContainer = @"iCloud.com.David-Vincent-Hanagan.GlobalGear";
NSString *EQRRecordZoneStandard = @"standardPrimary";
NSString *EQRRecordZoneDemo = @"demoPrimary";

// Renter type strings
NSString* EQRRenterStudent = @"student";
NSString* EQRRenterFaculty = @"faculty";
NSString* EQRRenterStaff = @"staff";
NSString* EQRRenterPublic = @"public";
NSString* EQRRenterYouth = @"youth";
NSString* EQRRenterInClass = @"in class";

// Pricing type strings
//______******* if any change is made to these, be sure to update existing renter_type rows in BOTH
//______******* scheduleTracking AND scheduleTracking_uniqueItem_join tables
NSString *EQRPriceCommerial = @"Commercial";
NSString *EQRPriceArtist = @"Artist / Non-Profit";
NSString *EQRPriceStudent = @"Student";
NSString *EQRPriceFaculty = @"Faculty";
NSString *EQRPriceStaff = @"Staff";

// Exception codes
NSString* EQRErrorCode88888888 = @"88888888";

// Notification selectors
NSString* EQRVoidScheduleItemObjects = @"EQRVoidScheduleItemObjects";
//NSString* EQRRefreshEquipTable = @"EQRRefreshEquipTable";
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
NSString *EQRAChangeWasMadeToTheDatabaseSource = @"EQRAChangeWasMadeToTheDatabaseSource";
//NSString* EQREquipUniqueToBeDeleted = @"EQREquipUniqueToBeDeleted";
//NSString* EQREquipUniqueToBeDeletedCancel = @"EQREquipUniqueToBeDeletedCancel";
NSString* EQRJoinToBeDeletedInCheckInOut = @"EQRJoinToBeDeletedInCheckInOut";
NSString* EQRJoinToBeDeletedInCheckInOutCancel = @"EQRJoinToBeDeletedInCheckInOutCancel";
NSString* EQRLongPressOnNestedDayCell = @"EQRLongPressOnNestedDayCell";
NSString* EQRPartialRefreshToItineraryArray = @"EQRPartialRefreshToItineraryArray";
NSString* EQRQRCodeFlipsSwitchInRowCellContent = @"EQRQRCodeFlipsSwitchInRowCellContent";
NSString* EQRRefreshViewWhenOrientationRotates = @"EQRRefreshViewWhenOrientationRotates";
NSString* EQRDistIDPickerTapped = @"EQRDistIDPickerTapped";
NSString *EQRUpdateHeaderCellsInEquipSelection = @"EQRUpdateHeaderCellsInEquipSelection";

// Timing
float EQRHighlightTappingTime = 0.125;
float EQRResizingCollectionViewTime = 0.3;

// Top View column size
float EQRRentorTypeLeadingSpace = 80;

// Schedule sizes
float EQRScheduleItemWidthForDay = 26;
float EQRScheduleItemWidthForDayNarrow = 18;
float EQRScheduleItemHeightForDay = 30;
float EQRScheduleLengthOfEquipUniqueLabel = 200;

// Schedule view by category or subcategory or something else...
NSString* EQRScheduleGrouping = @"schedule_grouping";  //choose category or subcategory or schedule_grouping

// Application options
NSString* EQRApplicationKey = @"3j654FP00o91wer";
BOOL EQRDisableTimeLimitForRequest = YES;
BOOL EQRIncludeQRCodeReader = YES;
BOOL EQRAllowHardcodedPassword = NO;
NSString* EQRHardcodedPassword = @"super8";
BOOL EQRRandomizeEquipSelection = YES;

// service issue thresholds
NSInteger EQRThresholdForDescriptiveNote = 2;
NSInteger EQRThresholdForMinorIssue = 3;
NSInteger EQRThresholdForSeriousIssue = 5;


@implementation EQRGlobals

@end
