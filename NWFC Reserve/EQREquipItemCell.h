//
//  EQEquipItemCell.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/25/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRCellTemplate.h"
#import "EQREquipItem.h"

@interface EQREquipItemCell : EQRCellTemplate

@property int itemQuantity;
@property (strong, nonatomic) IBOutlet NSString* itemQuantityString;


-(void)initialSetupWithTitle:(NSString*)titleName andEquipItem:(EQREquipItem*)titleItemObject;
-(IBAction)plusHit:(id)sender;

@end
