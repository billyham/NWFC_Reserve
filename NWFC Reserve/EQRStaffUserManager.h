//
//  EQRStaffUserManager.h
//  NWFC Reserve
//
//  Created by Ray Smith on 8/6/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRContactNameItem.h"

@interface EQRStaffUserManager : NSObject <UITabBarControllerDelegate>

@property (strong, nonatomic) EQRContactNameItem* currentStaffUser;

+(EQRStaffUserManager*)sharedInstance;

- (void)goToKioskMode:(BOOL)isInKioskMode;
- (BOOL)currentKioskMode;

//UITabViewController delegate methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;

@end
