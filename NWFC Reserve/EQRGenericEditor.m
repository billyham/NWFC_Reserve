//
//  EQRGenericEditor.m
//  Gear
//
//  Created by Ray Smith on 10/27/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRGenericEditor.h"

//@interface EQRGenericEditor ()
//@end

@implementation EQRGenericEditor
@synthesize delegate;

- (void)initalSetupWithTitle:(NSString *)title subTitle:(NSString *)subtitle currentText:(NSString *)currentText keyboard:(NSString *)keyboard returnMethod:(NSString *)returnMethod {
    
}

- (void)setEnterButtonBlock:(void(^)(NSString *value))returnMethod {
    
}

@end
