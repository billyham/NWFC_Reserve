//
//  EQRAppDelegate.h
//  NWFC Reserve
//
//  Created by Japhy Ryder on 11/6/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EQRPersistenceController;

@interface EQRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, readonly) EQRPersistenceController *persistenceController;

@end
