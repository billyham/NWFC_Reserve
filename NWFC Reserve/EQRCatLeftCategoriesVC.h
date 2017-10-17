//
//  EQRCatLeftCategoriesVC.h
//  Gear
//
//  Created by Ray Smith on 9/18/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRTableVCWithDemoModePrompt.h"

@protocol EQRCatLeftCategoriesDelegate;

@interface EQRCatLeftCategoriesVC : EQRTableVCWithDemoModePrompt {
    __weak id <EQRCatLeftCategoriesDelegate> delegate;
}
@property (weak, nonatomic) id <EQRCatLeftCategoriesDelegate> delegate;
@end

@protocol EQRCatLeftCategoriesDelegate <NSObject>
- (void)didSelectCategory:(NSString *)selectedCategory;
- (void)didPassEquipTitleThroughCategory:(NSDictionary *)selectedEquipTitle;
@end
