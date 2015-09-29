//
//  EQRPriceMatrixCllctnViewContentVC.h
//  Gear
//
//  Created by Ray Smith on 9/25/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRPriceMatrixCllctnViewContentVC : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *equipNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *distIdLabel;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UITextField *costField;

-(void)initialSetupWithName:(NSString *)name distID:(NSString *)distID cost:(NSString *)cost;

@end
