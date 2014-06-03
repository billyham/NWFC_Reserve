//
//  EQRCheckPageRenderer.m
//  NWFC Reserve
//
//  Created by Ray Smith on 6/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckPageRenderer.h"

@implementation EQRCheckPageRenderer


#pragma mark - page renderer draw methods to override

- (void)drawHeaderForPageAtIndex:(NSInteger)index inRect:(CGRect)headerRect{
    
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(71, 141, 40, 19);
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 12], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: textStyle};
    
    [@"Name:" drawInRect: textRect withAttributes: textFontAttributes];
    
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(71, 163, 40, 19);
    NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text2Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 12], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text2Style};
    
    [@"Phone:" drawInRect: text2Rect withAttributes: text2FontAttributes];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(71, 185, 40, 19);
    NSMutableParagraphStyle* text3Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text3Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text3FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 12], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text3Style};
    
    [@"Email: ___________________________________________" drawInRect: text3Rect withAttributes: text3FontAttributes];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(390.5, 101.5, 185, 78)];
    [[UIColor blackColor] setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(111.5, 154.5)];
    [bezierPath addLineToPoint: CGPointMake(361.5, 154.5)];
    [bezierPath addLineToPoint: CGPointMake(111.5, 154.5)];
    [bezierPath closePath];
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(110.5, 176.5)];
    [bezier2Path addLineToPoint: CGPointMake(360.5, 176.5)];
    [bezier2Path addLineToPoint: CGPointMake(110.5, 176.5)];
    [bezier2Path closePath];
    [[UIColor blackColor] setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(111.5, 196.5)];
    [bezier3Path addLineToPoint: CGPointMake(361.5, 196.5)];
    [bezier3Path addLineToPoint: CGPointMake(111.5, 196.5)];
    [bezier3Path closePath];
    [[UIColor blackColor] setStroke];
    bezier3Path.lineWidth = 1;
    [bezier3Path stroke];
    
    
    
    

    
}


//- (void)drawContentForPageAtIndex:(NSInteger)index inRect:(CGRect)contentRect{
//    
//    
//    
//}


- (void)drawPrintFormatter:(UIPrintFormatter *)printFormatter forPageAtIndex:(NSInteger)index{
    
    [super drawPrintFormatter:printFormatter forPageAtIndex:index];
    
}


- (void)drawFooterForPageAtIndex:(NSInteger)index inRect:(CGRect)footerRect{
    
    
    
    
}


#pragma mark - other page renderer methods to override


//- (NSInteger)numberOfPages{
//    
//    
//    return 1;
//}



@end
