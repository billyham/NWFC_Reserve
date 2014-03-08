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
    
    NSLog(@"count of equipTitleItems array: %u", [self.arrayOfEquipTitleItems count]);
    
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
    
    NSLog(@"count of new title items to add: %u", [additionalTitles count]);
    
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
    
    NSLog(@"array of equipUniqueItems count: %u", [self.arrayOfEquipUniqueItemsAll count]);
    
    
    
    
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



#pragma mark - repsond to supplementary cell actions

-(void)collapseOrExpandSection:(NSString*)chosenSection{
    
    bool hideMeFlag = YES;
    NSString* objectToRemove;
    
    for (NSString* myObject in self.arrayOfEquipSectionsThatShouldBeHidden){
        
        if ([myObject isEqualToString:chosenSection]){
            
            hideMeFlag = NO;
            objectToRemove = myObject;
        }
    }
    
    if (hideMeFlag){
        
        //add object to array
        [self.arrayOfEquipSectionsThatShouldBeHidden addObject:chosenSection];
        
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"delete", @"type",
                                    chosenSection, @"sectionString",
                                      nil];
        
        
        //send note
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshEquipTable object:nil userInfo:thisDic];

        
    }else{

        //remove object from array
        [self.arrayOfEquipSectionsThatShouldBeHidden removeObject:objectToRemove];
        
        
        NSDictionary* thisDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"insert", @"type",
                                 chosenSection, @"sectionString",
                                 nil];;
        
        //send note
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRRefreshEquipTable object:nil userInfo:thisDic];

    }
    
    //________*****  need to reload the collection view!!!
    
}











@end
