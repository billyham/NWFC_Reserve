//
//  EQREditorMiscListCell.h
//  Gear
//
//  Created by Ray Smith on 2/3/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQREditorMiscListContentVC.h"
#import "EQRMiscJoin.h"
#import "EQRGenericTextEditor.h"

@protocol EQREditorMiscCellDelegate;

@interface EQREditorMiscListCell : UICollectionViewCell <EQRGenericTextEditorDelegate> {
    __weak id <EQREditorMiscCellDelegate> delegate;
}

@property (weak, nonatomic) id <EQREditorMiscCellDelegate> delegate;
@property BOOL toBeDeletedFlag;
@property (strong, nonatomic) EQREditorMiscListContentVC* myContentVC;

-(void)initialSetupWithMiscJoin:(EQRMiscJoin*)miscJoin deleteFlag:(BOOL)deleteFlag editMode:(BOOL)editModeFlag;
-(void)enterEditMode;
-(void)leaveEditMode;

//generic text editor delegate method
-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod;


@end

@protocol EQREditorMiscCellDelegate <NSObject>

-(void)tagMiscJoinToDelete:(NSString*)key_id;
-(void)tagMiscJoinToCancelDelete:(NSString*)key_id;

@end


