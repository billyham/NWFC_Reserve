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
    
    //need to set the key_id right away
    //send to PHP and use that mechanism to retrieve mysql's auto incremented id
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
    
    //instantiate new join item
    EQRScheduleTracking_EquipmentUnique_Join* newJoin = [[EQRScheduleTracking_EquipmentUnique_Join alloc] init];
    
    newJoin.equipUniqueItem_foreignKey = @"1";
    
    //______**********  HAVE NOT DEFINED THE REQUEST.KEY_ID YET
    newJoin.scheduleTracking_foreignKey = self.request.key_id;
}


-(void)removeRequestEquipJoin:(EQREquipItem*)thisEquipItem{
    
    //find an existing join with a matching equipItem and remove the sucker.
    
    
}














@end
