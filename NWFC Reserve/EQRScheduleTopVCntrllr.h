//
//  EQRScheduleTopVCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRWebData.h"
#import "EQRClassPickerVC.h"

@interface EQRScheduleTopVCntrllr : UIViewController <UICollectionViewDelegateFlowLayout, EQRWebDataDelegate, UIPopoverPresentationControllerDelegate, EQRClassPickerDelegate>

//EQRWebData Delegate methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action;

//EQRClassPicker delegate
-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem;

@end
