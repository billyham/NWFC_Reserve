//
//  EQRStatusBarView.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/21/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStatusBarView.h"
#import "EQRColors.h"

@implementation EQRStatusBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    if (!self.myColor){
        
        self.myColor = [UIColor lightGrayColor];
    }
    
    if (self.intID == 1){
        
        //// Rounded Rectangle Drawing
        UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPath];
        [roundedRectanglePath moveToPoint: CGPointMake(0, 10.5)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(10.5, 21) controlPoint1: CGPointMake(0, 16.3) controlPoint2: CGPointMake(4.7, 21)];
        [roundedRectanglePath addLineToPoint: CGPointMake(81, 21)];
        [roundedRectanglePath addLineToPoint: CGPointMake(97, 0)];
        [roundedRectanglePath addLineToPoint: CGPointMake(10.5, 0)];
        [roundedRectanglePath addCurveToPoint: CGPointMake(0, 10.5) controlPoint1: CGPointMake(4.7, 0) controlPoint2: CGPointMake(0, 4.7)];
        [roundedRectanglePath closePath];
        [self.myColor setFill];
        [roundedRectanglePath fill];\
        
        
    } else if (self.intID == 2){
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(87.5, 21)];
        [bezierPath addLineToPoint: CGPointMake(103.5, 0)];
        [bezierPath addLineToPoint: CGPointMake(193.5, 0)];
        [bezierPath addLineToPoint: CGPointMake(176.5, 21)];
        [self.myColor setFill];
        [bezierPath fill];
    
        
    } else if (self.intID == 3){
        
        //// Rounded Rectangle 2 Drawing
        UIBezierPath* roundedRectangle2Path = [UIBezierPath bezierPath];
        [roundedRectangle2Path moveToPoint: CGPointMake(280, 10.5)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(269.5, 0) controlPoint1: CGPointMake(280, 4.7) controlPoint2: CGPointMake(275.3, 0)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(199, 0)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(183, 21)];
        [roundedRectangle2Path addLineToPoint: CGPointMake(269.5, 21)];
        [roundedRectangle2Path addCurveToPoint: CGPointMake(280, 10.5) controlPoint1: CGPointMake(275.3, 21) controlPoint2: CGPointMake(280, 16.3)];
        [roundedRectangle2Path closePath];
        [self.myColor setFill];
        [roundedRectangle2Path fill];
        
    }

}


@end
