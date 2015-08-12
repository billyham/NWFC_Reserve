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

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - methods

-(void)initialSetupWithTitle:(NSString*) titleName isHidden:(BOOL)yesHidden isSearchResult:(BOOL)yesSearch{
        
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
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
//    newLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    //reveal button
    UIButton* thisRevealButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect thatRect = CGRectMake((self.contentView.frame.size.width / 2) -45, self.contentView.frame.origin.y, 90, self.contentView.frame.size.height);
    thisRevealButton.frame = thatRect;
    
    if (yesHidden){
        [thisRevealButton setTitle:@"Expand" forState:UIControlStateNormal];
        [thisRevealButton setTitle:@"Expanding" forState:UIControlStateHighlighted];
    }else{
        [thisRevealButton setTitle:@"Hide" forState:UIControlStateNormal];
        [thisRevealButton setTitle:@"Collapsing" forState:UIControlStateHighlighted];
    }
    
    
    [thisRevealButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [thisRevealButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    //add button target
    [thisRevealButton addTarget:self action:@selector(revealButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //assign to ivar
    self.revealButton = thisRevealButton;
    
    
    //all button
    UIButton* thisAllButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect peasRect = CGRectMake(self.contentView.frame.size.width - 150, self.contentView.frame.origin.y , 140, self.contentView.frame.size.height);
    thisAllButton.frame = peasRect;
    [thisAllButton setTitle:[NSString stringWithFormat:@"%@ %@", thisRevealButton.titleLabel.text, @"All"] forState:UIControlStateNormal];
    [thisAllButton setTitle:[NSString stringWithFormat:@"%@ %@", thisRevealButton.titleLabel.text, @"All"] forState:UIControlStateHighlighted];
    [thisAllButton setTitle:[NSString stringWithFormat:@"%@ %@", thisRevealButton.titleLabel.text, @"All"] forState:UIControlStateSelected];
    [thisAllButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [thisAllButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    //add all button
    [thisAllButton addTarget:self action:@selector(allButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //assign to ivar
    self.allButton = thisAllButton;
    
    
    //make the entire header cell a button to reveal or hide
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(revealButtonTapped:)];
    [self addGestureRecognizer:tapGesture];
    self.userInteractionEnabled = YES;
    
    
    //add subviews
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.revealButton];
    [self.contentView addSubview:self.allButton];
    
    //if search result, disable hide and expand buttons    
    [self.revealButton setHidden:yesSearch];
    [self.allButton setHidden:yesSearch];

    
}

-(void)updateButtons{
    
    NSLog(@"is this thing on??");

    
    //change text of button
    BOOL isCurrentlyHidden = NO;
    for (NSString* sectionString in [self.delegate retrieveArrayOfEquipSectionsThatShouldBeHidden]){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
            isCurrentlyHidden = YES;
            break;
        }
    }
    
    if (isCurrentlyHidden){
        
        [self.revealButton setTitle:@"Hide" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        [self.allButton setTitle:@"Hide All" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        
    }else{
        
        [self.revealButton setTitle:@"Expand" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
        [self.allButton setTitle:@"Expand All" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
    }

    
}


#pragma mark - notification

//-(void)refreshViewFromAllButton:(NSNotification*)note{
//    
//    NSDictionary* thisDic = [note userInfo];
//    NSString* insertOrDelete = [thisDic objectForKey:@"type"];
//    
//    if ([insertOrDelete isEqualToString:@"insert"]){
//        
//        if ([self.revealButton.titleLabel.text isEqualToString:@"Hide"]){
//            
//            [self.revealButton setTitle:@"Expand" forState:UIControlStateNormal];
//        }
//        
//    }else{
//        
//        if ([self.revealButton.titleLabel.text isEqualToString:@"Expand"]){
//            
//            [self.revealButton setTitle:@"Hide" forState:UIControlStateNormal];
//        }
//    }
//    
//}


#pragma mark - disclosure methods

-(IBAction)revealButtonTapped:(id)sender{
    
    //inform the delegate about the status of hide/reveal for persistence
    
    //change text of button
    BOOL isCurrentlyHidden = NO;
    for (NSString* sectionString in [self.delegate retrieveArrayOfEquipSectionsThatShouldBeHidden]){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
            isCurrentlyHidden = YES;
        }
    }
    
    if (isCurrentlyHidden){
        
        [self.revealButton setTitle:@"Hide" forState:UIControlStateNormal];
        
    }else{
        
        [self.revealButton setTitle:@"Expand" forState:UIControlStateNormal];
    }
    
    //update private request Manager to do the action and keep persistence
    [self.delegate collapseOrExpandSection:self.titleLabel.text WithAll:NO];
}


-(IBAction)allButtonTapped:(id)sender{
    
    //inform the delegate about the status of hide/reveal for persistence
    
    //change text of button
    BOOL isCurrentlyHidden = NO;
    for (NSString* sectionString in [self.delegate retrieveArrayOfEquipSectionsThatShouldBeHidden]){
        
        if ([sectionString isEqualToString:self.titleLabel.text]){
            
            isCurrentlyHidden = YES;
        }
    }
    
    if (isCurrentlyHidden){
        
        [self.revealButton setTitle:@"Hide" forState:UIControlStateNormal];
        
    }else{
        
        [self.revealButton setTitle:@"Expand" forState:UIControlStateNormal];
    }
    
    //update private request Manager to do the action and keep persistence
    [self.delegate collapseOrExpandSection:self.titleLabel.text WithAll:YES];
    
    
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
