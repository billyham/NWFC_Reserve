//
//  EQRCheckVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRCheckVCntrllr : UIViewController

@property (strong, nonatomic) NSString* scheduleRequestKeyID;

-(void)initialSetupWithInfo:(NSDictionary*)userInfo;

@end
