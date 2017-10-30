//
//  EQRGenericEditor.h
//  Gear
//
//  Created by Ray Smith on 10/27/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRGenericEditorDelegate;

@interface EQRGenericEditor : UIViewController{
    __weak id <EQRGenericEditorDelegate> delegate;
}
@property (weak, nonatomic) id <EQRGenericEditorDelegate> delegate;

-(void)initalSetupWithTitle:(NSString *)title
                   subTitle:(NSString *)subtitle
                currentText:(NSString *)currentText
                   keyboard:(NSString *)keyboard
               returnMethod:(NSString *)returnMethod;

@end

@protocol EQRGenericEditorDelegate <NSObject>

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;
-(void)cancelByDismissingVC;

@end
