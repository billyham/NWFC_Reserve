//
//  EQRScheduleNestedDayCell.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/25/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleNestedDayCell.h"

@interface EQRScheduleNestedDayCell ()

@property (strong, nonatomic) UILongPressGestureRecognizer* longPressGesture;

@end

@implementation EQRScheduleNestedDayCell


-(void)initialSetupWithTitle:(NSString*) titleName{
    
    self.backgroundColor = [UIColor clearColor];
    
    //make cell semi transparent to spot overlapping items in schedule
//    self.backgroundView.alpha = 0.5;
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, -20, 295, 50)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName; 
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:9.f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    //add a slight angle???
    CGAffineTransform thisTransform = CGAffineTransformMakeRotation(-0.1);
    self.titleLabel.transform = thisTransform;
    
    [self.contentView addSubview:self.titleLabel];
    
    //add long press gesture recog
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    [self addGestureRecognizer:self.longPressGesture];
    
}

-(void)longPressMethod:(id)gesture{
    
    NSLog(@"long press is pressed pants");
    
    
    
}

@end
