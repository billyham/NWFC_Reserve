//
//  EQRItineraryVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRWebData.h"

typedef NS_OPTIONS(NSUInteger, EQRItineraryFilter){
    
    EQRGoingShelf = (1 << 0),  //00000001
    EQRGoingPrepped = (1 << 1),  //00000010
    EQRGoingPickedUp = (1 << 2),  //00000100
    EQRReturningOut = (1 << 3),  //00001000
    EQRReturningReturned = (1 << 4),  //00010000
    EQRReturningShelved = (1 << 5),  //00100000
    EQRFilterAll = 63,
    EQRFilterNone = 0
    
};


@interface EQRItineraryVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverControllerDelegate, EQRWebDataDelegate>

-(IBAction)applyFilter:(id)sender;


//webData DelegateDataFeed methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action;


@end
