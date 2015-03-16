//
//  EQRInboxLeftTableVC.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRInboxRightVC.h"
#import "EQRWebData.h"

@protocol EQRInboxLeftTableDelegate;


@interface EQRInboxLeftTableVC : UITableViewController <EQRInboxRightDelegate, EQRWebDataDelegate>{
    
    __weak id <EQRInboxLeftTableDelegate> delegateForLeftSide;

}

@property (weak, nonatomic) id <EQRInboxLeftTableDelegate> delegateForLeftSide;

//webData dataFeedDelegate methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action;

@end




@protocol EQRInboxLeftTableDelegate <NSObject>

-(NSString*)selectedInboxOrArchive;

@optional
-(NSDictionary*)getDateRange;

@end