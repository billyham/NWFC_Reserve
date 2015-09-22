//
//  EQRSigEquipListVC.h
//  Gear
//
//  Created by Ray Smith on 9/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@interface EQRSigEquipListVC : UIViewController

@property (strong, nonatomic) EQRScheduleRequestItem *requestItem;

-(void)loadTheData;

@end
