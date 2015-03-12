//
//  EQRNavBarWeeksView.m
//  Gear
//
//  Created by Ray Smith on 3/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRNavBarWeeksView.h"

@implementation EQRNavBarWeeksView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
   
    if (self.isNarrowFlag){
        
        //when narrow, create lines that are 18px across. Otherwise, create lines that are 26px across
        
        //// Color Declarations
        UIColor* color4 = [UIColor colorWithRed: 0.779 green: 0.779 blue: 0.779 alpha: 1];
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(17, 0, 2, 30)];
        [color4 setFill];
        [rectanglePath fill];
        
        
        
        //// Rectangle 8 Drawing
        UIBezierPath* rectangle8Path = [UIBezierPath bezierPathWithRect: CGRectMake(143, 0, 2, 30)];
        [color4 setFill];
        [rectangle8Path fill];
        
        
        
        
        //// Rectangle 15 Drawing
        UIBezierPath* rectangle15Path = [UIBezierPath bezierPathWithRect: CGRectMake(269, 0, 2, 30)];
        [color4 setFill];
        [rectangle15Path fill];
        
        
        
        
        //// Rectangle 22 Drawing
        UIBezierPath* rectangle22Path = [UIBezierPath bezierPathWithRect: CGRectMake(395, 0, 2, 30)];
        [color4 setFill];
        [rectangle22Path fill];
        
        
        
        
        //// Rectangle 29 Drawing
        UIBezierPath* rectangle29Path = [UIBezierPath bezierPathWithRect: CGRectMake(521, 0, 2, 30)];
        [color4 setFill];
        [rectangle29Path fill];
        
        
        
    }else{
        
        //// Color Declarations
        UIColor* color3 = [UIColor colorWithRed: 0.779 green: 0.779 blue: 0.779 alpha: 0.5];
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(25, 0, 2, 30)];
        [color3 setFill];
        [rectanglePath fill];
        
        
        
        
        //// Rectangle 8 Drawing
        UIBezierPath* rectangle8Path = [UIBezierPath bezierPathWithRect: CGRectMake(207, 0, 2, 30)];
        [color3 setFill];
        [rectangle8Path fill];
        
        
        
        
        //// Rectangle 15 Drawing
        UIBezierPath* rectangle15Path = [UIBezierPath bezierPathWithRect: CGRectMake(389, 0, 2, 30)];
        [color3 setFill];
        [rectangle15Path fill];
        
        
        
        
        //// Rectangle 22 Drawing
        UIBezierPath* rectangle22Path = [UIBezierPath bezierPathWithRect: CGRectMake(571, 0, 2, 30)];
        [color3 setFill];
        [rectangle22Path fill];
        
        
        
        
        //// Rectangle 29 Drawing
        UIBezierPath* rectangle29Path = [UIBezierPath bezierPathWithRect: CGRectMake(727, 0, 2, 30)];
        [color3 setFill];
        [rectangle29Path fill];
        
        
            
    }
    
    
    
    
}


@end
