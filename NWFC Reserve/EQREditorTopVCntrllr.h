//
//  EQREditorTopVCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQREditorRenterVCntrllr.h"
#import "EQRContactPickerVC.h"
#import "EQREditorEquipListCell.h"

@interface EQREditorTopVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, EQRRenterTypeDelegate, EQRContactPickerDelegate, UIPopoverControllerDelegate, UICollectionViewDelegateFlowLayout, EQREditorEquipCellDelegate>

@property (strong, nonatomic) NSString* scheduleRequestKeyID;
@property BOOL saveButtonTappedFlag;

-(void)initialSetupWithInfo:(NSDictionary*)userInfo;
-(IBAction)saveAction:(id)sender;
-(IBAction)deleteRequest:(id)sender;
-(IBAction)addEquipItem:(id)sender;

//EQREditorEquipList Delegate methods
-(void)tagEquipUniqueToDelete:(NSString*)key_id;
-(void)tagEquipUniqueToCancelDelete:(NSString*)key_id;

@end
