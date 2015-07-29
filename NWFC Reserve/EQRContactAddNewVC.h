//
//  EQRContactAddNewVC.h
//  Gear
//
//  Created by Ray Smith on 11/23/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRContactNameItem.h"

@protocol EQRContactAddDelegate;

@interface EQRContactAddNewVC : UIViewController{
    
    __weak id <EQRContactAddDelegate> delegate;
}

@property (weak, nonatomic) id <EQRContactAddDelegate> delegate;

-(IBAction)doneButton:(id)sender;

@end


@protocol EQRContactAddDelegate <NSObject>

-(void)informAdditionHasHappended:(EQRContactNameItem*)newContact;

@end

