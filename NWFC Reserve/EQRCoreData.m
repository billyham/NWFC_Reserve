//
//  EQRCoreData.m
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import "EQRCoreData.h"
#import "EQRAppDelegate.h"
#import "EQRPersistenceController.h"

//@class EQRAppDelegate;

@interface EQRCoreData()
@property(strong, nonatomic) NSManagedObjectContext *moc;
@end

@implementation EQRCoreData

+(EQRCoreData*)sharedInstance{
    
    EQRCoreData *coreData = (EQRCoreData *)[super sharedInstance];
    
    // TODO: replace with dependency injection
    EQRAppDelegate *appDelegate = (EQRAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[appDelegate persistenceController] managedObjectContext];
    coreData.moc = moc;
    
    return coreData;
}

-(void) queryWithLink:(NSString*)link parameters:(NSArray*)para class:(NSString*)classString completion:(CompletionBlockWithArray)completeBlock{
 
    NSLog(@"core data fires");
    
    [super queryWithLink:link parameters:para class:classString completion:completeBlock];
}

@end
