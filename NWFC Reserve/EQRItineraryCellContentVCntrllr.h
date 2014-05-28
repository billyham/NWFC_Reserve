//
//  EQRItineraryCellContentVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRStatusBarView.h"


@interface EQRItineraryCellContentVCntrllr : UIViewController

@property (strong, nonatomic) IBOutlet UILabel* interactionTime;
@property (strong, nonatomic) IBOutlet UILabel* firstLastName;
@property (strong, nonatomic) IBOutlet UILabel* switchLabel1;
@property (strong, nonatomic) IBOutlet UILabel* switchLabel2;
@property (strong, nonatomic) IBOutlet UILabel* cautionLabel1;
@property (strong, nonatomic) IBOutlet UILabel* cautionLabel2;
@property (strong, nonatomic) IBOutlet UILabel* renterType;
@property (strong, nonatomic) IBOutlet UISwitch* switch1;
@property (strong, nonatomic) IBOutlet UISwitch* switch2;


//??
@property BOOL showPrepSwitch;
@property BOOL showShelfSwitch;
//

@property (strong, nonatomic) EQRStatusBarView* firstStatusBar;
@property (strong, nonatomic) EQRStatusBarView* secondStatusBar;
@property (strong, nonatomic) EQRStatusBarView* thirdStatusBar;

@property BOOL markedForReturning;
@property NSUInteger myStatus;

@property (strong, nonatomic) NSString* requestKeyId;


-(IBAction)switch1Fires:(id)sender;
-(IBAction)switch2Fires:(id)sender;


@end
