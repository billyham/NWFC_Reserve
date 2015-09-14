//
//  EQRReqeustDatesAndEquipListVM.h
//  Gear
//
//  Created by Ray Smith on 9/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRScheduleRequestItem.h"


@interface EQRReqeustDatesAndEquipListVM : NSObject

//what i need
//@property (strong, nonatomic) EQRScheduleRequestItem *requestItem;
//@property (strong, nonatomic) NSArray *arrayOfEquip;
//@property (strong, nonatomic) NSArray *arrayOfMisc;

//what i give
@property (strong, nonatomic) NSAttributedString *summaryString;

+(NSAttributedString *)getSummaryTextWithRequest:(EQRScheduleRequestItem *)requestItem ArrayOfMisc:(NSArray *)arrayOfMisc;

//-(instancetype)initWithRequest:(EQRScheduleRequestItem *)requestItem ArrayOfEquip:(NSArray *)arrayOfEquip ArrayOfMisc:(NSArray *)arrayOfMisc;

@end
