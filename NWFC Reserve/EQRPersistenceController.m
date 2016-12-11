//
//  EQRPersistenceController.m
//  Gear
//
//  Created by Ray Smith on 8/3/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//


//With a little help from: http://martiancraft.com/blog/2015/03/core-data-stack/

#import "EQRPersistenceController.h"

@interface EQRPersistenceController()

@property (strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong) NSManagedObjectContext *privateContext;
@property (strong) InitCallbackBlock initCallback;

- (void)initializeCoreData;

@end

@implementation EQRPersistenceController

- (id)initWithCallback:(InitCallbackBlock)callback{
    
    if (!(self = [super init])) return nil;
    
    [self setInitCallback:callback];
    [self initializeCoreData];
    
    return self;
}

- (void)initializeCoreData{
    
    if ([self managedObjectContext]) return;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Gear" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    ZAssert(mom, @"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
//    ZAssert(coordinator, @"Failed to initialize coordinator");
    
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    
    [self setPrivateContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [[self privateContext] setPersistentStoreCoordinator:coordinator];
    [[self managedObjectContext] setParentContext:[self privateContext]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSPersistentStoreCoordinator *psc = [[self privateContext] persistentStoreCoordinator];
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        options[NSSQLitePragmasOption] = @{ @"journal_mode":@"DELETE"};
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL * storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
        
        NSError *error = nil;
//        ZAssert([psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error], @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
        
        if (![self initCallback]) return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self initCallback];
        });
    });
}

- (void)save{
    
    if (![[self privateContext] hasChanges] && ![[self managedObjectContext] hasChanges]) return;
    
    [[self managedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        
//        ZAssert([[self managedObjectContext] save:&error], @"Failed to save main context: %@\n%@", [error localizedDescription], [error userInfo]);

        [[self privateContext] performBlock:^{
            NSError *privateError = nil;
//            ZAssert([[self privateContext] save:&privateError], @"Error saving private context: %@\n%@", [privateError localizedDescription], [privateError userInfo]);
        }];
    }];
}

@end
