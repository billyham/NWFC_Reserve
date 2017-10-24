//
//  EQREquipTitlePricesTVC.h
//  Gear
//
//  Created by Ray Smith on 10/19/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQREquipTitlePricesDelegate;

@interface EQREquipTitlePricesTVC : UITableViewController {
    __weak id <EQREquipTitlePricesDelegate> delegate;
}

@property (weak, nonatomic) id <EQREquipTitlePricesDelegate> delegate;

- (void)setText:(NSDictionary *)properties;

@end

@protocol EQREquipTitlePricesDelegate
- (void)propertySelection:(NSString *)property value:(NSString *)value;
@end
