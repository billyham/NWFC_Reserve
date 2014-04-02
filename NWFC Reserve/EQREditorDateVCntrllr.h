//
//  EQREditorDateVCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 4/1/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREditorDateVCntrllr : UIViewController 

@property (strong, nonatomic) IBOutlet UIDatePicker* pickupDateField;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnDateField;
@property (strong, nonatomic) IBOutlet UIButton* saveButton;

@end
