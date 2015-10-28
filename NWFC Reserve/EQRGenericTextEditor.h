//
//  EQRGenericTextEditor.h
//  Gear
//
//  Created by Ray Smith on 3/10/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - completion block definition
typedef void (^CompletionBlock) ();


@protocol EQRGenericTextEditorDelegate;

@interface EQRGenericTextEditor : UIViewController{
    __weak id <EQRGenericTextEditorDelegate> delegate;
}

@property (weak, nonatomic) id <EQRGenericTextEditorDelegate> delegate;

-(void)initalSetupWithTitle:(NSString *)title subTitle:(NSString *)subtitle currentText:(NSString *)currentText keyboard:(NSString *)keyboard returnMethod:(NSString *)returnMethod;

@end


@protocol EQRGenericTextEditorDelegate <NSObject>

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;
-(void)cancelByDismissingVC;

@end