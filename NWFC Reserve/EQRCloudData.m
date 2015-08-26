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
#import "EQRClassCatalog.h"
#import "EQRClassItem.h"

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
    
    //___________When does this get called??? ever??
    
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
    
    EQRModeManager *modeManager = [EQRModeManager sharedInstance];
    BOOL isInDemoMode = [modeManager isInDemoMode];
    
    CKRecordZoneID *recordZone;
    
    if (isInDemoMode){
        recordZone = [[CKRecordZoneID alloc] initWithZoneName:EQRRecordZoneDemo  ownerName:CKOwnerDefaultName];
    }else{
        recordZone = [[CKRecordZoneID alloc] initWithZoneName:CKRecordZoneDefaultName  ownerName:CKOwnerDefaultName];
    }
    
    
    if ([link isEqualToString:@"EQSetNewContact.php"]){
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
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
        return;
    }
    
    if ([link isEqualToString:@"EQGetContactNameWithKey.php"]){

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
        return;
    }
    
    if ([link isEqualToString:@"EQGetClassCatalogTitleWithKey.php"]){
        
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
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ([record objectForKey:@"title"]){
                            
                            completeBlock([record objectForKey:@"title"]);
                            
                        }else{
                            //error handling when no recoredName is returend
                            NSLog(@"EQRCloudData > queryForStringAsync for EQGetClassCatalogTitleWithKey, no key returned  %@", error);
                        }
                    });
                    
                }else{
                    NSLog(@"failed to pull record with this error: %@", error);
                }
            }];
        }];

        return;
    }
    
    if ([link isEqualToString:@"EQSetNewClassCatalog.php"]){
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
            CKRecord *classCatalogRecord = [[CKRecord alloc] initWithRecordType:@"ClassCatalog" zoneID:recordZone];
            
            //set the contact's key_id
            for (NSArray *subArray in para){
                
                classCatalogRecord[[subArray objectAtIndex:0]] = [subArray objectAtIndex:1];
            }
            
            classCatalogRecord[@"decommissioned" ] = @"";
            
            CKContainer *myContainer = [CKContainer containerWithIdentifier:EQRCloudKitContainer];
            CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
            [privateDatabase saveRecord:classCatalogRecord completionHandler:^(CKRecord *record, NSError *error) {
                
                if (!error){
                    //successfully saved record
                    //__________!!!!!!!!!!!!    THIS IS UGLY    !!!!!!!!!!!!_______________
//                    NSLog(@"successfully saved record");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        completeBlock(record.recordID.recordName);
                    });
                    
                }else{
                    
                    NSLog(@"failed to save record with this error: %@", error);
                }
            }];
        }];

        return;
    }
    
    if ([link isEqualToString:@"EQSetNewClassSection.php"]){
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
            CKRecord *classSectionRecord = [[CKRecord alloc] initWithRecordType:@"ClassSection" zoneID:recordZone];
            
            //set the contact's key_id
            for (NSArray *subArray in para){
                
                classSectionRecord[[subArray objectAtIndex:0]] = [subArray objectAtIndex:1];
            }
            
            CKContainer *myContainer = [CKContainer containerWithIdentifier:EQRCloudKitContainer];
            CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
            [privateDatabase saveRecord:classSectionRecord completionHandler:^(CKRecord *record, NSError *error) {
                
                if (!error){

                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        completeBlock(record.recordID.recordName);
                    });
                    
                }else{
                    
                    NSLog(@"failed to save record with this error: %@", error);
                }
            }];
        }];
        
        return;
    }
}



-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString selector:(SEL)action completion:(CompletionBlockWithBool)completeBlock{
    
    NSLog(@"queryWithAsync with: %@", link);
    
//    self.completionBlockSignalFlag = NO;

    self.aSyncSelector = action;
    
    [self authenticateICloud];
    
    EQRModeManager *modeManager = [EQRModeManager sharedInstance];
    BOOL isInDemoMode = [modeManager isInDemoMode];
    
    CKRecordZoneID *recordZone;
    
    if (isInDemoMode){
        recordZone = [[CKRecordZoneID alloc] initWithZoneName:EQRRecordZoneDemo  ownerName:CKOwnerDefaultName];
    }else{
        recordZone = [[CKRecordZoneID alloc] initWithZoneName:CKRecordZoneDefaultName  ownerName:CKOwnerDefaultName];
    }
    
    if ([link isEqualToString:@"EQGetAllContactNames.php"]){
        
        CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"decommissioned != %@", @"1"];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Contact" predicate:predicate];

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
        return;
    }
    
    if ([link isEqualToString:@"EQGetEQRoomStaffAndInterns.php"]){
        
        //_________!!!!!!!!!!!   AAAUUUUGGHHHH!!!!! CKQUERY can't do OR comparisons   !!!!!!!!_______________
        
        CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(current_eq_staff beginswith '1') AND (decommissioned != '1')"];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(current_eq_intern beginswith '1') AND (decommissioned != '1')"];
        NSMutableSet *set1 = [NSMutableSet setWithCapacity:1];
        NSMutableSet *set2 = [NSMutableSet setWithCapacity:1];
        
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Contact" predicate:predicate1];
        CKQuery *query2 = [[CKQuery alloc] initWithRecordType:@"Contact" predicate:predicate2];
        
        [self confirmExistenceOfZone:recordZone.zoneName completion:^(BOOL successBool) {
            
            [privateDatabase performQuery:query inZoneWithID:recordZone completionHandler:^(NSArray *results, NSError *error) {
                if (error) {
                    // Error handling for failed fetch from public database
                    NSLog(@"Error handling for failed fetch from private database: %@", error);
                    completeBlock(NO);
                }
                else {
 
                    for (CKRecord *recordObject in results){
                        EQRContactNameItem *newRecord = [[EQRContactNameItem alloc] init];
                        newRecord.key_id = recordObject.recordID.recordName;
                        newRecord.first_name = [recordObject objectForKey:@"first_name"];
                        newRecord.last_name = [recordObject objectForKey:@"last_name"];
                        newRecord.first_and_last = [recordObject objectForKey:@"first_and_last"];
                        newRecord.phone = [recordObject objectForKey:@"phone"];
                        newRecord.email = [recordObject objectForKey:@"email"];
                        
                        [set1 addObject:newRecord];
                    }
                    
                    [privateDatabase performQuery:query2 inZoneWithID:recordZone completionHandler:^(NSArray *results, NSError *error) {
                        if (error) {
                            // Error handling for failed fetch from public database
                            NSLog(@"Error handling for failed fetch from private database: %@", error);
                            completeBlock(NO);
                        }
                        else {
                         
                            for (CKRecord *recordObject in results){
                                BOOL foundInSet1 = NO;

                                for (EQRContactNameItem *recordFromSet1 in set1){
                                    
                                    if ([recordFromSet1.key_id isEqualToString:recordObject.recordID.recordName]){
                                        foundInSet1 = YES;
                                        break;
                                    }
                                }
                                
                                if (foundInSet1 == NO){
                                    
                                    EQRContactNameItem *newRecord = [[EQRContactNameItem alloc] init];
                                    newRecord.key_id = recordObject.recordID.recordName;
                                    newRecord.first_name = [recordObject objectForKey:@"first_name"];
                                    newRecord.last_name = [recordObject objectForKey:@"last_name"];
                                    newRecord.first_and_last = [recordObject objectForKey:@"first_and_last"];
                                    newRecord.phone = [recordObject objectForKey:@"phone"];
                                    newRecord.email = [recordObject objectForKey:@"email"];
                                    
                                    [set2 addObject:newRecord];
                                }
                            }
                            
                            //combine the sets
                            [set1 unionSet:set2];
                            
                            //send EQRContactNameItems back
                            for (EQRContactNameItem *recordObjectYep in set1){
                                
                                [self asyncDispatchWithObject:recordObjectYep];
                                
                                self.delayedCompletionBlock = completeBlock;
                                [self sendAsyncCompletionBlock];
                            }
                        }
                    }];
                }
            }];
        }];
        return;
    }
    
    if ([link isEqualToString:@"EQGetClassesAll.php"]){
        
        //_______!!!!!!!!!!  NEEDS TO GET INSTRUCTOR INFO FROM CLASS CATALOG RECORD TYPE   !!!!!!!!!!___________
        
        CKDatabase *privateDatabase = [[CKContainer containerWithIdentifier:EQRCloudKitContainer] privateCloudDatabase];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"ClassSection" predicate:predicate];
        
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
                        EQRClassItem *newRecord = [[EQRClassItem alloc] init];
                        newRecord.key_id = recordObject.recordID.recordName;
                        newRecord.section_name = [recordObject objectForKey:@"section_name"];
                        newRecord.term = [recordObject objectForKey:@"term"];
                        newRecord.instructor_foreign_key = [recordObject objectForKey:@"instructor_foreign_key"];
                        newRecord.catalog_foreign_key = [recordObject objectForKey:@"catalog_foreign_key"];
                        
                        [self asyncDispatchWithObject:newRecord];
                    }
                    
                    self.delayedCompletionBlock = completeBlock;
                    [self sendAsyncCompletionBlock];
                }
            }];
        }];
        return;
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
