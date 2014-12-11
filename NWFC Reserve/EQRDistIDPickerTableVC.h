//
//  EQRDistIDPickerTableVC.h
//  Gear
//
//  Created by Ray Smith on 12/10/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@protocol EQRDistIDPickerDelegate;

@interface EQRDistIDPickerTableVC : UITableViewController{
    
    __weak id <EQRDistIDPickerDelegate> delegate;
}

@property (weak, nonatomic) id <EQRDistIDPickerDelegate> delegate;

-(void)initialSetupWithIndexPath:(NSIndexPath*)indexPath equipTitleKey:(NSString*)equipTitleKey scheduleItem:(EQRScheduleRequestItem*)scheduleItem;

@end


@protocol EQRDistIDPickerDelegate <NSObject>

-(void)distIDSelectionMade;

@end