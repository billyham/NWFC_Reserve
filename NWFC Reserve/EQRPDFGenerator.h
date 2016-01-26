//
//  EQRPDFGenerator.h
//  Gear
//
//  Created by Ray Smith on 12/7/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRMultiColumnTextView.h"

typedef void (^CompletionBlockPDFGenerator) ();

@interface EQRPDFGenerator : NSObject 

@property (strong, nonatomic) UITextView *myTextView;
@property (strong, nonatomic) EQRMultiColumnTextView *myMultiColumnView;
@property (strong, nonatomic) NSMutableArray *arrayOfMultiColumnTextViews;
@property float additionalXAdjustment;
@property (strong, nonatomic) UIImage *sigImage;
@property BOOL hasSigImage;


// agreements parameter can be nil
-(void)launchPDFGeneratorWithName:(NSString *)name
                            phone:(NSString *)phone
                            email:(NSString *)email
                       renterType:(NSString *)renterType
                       agreements:(NSArray *)arrayOfAgreements
                       completion:(CompletionBlockPDFGenerator)completeBlock;

@end
