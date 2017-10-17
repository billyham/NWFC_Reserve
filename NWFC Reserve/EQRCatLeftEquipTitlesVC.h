//
//  EQRCatLeftEquipTitlesVC.h
//  Gear
//
//  Created by Ray Smith on 9/18/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRTableVCWithDemoModePrompt.h"

@protocol EQRCatEquipTitleDelegate;

@interface EQRCatLeftEquipTitlesVC : EQRTableVCWithDemoModePrompt {
    __weak id <EQRCatEquipTitleDelegate> delegate;
}
@property (weak, nonatomic) id <EQRCatEquipTitleDelegate> delegate;
@property (strong, nonatomic) NSString *selectedCategory;
@end

@protocol EQRCatEquipTitleDelegate <NSObject>
- (void)didSelectEquipTitle:(NSDictionary *)selectedEquipTitle;
@end
