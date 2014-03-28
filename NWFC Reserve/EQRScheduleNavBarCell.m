//
//  EQRHeaderForNavBar.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/26/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleNavBarCell.h"
#import "EQRGlobals.h"
#import "EQRScheduleRequestManager.h"

@implementation EQRScheduleNavBarCell

-(void)initialSetupWithTitle:(NSString*) titleName{
    
    //receive notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(buttonHighlightResponse:) name:EQRButtonHighlight object:nil];
    [nc addObserver:self selector:@selector(buttonTurnOffHighlight:) name:EQRButtonUnHighlight object:nil];
    
        self.clipsToBounds = YES;
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.f];
    //set text color
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    //center label text
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:self.titleLabel];
    
    //if the button is selected, highlight it
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
            self.titleLabel.backgroundColor = [UIColor yellowColor];
        }
    }
    
    
}


-(void)buttonHighlightResponse:(NSNotification*)note{
    
    NSString* titleString = [note.userInfo objectForKey:@"sectionString"];
    
    if ([titleString isEqualToString:self.titleLabel.text]){
        
        //found a match, so Highlight the button
        self.titleLabel.backgroundColor = [UIColor yellowColor];
    }
    
}

-(void)buttonTurnOffHighlight:(NSNotification*)note{
    
    NSString* titleString = [note.userInfo objectForKey:@"sectionString"];
    
    
    NSLog(@"button turn off fires with self.titlelabel.text = %@  and sectionString: %@", self.titleLabel.text, titleString);
    
    if ([titleString isEqualToString:self.titleLabel.text]){
        
        //found a match, so UN-highlight the button
        self.titleLabel.backgroundColor = [UIColor clearColor];
    }
    
    
}


@end
