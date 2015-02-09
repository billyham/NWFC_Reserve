//
//  EQRStaffUserManager.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/6/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffUserManager.h"
#import "EQRReserveTopVCntrllr.h"
#import "EQRItineraryVCntrllr.h"
#import "EQRScheduleTopVCntrllr.h"
#import "EQRStaffPage1VCntrllr.h"

@interface EQRStaffUserManager ()

@property BOOL isInKioskMode;

@end

@implementation EQRStaffUserManager


+(EQRStaffUserManager*)sharedInstance{
    
    static EQRStaffUserManager* myInstance = nil;
    
    if (!myInstance) {
        
        myInstance = [[EQRStaffUserManager alloc] init];
    }
    
    return myInstance;
}

- (BOOL)currentKioskMode{
    
    return self.isInKioskMode;
}


- (void)goToKioskMode:(BOOL)isInKioskMode{
    
    self.isInKioskMode = isInKioskMode;
    
}


//UITabViewController delegate methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    if (self.isInKioskMode == NO){
        
        return YES;
        
    }else{
        
        NSString* classString;
        
        if ([viewController class] == [UINavigationController class]){
            
//            NSLog(@"this is the viewController class inside the navigation controller: %@", [[(UINavigationController*)viewController topViewController] class]);
            
            classString = [NSString stringWithFormat:@"%@", [[(UINavigationController*)viewController topViewController] class]];
            
        }else{
            
            if ([viewController class] == [UISplitViewController class]){
                
//                NSLog(@"this is the viewController class: %@", [[[(UISplitViewController*)viewController viewControllers] objectAtIndex:0] class]);
                
                classString = [NSString stringWithFormat:@"%@", [viewController class]];
            }
        }
        
        if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRReserveTopVCntrllr class]]]){
            return YES;
        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [UISplitViewController class]]]){  //uisplitview is inbox
            return NO;
        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRItineraryVCntrllr class]]]){
            return NO;
        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRScheduleTopVCntrllr class]]]){
            return NO;
        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRStaffPage1VCntrllr class]]]){
            return YES;
        }else{
            return YES;
        }
    }
}


@end


