//
//  EQRPickerThenTextEditor.h
//  Gear
//
//  Created by Ray Smith on 1/28/18.
//  Copyright © 2018 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRGenericEditor.h"
#import "EQRGenericPickerVC.h"

@interface EQRPickerThenTextEditor : NSObject

- (void)initialSetupWithPicker:(EQRGenericPickerVC *)picker callback:(void(^)(NSArray *values))cb;
- (void)addTextEditor:(EQRGenericEditor *)genericEditor;
- (void)presentEditor:(UIViewController *)vc;

@end
