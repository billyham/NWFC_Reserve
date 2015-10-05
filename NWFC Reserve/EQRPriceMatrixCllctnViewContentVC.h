//
//  EQRPriceMatrixCllctnViewContentVC.h
//  Gear
//
//  Created by Ray Smith on 9/25/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRPriceMatrixContentDelegate;


@interface EQRPriceMatrixCllctnViewContentVC : UIViewController{
    __weak id <EQRPriceMatrixContentDelegate> delegate;
}

@property (weak, nonatomic) id <EQRPriceMatrixContentDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *equipNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *distIdLabel;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UITextField *costField;

-(void)initialSetupWithName:(NSString *)name distID:(NSString *)distID cost:(NSString *)cost joinKeyID:(NSString *)keyID indexPath:(NSIndexPath *)indexPath;

@end

@protocol EQRPriceMatrixContentDelegate <NSObject>

-(void)launchCostEditorWithJoinKeyID:(NSString *)joinKeyID isEquipJoin:(BOOL)isEquipJoin cost:(NSString *)cost indexPath:(NSIndexPath *)indexPath;

@end