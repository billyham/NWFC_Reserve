//
//  EQRScheduleNestedDayCell.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/25/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRScheduleNestedDayCell.h"
#import "EQRGlobals.h"

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

-(void)longPressMethod:(UILongPressGestureRecognizer *)gesture{
    
    NSLog(@"long press is pressed pants");
    
    if (gesture.state == UIGestureRecognizerStateBegan){
        
        //make cell invisible
        [self setHidden:YES];
        
        
        
        //send message to collectionViewController to create a new view object at the cell's location and size
        CGRect frameSize = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        //translate coordinates from cell to view controller
        CGRect frameSizeInSuperViewCooridnates = [self convertRect:frameSize toView:self.superview.superview.superview.superview.superview];
        
        //save cgrect as an object
        NSValue* frameSizeValue = [NSValue valueWithCGRect:frameSizeInSuperViewCooridnates];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 frameSizeValue, @"frameSizeValue",
                                 nil];
        
        //send note to EQRScheduleTopVCntrllr
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
        
        
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged){
                
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        
        //make cell invisible
        [self setHidden:NO];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled){
        
        //make cell invisible
        [self setHidden:NO];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
    }
    
    if (gesture.state == UIGestureRecognizerStateFailed){
        
        //make cell invisible
        [self setHidden:NO];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
        
    }
}

@end
