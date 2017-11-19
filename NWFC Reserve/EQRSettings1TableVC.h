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
#import "EQRGenericBlockOfTextEditor.h"

@protocol EQRSettings1TableDelegate;

@interface EQRSettings1TableVC : UITableViewController  <EQRPasswordEntryDelegate,  EQRGenericEditorDelegate, UITableViewDelegate>{
    __weak id <EQRSettings1TableDelegate> delegate;
}
@property (weak, nonatomic) id <EQRSettings1TableDelegate> delegate;

-(IBAction)termTextFieldDidChange:(id)sender;
-(IBAction)campTermTextFieldDidChange:(id)sender;

@end


@protocol EQRSettings1TableDelegate <NSObject>
-(void)demoModeChanged:(BOOL)demoModeOn;
-(void)kioskModeChanged:(BOOL)kioskModeOn;
@end
