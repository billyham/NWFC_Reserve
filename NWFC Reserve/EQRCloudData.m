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



@interface EQRCloudData ()



@end

@implementation EQRCloudData

//@synthesize delegateDataFeed;

+(EQRCloudData*)sharedInstance{
    
    EQRCloudData *myInstance = [[EQRCloudData alloc] init];
    return myInstance;
}

#pragma mark - public methods

-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock{
    
    [self authenticateICloud];
    
    if ([link isEqualToString:@"EQGetContactNameWithKey.php"]){
        
//        CKDatabase *privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
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
        
        CKDatabase *privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
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

-(void)authenticateICloud{
    
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
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


-(NSString*)queryForStringWithLink:(NSString*)link parameters:(NSArray*)para{
    
    if ([link isEqualToString:@"EQSetNewContact.php"]){
        
        CKRecord *contactRecord = [[CKRecord alloc] initWithRecordType:@"Contact"];
        
        for (NSArray *subArray in para){
            contactRecord[[subArray objectAtIndex:0]] = [subArray objectAtIndex:1];
        }
        
        contactRecord[@"decommissioned" ] = @"";
        
        CKContainer *myContainer = [CKContainer defaultContainer];
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



-(void)queryWithAsync:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString selector:(SEL)action completion:(CompletionBlockWithBool)completeBlock{
    
    
}

-(void)stopXMLParsing{
    
}


@end
