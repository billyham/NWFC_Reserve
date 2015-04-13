//
//  EQRSettings1TableVC.h
//  Gear
//
//  Created by Ray Smith on 4/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRPasswordEntryVC.h"
#import "EQRGenericTextEditor.h"

@interface EQRSettings1TableVC : UITableViewController  <EQRPasswordEntryDelegate, UIPopoverControllerDelegate, EQRGenericTextEditorDelegate, UITableViewDelegate>

-(IBAction)urlTextFieldDidChange:(id)sender;
-(IBAction)termTextFieldDidChange:(id)sender;
-(IBAction)campTermTextFieldDidChange:(id)sender;

//passwordEntryVC delegate methods
-(void)passwordEntered:(BOOL)passwordSuccessful;

//EQRGenericTextEditorDelegate methods
-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;

@end
