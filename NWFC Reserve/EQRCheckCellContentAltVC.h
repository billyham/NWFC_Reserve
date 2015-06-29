//
//  EQRCheckCellContentAltVC.h
//  Gear
//
//  Created by Ray Smith on 6/24/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRCheckCellContentAltVC : UIViewController

@property (strong, nonatomic) NSIndexPath* myIndexPath;
@property (strong, nonatomic) NSString* myJoinKeyID;
@property (strong, nonatomic) NSString* joinPropertyToBeUpdated;
@property (strong, nonatomic) NSString* equipUniqueItem_foreignKey;
@property (strong, nonatomic) NSString* equipTitleItem_foreignKey;


@property (strong, nonatomic) IBOutlet UILabel* equipNameLabel;
@property (strong, nonatomic) IBOutlet UIButton* distIDLabel;
//@property (strong, nonatomic) IBOutlet UILabel* status1Label;
//@property (strong, nonatomic) IBOutlet UILabel* status2Label;
@property (strong, nonatomic) IBOutlet UISwitch* statusSwitch;
//@property (strong, nonatomic) IBOutlet UIButton* serviceIssue;

@property BOOL isContentForMiscJoin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthContraint;


//-(void)initialSetupWithDeleteFlag:(BOOL)deleteFlag;

@end
