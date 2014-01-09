//
//  EQRCellTemplateVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREquipContentViewVCntrllr : UIViewController

@property (strong, nonatomic) IBOutlet UIButton* plusButton;
@property (strong, nonatomic) IBOutlet UIButton* minusButton;
@property (strong, nonatomic) IBOutlet UILabel* titleLabel;
@property (strong, nonatomic) IBOutlet UITextField* quantityTextField;

-(IBAction)addOneEquipItem:(id)sender;

@end
