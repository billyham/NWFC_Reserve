//
//  EQRSigCaptureMainVC.h
//  Gear
//
//  Created by Ray Smith on 6/23/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@interface EQRSigCaptureMainVC : UIViewController

-(void)loadTheDataWithRequestItem:(EQRScheduleRequestItem *)requestItem;

@end
