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
#import "EQRInboxLeftTopVC.h"
#import "EQRGlobals.h"

@interface EQRStaffUserManager ()

@property BOOL isInKioskMode;
@property (strong, nonatomic) NSMutableArray* arrayOfHiddenVCs;

@end

@implementation EQRStaffUserManager


+ (EQRStaffUserManager*)sharedInstance{
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
    if (self.isInKioskMode){
        
        if (!self.arrayOfHiddenVCs){
            self.arrayOfHiddenVCs = [NSMutableArray arrayWithCapacity:1];
        }
        
        UIApplication* thisApp = [UIApplication sharedApplication];
        NSArray* originalArray = [(UITabBarController*)thisApp.keyWindow.rootViewController viewControllers];
        NSMutableArray* arrayToKeep = [NSMutableArray arrayWithCapacity:1];
        for (UIViewController* thisVC in originalArray){
            
            if ([thisVC.title isEqualToString:@"Request"]){
                [arrayToKeep addObject:thisVC];
            }else if ([thisVC.title isEqualToString:@"Month"]){
                [self.arrayOfHiddenVCs insertObject:thisVC  atIndex:0];
            }else if ([thisVC.title isEqualToString:@"Day"]){
                [self.arrayOfHiddenVCs insertObject:thisVC atIndex:0];
            }else if ([thisVC.title isEqualToString:@"Inbox"]){
                [self.arrayOfHiddenVCs insertObject:thisVC atIndex:0];
            }else if ([thisVC.title isEqualToString:@"Catalog"]){
                [self.arrayOfHiddenVCs insertObject:thisVC atIndex:0];
            }else if ([thisVC.title isEqualToString:@"Settings"]){
                [arrayToKeep addObject:thisVC];
            }else{
                NSLog(@"EQRStaffUserManager > goToKioskMode  Failed to identify the VC");
            }
        }
        [(UITabBarController*)thisApp.keyWindow.rootViewController setViewControllers:arrayToKeep];
        
    } else {
        
        UIApplication* thisApp = [UIApplication sharedApplication];
        NSArray* originalArray = [(UITabBarController*)thisApp.keyWindow.rootViewController viewControllers];
        NSMutableArray* arrayToKeep = [NSMutableArray arrayWithCapacity:1];
        
        // Combined hidden and visible arrays
        [arrayToKeep addObjectsFromArray:originalArray];
        for (UIViewController *object in self.arrayOfHiddenVCs){
            if (EQRHideCatalog == YES && [object.title isEqualToString:@"Catalog"]) {
                continue;
            }
            [arrayToKeep insertObject:object atIndex:1];
        }
        
        [self.arrayOfHiddenVCs removeAllObjects];
        
        [(UITabBarController*)thisApp.keyWindow.rootViewController setViewControllers:arrayToKeep];
    }
}


#pragma mark - UITabViewController delegate methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
//    if (self.isInKioskMode == NO){
//        
//        return YES;
//        
//    }else{
//        
//        NSString* classString;
//        
//        if ([viewController class] == [UINavigationController class]){
//            
////            NSLog(@"this is the viewController class inside the navigation controller: %@", [[(UINavigationController*)viewController topViewController] class]);
//            
//            classString = [NSString stringWithFormat:@"%@", [[(UINavigationController*)viewController topViewController] class]];
//            
//        }else{
//            
//            if ([viewController class] == [UISplitViewController class]){
//                
////                NSLog(@"this is the viewController class: %@", [[[(UISplitViewController*)viewController viewControllers] objectAtIndex:0] class]);
//                
//                classString = [NSString stringWithFormat:@"%@", [viewController class]];
//            }
//        }
//        
//        if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRReserveTopVCntrllr class]]]){
//            return YES;
//        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [UISplitViewController class]]]){  //uisplitview is inbox
//            return NO;
//        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRItineraryVCntrllr class]]]){
//            return NO;
//        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRScheduleTopVCntrllr class]]]){
//            return NO;
//        }else if ([classString isEqualToString:[NSString stringWithFormat:@"%@", [EQRStaffPage1VCntrllr class]]]){
//            return YES;
//        }else{
//            return YES;
//        }
//    }
    
    return YES;
}


@end


