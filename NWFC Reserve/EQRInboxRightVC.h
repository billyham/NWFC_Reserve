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
#import "EQREditorMiscListCell.h"
#import "EQRDistIDPickerTableVC.h"
#import "EQRNotesVC.h"

@protocol EQRInboxRightDelegate;


@interface EQRInboxRightVC : UIViewController <UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate, UISearchBarDelegate, EQRContactPickerDelegate, EQRRenterTypeDelegate, EQRClassPickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EQREditorEquipCellDelegate, EQREditorMiscCellDelegate, UIPopoverControllerDelegate, EQRDistIDPickerDelegate, EQRNoteDelegate> {
    
    __weak id <EQRInboxRightDelegate> delegateForRightSide;
}

@property (weak, nonatomic) id <EQRInboxRightDelegate> delegateForRightSide;
@property (nonatomic, strong) UIPopoverController *popover;

-(void)renewTheViewWithRequest:(EQRScheduleRequestItem*)request;

//EQREditorEquipList Delegate methods
-(void)tagEquipUniqueToDelete:(NSString*)key_id;
-(void)tagEquipUniqueToCancelDelete:(NSString*)key_id;
-(void)distIDPickerTapped:(NSDictionary*)infoDictionary;

//EQREditorMiscCell Delegate methods
-(void)tagMiscJoinToDelete:(NSString*)key_id;
-(void)tagMiscJoinToCancelDelete:(NSString*)key_id;

//dist id picker delegate method
-(void)distIDSelectionMadeWithOriginalEquipUniqueKey:(NSString*)originalKeyID equipUniqueItem:(id)distEquipUniqueItem;

//notes delegate method
-(void)retrieveNotesData:(NSString*)noteText;

@end


@protocol EQRInboxRightDelegate <NSObject>

//-(EQRScheduleRequestItem*)selectedRequest;

@end
