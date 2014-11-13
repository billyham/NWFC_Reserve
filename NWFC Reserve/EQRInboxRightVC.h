//
//  EQRInboxRightVC.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EQRScheduleRequestItem.h"

@protocol EQRInboxRightDelegate;


@interface EQRInboxRightVC : UIViewController <UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    
    __weak id <EQRInboxRightDelegate> delegateForRightSide;
}

@property (weak, nonatomic) id <EQRInboxRightDelegate> delegateForRightSide;
@property (nonatomic, strong) UIPopoverController *popover;

-(void)renewTheViewWithRequest:(EQRScheduleRequestItem*)request;


@end


@protocol EQRInboxRightDelegate <NSObject>

//-(EQRScheduleRequestItem*)selectedRequest;

@end
