//
//  EQRGenericPickerVC.h
//  Gear
//
//  Created by Ray Smith on 1/18/18.
//  Copyright © 2018 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EQRGenericPickerVC : UIViewController 

- (void)initialSetupWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                        array:(NSArray *)array
                selectedValue:(NSString *)selectedValue;

@end
