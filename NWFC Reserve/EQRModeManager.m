//
//  EQRModeManager.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/11/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRModeManager.h"

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



@end
