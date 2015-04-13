//
//  EQRSettingsLeftTableVC.h
//  Gear
//
//  Created by Ray Smith on 4/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRSettings1TableVC.h"


@interface EQRSettingsLeftTableVC : UITableViewController <EQRSettings1TableDelegate>

//EQRSettings1 page delegate
-(void)demoModeChanged:(BOOL)demoModeOn;
-(void)kioskModeChanged:(BOOL)kioskModeOn;

@end

