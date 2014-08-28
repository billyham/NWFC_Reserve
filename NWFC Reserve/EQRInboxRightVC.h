//
//  EQRInboxRightVC.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@protocol EQRInboxRightDelegate;


@interface EQRInboxRightVC : UIViewController <UISplitViewControllerDelegate> {
    
    __weak id <EQRInboxRightDelegate> delegateForRightSide;
}

@property (weak, nonatomic) id <EQRInboxRightDelegate> delegateForRightSide;
@property (nonatomic, strong) UIPopoverController *popover;

-(void)renewTheView;

@end


@protocol EQRInboxRightDelegate <NSObject>

-(void)selectedRequest:(EQRScheduleRequestItem*)request;

@end
