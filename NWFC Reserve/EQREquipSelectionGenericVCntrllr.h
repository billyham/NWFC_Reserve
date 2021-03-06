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
#import "EQRMiscEditVC.h"
#import "EQRScheduleRequestManager.h"


@interface EQREquipSelectionGenericVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EQREquipOptionsDelegate, EQRNoteDelegate, EQRMiscEditVCDelegate, EQREquipSelectionDelegate>{
}

@property (nonatomic, strong) IBOutlet UICollectionView* equipCollectionView;
@property (nonatomic, strong) IBOutlet UIButton* continueButton;
@property BOOL isInPopover;

- (void)overrideSharedRequestManager:(id)privateRequestManager;
- (IBAction)cancelTheThing:(id)sender;

//equip options delegate method
- (void)optionsSelectionMade;

//notes delegate method
- (void)retrieveNotesData:(NSString*)noteText;

//miscEditVC methods
- (void)receiveMiscData:(NSString *)miscItemText;

//scheduleRequestManager delegate method
- (void)refreshTheCollectionWithType:(NSString *)type SectionArray:(NSArray *)array;


@end

