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
#import "EQRColors.h"

@implementation EQRScheduleNavBarCell

-(void)initialSetupWithTitle:(NSString*) titleName{
    
    //load colors
    EQRColors* myColors = [EQRColors sharedInstance];
    
    //receive notifications
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(buttonHighlightResponse:) name:EQRButtonHighlight object:nil];
    [nc addObserver:self selector:@selector(buttonTurnOffHighlight:) name:EQRButtonUnHighlight object:nil];
    
        self.clipsToBounds = YES;
    
    //____did this via nib instead___
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.titleLabel = thisLabel;
    
    //center label text
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.titleLabel.text = titleName;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10.f];
    //set text color
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.titleLabel];
    
    
    //add constraints.... this works, huzzah!
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = @{@"titleView":self.titleLabel};
    
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[titleView]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[titleView]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    NSArray *constraint_POS_VB = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleView]-1-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_HB = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[titleView]-1-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    [[self.titleLabel superview] addConstraints:constraint_POS_H];
    [[self.titleLabel superview] addConstraints:constraint_POS_V];
    [[self.titleLabel superview] addConstraints:constraint_POS_HB];
    [[self.titleLabel superview] addConstraints:constraint_POS_VB];

    
    
    
    //if the button is selected, highlight it
    EQRScheduleRequestManager* requestManager = [EQRScheduleRequestManager sharedInstance];
    for (NSString* sectionString in requestManager.arrayOfEquipSectionsThatShouldBeVisibleInSchedule){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
            self.titleLabel.backgroundColor = [myColors.colorDic objectForKey:EQRColorSelectionBlue];
        }
    }
    
    
}


-(void)buttonHighlightResponse:(NSNotification*)note{
    
    //load colors
    EQRColors* myColors = [EQRColors sharedInstance];
    
    NSString* titleString = [note.userInfo objectForKey:@"sectionString"];
    
    if ([titleString isEqualToString:self.titleLabel.text]){
        
        //found a match, so Highlight the button
        self.titleLabel.backgroundColor = [myColors.colorDic objectForKey:EQRColorSelectionBlue];
    }
    
}

-(void)buttonTurnOffHighlight:(NSNotification*)note{
    
    NSString* titleString = [note.userInfo objectForKey:@"sectionString"];
    
    
//    NSLog(@"button turn off fires with self.titlelabel.text = %@  and sectionString: %@", self.titleLabel.text, titleString);
    
    if ([titleString isEqualToString:self.titleLabel.text]){
        
        //found a match, so UN-highlight the button
        self.titleLabel.backgroundColor = [UIColor clearColor];
    }
    
    
}


@end
