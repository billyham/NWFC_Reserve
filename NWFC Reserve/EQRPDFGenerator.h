//
//  EQRPDFGenerator.h
//  Gear
//
//  Created by Ray Smith on 12/7/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRMultiColumnTextView.h"

@interface EQRPDFGenerator : NSObject

@property (strong, nonatomic) UITextView *myTextView;
@property (strong, nonatomic) EQRMultiColumnTextView *myMultiColumnView;
@property float additionalXAdjustment;
@property (strong, nonatomic) UIImage *sigImage;
@property BOOL hasSigImage;

-(void)launchPDFGenerator;

@end
