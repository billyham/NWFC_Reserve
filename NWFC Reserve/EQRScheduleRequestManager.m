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


@interface EQRScheduleRequestManager ()

@property (strong, nonatomic) NSArray* arrayOfEquipUniquesAfterCollisionSubraction;


@end

@implementation EQRScheduleRequestManager

@synthesize equipSelectionDelegate;

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
    
    //empty out array of hidden sections
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


-(void)dismissRequest:(BOOL)isCanceled{
    
    //set request item's properties to nil
//    if(self.request){
//        
//        self.request.classSection_foreignKey = nil;
//        self.request.classTitle_foreignKey = nil;
//        
//    }

    if (isCanceled == YES){
        
        //notes will have been saved immediately to the data layer
        //must alter the existing scheduleRequest to eliminate any notes
        //update data layer
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.request.key_id, nil];
        NSArray* secondArray = [NSArray arrayWithObjects:@"notes", @"", nil];
        NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
        [webData queryForStringWithLink:@"EQAlterNotesInScheduleRequest.php" parameters:topArray];
        
        
        //and also, go to data layer to delete miscJoins
        //go to data layer, enter the scheduleRequest key and delete items with php call
        NSArray* alphaArray = @[@"scheduleTracking_foreignKey", self.request.key_id];
        NSArray* omegaArray = @[alphaArray];
        [webData queryForStringWithLink:@"EQDeleteAllMiscJoinsWithScheduleKey.php" parameters:omegaArray];
        
        //____!!!!!!!  also delete any transaction that has a matching scheduleRequest_foreignKey  !!!!!_____
        
    }
    
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
    
    //whether or not to include equipment that is damaged and needs repair
    BOOL allowSeriousServiceIssueFlag = self.request.allowSeriousServiceIssueFlag;
    
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
                    
                    //prevent the addition of this item if its broken and flag is up
                    if ((allowSeriousServiceIssueFlag == NO) && ([obj.status_level integerValue] >= EQRThresholdForSeriousIssue)){
                        
                        foundObjectFlag = YES;
                        break;
                        
                    }else{  //otherwise continue by upticking the item count
                    
                        //replace the existing NSNumber at index 1 by adding one
                        int newInt =  [(NSNumber*)[objArray objectAtIndex:1] intValue] + 1;
                        NSNumber* newNumber = [NSNumber numberWithInt:newInt];
                        [objArray replaceObjectAtIndex:1 withObject:newNumber];
                    }
                    
                    foundObjectFlag = YES;
                    
                    //found a match so exit the inner loop
                    break;
                }
            }
            
            if (!foundObjectFlag){
                
                //prevent the addition of this item if its broken and flag is up
                if ((allowSeriousServiceIssueFlag == NO) && ([obj.status_level integerValue] >= EQRThresholdForSeriousIssue)){
                    
                    //dont' add this item, it's busted
                    
                }else{
                    
                    //didn't find a match, create a new entry for this title item
                    NSMutableArray* brandNewArray = [NSMutableArray arrayWithObjects:obj.equipTitleItem_foreignKey, [NSNumber numberWithInt:1], nil];
                    
                    [topArray addObject:brandNewArray];
                }
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
    
//    NSLog(@"count of equipTitleItems array: %u", (int)[self.arrayOfEquipTitleItems count]);
    
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
    
//    NSLog(@"count of new title items to add: %u", (int)[additionalTitles count]);
    
    //append the requestManager array ivar with the new items
    [self.arrayOfEquipTitlesWithCountOfUniqueItems addObjectsFromArray:additionalTitles];
    
    //---------------------
    
}


-(BOOL)confirmAvailabilityOfTitleItem:(NSString*)equipTitleItem_foreignKey{
    
    //_____ Must call allocateGearListWithDates method before using this method ____
    //iterate through local array
    int numberOfAvailableItems = 0;
    for (NSArray* subArray in self.arrayOfEquipTitlesWithCountOfUniqueItems){
        
        if ([(NSString*)[subArray objectAtIndex:0] isEqualToString:equipTitleItem_foreignKey]){
            
            numberOfAvailableItems = [(NSNumber*)[subArray objectAtIndex:1] intValue];
            break;
        }
    }
    
    if (numberOfAvailableItems > 0){
        return YES;
    }else{
        return NO;
    }
}


-(NSString*)retrieveAnAvailableUniqueKeyFromTitleKey:(NSString*)equipTitleItem_foreignKey{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* firstArray = @[@"equipTitleItem_foreignKey", equipTitleItem_foreignKey];
    NSArray* topArray = @[firstArray];
    [webData queryWithLink:@"EQGetEquipUniquesWithEquipTitleKey" parameters:topArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
       
        for (id object in muteArray){
            [tempMuteArray addObject:object];
        }
    }];
    
//    NSLog(@"count of tempMuteArray: %u", [tempMuteArray count]);
    if ([tempMuteArray count] < 1){
        //error handling when no items are returned
        return nil;
    }
    
    //reduce result by matching items in self.arrayOfEquipUniqueItemsByDateCollision
    //__1__ identify any corresponding
    NSMutableArray* arrayOfJustMatchingTitles = [NSMutableArray arrayWithCapacity:1];
    for (EQREquipUniqueItem* item in self.arrayOfEquipUniqueItemsByDateCollision){
        if ([item.equipTitleItem_foreignKey isEqualToString:equipTitleItem_foreignKey]){
            [arrayOfJustMatchingTitles addObject:item];
        }
    }
//        NSLog(@"count of arrayOfJustMatchingTitle: %u", [arrayOfJustMatchingTitles count]);
    
    NSMutableArray* arrayOfUniqueObjectsToBeRemoved = [NSMutableArray arrayWithCapacity:1];
    for (EQREquipUniqueItem* equipUniqueItemObject in tempMuteArray){
        
        for (EQREquipUniqueItem* equipUniqueFromJustMatching in arrayOfJustMatchingTitles){
            
            if ([equipUniqueItemObject.key_id isEqualToString:equipUniqueFromJustMatching.key_id]){
                
                [arrayOfUniqueObjectsToBeRemoved addObject:equipUniqueItemObject];
                break;
            }
        }
    }
//    NSLog(@"count of arrayOfUniqueObjectsToBeRemoved: %u", [arrayOfUniqueObjectsToBeRemoved count]);
    //remove them objects (if there are any)
    if ([arrayOfUniqueObjectsToBeRemoved count] > 0){
        [tempMuteArray removeObjectsInArray:arrayOfUniqueObjectsToBeRemoved];
    }
//        NSLog(@"RE-count of tempMuteArray: %u", [tempMuteArray count]);
    
    //pick the unique at the bottom of the stack
    return [(EQREquipUniqueItem*)[tempMuteArray objectAtIndex:0] key_id];
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


-(NSArray*)retrieveArrayOfEquipTitlesWithCountOfUniqueItems{
    
    if (self.arrayOfEquipTitlesWithCountOfUniqueItems){
        
        return self.arrayOfEquipTitlesWithCountOfUniqueItems;
    } else {
        
        return nil;
    }
}


-(NSArray*)retrieveArrayOfEquipSectionsThatShouldBeHidden{
    
    if (self.arrayOfEquipSectionsThatShouldBeHidden){
        
        return self.arrayOfEquipSectionsThatShouldBeHidden;
    } else {
        
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
    newJoin.schedule_grouping = thisEquipItem.schedule_grouping;
    
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

-(void)emptyTheArrayOfEquipJoins{
    
    [self.request.arrayOfEquipmentJoins removeAllObjects];
}


#pragma mark - equipment update fulfillment


-(void)justConfirm{
    
    //    NSLog(@"this is the contact_foreignKey: %@", [NSString stringWithFormat:@"%@", request.contact_foreignKey]);
    
    
    //________A PROVISION THAT PUTS ITEMS SCHEDULED ONLY A DAY AWAY AT THE BOTTOM OF THE STACK
    //set ivar array of equipUniques to avoid scheduling equipment that is one day away from this request
    [self allocateGearListWithExpandedDatesForBufferZoneWithBeginDate:self.request.request_date_begin EndDate:self.request.request_date_end];
    
    
    //must not include nil objects in array
    //cycle though all inputs and ensure some object is included. use @"88888888" as an error code
    if (!self.request.contact_foreignKey) self.request.contact_foreignKey = EQRErrorCode88888888;
    if (!self.request.classSection_foreignKey) self.request.classSection_foreignKey = EQRErrorCode88888888;
    if (!self.request.classTitle_foreignKey) self.request.classTitle_foreignKey = EQRErrorCode88888888;
    if (!self.request.request_date_begin) self.request.request_date_begin = [NSDate date];
    if (!self.request.request_date_end) self.request.request_date_end = [NSDate date];
    if (!self.request.contact_name) self.request.contact_name = EQRErrorCode88888888;
    if (!self.request.notes) self.request.notes = @"";
    
    //format the nsdates to a mysql compatible string
    NSDateFormatter* dateFormatForDate = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatForDate setLocale:usLocale];
    [dateFormatForDate setDateFormat:@"yyyy-MM-dd"];
    NSString* dateBeginString = [dateFormatForDate stringFromDate:self.request.request_date_begin];
    NSString* dateEndString = [dateFormatForDate stringFromDate:self.request.request_date_end];
    
    //format the time
    NSDateFormatter* dateFormatForTime = [[NSDateFormatter alloc] init];
    [dateFormatForTime setLocale:usLocale];
    [dateFormatForTime setDateFormat:@"HH:mm"];
    NSString* timeBeginStringPartOne = [dateFormatForTime stringFromDate:self.request.request_time_begin];
    NSString* timeEndStringPartOne = [dateFormatForTime stringFromDate:self.request.request_time_end];
    NSString* timeBeginString = [NSString stringWithFormat:@"%@:00", timeBeginStringPartOne];
    NSString* timeEndString = [NSString stringWithFormat:@"%@:00", timeEndStringPartOne];
    
    //time of request
    NSDate* timeRequest = [NSDate date];
    NSDateFormatter* timeStampFormatter = [[NSDateFormatter alloc] init];
    [timeStampFormatter setLocale:usLocale];
    [timeStampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeRequestString = [timeStampFormatter stringFromDate:timeRequest];
    
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.request.key_id,nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"contact_foreignKey", self.request.contact_foreignKey, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"classSection_foreignKey", self.request.classSection_foreignKey,nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"classTitle_foreignKey", self.request.classTitle_foreignKey,nil];
    NSArray* fifthArray = [NSArray arrayWithObjects:@"request_date_begin", dateBeginString, nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"request_date_end", dateEndString, nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"request_time_begin", timeBeginString, nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"request_time_end", timeEndString, nil];
    NSArray* ninthArray =[NSArray arrayWithObjects:@"contact_name", self.request.contact_name, nil];
    NSArray* tenthArray = [NSArray arrayWithObjects:@"renter_type", self.request.renter_type, nil];
    NSArray* eleventhArray = [NSArray arrayWithObjects:@"time_of_request", timeRequestString, nil];
    NSArray* twelfthArray = [NSArray arrayWithObjects:@"notes", self.request.notes, nil];
    
    NSArray* bigArray = [NSArray arrayWithObjects:
                         firstArray,
                         secondArray,
                         thirdArray,
                         fourthArray,
                         fifthArray,
                         sixthArray,
                         seventhArray,
                         eighthArray,
                         ninthArray,
                         tenthArray,
                         eleventhArray,
                         twelfthArray,
                         nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    [webData queryForStringWithLink:@"EQSetNewScheduleRequest.php" parameters:bigArray];
//    NSLog(@"this is the returnID: %@", returnID);
    
    
    //___________************  Use this moment to allocate a uniqueItem object (key_id and/or dist ID) *****_______
    
    // replace the equipUniqueItem_foreignKey in the equipJoins in the requestManager's array
    
    // use the requestManager's array of all equipItems: requestManager.arrayOfEquipUniqueItems
    // compare against: requestManager.arrayOfEquipUniqueItemsByDateCollision
    // derive available key_ids or distinquishing ids
    
    //start by identifying uniqueIds and making an array for each with the all key_ids
    //subtract from each array the selected key_ids
    //sort the array by distinguishing ids and select the lowest one for the join
    
    NSMutableArray* tempListOfUniqueItemsJustRequested = [NSMutableArray arrayWithCapacity:1];
    
    //compare this transaction's selections with the array of unqiue item collisions
    
    for (EQRScheduleTracking_EquipmentUnique_Join* join in self.request.arrayOfEquipmentJoins){
        
        //add to nested array  only if it hasn't been added already
        BOOL addFlag = YES;
        
        NSMutableArray* listOfAllUniqueKeys = [NSMutableArray arrayWithCapacity:1];
        
        for (NSMutableArray* arrayOfUniqueKeys in self.arrayOfEquipUniqueItemsWithSubArrays){
            
            if ([[(EQREquipUniqueItem*)[arrayOfUniqueKeys objectAtIndex:0] equipTitleItem_foreignKey] isEqualToString:join.equipTitleItem_foreignKey]){
                
                for (NSMutableArray* innerArray in tempListOfUniqueItemsJustRequested){
                    
                    if ([[(EQREquipUniqueItem*)[innerArray objectAtIndex:0] equipTitleItem_foreignKey] isEqualToString:join.equipTitleItem_foreignKey]){
                        
                        //found a match to an existing item, so don't add
                        addFlag = NO;
                        
                        break;
                    }
                }
                
                [listOfAllUniqueKeys addObjectsFromArray:arrayOfUniqueKeys];
                
                //stop inner loop
                break;
            }
        }
        
        //add to array of arrays
        if (addFlag){
            
            //____!!!!!!  objects added recently may not be in the arrayOfEquipUniqueItemsWithSubarray   !!!!!!_____
            //____!!!!!!   will crash if adding empty array   !!!!!!_____
            if ([listOfAllUniqueKeys count] > 0){
                [tempListOfUniqueItemsJustRequested addObject:listOfAllUniqueKeys];
            }
        }
    }
    //______the result is a nested array of just the titleItems requested, with sub_arrays of ALL uniqueItems
    
    
    //if not items are in the tempListOfUniqueItemsJustRequests, then fail gracefully....
    //not true!!!!!  it could just be a misc item!!!!!!
//    if ([tempListOfUniqueItemsJustRequested count] < 1){
////        NSLog(@"failing gracefully in requestManager > justConfirm");
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to identify part of the gear list, please modify the request in Inbox with the correct gear" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
//        return;
//    }
    
    
    //____now remove the unique items that have date collisions
    //the top array
    for (NSMutableArray* selectedUniqueList in tempListOfUniqueItemsJustRequested){
        
        NSMutableArray* arrayOfUniquesToRemove = [NSMutableArray arrayWithCapacity:1];
        
        //the inner array
        for (EQREquipUniqueItem* selectedUniqueItem in selectedUniqueList){
            
            for (EQREquipUniqueItem* unItem in self.arrayOfEquipUniqueItemsByDateCollision){
                
                //                NSLog(@"this is the selectedUniqueItem.key_id: %@  and this is the unItem.key_id: %@", selectedUniqueItem.key_id,unItem.key_id );
                
                if ([selectedUniqueItem.key_id isEqualToString:unItem.key_id]){
                    
                    //on a match, remove item from the tempList by adding to the list of objects to remove
                    [arrayOfUniquesToRemove addObject:selectedUniqueItem];
                }
            }
        }
        
        //here is where we deduct the list of deductions
        [selectedUniqueList removeObjectsInArray:arrayOfUniquesToRemove];
    }
    
    //____now (maybe) remove UniqueItems that are damaged
    if (self.request.allowSeriousServiceIssueFlag == NO){
        
        //the top array
        for (NSMutableArray* selectedUniqueList in tempListOfUniqueItemsJustRequested){
            
            NSMutableArray* arrayOfUniquesToRemove = [NSMutableArray arrayWithCapacity:1];
         
            //the inner array
            for (EQREquipUniqueItem* selectedUniqueItem in selectedUniqueList){
                
                if ([selectedUniqueItem.status_level integerValue] >= EQRThresholdForSeriousIssue){
                    
                    //too damaged to allow out
                    [arrayOfUniquesToRemove addObject:selectedUniqueItem];
                }
            }
            
            //here is where we remove stuff
            [selectedUniqueList removeObjectsInArray:arrayOfUniquesToRemove];
        }
    }
    

    //___sort the subarrays by dist id___
    //sort sub arrays first, but dist ID
    NSMutableArray* sortedTempListOfUniqueItemsJustRequested = [NSMutableArray arrayWithCapacity:1];
    [tempListOfUniqueItemsJustRequested enumerateObjectsUsingBlock:^(NSArray* objArray, NSUInteger idx, BOOL *stop) {
        
        //sort in asending order
        NSArray* sortedSubArray = [objArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            //first, compare on equipTitleItem_foreignKey
            NSString* string1 = [(EQREquipUniqueItem*)obj1 equipTitleItem_foreignKey];
            NSString* string2 = [(EQREquipUniqueItem*)obj2 equipTitleItem_foreignKey];
            
            NSInteger firstComparisonResult = [string1 compare:string2];
            
            //if equipTitleItem_foreignKey is the same, sort using dist id
            if (firstComparisonResult == NSOrderedSame){
                
                //___1, give preference to any item that does NOT have a minor service issue
                NSString* testOnMinorIssue1 = @"0";
                NSString* testOnMinorIssue2 = @"0";
                
                if ([[(EQREquipUniqueItem*)obj1 status_level] integerValue] >= EQRThresholdForMinorIssue){
                    testOnMinorIssue1 = @"1";
                }
                
                if ([[(EQREquipUniqueItem*)obj2 status_level] integerValue] >= EQRThresholdForMinorIssue){
                    testOnMinorIssue2 = @"1";
                }
                
                NSInteger firstAndAHalfComparisonResult = [testOnMinorIssue1 compare:testOnMinorIssue2];
                
                if (firstAndAHalfComparisonResult == NSOrderedSame){
                    
                    //____2, give preference to any item that IS NOT in the array of buffer objects
                    NSString* testOnString3 = @"0";
                    NSString* testOnString4 = @"0";
                    
                    //                NSLog(@"count of expandedBuffer array: %u", [self.arrayOfEquipUniqueItemsByExpandedBuffer count]);
                    for (EQREquipUniqueItem* testItem in self.arrayOfEquipUniqueItemsByExpandedBuffer){
                        
                        if ([testItem.key_id isEqualToString:[(EQREquipUniqueItem*)obj1 key_id]]){
                            testOnString3 = @"1";
                            break;
                        }
                    }
                    
                    for (EQREquipUniqueItem* testItem in self.arrayOfEquipUniqueItemsByExpandedBuffer){
                        
                        if ([testItem.key_id isEqualToString:[(EQREquipUniqueItem*)obj2 key_id]]){
                            testOnString4 = @"1";
                            break;
                        }
                    }
                    
                    NSInteger secondComparisonResult = [testOnString3 compare:testOnString4];
                    
                    //_____3, statuslevel and nextDayStatus are equal, move onto the dist id
                    if (secondComparisonResult == NSOrderedSame){
                        
                        
                        NSString* string3 = [(EQREquipUniqueItem*)obj1 distinquishing_id];
                        NSString* string4 = [(EQREquipUniqueItem*)obj2 distinquishing_id];
                        
                        //if dist id is only one character in length, add a 0 to the start.
                        if ([string3 length] < 2){
                            string3 = [NSString stringWithFormat:@"0%@", string3];
                        }
                        
                        if ([string4 length] < 2){
                            string4 = [NSString stringWithFormat:@"0%@", string4];
                        }
                        
                        //only if app is set to randomize equipment selection:
                        if (EQRRandomizeEquipSelection == YES){
                            float randomNumber = arc4random() % 2;
                            if (randomNumber > 0){
                                NSString *tempString = string3;
                                string3 = string4;
                                string4 = tempString;
                            }
                        }
                        
                        return [string3 compare:string4];
                        
                    }else{
                        
                        return secondComparisonResult;
                    }
                    
                } else {
                    
                    return firstAndAHalfComparisonResult;
                }
                
            } else {
                
                return firstComparisonResult;
            }
        }];
        
        [sortedTempListOfUniqueItemsJustRequested addObject:[NSMutableArray arrayWithArray:sortedSubArray]];
    }];
    

    
    //geez.... now for each title item, find the matching array of uniques, and assign the key_id from the top of the stack and then pop the stack
    
    for (EQRScheduleTracking_EquipmentUnique_Join* joinMe in self.request.arrayOfEquipmentJoins){
        
//        NSLog(@"count of items in uniqueArrayMe: %lu", (unsigned long)[[tempListOfUniqueItemsJustRequested objectAtIndex:0] count]);
        
        for (NSMutableArray* uniqueArrayMe in sortedTempListOfUniqueItemsJustRequested){
            
            //____an array may be left empty after the last function, avoid tyring to iterate through
            //____it or app will crash
            if ([uniqueArrayMe count] > 0){
                
                NSMutableArray* kickMeOffTheTeam = [NSMutableArray arrayWithCapacity:1];
                BOOL foundAMatchFlag = NO;
                
                if ([[(EQREquipUniqueItem*)[uniqueArrayMe objectAtIndex:0] equipTitleItem_foreignKey] isEqualToString:joinMe.equipTitleItem_foreignKey]) {
                    
                    joinMe.equipUniqueItem_foreignKey =[(EQREquipUniqueItem*)[uniqueArrayMe objectAtIndex:0] key_id];
                    
                    foundAMatchFlag = YES;
                    
                    //remove the EQREquipUniqueItem at index 0
                    [kickMeOffTheTeam addObject:[uniqueArrayMe objectAtIndex:0]];
                    
                }
                
                if (foundAMatchFlag){
                    
                    //remove the uniqueItem From the array
                    [uniqueArrayMe removeObjectsInArray:kickMeOffTheTeam];
                    
                    break;
                }
            }
            
        }
    }
    
    
    //input array of scheduleTracking_equipUniqueItem_joins
    for (EQRScheduleTracking_EquipmentUnique_Join* join in self.request.arrayOfEquipmentJoins){
        
//        NSLog(@"this is the equipUniqueItem key: %@", join.equipUniqueItem_foreignKey, nil);
        
        NSArray* firstArrayForJoin = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", join.scheduleTracking_foreignKey, nil];
        NSArray* secondArrayForJoin = [NSArray arrayWithObjects:@"equipUniqueItem_foreignKey", join.equipUniqueItem_foreignKey, nil];
        NSArray* thirdArrayForJoin = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", join.equipTitleItem_foreignKey, nil];
        NSArray* bigArrayForJoin = [NSArray arrayWithObjects:
                                    firstArrayForJoin,
                                    secondArrayForJoin,
                                    thirdArrayForJoin,
                                    nil];
        
        join.key_id = [webData queryForStringWithLink:@"EQSetNewScheduleEquipJoin.php" parameters:bigArrayForJoin];
//        NSLog(@"this is the schedule_equip_join return key_id: %@", returnID2);
        
        NSLog(@"this is the join.cost: %@",join.cost);
        
        //update cost of the join item
        if (join.cost)
            if (![join.cost isEqualToString:@""]){
                
                //only save value if it was manually altered. 
                if (join.hasAStoredCostValue){
                    
                    NSLog(@"SchedulerequestManager > justConfirm is altering cost of a join with Key_id: %@  and cost: %@", join.key_id, join.cost);
                    
                    if (join.key_id){
                        NSArray *firstArray = @[@"key_id", join.key_id];
                        NSArray *secondArray = @[@"cost", join.cost];
                        NSArray *topArray = @[firstArray, secondArray];
                        
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                        dispatch_async(queue, ^{
                            
                            [webData queryForStringwithAsync:@"EQAlterCostOfScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnKey) {
                                
                                if ([returnKey isEqualToString:join.key_id]){
                                    
                                    //everthign is cool
                                    
                                }else{
                                    
                                    //error handling
                                    NSLog(@"failed to successfully alter transaction equipJoin price");
                                }
                            }];
                        });
                    }
                }
            }
        
        //update deposit of the join item
        if (join.deposit)
            if (![join.deposit isEqualToString:@""]){
                
                NSLog(@"SchedulerequestManager > justConfirm is altering deposit of a join with Key_id: %@  and deposit: %@", join.key_id, join.deposit);
                
                if (join.key_id){
                    NSArray *firstArray = @[@"key_id", join.key_id];
                    NSArray *secondArray = @[@"deposit", join.deposit];
                    NSArray *topArray = @[firstArray, secondArray];
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                    dispatch_async(queue, ^{
                        
                        [webData queryForStringwithAsync:@"EQAlterDepositOfScheduleEquipJoin.php" parameters:topArray completion:^(NSString *returnKey) {
                            
                            if ([returnKey isEqualToString:join.key_id]){
                                
                                //everthign is cool
                                
                            }else{
                                
                                //error handling
                                NSLog(@"failed to successfully alter transaction equipJoin deposit");
                            }
                        }];
                    });
                }
            }
        
    }
}



#pragma mark - gear allocation

-(void)allocateGearListWithDates:(NSDictionary*)datesDic{
    
    //______DATESDIC CAN BE NIL, THEN IT IS USES DATES ASSIGNED TO THE REQUEST ITEM_____
    //______THUS far, datesDic is NEVER used
    
    //request ivars that determine how to handle collisions and how precisely
    BOOL allowSameDayFlag = self.request.allowSameDayFlag;
    BOOL allowConflictFlag = self.request.allowConflictFlag;
    
    
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
    
    //determine if should allow same day pickup and return
    //____!!!!!! BUT it doesn't work   !!!!!________
    //_____  currently, allowSameDayFlag is NEVER set to YES  _______
    
    if (allowSameDayFlag == YES){     //use precise dates
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
    }else{    //use dates that drop the hours and minutes
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    NSString* dateBeginString;
    NSString* dateEndString;
    
    //determine if should allow date conflicts
    if (allowConflictFlag == YES){
        
        dateBeginString = [dateFormatter stringFromDate:self.request.request_date_begin];
        
        //end date is earlier than begin date. a sure fire way for the PHP script to return nothing
        dateEndString = [dateFormatter stringFromDate:[self.request.request_date_begin dateByAddingTimeInterval:-172800]];
        
    }else{
        
        dateBeginString = [dateFormatter stringFromDate:self.request.request_date_begin];
        dateEndString = [dateFormatter stringFromDate:self.request.request_date_end];
    }

    //use request item's dates or supplied dateDic
    //______this never gets called and will ignore the usefulness of the expanded list for buffer zones_____
    if (datesDic != nil){
        
        //use the supplied parameter
        dateBeginString = [datesDic objectForKey:@"request_date_begin"];
        dateEndString = [datesDic objectForKey:@"request_date_end"];
    }
    
    
    //_____REPLACED BY THE FOLLOWING SINGLE PHP CALL____ FOR PERFORMANCE IMPROVEMENT_____
    //get data two php calls...
//    NSArray* arrayOfScheduleTrackingKeyIDs = [self getArrayOfScheduleTrackingIDsWithBeginDate:dateBeginString endDate:dateEndString];
//    
//    //assign to requestManager ivar (this is used in EQEquipSummaryVCntrllr > justConfirm method
//    self.arrayOfEquipUniqueItemsByDateCollision = [self getArrayOfEquipUniquesWithArrayOfScheduleTrackingIDs:arrayOfScheduleTrackingKeyIDs];
    
    //the PHP call
    self.arrayOfEquipUniqueItemsByDateCollision = [self getArrayOfEquipUniquesWithBeginDate:dateBeginString EndDate:dateEndString];
    
    
    //remove duplicate equipUniqueItems so they don't get double counted in the next step
    NSMutableArray *arrayOfEquipUniqueItemsByDataCollisionDeDuped = [NSMutableArray arrayWithCapacity:1];
    for (EQREquipUniqueItem *thisItem in self.arrayOfEquipUniqueItemsByDateCollision){
        BOOL addMeToTheArray = YES;
        for (EQREquipUniqueItem *thisOtherItem in arrayOfEquipUniqueItemsByDataCollisionDeDuped){
            if ([thisItem.key_id isEqualToString:thisOtherItem.key_id]){
                //found a match to an existing uniqueItem, so dismiss me
                addMeToTheArray = NO;
                break;
            }
        }
        if (addMeToTheArray){
            [arrayOfEquipUniqueItemsByDataCollisionDeDuped addObject:thisItem];
        }
    }
    
    //assign de-duped array to property
    self.arrayOfEquipUniqueItemsByDateCollision = arrayOfEquipUniqueItemsByDataCollisionDeDuped;
    
    //Update the array that tracks the COUNT of equipTitleItems
    //loop through arrayOfEquipUniqueItems
    for (EQREquipUniqueItem* eqritem in self.arrayOfEquipUniqueItemsByDateCollision){
        
        for (NSMutableArray* checkArray in self.arrayOfEquipTitlesWithCountOfUniqueItems){
            
            if ([eqritem.equipTitleItem_foreignKey isEqualToString:[checkArray objectAtIndex:0]] ){
                
                //found a matching title item, now reduce the count of available items by one
                //... but only if the current available quantity is above 0 (to prevent going into negative integers)
                
                if ([(NSNumber*)[checkArray objectAtIndex:1] integerValue] > 0){
                    
                    int newIntValue = [(NSNumber*)[checkArray objectAtIndex:1] intValue] - 1;
                    NSNumber* newNumber = [NSNumber numberWithInt: newIntValue];
                    [checkArray replaceObjectAtIndex:1 withObject:newNumber];
                }
                
                break;
            }
        }
    }
    
    //____!!!!!!  further reduce the available list of items by removing the damaged equipment from play   !!!!!______

}


-(void)allocateGearListWithExpandedDatesForBufferZoneWithBeginDate:(NSDate*)begindate EndDate:(NSDate*)endDate{
    
    
    //begin and end dates in sql format
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //expand dates
    NSDate* newBeginDate = [begindate dateByAddingTimeInterval:-86400];
    NSDate* newEndDate = [endDate dateByAddingTimeInterval:86400];
    
    NSString* dateBeginString = [dateFormatter stringFromDate:newBeginDate];
    NSString* dateEndString = [dateFormatter stringFromDate:newEndDate];
    
    
//    NSArray* trackingKeysArray = [self getArrayOfScheduleTrackingIDsWithBeginDate:dateBeginString endDate:dateEndString];
//
//    self.arrayOfEquipUniqueItemsByExpandedBuffer = [self getArrayOfEquipUniquesWithArrayOfScheduleTrackingIDs:trackingKeysArray];
    
    self.arrayOfEquipUniqueItemsByExpandedBuffer = [self getArrayOfEquipUniquesWithBeginDate:dateBeginString EndDate:dateEndString];
}


//_______THESE TWO METHODS REPLACED WITH ONE THAT HAS A MORE SOPHISTICATED MYSQL CALL, BETTER PERFORMANCE______
//-(NSArray*)getArrayOfScheduleTrackingIDsWithBeginDate:(NSString*)beginDate endDate:(NSString*)endDate{
//    
//    EQRWebData* webData = [EQRWebData sharedInstance];
//    
//    //declare arrays
//    NSArray* arrayWithBeginDate;
//    NSArray* arrayWithEndDate;
//    
//    arrayWithBeginDate = [NSArray arrayWithObjects:@"request_date_begin", beginDate, nil];
//    arrayWithEndDate = [NSArray arrayWithObjects:@"request_date_end", endDate, nil];
//    NSArray* arrayTopDate = [NSArray arrayWithObjects:arrayWithBeginDate, arrayWithEndDate, nil];
//    
//    NSMutableArray* arrayOfScheduleTrackingKeyIDs = [NSMutableArray arrayWithCapacity:1];
//    
//    [webData queryWithLink:@"EQGetScheduleItemsInDateRange.php" parameters:arrayTopDate class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
//        
//        //        NSLog(@"result from schedule request Date range: %@", muteArray);
//        
//        //populate array with key_ids
//        for (EQRScheduleRequestItem* objKey in muteArray){
//            
//            [arrayOfScheduleTrackingKeyIDs addObject:objKey];
//            
//            //cycle through and get equipUniqueItem key IDs
//        }
//    }];
//    
//    return arrayOfScheduleTrackingKeyIDs;
//}
//
//
//-(NSMutableArray*)getArrayOfEquipUniquesWithArrayOfScheduleTrackingIDs:(NSArray*)arrayOfScheduleTrackingKeyIDs{
//    
//    EQRWebData* webData = [EQRWebData sharedInstance];
//
//    NSMutableArray* arrayOfEquipUniqueItems = [NSMutableArray arrayWithCapacity:1];
//
//    //Use sql with inner join...
//    //  get reserved EquipUniqueItem objects With ScheduleTrackingKeys
//    
//    for (EQRScheduleTracking_EquipmentUnique_Join* objThingy in arrayOfScheduleTrackingKeyIDs){
//        
//        NSArray* arrayWithTrackingKey = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", objThingy.key_id, nil];
//        NSArray* topArrayWithTrackingKey = [NSArray arrayWithObject:arrayWithTrackingKey];
//        
//        [webData queryWithLink:@"EQGetUniqueItemKeysWithScheduleTrackingKeys.php" parameters:topArrayWithTrackingKey class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray2) {
//            
//            for (EQREquipUniqueItem* objUniqueItem in muteArray2){
//                
//                //                NSLog(@"this is EquipUniqueItem key_id: %@  and titleItem key_id: %@ and name: %@",
//                //                      objUniqueItem.key_id, objUniqueItem.equipTitleItem_foreignKey, objUniqueItem.name);
//                
//                [arrayOfEquipUniqueItems addObject:objUniqueItem];
//            }
//        }];
//    }
//    
//    return arrayOfEquipUniqueItems;
//}

-(NSMutableArray*)getArrayOfEquipUniquesWithBeginDate:(NSString*)beginDate EndDate:(NSString*)endDate{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //declare arrays
    NSArray* arrayWithBeginDate;
    NSArray* arrayWithEndDate;
    
    arrayWithBeginDate = [NSArray arrayWithObjects:@"request_date_begin", beginDate, nil];
    arrayWithEndDate = [NSArray arrayWithObjects:@"request_date_end", endDate, nil];
    NSArray* arrayTopDate = [NSArray arrayWithObjects:arrayWithBeginDate, arrayWithEndDate, nil];
    
    NSMutableArray* arrayOfEquipUniqueItems = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetEquipUniqueItemsWithScheduleDateRange.php" parameters:arrayTopDate class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray2) {
        
        for (EQREquipUniqueItem* objUniqueItem in muteArray2){
                        
            [arrayOfEquipUniqueItems addObject:objUniqueItem];
        }
    }];
    
    return arrayOfEquipUniqueItems;
}


-(NSArray*)retrieveAvailableEquipUniquesForTitleKey:(NSString*)equipTitleItem_foreignKey{
    
//    NSLog(@"this is the titleItem foreign key: %@", equipTitleItem_foreignKey);
    
    NSMutableArray* muteArray = [NSMutableArray arrayWithCapacity:1];
    
    for (EQREquipUniqueItem* eqritem in self.arrayOfEquipUniqueItemsByDateCollision){
        
        if ([eqritem.equipTitleItem_foreignKey isEqualToString:equipTitleItem_foreignKey]){
            
            //add to our new array
            [muteArray addObject:eqritem];
        }
    }
    
//    NSLog(@"this is the count of the array: %u", [muteArray count]);
    
    return [NSArray arrayWithArray:muteArray];
}



#pragma mark - repsond to supplementary cell actions

//from request equip selection list
-(void)collapseOrExpandSection:(NSString*)chosenSection WithAll:(BOOL)withAllFlag{
    
    bool hideMeFlag = YES;
//    NSString* objectToRemove;
    NSArray* arrayOfObjectsToRemove;
    NSMutableArray* arrayOfObjectsToAdd = [NSMutableArray arrayWithCapacity:1];
    NSArray* chosenArray;
    
    //ensure this ivar exists
    if (!self.arrayOfEquipSectionsThatShouldBeHidden){
        
        self.arrayOfEquipSectionsThatShouldBeHidden = [NSMutableArray arrayWithCapacity:1];
    }
    
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
        
        [self.equipSelectionDelegate refreshTheCollectionWithType:@"insert" SectionArray:chosenArray];
        
        return;
    }
    
    //when all sections are to be hidden
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
        
        [self.equipSelectionDelegate refreshTheCollectionWithType:@"delete" SectionArray:chosenArray];
        
        return;
    }
    
    
    
    //________for individual hide/expand__________
    if (hideMeFlag){
        
        //add object to array
        [self.arrayOfEquipSectionsThatShouldBeHidden addObject:chosenSection];
        
        chosenArray = [NSArray arrayWithObject:chosenSection];
        
//        NSLog(@"in requestManager count of chosenSection for arrayOfEquipSectionsThatShouldBeHidden: %u", (int)[chosenArray count]);
        
        [self.equipSelectionDelegate refreshTheCollectionWithType:@"delete" SectionArray:chosenArray];
        
    }else{
        
        //loop through array
        for (NSString* objectToRemove in arrayOfObjectsToRemove){
            
            //remove object from array
            [self.arrayOfEquipSectionsThatShouldBeHidden removeObject:objectToRemove];
        }
        
        chosenArray = [NSArray arrayWithObject:chosenSection];
        
        [self.equipSelectionDelegate refreshTheCollectionWithType:@"insert" SectionArray:chosenArray];
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
