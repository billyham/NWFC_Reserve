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

@interface EQRScheduleRequestManager : NSObject

@property (strong, nonatomic) EQRScheduleRequestItem* request;

@property (strong, nonatomic) NSMutableArray* arrayOfEquipTitlesWithCountOfUniqueItems;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipTitleItems;

@property (strong, nonatomic) NSMutableArray* arrayOfEquipUniqueItemsAll;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipUniqueItemsWithSubArrays;
@property (strong, nonatomic) NSMutableArray* arrayOfEquipUniqueItemsByDateCollision;

@property (strong, nonatomic) NSMutableArray* arrayOfEquipSectionsThatShouldBeHidden; //for equip reservation
@property (strong, nonatomic) NSMutableArray* arrayOfEquipSectionsThatShouldBeVisibleInSchedule;

//arrays for schedule of uniqueItems
@property (strong, nonatomic) NSArray* arrayOfMonthScheduleTracking_EquipUnique_Joins;
@property (strong, nonatomic) NSMutableArray* arrayOfRowCellRects;  //???????




+(EQRScheduleRequestManager*)sharedInstance;
-(void)createNewRequest;
-(void)dismissRequest;
-(void)resetEquipListAndAvailableQuantites;
-(NSArray*)retrieveAllEquipUniqueItems;
-(NSArray*)retrieveArrayOfEquipJoins;
-(void)collapseOrExpandSection:(NSString*)chosenSection;
-(void)collapseOrExpandSectionInSchedule:(NSString*)chosenSection;


//_________ **********  THIS SHOULD BE RECEIVING EquipUniqueItem INSTEAD OF titleItems  ********________
-(void)addNewRequestEquipJoin:(EQREquipItem*)thisEquipItem;

-(void)removeRequestEquipJoin:(EQREquipItem*)thisEquipItem;


@end
