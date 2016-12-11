//
//  EQRPersistenceController.h
//  Gear
//
//  Created by Ray Smith on 8/3/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^InitCallbackBlock)(void);

@interface EQRPersistenceController : NSObject

@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithCallback:(InitCallbackBlock)callback;
- (void)save;

@end
