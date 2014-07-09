//
//  EQRTapRadioButtonView.h
//  NWFC Reserve
//
//  Created by Ray Smith on 7/9/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRTapRadioButtonView : UIView

@property (strong, nonatomic) IBOutlet UIColor* innerCircleColor;

//-(void)initialSetup;

-(void)tapped;

@end

