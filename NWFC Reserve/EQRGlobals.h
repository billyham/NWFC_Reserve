//
//  EQRGlobals.h
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//
//

#import <Foundation/Foundation.h>

// Build spec, defaults to NWFC
extern BOOL EQRBuildNWDoc;
extern BOOL EQRBuildPSU;

extern BOOL EQRSuppressDemoColor;

// Logs
extern BOOL EQRLogInputStrings;

// Datastore Settings
extern BOOL EQRUseCoreData;
extern NSString *EQRCloudKitContainer;
extern NSString *EQRRecordZoneStandard;
extern NSString *EQRRecordZoneDemo;

// Renter type Strings
extern NSString* EQRRenterStudent;
extern NSString* EQRRenterFaculty;
extern NSString* EQRRenterStaff;
extern NSString* EQRRenterPublic;
extern NSString* EQRRenterYouth;
extern NSString* EQRRenterInClass;

// Renter pricing type strings
extern NSString *EQRPriceCommerial;
extern NSString *EQRPriceArtist;
extern NSString *EQRPriceStudent;
extern NSString *EQRPriceFaculty;
extern NSString *EQRPriceStaff;

// Exception codes
extern NSString* EQRErrorCode88888888;

// Notification selectors
extern NSString* EQRVoidScheduleItemObjects;
//extern NSString* EQRRefreshEquipTable;
extern NSString* EQRRefreshScheduleTable;
extern NSString* EQRButtonHighlight;
extern NSString* EQRButtonUnHighlight;
extern NSString* EQRPresentScheduleRowQuickView;
extern NSString* EQRPresentItineraryQuickView;
extern NSString* EQRPresentRequestEditorFromSchedule;
extern NSString* EQRPresentRequestEditorFromItinerary;
extern NSString* EQRPresentCheckInOut;
extern NSString* EQRUpdateCheckInOutArrayOfJoins;
extern NSString* EQRMarkItineraryAsCompleteOrNot;
extern NSString* EQRAChangeWasMadeToTheSchedule;
extern NSString *EQRAChangeWasMadeToTheDatabaseSource;
//extern NSString* EQREquipUniqueToBeDeleted;
//extern NSString* EQREquipUniqueToBeDeletedCancel;
extern NSString* EQRJoinToBeDeletedInCheckInOut;
extern NSString* EQRJoinToBeDeletedInCheckInOutCancel;
extern NSString* EQRLongPressOnNestedDayCell;
extern NSString* EQRPartialRefreshToItineraryArray;
extern NSString* EQRQRCodeFlipsSwitchInRowCellContent;
extern NSString* EQRRefreshViewWhenOrientationRotates;
extern NSString* EQRDistIDPickerTapped;
extern NSString *EQRUpdateHeaderCellsInEquipSelection;

// Timing
extern float EQRHighlightTappingTime;
extern float EQRResizingCollectionViewTime;

// Top View column size
extern float EQRRentorTypeLeadingSpace;

// Schedule collection view cell size
extern float EQRScheduleItemWidthForDay;
extern float EQRScheduleItemWidthForDayNarrow;
extern float EQRScheduleItemHeightForDay;
extern float EQRScheduleLengthOfEquipUniqueLabel;

// Schedule view by category or subcategory
extern NSString* EQRScheduleGrouping;

// Application options
extern NSString* EQRApplicationKey;
extern BOOL EQRDisableTimeLimitForRequest;
extern BOOL EQRIncludeQRCodeReader;
extern BOOL EQRAllowHardcodedPassword;
extern NSString* EQRHardcodedPassword;
extern BOOL EQRRandomizeEquipSelection;

// Service issue thresholds
extern NSInteger EQRThresholdForDescriptiveNote;
extern NSInteger EQRThresholdForMinorIssue;
extern NSInteger EQRThresholdForSeriousIssue;



@interface EQRGlobals : NSObject


@end
