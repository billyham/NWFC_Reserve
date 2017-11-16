//
//  EQREditorDateVCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 4/1/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREditorDateVCntrllr : UIViewController

- (void)setPickupDate:(NSDate *)puDate returnDate:(NSDate *)reDate;
- (void)setShowExtended:(NSString *)method withTarget:(id)target;
- (void)setSaveSelector:(NSString *)method forTarget:(id)target;
- (void)setPickupAction:(NSString *)pickupMethod returnAction:(NSString *)returnMethod forTarget:(id)target;

- (void)setReturnDateAnimated:(NSDate *)date;
- (void)setReturnMax:(NSDate *)date;
- (void)setReturnMin:(NSDate *)date;

- (NSDate *)retrievePickUpDate;
- (NSDate *)retrieveReturnDate;

@end
