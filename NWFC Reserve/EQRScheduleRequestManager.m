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
    
    self.request = requestItem;
    
    //set timestamp
    self.request.time_of_request = [NSDate date];
    
    //--
    //need to set the key_id right away
    //get the next key_id value for a scheduleTracking object
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSString* lastKeyId = [webData queryForStringWithLink:@"EQGetNextScheduleRequestKey.php" parameters:nil];
    
    int lastKeyIdInt = (int)[lastKeyId integerValue];
    int nextKeyId = lastKeyIdInt + 1;
    NSString* nextKeyIdString = [NSString stringWithFormat:@"%u", nextKeyId];
    
    //set the request's key_id ivar
    self.request.key_id = nextKeyIdString;
    NSLog(@"this is the nextKeyIdString %@", nextKeyIdString);
    //---
}


-(void)dismissRequest{
    
    //set request item to nil
    self.request = nil;
    
    //void any local ivars that view controllers have established for keeping track of selections and flags
    //send by notification!!
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRVoidScheduleItemObjects object:self userInfo:nil];
    
}


-(NSArray*)retrieveArrayOfEquipJoins{
    
    if ([self.request.arrayOfEquipmentJoins count] > 0){
        
        NSArray* returnArray = [NSArray arrayWithArray:self.request.arrayOfEquipmentJoins];
        
        return returnArray;

    }else{
        
        return nil;
    }
}


-(void)addNewRequestEquipJoin:(EQREquipItem*)thisEquipItem{
    
    NSLog(@"adding a new request join with with schedule tracking key %@", self.request.key_id);
    
    //instantiate new join item
    EQRScheduleTracking_EquipmentUnique_Join* newJoin = [[EQRScheduleTracking_EquipmentUnique_Join alloc] init];
    
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














@end
