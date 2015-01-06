//
//  EQRCheckPrintPage.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 6/4/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@interface EQRCheckPrintPage : UIViewController <NSLayoutManagerDelegate>

@property (nonatomic, strong) NSString* rentorNameAtt;
@property (nonatomic, strong) NSString* rentorPhoneAtt;
@property (nonatomic, strong) NSString* rentorEmailAtt;


@property (nonatomic, strong) IBOutlet UITextView* summaryTextView;
@property (nonatomic, strong) NSTextStorage* summaryTextStorage;

@property (nonatomic, strong) NSMutableAttributedString* datesAtt;
@property (nonatomic, strong) NSMutableAttributedString* summaryTotalAtt;


@property (nonatomic, strong) IBOutlet UIButton* dismissButton;



-(void)initialSetupWithScheduleRequestItem:(EQRScheduleRequestItem*)request;

-(IBAction)dismissMe:(id)sender;

@end
