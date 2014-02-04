//
//  EQREquipSummaryVCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 1/31/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREquipSummaryVCntrllr : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* rentorName;
@property (nonatomic, strong) IBOutlet UILabel* rentorPhone;
@property (nonatomic, strong) IBOutlet UILabel* rentorEmail;
@property (nonatomic, strong) IBOutlet UILabel* rentorPickupDateLabel;
@property (nonatomic, strong) IBOutlet UILabel* rentorReturnDateLabel;
@property (nonatomic, strong) IBOutlet UILabel* rentorEquipListLabel;
@property (nonatomic, strong) IBOutlet UITextView* summaryTextView;

@end
