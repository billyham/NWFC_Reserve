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
#import "EQREquipItem.h"
#import "EQREquipUniqueItem.h"

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
    
    //attach a MISCELLANEOUS section...
    //after sorting
    //needs schedule_grouping value?
    //add NSArray parameter with objects (name),
    //... needs Join attributes: scheduleTracking_foreignKey, prep_flag, etc_flags...
    //... OR provides NSString parameter with scheduleTracking key to pull related objects from database
    
    
    
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
    
    //Have a comppleted array of arrays. Now need to SORT them
    NSArray* arrayToReturn = [NSArray arrayWithArray:tempTopArray];
    
    //sort sub arrays first, but dist ID
    NSMutableArray* newMuteTopArray = [NSMutableArray arrayWithCapacity:1];
    [arrayToReturn enumerateObjectsUsingBlock:^(NSArray* objArray, NSUInteger idx, BOOL *stop) {
        
        //sort in asending order
        NSArray* sortedSubArray = [objArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            //first, compare on equipTitleItem_foreignKey
            NSString* string1 = [(EQREquipUniqueItem*)obj1 equipTitleItem_foreignKey];
            NSString* string2 = [(EQREquipUniqueItem*)obj2 equipTitleItem_foreignKey];
            
            NSInteger firstComparisonResult = [string1 compare:string2];
            
            //if equipTitleItem_foreignKey is the same, sort using dist id
            if (firstComparisonResult == NSOrderedSame){
                
                NSString* string3 = [(EQREquipUniqueItem*)obj1 distinquishing_id];
                NSString* string4 = [(EQREquipUniqueItem*)obj2 distinquishing_id];
                
                //if dist id is only one character in length, add a 0 to the start.
                if ([string3 length] < 2){
                    string3 = [NSString stringWithFormat:@"0%@", string3];
                }
                
                if ([string4 length] < 2){
                    string4 = [NSString stringWithFormat:@"0%@", string4];
                }
                
                return [string3 compare:string4];
                
            } else {
                
                return firstComparisonResult;
            }
        }];
        
        [newMuteTopArray addObject:sortedSubArray];
    }];
    
    //sort the top array alphabetically by schedule grouping
    NSArray* sortedTopArray = [newMuteTopArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [[(EQRScheduleTracking_EquipmentUnique_Join*)[obj1 objectAtIndex:0] schedule_grouping]
                compare:[(EQRScheduleTracking_EquipmentUnique_Join*)[obj2 objectAtIndex:0] schedule_grouping]];
    }];
    
    return sortedTopArray;
}


//same function for EquipUnqiueItems* but uses category instead of schedule_grouping
+(NSArray*)convertFlatArrayofUniqueItemsToStructureWithCategory:(NSArray*)flatArray{
    
    //first get array of grouping objects
    //get title items EQGetEquipmentTitlesAll (except items with hide_from_public set to YES)
    EQRWebData* webData = [EQRWebData sharedInstance];
    __block NSMutableSet* tempMuteSetOfGroupingStrings = [NSMutableSet setWithCapacity:1];
    __block NSMutableDictionary* tempMuteDicOfTitleKeysToGrouping = [NSMutableDictionary dictionaryWithCapacity:1];
    
    
    [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
        
        //loop through entire title item array
        for (EQREquipItem* item in muteArray){
            
            //add item's category to the dictionary
            [tempMuteDicOfTitleKeysToGrouping setValue:item.category forKey:item.key_id];
            
            BOOL foundTitleDontAdd = NO;
            
            for (NSString* titleString in tempMuteSetOfGroupingStrings){
                
                //identify items with schedule _grouping already in our muteable array
                if ([item.category isEqualToString:titleString]){
                    
                    foundTitleDontAdd = YES;
                }
            }
            
            //advance to next title item
            if (foundTitleDontAdd == NO){
                
                //otherwise add grouping in set
                [tempMuteSetOfGroupingStrings addObject:item.category];
            }
        }
    }];
    
    NSMutableArray* tempTopArray = [NSMutableArray arrayWithCapacity:1];
    
    //loop through ivar array of uniques
    for (EQREquipUniqueItem* uniqueItem in flatArray){
        
        //find a matching key_id
        NSString* groupingString = [tempMuteDicOfTitleKeysToGrouping objectForKey:uniqueItem.equipTitleItem_foreignKey];
        
        //assign to object
        uniqueItem.category = groupingString;
        
        BOOL createNewSubArray = YES;
        
        for (NSMutableArray* subArray in tempTopArray){
            
            if ([uniqueItem.category isEqualToString:[(EQREquipUniqueItem*)[subArray objectAtIndex:0] category]]){
                
                createNewSubArray = NO;
                
                //add join to this subArray
                [subArray addObject:uniqueItem];
            }
        }
        
        if (createNewSubArray == YES){
            
            //create a new array
            NSMutableArray* newArray = [NSMutableArray arrayWithObject:uniqueItem];
            
            //add the subarray to the top array
            [tempTopArray addObject:newArray];
        }
        
    }
    
    //Have a comppleted array of arrays. Now need to SORT them
    NSArray* arrayToReturn = [NSArray arrayWithArray:tempTopArray];
    
    //sort sub arrays first, but dist ID
    NSMutableArray* newMuteTopArray = [NSMutableArray arrayWithCapacity:1];
    [arrayToReturn enumerateObjectsUsingBlock:^(NSArray* objArray, NSUInteger idx, BOOL *stop) {
        
        //sort in asending order
        NSArray* sortedSubArray = [objArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            //first, compare on equipTitleItem_foreignKey
            NSString* string1 = [(EQREquipUniqueItem*)obj1 equipTitleItem_foreignKey];
            NSString* string2 = [(EQREquipUniqueItem*)obj2 equipTitleItem_foreignKey];
            
            NSInteger firstComparisonResult = [string1 compare:string2];
            
            //if equipTitleItem_foreignKey is the same, sort using dist id
            if (firstComparisonResult == NSOrderedSame){
                
                NSString* string3 = [(EQREquipUniqueItem*)obj1 distinquishing_id];
                NSString* string4 = [(EQREquipUniqueItem*)obj2 distinquishing_id];
                
                //if dist id is only one character in length, add a 0 to the start.
                if ([string3 length] < 2){
                    string3 = [NSString stringWithFormat:@"0%@", string3];
                }
                
                if ([string4 length] < 2){
                    string4 = [NSString stringWithFormat:@"0%@", string4];
                }
                
                return [string3 compare:string4];
                
            } else {
                
                return firstComparisonResult;
            }
        }];
        
        [newMuteTopArray addObject:sortedSubArray];
    }];
    
    //sort the top array alphabetically by schedule grouping
    NSArray* sortedTopArray = [newMuteTopArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [[(EQREquipUniqueItem*)[obj1 objectAtIndex:0] category]
                compare:[(EQREquipUniqueItem*)[obj2 objectAtIndex:0] category]];
    }];
    
    return sortedTopArray;
}


#pragma clang diagnostic pop


//enter arary of Schedule_Equip_Joins and get array of dictionaries with two items:
//key "equipTitleObject" and value is EquipTitleItem object
//key "quantity" and value is NSNumber
+(NSArray*)decomposeJoinsToEquipTitlesWithQuantities:(NSArray*)EquipJoins{
    
    //arrayOfJoins, use equipTitleItem_foreignKey
    
    //1.
    //create a mutearray with mutearrays as its objects, the sub array has equipTitle_ForeignKeys
    NSMutableArray* tempArrayOfArrays = [NSMutableArray arrayWithCapacity:1];
    
    //loop through the array of joins
    for (EQRScheduleTracking_EquipmentUnique_Join* join in EquipJoins){
        
        //test if the titleKey is currently in the tempArray
        BOOL isAnExistingTitle = NO;
        
        //loop through tempArray
        for (NSMutableArray* subArray in tempArrayOfArrays){
            
            if ([join.equipTitleItem_foreignKey isEqualToString:(NSString*)[subArray objectAtIndex:0]]){
                
                //found a match, add this join's equipTitle_foreignKey as another object in the subarray
                isAnExistingTitle = YES;
                
                //try adding it here and now???
                [subArray addObject:join.equipTitleItem_foreignKey];
                
                //_____????  Is this break OK???_____ Yes. Yes it is.
                break;
            }
        }
    
        //if no match was found, create a new muteArray with this key
        if (isAnExistingTitle == NO){
            
            [tempArrayOfArrays addObject:[NSMutableArray arrayWithObject:join.equipTitleItem_foreignKey]];
        }
    }
    

    //2.
    //now enumerate through that array and count up the objects in each subarray and query for the object from the foreign key
    
    NSMutableArray* arrayToReturn = [NSMutableArray arrayWithCapacity:1];

    for (NSMutableArray* subMuteArray in tempArrayOfArrays){
        
        NSNumber* qty = [NSNumber numberWithInt:(int)[subMuteArray count]];
        
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", [subMuteArray objectAtIndex:0], nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
        NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetEquipmentTitles.php" parameters:topArray class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
           
            for (EQREquipItem* item in muteArray){
                
                [tempMuteArray addObject:item];
            }
        }];
        
        //declare the equipItem
        EQREquipItem* equipItem;
        
        if ([tempMuteArray count] > 0){
            
            equipItem = [tempMuteArray objectAtIndex:0];
        } else {
            
            //error handling an object is not returned
            NSLog(@"DataStructure > decomposeJoins failed to find a matching title item");
            
            return nil;
        }
        
        NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                equipItem, @"equipTitleObject",
                                qty, @"quantity",
                                nil];
        
        //add this dic to the returnArray
        [arrayToReturn addObject:newDic];
        
    }
    
    return [NSArray arrayWithArray:arrayToReturn];
}


+(NSString*)dateAsString:(NSDate*)myDate{
    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateString = [dateFormatForDate stringFromDate:myDate];
    
    return dateString;
    
}

+(NSString*)dateAsStringSansTime:(NSDate*)myDate{
    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateString = [dateFormatForDate stringFromDate:myDate];
    
    return dateString;
    
}


+(NSString*)timeAsString:(NSDate*)myDate{
    
    //format the time to a mysql compatible string, dropping the seconds
    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForTime setLocale:usLocale];
    [dateFormatForTime setDateFormat:@"HH:mm"];
    NSString* timeStringPartOne = [dateFormatForTime stringFromDate:myDate];
    NSString* timeString = [NSString stringWithFormat:@"%@:00", timeStringPartOne];
    
    return timeString;
    
}

+(NSDate*)dateFromCombinedDay:(NSDate*)myDay And8HourShiftedTime:(NSDate*)myTime{
    
    //add times to dates
    NSDate* newDate = [myDay dateByAddingTimeInterval: [myTime timeIntervalSinceReferenceDate]];
    
    //______adjust by subtracting 8 hours
    float secondsForOffset = -28800;    //this is 9 hours = 32400, this is 8 hours = 28800;
    NSDate* newAdjustedDate = [newDate dateByAddingTimeInterval:secondsForOffset];
    
    return newAdjustedDate;
}


//+(NSDate*)dateFromCombinedDay:(NSDate*)myDay AndTime:(NSDate*)myTime{
//    
//    //add times to dates
//    NSDate* newDate = [myDay dateByAddingTimeInterval:[myTime timeIntervalSinceReferenceDate]];
//    
//    return newDate;
//}


+(NSDate*)dateByStrippingOffTime:(NSDate*)myDate{
    
    NSString* dateAsString = [self dateAsStringSansTime:myDate];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDate* newDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", dateAsString]];
    
    return newDate;
    
}

+(NSDate*)timeByStrippingOffDate:(NSDate*)myDate{
    
    NSString* timeAsString = [self timeAsString:myDate];
    
    //piggy back the time by adding it to the system reference date
    float secondsFromHours = [[timeAsString substringToIndex:2] floatValue] * 60 * 60;
    float secondsFromMinutes = [[timeAsString substringWithRange:NSMakeRange(3, 2)] floatValue] * 60;
    float combinedSeconds = secondsFromHours + secondsFromMinutes;
    NSDate* referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:combinedSeconds];
    
    //______adjust by 8 hours
    float secondsForOffset = 28800;    //this is 9 hours = 32400, this is 8 hours = 28800, this is 16 hours = 57600
    NSDate* timeAdjustedReferenceDate = [referenceDate dateByAddingTimeInterval:secondsForOffset];
    
    return timeAdjustedReferenceDate;
}







@end
