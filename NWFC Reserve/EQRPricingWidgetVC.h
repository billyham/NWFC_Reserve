//
//  EQRPricingWidgetVC.h
//  Gear
//
//  Created by Ray Smith on 10/5/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRTransaction.h"

@interface EQRPricingWidgetVC : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *editButton;

-(void)initialSetupWithTransaction:(EQRTransaction *)transaction pricingCategory:(NSString *)pricingCategory;
-(void)deleteExistingData;

@end
