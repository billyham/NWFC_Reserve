//
//  EQRStaffUserManager.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/6/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffUserManager.h"

@implementation EQRStaffUserManager


+(EQRStaffUserManager*)sharedInstance{
    
    static EQRStaffUserManager* myInstance = nil;
    
    if (!myInstance) {
        
        myInstance = [[EQRStaffUserManager alloc] init];
    }
    
    return myInstance;
}


@end


