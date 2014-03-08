//
//  EQRHeaderCellTemplate.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/7/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRHeaderCellTemplate.h"
#import "EQRScheduleRequestManager.h"
#import "EQRGlobals.h"

@interface EQRHeaderCellTemplate()

@property BOOL detailIsHiddenFlag;

@end

@implementation EQRHeaderCellTemplate

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - methods

-(void)initialSetupWithTitle:(NSString*) titleName isHidden:(BOOL)yesHidden{
    
    //cell's background color
    self.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    
    //label
    CGRect thisRect = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:thisRect];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
//    newLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    //reveal button
    UIButton* thisRevealButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect thatRect = CGRectMake(self.contentView.frame.size.width - 100, self.contentView.frame.origin.y, 90, self.contentView.frame.size.height);
    thisRevealButton.frame = thatRect;
    
    if (yesHidden){
        [thisRevealButton setTitle:@"Expand" forState:UIControlStateNormal];
        [thisRevealButton setTitle:@"Expanding" forState:UIControlStateHighlighted];
    }else{
        [thisRevealButton setTitle:@"Collapse" forState:UIControlStateNormal];
        [thisRevealButton setTitle:@"Collapsing" forState:UIControlStateHighlighted];
    }
    
    
    [thisRevealButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [thisRevealButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    //add button target
    [thisRevealButton addTarget:self action:@selector(revealButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //assign to ivar
    self.revealButton = thisRevealButton;
    
    //add subviews
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.revealButton];
}


#pragma mark - disclosure methods

-(IBAction)revealButtonTapped:(id)sender{
    
    //inform the request manager about the status of hide/reveal for persistence
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    
    //change text of button
    BOOL isCurrentlyHidden = NO;
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeHidden){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
            isCurrentlyHidden = YES;
        }
    }
    
    if (isCurrentlyHidden){
        
        [self.revealButton setTitle:@"Collapse" forState:UIControlStateNormal];
        
    }else{
        
        [self.revealButton setTitle:@"Expand" forState:UIControlStateNormal];
    }
    
    //update request Manager to do the action and keep persistence
    [requestManager collapseOrExpandSection:self.titleLabel.text];
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
