//
//  EQRScheduleRequestManager.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/31/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRScheduleRequestItem.h"
#import "EQREquipItem.h"
#import "EQREquipItemCell.h"
#import "EQRHeaderCellTemplate.h"
#import "EQRMiscJoin.h"

@protocol EQREquipSelectionDelegate;

typedef void (^BlockWithArray)(NSMutableArray *muteArray);


@interface EQRScheduleRequestManager : NSObject <EQREquipItemCellDelegate, EQRHeaderCellTemplateDelegate>{
    __weak id <EQREquipSelectionDelegate> equipSelectionDelegate;
}

@property (nonatomic, weak) id <EQREquipSelectionDelegate> equipSelectionDelegate;

@property (strong, nonatomic) EQRScheduleRequestItem* request;

@property (strong, nonatomic) NSMutableArray* arrayOfEquipTitlesWithCountOfUniqueItems;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipTitleItems;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipTitleCategories;

@property (strong, nonatomic) NSMutableArray* arrayOfEquipUniqueItemsAll;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipUniqueItemsWithSubArrays;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipUniqueItemsByDateCollision;
@property (strong, nonatomic) NSArray* arrayOfEquipUniqueItemsByExpandedBuffer;

@property (strong, nonatomic) NSMutableArray* arrayOfEquipSectionsThatShouldBeHidden; //for equip reservation
@property (strong, nonatomic) NSMutableArray* arrayOfEquipSectionsThatShouldBeVisibleInSchedule;  //for schedule

//arrays for schedule of uniqueItems
@property (strong, nonatomic) NSArray* arrayOfMonthScheduleTracking_EquipUnique_Joins;
@property (strong, nonatomic) NSMutableArray* arrayOfRowCellRects;  //???????




+(EQRScheduleRequestManager*)sharedInstance;
-(void)createNewRequest:(void (^)(NSString *returnValue))cb;
-(void)dismissRequest:(BOOL)isCanceled;
-(void)resetEquipListAndAvailableQuantites;
-(BOOL)confirmAvailabilityOfTitleItem:(NSString*)equipTitleItem_foreignKey;
-(NSString*)retrieveAnAvailableUniqueKeyFromTitleKey:(NSString*)equipTitleItem_foreignKey;
//-(NSArray*)retrieveAllEquipUniqueItems;
-(void)retrieveAllEquipUniqueItems:(BlockWithArray)cb;
-(void)collapseOrExpandSectionInSchedule:(NSString*)chosenSection;
-(void)allocateGearListWithDates:(NSDictionary*)datesDic;
-(void)justConfirm;


//EQREquipItemCellDelegate protocal methods
-(NSArray*)retrieveArrayOfEquipJoins;
-(NSArray*)retrieveArrayOfEquipTitlesWithCountOfUniqueItems;
-(void)addNewRequestEquipJoin:(EQREquipItem*)thisEquipItem;
-(void)removeRequestEquipJoin:(EQREquipItem*)thisEquipItem;
-(void)emptyTheArrayOfEquipJoins;


//EQRHeaderCellDelegate protocal methods
-(NSArray*)retrieveArrayOfEquipSectionsThatShouldBeHidden;
-(void)collapseOrExpandSection:(NSString*)chosenSection WithAll:(BOOL)withAllFlag;

//Check In/Out methods for obtaining available equipUniqueItems for equipment title
-(NSArray*)retrieveAvailableEquipUniquesForTitleKey:(NSString*)equipTitleItem_foreignKey;

@end

@protocol EQREquipSelectionDelegate

-(void)refreshTheCollectionWithType:(NSString *)type SectionArray:(NSArray *)array;

@end
