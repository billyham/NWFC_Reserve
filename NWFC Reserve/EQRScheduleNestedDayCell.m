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
@property (nonatomic, strong) NSString* joinKeyID;
@property (nonatomic, strong) NSString* joinTitleKeyID;
@property (nonatomic, strong) NSIndexPath* indexPathForRowCell;

@end

@implementation EQRScheduleNestedDayCell


-(void)initialSetupWithTitle:(NSString*) titleName joinKeyID:(NSString*)joinKeyID joinTitleKeyID:(NSString*)joinTitleKeyID indexPath:(NSIndexPath*)indexPath{
    
    //set ivars
    self.joinKeyID = joinKeyID;
    self.joinTitleKeyID = joinTitleKeyID;
    self.indexPathForRowCell = indexPath;
    
    self.backgroundColor = [UIColor clearColor];
    
    //make cell semi transparent to spot overlapping items in schedule
//    self.backgroundView.alpha = 0.5;
    
    UILabel* thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, -20, 295, 50)];
    self.titleLabel = thisLabel;
    
    self.titleLabel.text = titleName; 
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:9.f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    //add a slight angle to the label
    CGAffineTransform thisTransform = CGAffineTransformMakeRotation(-0.1);
    self.titleLabel.transform = thisTransform;
    
    //apply rounded corners
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 4.0;
    
    [self.contentView addSubview:self.titleLabel];
    
    //add long press gesture recog
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    [self addGestureRecognizer:self.longPressGesture];
    
}

-(void)longPressMethod:(UILongPressGestureRecognizer *)gesture{
        
    if (gesture.state == UIGestureRecognizerStateBegan){
        
        //make cell invisible
        [self setHidden:YES];
        
        //original point with offset ...  I HAVE NO IDEA WHY THE X VALUE NEEDS TO REFERENCE THE CONTENTVIEW, BUT OTHERWISE IT DON'T WORK
        CGPoint originPoint = CGPointMake(
                                          self.contentView.frame.origin.x + EQRScheduleLengthOfEquipUniqueLabel,
                                          self.frame.origin.y);
        
        //Size is OK
        CGSize originSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        
        //convert values to other superview coordinates
        CGPoint convertedPointForX = [self convertPoint:originPoint toView:self.superview];
        CGPoint convertedPointForY = [self convertPoint:convertedPointForX toView:self.superview.superview.superview.superview.superview];
        
        //final CGRect
        CGRect frameSizeInSuperViewCooridnates = CGRectMake(convertedPointForX.x, convertedPointForY.y, originSize.width, originSize.height);
        
        //___this is the view hierarchy___
        //self
        //UICollectionView
        //UIView
        //EQRScheduleRowCell
        //UICollectionView
        //UIView
        //UIViewControllerWrapperView
        //UINavigationTransitionView
        //UILayoutContainerView
        
        //save cgrect as an object
        NSValue* frameSizeValue = [NSValue valueWithCGRect:frameSizeInSuperViewCooridnates];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 frameSizeValue, @"frameSizeValue",
                                 self.contentView.backgroundColor, @"color",
                                 nil];
        
        //send note to EQRScheduleTopVCntrllr
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
        
        
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged){
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
        
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        
        //____________don't make cell visible
//        [self setHidden:NO];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 self.joinKeyID, @"key_id",
                                 self.joinTitleKeyID, @"equipTitleItem_foreignKey",
                                 self.indexPathForRowCell, @"indexPath",
                                 nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
        
        //instead... send message to matching rowCell??? 
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled){
        
        //make cell visible
        [self setHidden:NO];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
    }
    
    if (gesture.state == UIGestureRecognizerStateFailed){
        
        //make cell visible
        [self setHidden:NO];
        
        NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 gesture, @"gesture",
                                 nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRLongPressOnNestedDayCell object:nil userInfo:userDic];
        
    }
}

@end
