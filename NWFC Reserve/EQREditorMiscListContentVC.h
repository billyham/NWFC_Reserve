//
//  EQREditorMiscListContentVC.h
//  Gear
//
//  Created by Ray Smith on 2/3/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREditorMiscListContentVC : UIViewController

@property (strong, nonatomic) IBOutlet UIButton* myDeleteButton;
@property (strong, nonatomic) IBOutlet UILabel* myLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* labelTrailingConstraint;

@end
