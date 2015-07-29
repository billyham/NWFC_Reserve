//
//  EQRContactPickerVC.h
//  Gear
//
//  Created by Ray Smith on 11/16/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRContactAddNewVC.h"
#import "EQRWebData.h"

@protocol EQRContactPickerDelegate;


@interface EQRContactPickerVC : UIViewController <UITableViewDataSource, UITableViewDelegate, EQRContactAddDelegate, UISearchDisplayDelegate, EQRWebDataDelegate>{
    
    __weak id <EQRContactPickerDelegate> delegate;
}

@property (weak, nonatomic) id <EQRContactPickerDelegate> delegate;

-(void)replaceDefaultContactArrayWith:(NSArray*)substituteContactArray;
-(id)retrieveContactItem;

//EQRContactAddDelegate method
-(void)informAdditionHasHappended:(EQRContactNameItem*)newContact;

//webData dataFeedDelegate methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action;

@end


@protocol EQRContactPickerDelegate <NSObject>
-(void)retrieveSelectedNameItem;

@optional
-(void)retrieveSelectedNameItemWithObject:(id)contactObject;

@end