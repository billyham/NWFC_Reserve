//
//  EQREquipSelectionGenericVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/6/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "EQREquipItemCell.h"
#import "EQREquipOptionsTableVC.h"
#import "EQRNotesVC.h"


@interface EQREquipSelectionGenericVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EQREquipOptionsDelegate, EQRNoteDelegate, UIPopoverControllerDelegate>{
    
    
}

@property (nonatomic, strong) IBOutlet UICollectionView* equipCollectionView;
@property (nonatomic, strong) IBOutlet UIButton* continueButton;
@property BOOL isInPopover;

-(void)overrideSharedRequestManager:(id)privateRequestManager;

//equip options delegate method
-(void)optionsSelectionMade;

//notes delegate method
-(void)retrieveNotesData:(NSString*)noteText;

@end


