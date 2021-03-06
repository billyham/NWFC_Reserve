//
//  EQRSettings2TableVC.h
//  Gear
//
//  Created by Ray Smith on 4/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRGenericTextEditor.h"

@interface EQRSettings2TableVC : UITableViewController <EQRGenericEditorDelegate>

-(IBAction)urlTextFieldDidChange:(id)sender;

//EQRGenericEditorDelegate methods
-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;

@end
