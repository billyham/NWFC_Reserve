//
//  EQRGlobals.h
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* ApplicationKey;

//Notification selectors
extern NSString* EQRVoidScheduleItemObjects;
extern NSString* EQRRefreshEquipTable;
extern NSString* EQRRefreshScheduleTable;
extern NSString* EQRButtonHighlight;
extern NSString* EQRButtonUnHighlight;
extern NSString* EQRPresentRequestEditor;
extern NSString* EQRAChangeWasMadeToTheSchedule;
extern NSString* EQREquipUniqueToBeDeleted;
extern NSString* EQREquipUniqueToBeDeletedCancel;

//Timing
extern float EQRHighlightTappingTime;
extern float EQRResizingCollectionViewTime;
extern float EQRRentorTypeLeadingSpace;

//Schedule collection view cell size
extern float EQRScheduleItemWidthForDay;
extern float EQRScheduleItemHeightForDay;
extern float EQRScheduleLengthOfEquipUniqueLabel;

//Schedule view by category or subcategory
extern NSString* EQRScheduleGrouping;

extern BOOL EQRDisableTimeLimitForRequest;

//colors?
extern UIColor* EQRNavBarSelected;


@interface EQRGlobals : NSObject


@end
