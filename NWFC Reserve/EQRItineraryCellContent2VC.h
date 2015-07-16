//
//  EQRItineraryCellContent2VC.h
//  Gear
//
//  Created by Ray Smith on 7/7/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRItineraryCellContent2VC : UIViewController

@property BOOL markedForReturning;
@property NSUInteger myStatus;
@property (strong, nonatomic) NSString* requestKeyId;

@property (strong, nonatomic) IBOutlet UIView *subViewFullSize;

@property (strong, nonatomic) IBOutlet UIImageView *arrow;
@property (strong, nonatomic) IBOutlet UIImageView *bigArrow1;
@property (strong, nonatomic) IBOutlet UIImageView *bigArrow2;

@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;

@property (strong, nonatomic) IBOutlet UILabel *textOverButton1;
@property (strong, nonatomic) IBOutlet UILabel *textOverButton2;

@property (strong, nonatomic) IBOutlet UILabel *requestTime;
@property (strong, nonatomic) IBOutlet UILabel *requestName;
@property (strong, nonatomic) IBOutlet UILabel *requestRenterType;
@property (strong, nonatomic) IBOutlet UILabel *requestClass;

@property (strong, nonatomic) IBOutlet UILabel *button1Status;
@property (strong, nonatomic) IBOutlet UILabel *button2Status;


//button methods

-(IBAction)switch1Fires:(id)sender;
-(IBAction)switch2Fires:(id)sender;

@end
