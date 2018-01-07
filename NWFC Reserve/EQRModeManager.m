//
//  EQRModeManager.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/11/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRModeManager.h"
#import "EQRColors.h"
#import "EQRGlobals.h"

@implementation EQRModeManager


+(EQRModeManager*)sharedInstance{
    static EQRModeManager* myInstance = nil;
    if (!myInstance){
        myInstance = [[EQRModeManager alloc] init];
    }
    return myInstance;
}


-(void)enableKioskMode{
    
}


-(void)enableStaffMode{
    
}


-(void)enableManagerMode{
    
}


-(void)enableDemoMode:(BOOL)demoModeIsOn{
    
    //change user defaults with new string text
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *setStringForDefaults;
    if (demoModeIsOn){
        setStringForDefaults = @"yes";
        self.isInDemoMode = YES;
    }else{
        setStringForDefaults = @"no";
        self.isInDemoMode = NO;
    }
    
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            setStringForDefaults, @"demoModeIsOn"
                            , nil];
    
    [defaults setObject:newDic forKey:@"demoModeIsOn"];
    [defaults synchronize];
}

-(void)alterNavigationBar:(UINavigationBar *)navBar navigationItem:(UINavigationItem *)navItem isInDemo:(BOOL)isInDemo {
    
    if (isInDemo){
        if (EQRSuppressDemoColor == NO){

            EQRColors* colors = [EQRColors sharedInstance];
            navBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
            navBar.barStyle = UIBarStyleBlackOpaque;
            navBar.tintColor = [colors.colorDic objectForKey:EQRColorDemoNavItems];
            
            for (UIBarButtonItem *button in navItem.leftBarButtonItems){
                button.tintColor = [colors.colorDic objectForKey:EQRColorDemoNavItems];
            }
            for (UIBarButtonItem *button in navItem.rightBarButtonItems){
                button.tintColor = [colors.colorDic objectForKey:EQRColorDemoNavItems];
            }
        }
    }else{
        navBar.barTintColor = nil;
        navBar.barStyle = UIBarStyleDefault;
        navBar.tintColor = nil;
        
        for (UIBarButtonItem *button in navItem.leftBarButtonItems){
            button.tintColor = nil;
        }
        for (UIBarButtonItem *button in navItem.rightBarButtonItems){
            button.tintColor = nil;
        }
    }
}



@end
