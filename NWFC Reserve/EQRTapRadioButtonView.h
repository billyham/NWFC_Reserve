//
//  EQRTapRadioButtonView.h
//  NWFC Reserve
//
//  Created by Ray Smith on 7/9/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

@protocol EQRTapRadioButtonDelegate;


#import <UIKit/UIKit.h>

@interface EQRTapRadioButtonView : UIView{

    __weak id <EQRTapRadioButtonDelegate> delegate;
    
}

@property (nonatomic, weak) id <EQRTapRadioButtonDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIColor* innerCircleColor;
@property BOOL IAmSwitch2;

@end

@protocol EQRTapRadioButtonDelegate <NSObject>

-(IBAction)switch1Fires:(id)sender;
-(IBAction)switch2Fires:(id)sender;

@end