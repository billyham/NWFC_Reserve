//
//  EQRScheduleCellContentVCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/20/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRNavBarDatesView.h"
#import "EQRNavBarWeeksView.h"


@interface EQRScheduleCellContentVCntrllr : UIViewController 

@property (strong, nonatomic) IBOutlet UILabel* myRowLabel;
@property (strong, nonatomic) IBOutlet EQRNavBarDatesView* navBarDates;
@property (strong, nonatomic) IBOutlet EQRNavBarWeeksView *navBarWeeks;
@property (strong, nonatomic) IBOutlet UIButton* serviceIssuesButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *weeksLeadingConstraint;
@property NSInteger weekIndicatorOffset;




@end
