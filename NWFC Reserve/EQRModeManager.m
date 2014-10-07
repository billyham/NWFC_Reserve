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


-(void)enableDemoMode{
    
    
}



@end
