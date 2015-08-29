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
#import "EQRMiscJoin.h"

@implementation EQRDataStructure


#pragma mark - methods

+(EQRDataStructure*)sharedInstance{
    
    static EQRDataStructure* myInstance = nil;
    
    if (!myInstance){
        
        myInstance = [[EQRDataStructure alloc] init];
    }
    
    return myInstance;
}


+(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray withMiscJoins:(NSArray*)arrayOfMisc{
    
    //attach a MISCELLANEOUS section...
    //after sorting
    //needs schedule_grouping value?
    //add NSArray parameter with objects (name),
    //... needs Join attributes: scheduleTracking_foreignKey, prep_flag, etc_flags...
    //... OR provides NSString parameter with scheduleTracking key to pull related objects from database

    
    NSArray* regularArray = [self turnFlatArrayToStructuredArrayTheOldWay:flatArray];

    NSMutableArray* sortedTopArrayWithMisc = [NSMutableArray arrayWithCapacity:1];
    [sortedTopArrayWithMisc addObjectsFromArray:regularArray];

    if ([arrayOfMisc count] > 0){
        //_______!!!!!  add miscJoin ites   !!!!!!________
        [sortedTopArrayWithMisc addObject:arrayOfMisc];
    }
    
    return sortedTopArrayWithMisc;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray{

    //first get array of grouping objects
    //get title items EQGetEquipmentTitlesAll (except items with hide_from_public set to YES)
    __block NSMutableSet* tempMuteSetOfGroupingStrings = [NSMutableSet setWithCapacity:1];
    __block NSMutableDictionary* tempMuteDicOfTitleKeysToGrouping = [NSMutableDictionary dictionaryWithCapacity:1];
    
    
        //______!!!!!!!!!     METHOD 1, THE SLOW WAY    !!!!!!!!!!!!!
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
//        
//        //loop through entire title item array
//        for (EQREquipItem* item in muteArray){
//            
//            //add item's schedule_grouping to the dictionary
//            [tempMuteDicOfTitleKeysToGrouping setValue:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]forKey:item.key_id];
//            
//            BOOL foundTitleDontAdd = NO;
//            
//            for (NSString* titleString in tempMuteSetOfGroupingStrings){
//                
//                //identify items with schedule _grouping already in our muteable array
//                if ([[item performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:titleString]){
//                    
//                    foundTitleDontAdd = YES;
//                    break;
//                }
//            }
//            
//            //advance to next title item
//            if (foundTitleDontAdd == NO){
//                
//                //otherwise add grouping in set
//                [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
//            }
//        }
//    }];
    
    
    //______!!!!!!!!!     METHOD 2, THE FAST WAY    !!!!!!!!!!!!!
    for (EQRScheduleTracking_EquipmentUnique_Join* item in flatArray){
        
        //add item's schedule_grouping to the dictionary
        [tempMuteDicOfTitleKeysToGrouping setValue:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]forKey:item.equipTitleItem_foreignKey];
        
        BOOL foundTitleDontAdd = NO;
        
        for (NSString* titleString in tempMuteSetOfGroupingStrings){
            
            //identify items with schedule _grouping already in our muteable array
            if ([[item performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:titleString]){
                
                foundTitleDontAdd = YES;
                break;
            }
        }
        
        //advance to next title item
        if (foundTitleDontAdd == NO){
            
            //otherwise add grouping in set
            [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
        }
    }
    
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
                //_____need to accommodate dist ids in the hundreds.
                
                //______first change the single digits...
                
                //if dist id is only one character in length, add a 0 to the start.
                if ([string3 length] < 2){
                    string3 = [NSString stringWithFormat:@"00%@", string3];
                }
                if ([string4 length] < 2){
                    string4 = [NSString stringWithFormat:@"00%@", string4];
                }
                
                //______next change the double digits...
                
                //if dist id is only one character in length, add a 0 to the start.
                if ([string3 length] < 3){
                    string3 = [NSString stringWithFormat:@"0%@", string3];
                }
                if ([string4 length] < 3){
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


+(NSArray*)turnFlatArrayToStructuredArrayTheOldWay:(NSArray*)flatArray{
    
    //first get array of grouping objects
    //get title items EQGetEquipmentTitlesAll (except items with hide_from_public set to YES)
    __block NSMutableSet* tempMuteSetOfGroupingStrings = [NSMutableSet setWithCapacity:1];
    __block NSMutableDictionary* tempMuteDicOfTitleKeysToGrouping = [NSMutableDictionary dictionaryWithCapacity:1];
    
    
    //______!!!!!!!!!     METHOD 1, THE SLOW WAY    !!!!!!!!!!!!!
    EQRWebData* webData = [EQRWebData sharedInstance];
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
                    break;
                }
            }
            
            //advance to next title item
            if (foundTitleDontAdd == NO){
                
                //otherwise add grouping in set
                [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
            }
        }
    }];
    
    
    //______!!!!!!!!!     METHOD 2, THE FAST WAY    !!!!!!!!!!!!!
    //    for (EQRScheduleTracking_EquipmentUnique_Join* item in flatArray){
    //
    //        //add item's schedule_grouping to the dictionary
    //        [tempMuteDicOfTitleKeysToGrouping setValue:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]forKey:item.equipTitleItem_foreignKey];
    //
    //        BOOL foundTitleDontAdd = NO;
    //
    //        for (NSString* titleString in tempMuteSetOfGroupingStrings){
    //
    //            //identify items with schedule _grouping already in our muteable array
    //            if ([[item performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:titleString]){
    //
    //                foundTitleDontAdd = YES;
    //                break;
    //            }
    //        }
    //
    //        //advance to next title item
    //        if (foundTitleDontAdd == NO){
    //
    //            //otherwise add grouping in set
    //            [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
    //        }
    //    }
    
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

+(NSDate*)dateWithoutTimeFromString:(NSString*)dateString{
    
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *returnDate = [dateFormatForDate dateFromString:dateString];
    return  returnDate;
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

+(NSString*)emailValidationAndSecureForDisplay:(NSString*)email{
    
    if (email == nil || [email isEqualToString:@""]){
        return nil;
    }
    
    //if it ends in @ or . call it out, or the following will crash it
    NSString* finalCharacter = [email substringFromIndex:[email length] - 1];
    if ([finalCharacter isEqualToString:@"@"] || [finalCharacter isEqualToString:@"."]){
        return nil;
    }
    
    NSString* emailForDisplay;
    NSRange atRange = [email rangeOfString:@"@"];
    NSRange dotRange = [email rangeOfString:@"."];
    
    //error when no @ or .
    if ((atRange.location == NSNotFound) || (dotRange.location == NSNotFound)){
        return nil;
    }
    
    //error if . comes before @
//    if (atRange.location > dotRange.location){
//        return nil;
//    }
    
    NSRange atRangeError = [[email substringFromIndex:atRange.location + 1] rangeOfString:@"@"];
//    NSRange dotRangeError = [[email substringFromIndex:dotRange.location + 1] rangeOfString:@"."];
    
    //error when too many @ or . 's
    if (atRangeError.location != NSNotFound){
        return nil;
    }
    
//    if (dotRangeError.location != NSNotFound){
//        return  nil;
//    }
    
    //__1__
//    NSInteger firstTwoLettersLength = 2;
//    NSInteger lengthOfDots1 = atRange.location - 2;
//    if (lengthOfDots1 < 0) { //when address name is one letter long
//        lengthOfDots1 = 0;
//        firstTwoLettersLength = 1;
//    }
//    
//    NSString* firstTwoLetters = [email substringToIndex:firstTwoLettersLength];
//    
//    int i;
//    NSMutableString *stringOfDots1  = [NSMutableString stringWithString:@""];
//    for (i=0 ; i < lengthOfDots1 ; i++){
//        [stringOfDots1 appendString:@"●"];
//    }
//    
//    NSInteger lengthOfDots2 = dotRange.location - atRange.location - 2;
//    int n;
//    NSMutableString *stringOfDots2 = [NSMutableString stringWithString:@""];
//    for (n=0 ; n < lengthOfDots2 ; n++){
//        [stringOfDots2 appendString:@"●"];
//    }
//    
//    NSString *firstLetterAfterAt = [email substringWithRange:NSMakeRange(atRange.location + 1, 1)];
//    NSString *lettersAfterDot = [email substringFromIndex:dotRange.location];
//    
//    emailForDisplay = [NSString stringWithFormat:@"%@%@@%@%@%@", firstTwoLetters, stringOfDots1, firstLetterAfterAt, stringOfDots2, lettersAfterDot];
    
    
    //__2__ better
    NSInteger lengthOfDots1 = atRange.location;
    int i;
    NSMutableString *stringOfDots1  = [NSMutableString stringWithString:@""];
    for (i=0 ; i < lengthOfDots1 ; i++){
        [stringOfDots1 appendString:@"●"];
    }
    
    NSString *lettersAfterAt = [email substringFromIndex:atRange.location];
    
    emailForDisplay = [NSString stringWithFormat:@"%@%@", stringOfDots1, lettersAfterAt];
    
    
    return emailForDisplay;
}

+(NSString*)phoneValidationAndSecureForDisplay:(NSString*)phone{
    
    if ((phone == nil) || ([phone isEqualToString:@""])){
        return nil;
    }
    
    //remove spaces, dashes, paranthesis, dots, en dashes, em dashes
    NSString *phoneForDisplay;
    NSString *string1 = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *string2 = [string1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *string3 = [string2 stringByReplacingOccurrencesOfString:@"(" withString:@""];
    NSString *string4 = [string3 stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSString *string5 = [string4 stringByReplacingOccurrencesOfString:@"–" withString:@""];
    NSString *string6 = [string5 stringByReplacingOccurrencesOfString:@"—" withString:@""];
    NSString *phoneClean = [string6 stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSInteger lengthOfPhone = [phoneClean length];
    
    //return nil is less than 10 and more than 11
    if ((lengthOfPhone < 10) || (lengthOfPhone > 11)){
        return nil;
    }
    
    //if first of 11 numbers is not 1, return nil, otherwise drop the 1
    if (lengthOfPhone == 11){
        if ([[phoneClean substringToIndex:1] isEqualToString:@"1"]){
            phoneClean = [phoneClean substringFromIndex:1];
        }else{
            return nil;
        }
    }
    
    //show area code and last two numbers
    NSString *areaCode = [phoneClean substringToIndex:3];
    NSString *prefix = [phoneClean substringWithRange:NSMakeRange(3, 3)];
//    NSString *lastTwo = [phoneClean substringFromIndex:8];
    
    phoneForDisplay = [NSString stringWithFormat:@"(%@) %@–●●●●", areaCode, prefix];
    
    return phoneForDisplay;
}







@end
