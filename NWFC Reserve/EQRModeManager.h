//
//  EQRModeManager.h
//  NWFC Reserve
//
//  Created by Ray Smith on 8/11/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRModeManager : NSObject

@property BOOL isInKioskMode;
@property BOOL isInManagerMode;
@property BOOL isInDemoMode;

+(EQRModeManager*)sharedInstance;

-(void)enableKioskMode;
-(void)enableStaffMode;
-(void)enableManagerMode;

-(void)enableDemoMode:(BOOL)demoModeIsOn;

@end
