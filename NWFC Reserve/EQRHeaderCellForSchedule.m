//
//  EQRHeaderCellForSchedule.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/24/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRHeaderCellForSchedule.h"
#import "EQRScheduleRequestManager.h"

@implementation EQRHeaderCellForSchedule

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
