//
//  EQRPDFGenerator.h
//  Gear
//
//  Created by Ray Smith on 12/7/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRPDFGenerator : NSObject

@property (strong, nonatomic) UITextView *myTextView;

-(void)launchPDFGenerator;

@end
