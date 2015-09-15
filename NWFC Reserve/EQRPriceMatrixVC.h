//
//  EQRPriceMatrixVC.h
//  Gear
//
//  Created by Dave Hanagan on 9/14/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@interface EQRPriceMatrixVC : UIViewController

-(void)startNewTransaction:(EQRScheduleRequestItem *)request;
-(void)editExistingTransaction:(EQRScheduleRequestItem *)request;
@end


