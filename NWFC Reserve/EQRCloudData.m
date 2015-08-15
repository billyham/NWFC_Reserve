//
//  EQRDataProxy.m
//  Gear
//
//  Created by Ray Smith on 3/11/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRCloudData.h"
#import <CloudKit/CloudKit.h>
#import "EQRContactNameItem.h"
#import "EQRGlobals.h"
#import "EQRStaffUserManager.h"
#import "EQRModeManager.h"

@interface EQRCloudData ()

//@property BOOL completionBlockSignalFlag;
@property SEL aSyncSelector;


@end

@implementation EQRCloudData

//@synthesize delegateDataFeed;

+(EQRCloudData*)sharedInstance{
    
    EQRCloudData *myInstance = [[EQRCloudData alloc] init];
    return myInstance;
}

#pragma mark - house keeping methods

-(void)authenticateICloud{
    
    [[CKContainer containerWithIdentifier:EQRCloudKitContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        if (accountStatus == CKAccountStatusNoAccount) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign in to iCloud"
                                                                           message:@"Sign in to your iCloud account to write records. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            
            UIViewController *thisViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            [thisViewController presentViewController:alert animated:YES completion:nil];
            
        }
        else {
            // Insert your just-in-time schema code here
        }
    }];
}


-(void)confirmExistenceOfZone:(NSString *)zoneString completion:(CompletionBlockWithBool)completeBlock{
    
    CKContainer *container = [CKContainer containerWithIdentifier:EQRCloudKitContainer];
    CKDatabase *database = [container privateCloudDatabase];
    
    CKRecordZoneID *recordZoneID = [[CKRecordZoneID alloc] initWithZoneName:zoneString ownerName:CKOwnerDefaultName];
    
    [database fetchRecordZoneWithID:recordZoneID completionHandler:^(CKRecordZone *zone, NSError *error) {
        
        if (error){
            
            CKRecordZone *newZone = [[CKRecordZone alloc] initWithZoneName:zoneString];
            NSArray *array = @[newZone];
            CKModifyRecordZonesOperation *operation = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:array recordZoneIDsToDelete:nil];
            operation.modifyRecordZonesCompletionBlock = ^(NSArray *savedRecordZones, NSArray *deletedRecordZoneIDs, NSError *operationError){
                
                if (operationError){
                    NSLog(@"CloudData > confirmExistenceOfZone reports failure to complete zone");
                    completeBlock(NO);
                }else{
                    completeBlock(YES);
                }
            };
            
            [database addOperation:operation];
            
        }else{
            
            completeBlock(YES);
        }
    }];
}


#pragma mark - query methods


-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock{
    
    NSLog(@"queryWithLink with: %@", link);
    
    [self authenticateICloud];
    
    if ([link isEqualToString:@"EQGetContactNameWithKey.php"]){
        
//        CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key_id = %@", @"10"];
//        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Contact" predicate:predicate];
//        [privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
//            if (error) {
//                // Error handling for failed fetch from public database
//                NSLog(@"Error handling for failed fetch from private database: %@", error);
//            }
//            else {
//                // Display the fetched records
//                NSLog(@"Display the fetched records");
//            }
//        }];
        
    }
    
    if ([link isEqualToString:@"EQGetAllContactNames.php"]){
        
        CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"decommissioned != %@", @"1"];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Contact" predicate:predicate];
        [privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            if (error) {
                // Error handling for failed fetch from public database
                NSLog(@"Error handling for failed fetch from private database: %@", error);
            }
            else {
                // Display the fetched records
                NSLog(@"Display the fetched records with count: %ld", (unsigned long)[results count]);
                
                NSMutableArray *muteArray = [NSMutableArray arrayWithCapacity:1];
                for (CKRecord *recordObject in results){
                    EQRContactNameItem *newRecord = [[EQRContactNameItem alloc] init];
                    newRecord.key_id = recordObject.recordID.recordName;
                    newRecord.first_name = [recordObject objectForKey:@"first_name"];
                    newRecord.last_name = [recordObject objectForKey:@"last_name"];
                    newRecord.first_and_last = [recordObject objectForKey:@"first_and_last"];
                    [muteArray addObject:newRecord];
                }
                completeBlock(muteArray);
            }
        }];
    }
    

    
}


-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para{
    
    NSLog(@"queryForStringWithLink with: %@", link);
    
    if ([link isEqualToString:@"EQSetNewContact.php"]){
        
        CKRecord *contactRecord = [[CKRecord alloc] initWithRecordType:@"Contact"];
        
        for (NSArray *subArray in para){
            contactRecord[[subArray objectAtIndex:0]] = [subArray objectAtIndex:1];
        }
        
        contactRecord[@"decommissioned" ] = @"";
        
        CKContainer *myContainer = [CKContainer containerWithIdentifier:EQRCloudKitContainer];
        CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
        
        [privateDatabase saveRecord:contactRecord completionHandler:^(CKRecord *record, NSError *error) {
            
            if (!error){
                //successfully saved record
                NSLog(@"successfully saved record");
                
            }else{
                
                NSLog(@"failed to save record with this error: %@", error);
            }
        }];
    }

    return @"nonsense";
}


-(void)queryForStringwithAsync:(NSString *)link parameters:(NSArray *)para completion:(CompletionBlockWithUnknownObject)completeBlock{
    
    NSLog(@"queryForStringWithAsync with: %@", link);
    
    if ([link isEqualToString:@"EQSetNewContact.php"]){
        
        EQRModeManager *modeManager = [EQRModeManager sharedInstance];
        BOOL isInDemoMode = [modeManager isInDemoMode];
        
        CKRecordZoneID *recordZone;
        
        if (isInDemoMode){
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:EQRRecordZoneDemo  ownerName:CKOwnerDefaultName];
        }else{
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:CKRecordZoneDefaultName  ownerName:CKOwnerDefaultName];
        }
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
            //        CKRecordID *contactRecordID = [[CKRecordID alloc] initWithRecordName:[[NSUUID UUID] UUIDString]  zoneID:recordZone];
            
            CKRecord *contactRecord = [[CKRecord alloc] initWithRecordType:@"Contact" zoneID:recordZone];
            
            //set the contact's key_id
            for (NSArray *subArray in para){
                contactRecord[[subArray objectAtIndex:0]] = [subArray objectAtIndex:1];
            }
            
            contactRecord[@"decommissioned" ] = @"";
            
            CKContainer *myContainer = [CKContainer containerWithIdentifier:EQRCloudKitContainer];
            CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
            [privateDatabase saveRecord:contactRecord completionHandler:^(CKRecord *record, NSError *error) {
                
                if (!error){
                    //successfully saved record
                    //__________!!!!!!!!!!!!    THIS IS UGLY    !!!!!!!!!!!!_______________
                    NSLog(@"successfully saved record");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        EQRContactNameItem *newRecord = [[EQRContactNameItem alloc] init];
                        newRecord.key_id = record.recordID.recordName;
                        newRecord.first_name = [record objectForKey:@"first_name"];
                        newRecord.last_name = [record objectForKey:@"last_name"];
                        newRecord.first_and_last = [record objectForKey:@"first_and_last"];
                        
                        completeBlock(newRecord);
                    });
                    
                }else{
                    
                    NSLog(@"failed to save record with this error: %@", error);
                }
            }];
        }];
    }
    
    if ([link isEqualToString:@"EQGetContactNameWithKey.php"]){
        
        EQRModeManager *modeManager = [EQRModeManager sharedInstance];
        BOOL isInDemoMode = [modeManager isInDemoMode];
        
        CKRecordZoneID *recordZone;
        
        if (isInDemoMode){
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:EQRRecordZoneDemo  ownerName:CKOwnerDefaultName];
        }else{
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:CKRecordZoneDefaultName  ownerName:CKOwnerDefaultName];
        }
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
            NSString *recordIDAsString;
            
            //set the contact's key_id
            for (NSArray *subArray in para){
                recordIDAsString = [subArray objectAtIndex:1];
            }
            
            CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordIDAsString zoneID:recordZone];

            CKContainer *myContainer = [CKContainer containerWithIdentifier:EQRCloudKitContainer];
            CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
            [privateDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
                
                if (!error){
                    //successfully saved record
                    //__________!!!!!!!!!!!!    THIS IS UGLY    !!!!!!!!!!!!_______________
                    NSLog(@"successfully pulled record");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        EQRContactNameItem *newRecord = [[EQRContactNameItem alloc] init];
                        newRecord.key_id = record.recordID.recordName;
                        newRecord.first_name = [record objectForKey:@"first_name"];
                        newRecord.last_name = [record objectForKey:@"last_name"];
                        newRecord.first_and_last = [record objectForKey:@"first_and_last"];
                        
                        completeBlock(newRecord);
                    });
                    
                }else{
                    NSLog(@"failed to pull record with this error: %@", error);
                }
            }];
        }];
    }
}



-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString selector:(SEL)action completion:(CompletionBlockWithBool)completeBlock{
    
    NSLog(@"queryWithAsync with: %@", link);
    
//    self.completionBlockSignalFlag = NO;

    self.aSyncSelector = action;
    
    [self authenticateICloud];
    
    if ([link isEqualToString:@"EQGetAllContactNames.php"]){
        
        CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"decommissioned != %@", @"1"];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Contact" predicate:predicate];
        
        EQRModeManager *modeManager = [EQRModeManager sharedInstance];
        BOOL isInDemoMode = [modeManager isInDemoMode];
        
        CKRecordZoneID *recordZone;
        
        if (isInDemoMode){
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:EQRRecordZoneDemo  ownerName:CKOwnerDefaultName];
        }else{
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:CKRecordZoneDefaultName  ownerName:CKOwnerDefaultName];
        }
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
            [privateDatabase performQuery:query inZoneWithID:recordZone completionHandler:^(NSArray *results, NSError *error) {
                if (error) {
                    // Error handling for failed fetch from public database
                    NSLog(@"Error handling for failed fetch from private database: %@", error);
                    completeBlock(NO);
                }
                else {
                    // Display the fetched records
                    //                NSLog(@"Display the fetched records with count: %ld", (unsigned long)[results count]);
                    
                    for (CKRecord *recordObject in results){
                        EQRContactNameItem *newRecord = [[EQRContactNameItem alloc] init];
                        newRecord.key_id = recordObject.recordID.recordName;
                        newRecord.first_name = [recordObject objectForKey:@"first_name"];
                        newRecord.last_name = [recordObject objectForKey:@"last_name"];
                        newRecord.first_and_last = [recordObject objectForKey:@"first_and_last"];
                        
                        [self asyncDispatchWithObject:newRecord];
                    }
                    
                    self.delayedCompletionBlock = completeBlock;
                    [self sendAsyncCompletionBlock];
                }
            }];
        }];
    }
    
    if ([link isEqualToString:@"EQGetEQRoomStaffAndInterns.php"]){
        
        CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"current_eq_staff beginswith '1'"];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Contact" predicate:predicate];
        
        EQRModeManager *modeManager = [EQRModeManager sharedInstance];
        BOOL isInDemoMode = [modeManager isInDemoMode];
        
        CKRecordZoneID *recordZone;
        
        if (isInDemoMode){
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:EQRRecordZoneDemo  ownerName:CKOwnerDefaultName];
        }else{
            recordZone = [[CKRecordZoneID alloc] initWithZoneName:CKRecordZoneDefaultName  ownerName:CKOwnerDefaultName];
        }
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
            [privateDatabase performQuery:query inZoneWithID:recordZone completionHandler:^(NSArray *results, NSError *error) {
                if (error) {
                    // Error handling for failed fetch from public database
                    NSLog(@"Error handling for failed fetch from private database: %@", error);
                    completeBlock(NO);
                }
                else {
                    // Display the fetched records
                    //                NSLog(@"Display the fetched records with count: %ld", (unsigned long)[results count]);
                    
                    for (CKRecord *recordObject in results){
                        EQRContactNameItem *newRecord = [[EQRContactNameItem alloc] init];
                        newRecord.key_id = recordObject.recordID.recordName;
                        newRecord.first_name = [recordObject objectForKey:@"first_name"];
                        newRecord.last_name = [recordObject objectForKey:@"last_name"];
                        newRecord.first_and_last = [recordObject objectForKey:@"first_and_last"];
                        newRecord.phone = [recordObject objectForKey:@"phone"];
                        newRecord.email = [recordObject objectForKey:@"email"];
                        
                        [self asyncDispatchWithObject:newRecord];
                    }
                    
                    self.delayedCompletionBlock = completeBlock;
                    [self sendAsyncCompletionBlock];
                }
            }];
        }];
        
    }
}

#pragma mark - async dispatch

-(void)asyncDispatchWithObject:(id)currentThing {

    if (self.delegateDataFeed != nil){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegateDataFeed addASyncDataItem:currentThing toSelector:self.aSyncSelector];
        });
    }
}


-(void)sendAsyncCompletionBlock{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //___Very importand that this if statement is INSIDE the dispatch
        if (self.delayedCompletionBlock != nil){
            
//            NSLog(@"CloudData > is sending a completion block" );
            
            self.delayedCompletionBlock(YES);
//            self.delayedCompletionBlock = nil;
        }
    });
}







@end
