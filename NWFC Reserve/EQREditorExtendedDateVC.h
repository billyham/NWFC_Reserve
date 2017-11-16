//
//  EQREditorExtendedDateVC.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQREditorDateVCntrllr.h"

@interface EQREditorExtendedDateVC : EQREditorDateVCntrllr

@property (strong, nonatomic) IBOutlet UIDatePicker* pickupTimeField;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnTimeField;

//-(NSDate*)retrievePickUpDate;
//-(NSDate*)retrieveReturnDate;

@end
