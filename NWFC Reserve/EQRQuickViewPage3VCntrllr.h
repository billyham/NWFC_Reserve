//
//  EQRQuickViewPage3VCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 8/11/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"


@interface EQRQuickViewPage3VCntrllr : UIViewController

-(void)initialSetupWithScheduleItem:(EQRScheduleRequestItem*)scheduleRequest;

-(IBAction)duplicate:(id)sender;
-(IBAction)split:(id)sender;
-(IBAction)print:(id)sender;

@end
