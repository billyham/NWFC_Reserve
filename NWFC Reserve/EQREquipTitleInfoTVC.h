//
//  EQREquipTitleInfoTVC.h
//  Gear
//
//  Created by Ray Smith on 10/19/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQREquipTitleInfoDelegate;

@interface EQREquipTitleInfoTVC : UITableViewController {
    __weak id <EQREquipTitleInfoDelegate> delegate;
}

@property (weak, nonatomic) id <EQREquipTitleInfoDelegate> delegate;

- (void)setText:(NSDictionary *)properties;

@end

@protocol EQREquipTitleInfoDelegate

@end
