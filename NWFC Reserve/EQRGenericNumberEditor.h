//
//  EQRGenericNumberEditor.h
//  Gear
//
//  Created by Dave Hanagan on 9/29/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRGenericNumberEditorDelegate;

@interface EQRGenericNumberEditor : UIViewController{
    
    __weak id <EQRGenericNumberEditorDelegate> delegate;
}

@property (weak, nonatomic) id <EQRGenericNumberEditorDelegate> delegate;

-(void)initalSetupWithTitle:(NSString *)title subTitle:(NSString *)subtitle currentText:(NSString *)currentText returnMethod:(NSString *)returnMethod;



@end


@protocol EQRGenericNumberEditorDelegate <NSObject>

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;
-(void)cancelByDismissingVC;

@end