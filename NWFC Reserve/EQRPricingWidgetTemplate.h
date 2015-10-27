//
//  EQRPricingWidgetTemplate.h
//  Gear
//
//  Created by Ray Smith on 10/27/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRTransaction.h"

@interface EQRPricingWidgetTemplate : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *editButton;

-(void)initialSetupWithTransaction:(EQRTransaction *)transaction;
-(void)deleteExistingData;

@end
