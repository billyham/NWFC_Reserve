//
//  EQRHeaderCellForSchedule.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/24/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRHeaderCellForSchedule.h"
#import "EQRScheduleRequestManager.h"
#import "EQRGlobals.h"

@implementation EQRHeaderCellForSchedule

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)initialSetupWithTitle:(NSString*) titleName isHidden:(BOOL)yesHidden{
    
    //receive notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(buttonHighlightResponse:) name:EQRButtonHighlight object:nil];
    [nc addObserver:self selector:@selector(buttonTurnOffHighlight:) name:EQRButtonUnHighlight object:nil];
    
    
    //cell's background color
    self.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    
    //size!
    //    CGRect newSize = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (self.frame.size.height) + 10);
    //    self.frame = newSize;
    
    
    //label
    CGRect thisRect = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:thisRect];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName;
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.0];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor clearColor];
    
    //center label text
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    
    //if the button is selected, highlight it
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
//            self.titleLabel.textColor = [UIColor darkGrayColor];
        }
    }
    
    
    
    //reveal button
//    UIButton* thisRevealButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    CGRect thatRect = CGRectMake(self.contentView.frame.size.width - 100, self.contentView.frame.origin.y, 90, self.contentView.frame.size.height);
//    thisRevealButton.frame = thatRect;
//    
//    if (yesHidden){
//        [thisRevealButton setTitle:@"Expand" forState:UIControlStateNormal];
//        [thisRevealButton setTitle:@"Expanding" forState:UIControlStateHighlighted];
//    }else{
//        [thisRevealButton setTitle:@"Hide" forState:UIControlStateNormal];
//        [thisRevealButton setTitle:@"Collapsing" forState:UIControlStateHighlighted];
//    }
//    
//    
//    [thisRevealButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [thisRevealButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
//    //add button target
//    [thisRevealButton addTarget:self action:@selector(revealButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    //assign to ivar
//    self.revealButton = thisRevealButton;
    
    //add subviews
    [self.contentView addSubview:self.titleLabel];
//    [self.contentView addSubview:self.revealButton];
}


#pragma mark = notifcation methods

-(void)buttonHighlightResponse:(NSNotification*)note{
    
    NSString* titleString = [note.userInfo objectForKey:@"sectionString"];
    
    if ([titleString isEqualToString:self.titleLabel.text]){
        
        //found a match, so make visible the label
//        self.titleLabel.textColor = [UIColor darkGrayColor];
    }
    
}

-(void)buttonTurnOffHighlight:(NSNotification*)note{
    
    NSString* titleString = [note.userInfo objectForKey:@"sectionString"];
    
    
//    NSLog(@"button turn off fires with self.titlelabel.text = %@  and sectionString: %@", self.titleLabel.text, titleString);
    
    if ([titleString isEqualToString:self.titleLabel.text]){
        
        //found a match, so hide the label
//        self.titleLabel.textColor = [UIColor clearColor];
    }
    
    
}


#pragma mark - disclosure methods

-(IBAction)revealButtonTapped:(id)sender{
    
    //inform the request manager about the status of hide/reveal for persistence
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //change text of button
    BOOL isCurrentlyHidden = YES;
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
            isCurrentlyHidden = NO;
            
            break;
        }
    }
    
    if (isCurrentlyHidden){
        
        [self.revealButton setTitle:@"Hide" forState:UIControlStateNormal];
        
    }else{
        
        [self.revealButton setTitle:@"Expand" forState:UIControlStateNormal];
    }
    
    //update request Manager to do the action and keep persistence
    [requestManager collapseOrExpandSectionInSchedule:self.titleLabel.text];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
