//
//  EQRStaffPage1VCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRPasswordEntryVC.h"
#import "EQRGenericTextEditor.h"

@interface EQRStaffPage1VCntrllr : UIViewController <EQRPasswordEntryDelegate, UIPopoverControllerDelegate, EQRGenericTextEditorDelegate>

-(IBAction)urlTextFieldDidChange:(id)sender;
-(IBAction)termTextFieldDidChange:(id)sender;
-(IBAction)campTermTextFieldDidChange:(id)sender;

//passwordEntryVC delegate methods
-(void)passwordEntered:(BOOL)passwordSuccessful;

//EQRGenericTextEditorDelegate methods
-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;

@end
