//
//  EQRDataStructure.m
//  NWFC Reserve
//
//  Created by Ray Smith on 9/10/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRDataStructure.h"
#import "EQRWebData.h"
#import "EQREquipItem.h"
#import "EQRGlobals.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"

@implementation EQRDataStructure


#pragma mark - methods

+(EQRDataStructure*)sharedInstance{
    
    static EQRDataStructure* myInstance = nil;
    
    if (!myInstance){
        
        myInstance = [[EQRDataStructure alloc] init];
    }
    
    return myInstance;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray{
    
    //first get array of grouping objects
    //get title items EQGetEquipmentTitlesAll (except items with hide_from_public set to YES)
    EQRWebData* webData = [EQRWebData sharedInstance];
    __block NSMutableSet* tempMuteSetOfGroupingStrings = [NSMutableSet setWithCapacity:1];
    __block NSMutableDictionary* tempMuteDicOfTitleKeysToGrouping = [NSMutableDictionary dictionaryWithCapacity:1];
    
    
    [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
        
        //loop through entire title item array
        for (EQREquipItem* item in muteArray){
            
            //add item's schedule_grouping to the dictionary
            [tempMuteDicOfTitleKeysToGrouping setValue:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]forKey:item.key_id];
            
            BOOL foundTitleDontAdd = NO;
            
            for (NSString* titleString in tempMuteSetOfGroupingStrings){
                
                //identify items with schedule _grouping already in our muteable array
                if ([[item performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:titleString]){
                    
                    foundTitleDontAdd = YES;
                }
            }
            
            //advance to next title item
            if (foundTitleDontAdd == NO){
                
                //otherwise add grouping in set
                [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
            }
        }
    }];
    
    NSMutableArray* tempTopArray = [NSMutableArray arrayWithCapacity:1];
    
    //loop through ivar array of joins
    for (EQRScheduleTracking_EquipmentUnique_Join* join in flatArray){
        
        //find a matching key_id
        NSString* groupingString = [tempMuteDicOfTitleKeysToGrouping objectForKey:join.equipTitleItem_foreignKey];
        
        //assign to join object
        join.schedule_grouping = groupingString;
        
        BOOL createNewSubArray = YES;
        
        for (NSMutableArray* subArray in tempTopArray){
            
            if ([join.schedule_grouping isEqualToString:[(EQRScheduleTracking_EquipmentUnique_Join*)[subArray objectAtIndex:0] schedule_grouping]]){
                
                createNewSubArray = NO;
                
                //add join to this subArray
                [subArray addObject:join];
            }
        }
        
        if (createNewSubArray == YES){
            
            //create a new array
            NSMutableArray* newArray = [NSMutableArray arrayWithObject:join];
            
            //add the subarray to the top array
            [tempTopArray addObject:newArray];
        }
        
    }
    
    NSArray* arrayToReturn = [NSArray arrayWithArray:tempTopArray];
    
    //sort the array alphabetically
    NSArray* sortedTopArray = [arrayToReturn sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [[(EQRScheduleTracking_EquipmentUnique_Join*)[obj1 objectAtIndex:0] schedule_grouping]
                compare:[(EQRScheduleTracking_EquipmentUnique_Join*)[obj2 objectAtIndex:0] schedule_grouping]];
    }];
    
    return sortedTopArray;
}

#pragma clang diagnostic pop


@end
