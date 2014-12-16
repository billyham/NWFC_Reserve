//
//  EQRNotesVC.h
//  Gear
//
//  Created by Ray Smith on 12/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@protocol EQRNoteDelegate;

@interface EQRNotesVC : UIViewController{
    
    __weak id <EQRNoteDelegate> delegate;
}

@property (weak, nonatomic) id <EQRNoteDelegate> delegate;

-(void)initialSetupWithScheduleRequest:(EQRScheduleRequestItem*)requestItem;

@end


@protocol EQRNoteDelegate <NSObject>

-(void)retrieveNotesData:(NSString*)noteText;

@end