//
//  EQRTapRadioButtonView.m
//  NWFC Reserve
//
//  Created by Ray Smith on 7/9/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRTapRadioButtonView.h"

@interface EQRTapRadioButtonView ()
@property CGRect originalFrame;
@end

@implementation EQRTapRadioButtonView
@synthesize delegate;


#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _innerCircleColor = [UIColor whiteColor];
    }
    return self;
}


#pragma mark - touch methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.originalFrame = self.frame;
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = CGRectMake(self.originalFrame.origin.x - 10, self.originalFrame.origin.y - 10, self.originalFrame.size.width  + 20, self.originalFrame.size.height +20);
    } completion:^(BOOL finished) {
    }];
    [super touchesBegan:touches withEvent:event];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = self.originalFrame;
    }];
    if (self.IAmSwitch2 == NO){
        [self.delegate switch1Fires:self];
    } else {
        [self.delegate switch2Fires:self];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = self.originalFrame;
    }];
}


#pragma mark - draw method
- (void)drawRect:(CGRect)rect
{
    // Color Declarations
    UIColor* color = [UIColor colorWithRed: 0 green: 0.657 blue: 0 alpha: 1];
    
    // Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2.5, 2.5, 25, 25)];
    [self.innerCircleColor setFill];
    [ovalPath fill];
    [color setStroke];
    ovalPath.lineWidth = 2.5;
    [ovalPath stroke];
}


@end
