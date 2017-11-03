//
//  EQRCheckVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRDistIDPickerTableVC.h"
#import "EQRWebData.h"

@interface EQRCheckVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, EQRDistIDPickerDelegate, UIPopoverControllerDelegate, EQRWebDataDelegate>

@property (strong, nonatomic) NSString* scheduleRequestKeyID;
@property BOOL marked_for_returning;
@property NSUInteger switch_num;

-(void)initialSetupWithInfo:(NSDictionary*)userInfo;

//dist id picker delegate method
-(void)distIDSelectionMadeWithOriginalEquipUniqueKey:(NSString*)originalKeyID equipUniqueItem:(id)distEquipUniqueItem;

//webData DelegateDataFeed methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action;

@end
