//
//  EQRInboxRightVC.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EQRScheduleRequestItem.h"
#import "EQRContactPickerVC.h"
#import "EQREditorRenterVCntrllr.h"
#import "EQRClassPickerVC.h"
#import "EQREditorEquipListCell.h"

@protocol EQRInboxRightDelegate;


@interface EQRInboxRightVC : UIViewController <UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UISearchBarDelegate, EQRContactPickerDelegate, EQRRenterTypeDelegate, EQRClassPickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EQREditorEquipCellDelegate, UIPopoverControllerDelegate> {
    
    __weak id <EQRInboxRightDelegate> delegateForRightSide;
}

@property (weak, nonatomic) id <EQRInboxRightDelegate> delegateForRightSide;
@property (nonatomic, strong) UIPopoverController *popover;

-(void)renewTheViewWithRequest:(EQRScheduleRequestItem*)request;

//EQREditorEquipList Delegate methods
-(void)tagEquipUniqueToDelete:(NSString*)key_id;
-(void)tagEquipUniqueToCancelDelete:(NSString*)key_id;

@end


@protocol EQRInboxRightDelegate <NSObject>

//-(EQRScheduleRequestItem*)selectedRequest;

@end
