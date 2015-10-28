//
//  EQRGenericBlockOfTextEditor.h
//  Gear
//
//  Created by Ray Smith on 10/27/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - completion block definition
typedef void (^CompletionBlock) ();


@protocol EQRGenericBlockOfTextTextEditorDelegate;

@interface EQRGenericBlockOfTextEditor : UIViewController{
    __weak id <EQRGenericBlockOfTextTextEditorDelegate> delegate;
}

@property (weak, nonatomic) id <EQRGenericBlockOfTextTextEditorDelegate> delegate;

-(void)initalSetupWithTitle:(NSString *)title
                   subTitle:(NSString *)subtitle
                currentText:(NSString *)currentText
                   keyboard:(NSString *)keyboard
               returnMethod:(NSString *)returnMethod;

@end


@protocol EQRGenericBlockOfTextTextEditorDelegate <NSObject>

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;
-(void)cancelByDismissingVC;

@end