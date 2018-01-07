//
//  EQRMultiTextEditorVC.h
//  Gear
//
//  Created by Ray Smith on 12/23/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRGenericEditor.h"

@protocol EQRMultiTextEditorDelegate;

@interface EQRMultiTextEditorVC : NSObject{
    __weak id <EQRMultiTextEditorDelegate> delegate;
}
@property (weak, nonatomic) id <EQRMultiTextEditorDelegate> delegate;

- (void)initialSetupWithReturnCallback:(void(^)(NSArray *values))cb;
- (void)pushNewTextEditor:(EQRGenericEditor *)genericEditor;
- (void)presentEditor:(UIViewController *)vc;

@end

@protocol EQRMultiTextEditorDelegate <NSObject>

@optional
//- (void)returnWithTextArray:(NSArray *)returnTextArray method:(NSString *)returnMethod;
//- (void)cancelByDismissingVC;
@end
