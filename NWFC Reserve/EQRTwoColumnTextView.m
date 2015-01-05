//
//  EQRTwoColumnTextView.m
//  Gear
//
//  Created by Ray Smith on 1/5/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRTwoColumnTextView.h"

@interface EQRTwoColumnTextView ()



@end

@implementation EQRTwoColumnTextView

//using textKit to create multiple columns of text in a single view
//from http://robots.thoughtbot.com/ios-text-kit-basics

- (void)awakeFromNib {
    
    [super awakeFromNib];

}

-(void)manuallySetText{
    
    self.layoutManager = [[NSLayoutManager alloc] init];
    
    self.textStorage = [[NSTextStorage alloc] initWithAttributedString:self.myAttString];
    
    [self createColumns];
    
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self createColumns];
    [self setNeedsDisplay];
}


- (void)setTextStorage:(NSTextStorage *)textStorage {
    
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:textStorage];
    [self.textStorage addLayoutManager:self.layoutManager];
    [self setNeedsDisplay];
}

- (void)createColumns {
    
    // Remove any existing text containers, since we will recreate them.
    for (NSUInteger i = [self.layoutManager.textContainers count]; i > 0;) {
        [self.layoutManager removeTextContainerAtIndex:--i];
    }
    
    // Capture some frequently-used geometry values in local variables.
    CGRect bounds = self.bounds;
    CGFloat x = bounds.origin.x;
    CGFloat y = bounds.origin.y;
    
    // These are effectively constants. If you want to make this class more
    // extensible, turning these into public properties would be a nice start!
    NSUInteger columnCount = 2;
    CGFloat interColumnMargin = 10;
    
    // Calculate sizes for building a series of text containers.
    CGFloat totalMargin = interColumnMargin * (columnCount - 1);
    CGFloat columnWidth = (bounds.size.width - totalMargin) / columnCount;
    CGSize columnSize = CGSizeMake(columnWidth, bounds.size.height);
    
    NSMutableArray *containers = [NSMutableArray arrayWithCapacity:columnCount];
    NSMutableArray *origins = [NSMutableArray arrayWithCapacity:columnCount];
    
    for (NSUInteger i = 0; i < columnCount; i++) {
        // Create a new container of the appropriate size, and add it to our array.
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:columnSize];
        [containers addObject:container];
        
        // Create a new origin point for the container we just added.
        NSValue *originValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
        [origins addObject:originValue];
        
        [self.layoutManager addTextContainer:container];
        x += columnWidth + interColumnMargin;
    }
    self.textOrigins = origins;
}

// Only override drawRect: if you perform custom drawing.

- (void)drawRect:(CGRect)rect {
   
    for (NSUInteger i = 0; i < [self.layoutManager.textContainers count]; i++) {
        NSTextContainer *container = self.layoutManager.textContainers[i];
        CGPoint origin = [self.textOrigins[i] CGPointValue];
        
        NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:container];
        
        [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:origin];
    }
    
}


@end
