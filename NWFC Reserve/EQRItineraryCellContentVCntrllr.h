//
//  EQRItineraryCellContentVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRItineraryCellContentVCntrllr : UIViewController

@property (strong, nonatomic) IBOutlet UILabel* interactionTime;
@property (strong, nonatomic) IBOutlet UILabel* firstLastName;
@property (strong, nonatomic) IBOutlet UILabel* checkInOrOut;
@property (strong, nonatomic) IBOutlet UILabel* renterType;
@property BOOL showPrepSwitch;
@property BOOL showShelveSwitch;

@end
