//
//  EQRPageConstructor.h
//  Gear
//
//  Created by Dave Hanagan on 12/23/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRScheduleRequestItem.h"

typedef void (^CompletionBlockPageConstructor) (NSString *pdf_name, NSDate *pdf_timestamp);

@interface EQRPageConstructor : NSObject 

// sigImage and agreements can be nil
-(void)generatePDFWithScheduleRequestItem:(EQRScheduleRequestItem*)request
                       withSignatureImage:(UIImage *)sigImage
                               agreements:(NSArray *)arrayOfAgreements
                               completion:(CompletionBlockPageConstructor)completeBlock;

@end
