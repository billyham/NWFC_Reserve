//
//  EQREquipOptionsTableVC.h
//  Gear
//
//  Created by Ray Smith on 12/8/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQREquipOptionsDelegate;

@interface EQREquipOptionsTableVC : UITableViewController{
    
    __weak id <EQREquipOptionsDelegate> delegate;
}

@property (weak, nonatomic) id <EQREquipOptionsDelegate>  delegate;

@property BOOL showAllEquipFlag;
@property BOOL allowSameDayFlag;
@property BOOL allowConflictFlag;

@end


@protocol EQREquipOptionsDelegate <NSObject>

-(void)optionsSelectionMade;

@end