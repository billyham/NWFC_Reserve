//
//  EQRGlobals.h
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* EQRApplicationKey;

//renter type Strings
extern NSString* EQRRenterStudent;
extern NSString* EQRRenterFaculty;
extern NSString* EQRRenterStaff;
extern NSString* EQRRenterPublic;
extern NSString* EQRRenterYouth;
extern NSString* EQRRenterInClass;

//error string
extern NSString* EQRErrorCode88888888;

//Notification selectors
extern NSString* EQRVoidScheduleItemObjects;
extern NSString* EQRRefreshEquipTable;
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
//extern NSString* EQREquipUniqueToBeDeleted;
//extern NSString* EQREquipUniqueToBeDeletedCancel;
extern NSString* EQRJoinToBeDeletedInCheckInOut;
extern NSString* EQRJoinToBeDeletedInCheckInOutCancel;
extern NSString* EQRLongPressOnNestedDayCell;
extern NSString* EQRPartialRefreshToItineraryArray;
extern NSString* EQRQRCodeFlipsSwitchInRowCellContent;
extern NSString* EQRRefreshViewWhenOrientationRotates;
extern NSString* EQRDistIDPickerTapped;

//Timing
extern float EQRHighlightTappingTime;
extern float EQRResizingCollectionViewTime;

//Top View column size
extern float EQRRentorTypeLeadingSpace;

//Schedule collection view cell size
extern float EQRScheduleItemWidthForDay;
extern float EQRScheduleItemWidthForDayNarrow;
extern float EQRScheduleItemHeightForDay;
extern float EQRScheduleLengthOfEquipUniqueLabel;

//Schedule view by category or subcategory
extern NSString* EQRScheduleGrouping;

//application options
extern BOOL EQRDisableTimeLimitForRequest;
extern BOOL EQRIncludeQRCodeReader;

//service issue thresholds
extern NSInteger EQRThresholdForDescriptiveNote;
extern NSInteger EQRThresholdForMinorIssue;
extern NSInteger EQRThresholdForSeriousIssue;



@interface EQRGlobals : NSObject


@end
