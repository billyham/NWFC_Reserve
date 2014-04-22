//
//  EQRScheduleRequestManager.m
//  NWFC Reserve
//
//  Created by Ray Smith on 12/31/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleRequestManager.h"
#import "EQRGlobals.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRWebData.h"
#import "EQREquipUniqueItem.h"
#import "EQRWebData.h"

@implementation EQRScheduleRequestManager


+(EQRScheduleRequestManager*)sharedInstance{
    
    static EQRScheduleRequestManager* myInstance = nil;
    
    if (!myInstance){
        
        myInstance = [[EQRScheduleRequestManager alloc] init];
    }
    
    return myInstance;
}


-(void)createNewRequest{
    
    EQRScheduleRequestItem* requestItem = [[EQRScheduleRequestItem alloc] init];
    
    //assign to ivar
    self.request = requestItem;
    
    //set flags
    self.request.showAllEquipmentFlag = NO;
    
    //set timestamp
    self.request.time_of_request = [NSDate date];
    
    //ensure the array of hidden sections exists
    if (!self.arrayOfEquipSectionsThatShouldBeHidden){
        
        self.arrayOfEquipSectionsThatShouldBeHidden = [NSMutableArray arrayWithCapacity:1];
    }
    
    //emply out array of hidden sections
    [self.arrayOfEquipSectionsThatShouldBeHidden removeAllObjects];
    
    //get device name
    NSString* myDeviceName = [[UIDevice currentDevice] name];
    NSLog(@"this is my device name: %@", myDeviceName);
    
    NSArray* bigPoppa = [NSArray arrayWithObjects:@"myDeviceName", myDeviceName, nil];
    NSArray* lilPoppa = [NSArray arrayWithObject:bigPoppa];
    
    //--
    //need to set the key_id right away
    //get the next key_id value for a scheduleTracking object
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSString* assignedKeyId = [webData queryForStringWithLink:@"EQRegisterScheduleRequest.php" parameters:lilPoppa];
    
    //set the request's key_id ivar
    self.request.key_id = assignedKeyId;
    NSLog(@"this is the nextKeyIdString %@", assignedKeyId);
    //---
    
    
}


-(void)dismissRequest{
    
    //set request item's properties to nil
//    if(self.request){
//        
//        self.request.classSection_foreignKey = nil;
//        self.request.classTitle_foreignKey = nil;
//        
//    }
    
    //set request item to nil
    self.request = nil;
    
    //void any local ivars that view controllers have established for keeping track of selections and flags
    //send by notification!!
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:self userInfo:nil];
    
}


#pragma mark -  Equipment lists and available quantities

//------------------------

//load list of equipment and total count of related unqiue items
//_______****** note that this is returing EquipUniqueItem objects but then discarding them. maybe keep more info...

-(void)resetEquipListAndAvailableQuantites{
    
    //clean out existing arrays
    if (self.arrayOfEquipTitlesWithCountOfUniqueItems){
        
        [self.arrayOfEquipTitlesWithCountOfUniqueItems removeAllObjects];
    }
    
    if (self.arrayOfEquipUniqueItemsByDateCollision){
        
        [self.arrayOfEquipUniqueItemsByDateCollision removeAllObjects];
    }
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryWithLink:@"EQGetEquipTitlesWithCountOfEquipUniques.php" parameters:nil class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
        
        //organize into a nested array
        NSMutableArray* topArray = [NSMutableArray arrayWithCapacity:1];
        
        for (EQREquipUniqueItem* obj in muteArray){
            
            BOOL foundObjectFlag = NO;
            
            NSString* thisTitleKey = obj.equipTitleItem_foreignKey;
            
            for (NSMutableArray* objArray in topArray){
                
                if ([[objArray objectAtIndex:0] isEqualToString:thisTitleKey]){
                    
                    //replace the existing NSNumber at index 1 by adding one
                    int newInt =  [(NSNumber*)[objArray objectAtIndex:1] intValue] + 1;
                    NSNumber* newNumber = [NSNumber numberWithInt:newInt];
                    [objArray replaceObjectAtIndex:1 withObject:newNumber];
                    
                    foundObjectFlag = YES;
                }
            }
            
            if (!foundObjectFlag){
                
                //didn't find a match, create a new entry for this title item
                NSMutableArray* brandNewArray = [NSMutableArray arrayWithObjects:obj.equipTitleItem_foreignKey, [NSNumber numberWithInt:1], nil];
                
                [topArray addObject:brandNewArray];
            }
        }
        
        //assign newly built array to the requestManager (why again the requestManager???
        self.arrayOfEquipTitlesWithCountOfUniqueItems = topArray;
    }];
    
    
    
    //______A function to add in any items from the list of title equipment where no uniques existed
    //loop through list of existing titleItems. subloop against all uniqueItems and add in where no match is found
    
    
    //_______get the ENTIRE list of equipment titles
    
    //empty out the current ivar
    [self.arrayOfEquipTitleItems removeAllObjects];
    
    NSMutableArray* weirdNewArray = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray2) {
        
        //do something with the returned array...
        //assign array of equipItems to requestManager ivar
        
        
        for (EQREquipItem* meMeMe in muteArray2){
            
            [weirdNewArray addObject:meMeMe];
        }
    }];
    
    self.arrayOfEquipTitleItems = weirdNewArray;
    
    NSLog(@"count of equipTitleItems array: %u", (int)[self.arrayOfEquipTitleItems count]);
    
    //compare the two arrays with title info...
    NSMutableArray* additionalTitles = [NSMutableArray arrayWithCapacity:1];
    
    for (EQREquipItem* equipTitleItem in self.arrayOfEquipTitleItems){
        
        BOOL flagToSkip = NO;
        
        for (NSArray* equipUniqueItemArray in self.arrayOfEquipTitlesWithCountOfUniqueItems){
            
            if ([(NSString*)[equipUniqueItemArray objectAtIndex:0] isEqualToString:equipTitleItem.key_id]){
                
                flagToSkip = YES;
                break;
            }
        }
        
        if (!flagToSkip){
            
            //add title item because it doesn't exist yet
            NSArray* newArrayItem = [NSArray arrayWithObjects:equipTitleItem.key_id, [NSNumber numberWithInt:0], nil];
            [additionalTitles addObject:newArrayItem];
        }
    }
    
    NSLog(@"count of new title items to add: %u", (int)[additionalTitles count]);
    
    //append the requestManager array ivar with the new items
    [self.arrayOfEquipTitlesWithCountOfUniqueItems addObjectsFromArray:additionalTitles];
    
    //---------------------
    
}


-(NSArray*)retrieveAllEquipUniqueItems{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    __block NSArray* arrayToReturn;
    
    [webData queryWithLink:@"EQGetEquipUniqueItemsAll.php" parameters:nil class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
        
        arrayToReturn = [NSArray arrayWithArray:muteArray];
        
    }];
    
    [self.arrayOfEquipUniqueItemsAll removeAllObjects];
    
    //set ivar
    self.arrayOfEquipUniqueItemsAll = [NSMutableArray arrayWithArray:arrayToReturn];
    
    NSLog(@"array of equipUniqueItems count: %u", (int)[self.arrayOfEquipUniqueItemsAll count]);
    
    
    
    
    //______****** add structure the array? nested array's in equipTitleItem id's?
    NSMutableArray* arrayWithSubArrays = [NSMutableArray arrayWithCapacity:1];
    
    for (EQREquipUniqueItem* uItem in self.arrayOfEquipUniqueItemsAll){
        
        
        NSMutableArray* nestedArray = [NSMutableArray arrayWithCapacity:1];
        BOOL gladflag = NO;
        
        for (NSMutableArray*  dutifullyNestedarray in arrayWithSubArrays){
            
            if ([[(EQREquipUniqueItem*)[dutifullyNestedarray objectAtIndex:0] equipTitleItem_foreignKey] isEqualToString:uItem.equipTitleItem_foreignKey] ){
                
                //a match is found with an existing object, add it to the array...
                
                [dutifullyNestedarray addObject:uItem];
                
                gladflag = YES;
            }
        }
        
        if (!gladflag){
            
            //... or else, create a new array and add it to the arrayWithSubArrays
            [nestedArray addObject:uItem];
            
            [arrayWithSubArrays addObject:nestedArray];
        }
    }
    
    //assign to ivar
    self.arrayOfEquipUniqueItemsWithSubArrays = arrayWithSubArrays;
    
    
    //... this is redundant....
    return arrayToReturn;
}



-(NSArray*)retrieveArrayOfEquipJoins{
    
    if ([self.request.arrayOfEquipmentJoins count] > 0){
        
        NSArray* returnArray = [NSArray arrayWithArray:self.request.arrayOfEquipmentJoins];
        
        return returnArray;

    }else{
        
        return nil;
    }
}


//_________ **********  THIS SHOULD BE RECEIVING EquipUniqueItem INSTEAD OF titleItems  ********________
//... OR it does the work of assigning a unique item...
-(void)addNewRequestEquipJoin:(EQREquipItem*)thisEquipItem{
    
    //instantiate new join item
    EQRScheduleTracking_EquipmentUnique_Join* newJoin = [[EQRScheduleTracking_EquipmentUnique_Join alloc] init];
    
    //_________*********  EEEEKKKK!! THIS IS WHERE THE EquipUniqueItem key_id is hardcoded ********______
    newJoin.equipUniqueItem_foreignKey = @"1";
    
    newJoin.equipTitleItem_foreignKey = thisEquipItem.key_id;
    newJoin.scheduleTracking_foreignKey = self.request.key_id;
    
    if (self.request.arrayOfEquipmentJoins){
   
        [[self.request arrayOfEquipmentJoins] addObject:newJoin];
    
    }else{
        
        self.request.arrayOfEquipmentJoins = [NSMutableArray arrayWithCapacity:1];
        
        [[self.request arrayOfEquipmentJoins] addObject:newJoin];
    }
}


-(void)removeRequestEquipJoin:(EQREquipItem*)thisEquipItem{
    
    //find an existing join with a matching equipItem and remove the sucker.
    if (self.request.arrayOfEquipmentJoins){
        
        //a integer for rembembering the flagged index
        NSInteger rememberThisInt= -1;
        
        //loop through the array
        for (EQRScheduleTracking_EquipmentUnique_Join* obj in self.request.arrayOfEquipmentJoins) {
            
            if ([[obj equipTitleItem_foreignKey] isEqualToString:thisEquipItem.key_id]){
                
                rememberThisInt = [self.request.arrayOfEquipmentJoins indexOfObject:obj];
                
                break;
            }
        };
        
        //the removal
        if (rememberThisInt >= 0){
            
            [self.request.arrayOfEquipmentJoins removeObjectAtIndex:rememberThisInt];
        }
    }
}


#pragma mark - gear allocation

-(void)allocateGearListWithDates:(NSDictionary*)datesDic{
    
    //______DATESDIC CAN BE NIL, THEN IS USES DATES ASSIGNED TO THE REQUEST ITEM_____
    
    
    //get a list of uniqueItems that fall within the rental dates.
    //1. get scheduleTracking objects within the dates (sql script?)
    //2. gather matching scheduleTracking_equip_joins (using scheduleTracking_foreignKey in schedule_equipUnique_joins)
    //3. gather key_ids for equipUniqueItems (using equipUniqueItem_foreignKey in scheduleTracking_equipUnique_joins)
    
    //subtract out the quantity of uniqueItems available per titleItems
    //compare with the quantitys requested, then pause and alert user if quantities are exceeded. Identified where excesses are.
    //1. create a subnested array of titleItems with quantities (similar to the requestManager's ivar
    //2. cycle through and add quantities from this request
    //3. cycle through, comparing with titleItem key_ids in requestManager's ivar,
    
    
    //begin and end dates in sql format
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatter stringFromDate:self.request.request_date_begin];
    NSString* dateEndString = [dateFormatter stringFromDate:self.request.request_date_end];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //declare arrays
    NSArray* arrayWithBeginDate;
    NSArray* arrayWithEndDate;
    
    //use request item's dates
    if (datesDic == nil){
        
        arrayWithBeginDate = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
        arrayWithEndDate = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    }else{
        //use the supplied parameter
        
        arrayWithBeginDate =[NSArray arrayWithObjects:@"request_date_begin", [datesDic objectForKey:@"request_date_begin"], nil];
        
        
    }
    
    NSArray* arrayTopDate = [NSArray arrayWithObjects:arrayWithBeginDate, arrayWithEndDate, nil];
    
    NSMutableArray* arrayOfScheduleTrackingKeyIDs = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* arrayOfEquipUniqueItems = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetScheduleItemsInDateRange.php" parameters:arrayTopDate class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        NSLog(@"result from schedule request Date range: %@", muteArray);
        
        //populate array with key_ids
        for (EQRScheduleRequestItem* objKey in muteArray){
            
            [arrayOfScheduleTrackingKeyIDs addObject:objKey];
            
            //cycle through and get equipUniqueItem key IDs
        }
    }];
    
    
    //Use sql with inner join...
    //  get reserved EquipUniqueItem objects With ScheduleTrackingKeys
    
    for (EQRScheduleTracking_EquipmentUnique_Join* objThingy in arrayOfScheduleTrackingKeyIDs){
        
        NSArray* arrayWithTrackingKey = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", objThingy.key_id, nil];
        NSArray* topArrayWithTrackingKey = [NSArray arrayWithObject:arrayWithTrackingKey];
        
        [webData queryWithLink:@"EQGetUniqueItemKeysWithScheduleTrackingKeys.php" parameters:topArrayWithTrackingKey class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray2) {
            
            for (EQREquipUniqueItem* objUniqueItem in muteArray2){
                
                //                NSLog(@"this is EquipUniqueItem key_id: %@  and titleItem key_id: %@ and name: %@",
                //                      objUniqueItem.key_id, objUniqueItem.equipTitleItem_foreignKey, objUniqueItem.name);
                
                [arrayOfEquipUniqueItems addObject:objUniqueItem];
            }
        }];
    }
    
    //assign to requestManager ivar (this is used in EQEquipSummaryVCntrllr > justConfirm method
    self.arrayOfEquipUniqueItemsByDateCollision = arrayOfEquipUniqueItems;
    
    
    //_____*******  add structure to the array by sections with titleKey???
    
    
    //_____********  NOW HAVE ARRAY OF UNIQUEITEMS BUT NOT SAVING IT ANYWHERE YET____*******
    //arrayOfEquipUniqueItems
    
    //SUBTRACT OUT the scheduled gear from the requestManager array of titles with qty count
    //loop through arrayOfEquipUniqueItems
    for (EQREquipUniqueItem* eqritem in arrayOfEquipUniqueItems){
        
        for (NSMutableArray* checkArray in self.arrayOfEquipTitlesWithCountOfUniqueItems){
            
            if ([eqritem.equipTitleItem_foreignKey isEqualToString:[checkArray objectAtIndex:0]] ){
                
                //found a matching title item, now reduce the count of available items by one
                //... but only if the current available quantity is above 0 (to prevent going into negative integers)
                
                if ([(NSNumber*)[checkArray objectAtIndex:1] integerValue] > 0){
                    
                    int newIntValue = [(NSNumber*)[checkArray objectAtIndex:1] intValue] - 1;
                    NSNumber* newNumber = [NSNumber numberWithInt: newIntValue];
                    [checkArray replaceObjectAtIndex:1 withObject:newNumber];
                }
            }
        }
    }
    
}




#pragma mark - repsond to supplementary cell actions

//from request equip selection list
-(void)collapseOrExpandSection:(NSString*)chosenSection WithAll:(BOOL)withAllFlag{
    
    bool hideMeFlag = YES;
//    NSString* objectToRemove;
    NSArray* arrayOfObjectsToRemove;
    NSMutableArray* arrayOfObjectsToAdd = [NSMutableArray arrayWithCapacity:1];
    NSArray* chosenArray;
    
    for (NSString* myObject in self.arrayOfEquipSectionsThatShouldBeHidden){
        
        if ([myObject isEqualToString:chosenSection]){
            
            hideMeFlag = NO;
            
            if (!withAllFlag){
                
                //when only one section is be hidden or revealed
//                objectToRemove = myObject;
                arrayOfObjectsToRemove = [NSArray arrayWithObject:myObject];
            }
        }
    }
    
    
    //__________for ALL hide and expand__________________
    //when all sections are to be revealed
    if (withAllFlag && (hideMeFlag == NO)){
        
        chosenArray = [NSArray arrayWithArray: self.arrayOfEquipSectionsThatShouldBeHidden];
        
        
        //remove all objects from ivar array
        [self.arrayOfEquipSectionsThatShouldBeHidden removeAllObjects];
        
        //inserts objects into colection view
        NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"insert", @"type",
                                 chosenArray, @"sectionArray",
                                 nil];
        
        
        //send note
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshEquipTable object:nil userInfo:thisDic];
        
        return;

    }
    
    //when all sections are to hidden
    //need to use a list of all equipSections (strings) and subtract out the EquipSectionThatShouldBeHidden
    if (withAllFlag && hideMeFlag){
        
        for (NSString* totalCatItem in self.arrayOfEquipTitleCategories){
            
            BOOL shouldAdd = YES;
            
            for (NSString* hiddenCatItem in self.arrayOfEquipSectionsThatShouldBeHidden){
                
                if ([hiddenCatItem isEqualToString:totalCatItem]){
                    
                    shouldAdd = NO;
                    break;
                }
            }
            
            if (shouldAdd) {
                
                [arrayOfObjectsToAdd addObject:totalCatItem];
            }
            
        }
        
        //add all objects not currently hidden to hidden ivar
        [self.arrayOfEquipSectionsThatShouldBeHidden addObjectsFromArray:arrayOfObjectsToAdd];
        
        //delete objects from collection view
        chosenArray = [NSArray arrayWithArray:arrayOfObjectsToAdd];
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"delete", @"type",
                                 chosenArray, @"sectionArray",
                                 nil];
        
        
        //send note
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshEquipTable object:nil userInfo:thisDic];
        
        return;
    }
    
    
    
    //________for individual hide/expand__________
    if (hideMeFlag){
        
        //add object to array
        [self.arrayOfEquipSectionsThatShouldBeHidden addObject:chosenSection];
        
        chosenArray = [NSArray arrayWithObject:chosenSection];
        
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"delete", @"type",
                                    chosenArray, @"sectionArray",
                                      nil];
        
        
        //send note
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshEquipTable object:nil userInfo:thisDic];

        
    }else{
        
        //loop through array
        for (NSString* objectToRemove in arrayOfObjectsToRemove){
            
            //remove object from array
            [self.arrayOfEquipSectionsThatShouldBeHidden removeObject:objectToRemove];
        }
        
        chosenArray = [NSArray arrayWithObject:chosenSection];
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"insert", @"type",
                                 chosenArray, @"sectionArray",
                                 nil];;
        
        //send note
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshEquipTable object:nil userInfo:thisDic];

    }
}




//from schedule
-(void)collapseOrExpandSectionInSchedule:(NSString*)chosenSection{
    
    //ensure the array of visible sections exists
    if (!self.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
        
        self.arrayOfEquipSectionsThatShouldBeVisibleInSchedule = [NSMutableArray arrayWithCapacity:1];
    }

    
    bool hideMeFlag = NO;
    NSString* objectToRemove;
    
    for (NSString* myObject in self.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
        
        if ([myObject isEqualToString:chosenSection]){
            
            hideMeFlag = YES;
            objectToRemove = myObject;
            
            break;
        }
    }
    
    //_____********  must close any currently open sections first, then open the selected one  ********____
    if (!hideMeFlag){
        
        
        //first, remove any existing object to hide them, so only section is visible at a time
        
        //populate a new array with existing object in array
        NSMutableArray* newMuteArray = [NSMutableArray arrayWithArray:self.arrayOfEquipSectionsThatShouldBeVisibleInSchedule];
        
        //remove existing objects from array
        [self.arrayOfEquipSectionsThatShouldBeVisibleInSchedule removeAllObjects];
        
        for (NSString* categoryItem in newMuteArray){
            
            NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"delete", @"type",
                                     categoryItem, @"sectionString",
                                     nil];
            
            //send note to collapse the section
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshScheduleTable object:nil userInfo:thisDic];
            
            //send note to unhighlight the button
            NSDictionary* dic = [NSDictionary dictionaryWithObject:categoryItem forKey:@"sectionString"];
            [[NSNotificationCenter defaultCenter] postNotificationName:EQRButtonUnHighlight object:nil userInfo:dic];
        }

    }
    
    
    if (hideMeFlag){
        
        //remove object from array
        [self.arrayOfEquipSectionsThatShouldBeVisibleInSchedule removeObject:objectToRemove];
        
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"delete", @"type",
                                 chosenSection, @"sectionString",
                                 nil];
        
        
        //send note
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshScheduleTable object:nil userInfo:thisDic];
        
        //send note to unhighlight the button
        NSDictionary* dic = [NSDictionary dictionaryWithObject:chosenSection forKey:@"sectionString"];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRButtonUnHighlight object:nil userInfo:dic];
        
        
    }else{
        
        //show me!
        
        //must add delay to allow time to close the exsiting sections first...
        [self performSelector:@selector(delayedExpandAction:) withObject:chosenSection afterDelay:0.01];
        
        //send note to highlight the button
        NSDictionary* dic = [NSDictionary dictionaryWithObject:chosenSection forKey:@"sectionString"];
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRButtonHighlight object:nil userInfo:dic];
    }
}


-(void) delayedExpandAction:(NSString*)chosenSection{
  
    //add object to array
    [self.arrayOfEquipSectionsThatShouldBeVisibleInSchedule addObject:chosenSection];
    
    
    NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"insert", @"type",
                             chosenSection, @"sectionString",
                             nil];;
    
    //send note
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshScheduleTable object:nil userInfo:thisDic];
    
};








@end
