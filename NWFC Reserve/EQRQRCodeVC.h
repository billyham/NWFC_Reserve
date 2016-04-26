//
//  EQRQRCodeVC.h
//  Gear
//
//  Created by Dave Hanagan on 4/26/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRQRCodeVC : UIViewController <UIPrintInteractionControllerDelegate>

-(void)initialSetupWithCode:(NSString *)code Name:(NSString *)name Number:(NSString *)number;

@end
