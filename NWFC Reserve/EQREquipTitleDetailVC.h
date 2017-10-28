//
//  EQREquipTitleDetailVC.h
//  Gear
//
//  Created by Ray Smith on 10/18/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRVCWithDemoModePrompt.h"

@protocol EQREquipTitleDetailDelegate;

@interface EQREquipTitleDetailVC : EQRVCWithDemoModePrompt {
    __weak id <EQREquipTitleDetailDelegate> delegate;
}
@property (weak, nonatomic) id <EQREquipTitleDetailDelegate> delegate;

- (void)launchWithKey:(NSString *)keyId;

@end

@protocol EQREquipTitleDetailDelegate <NSObject>
- (void)reloadList;
- (void)reloadAndSelect:(NSString *)keyId;
@end
