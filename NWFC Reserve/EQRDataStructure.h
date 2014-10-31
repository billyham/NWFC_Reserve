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
+(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray;

//enter arary of Schedule_Equip_Joins and get array of dictionaries with two items:
//key "equipTitleObject" and value is EquipTitleItem object
//key "quantity" and value is NSNumber
+(NSArray*)decomposeJoinsToEquipTitlesWithQuantities:(NSArray*)EquipJoins;

@end
