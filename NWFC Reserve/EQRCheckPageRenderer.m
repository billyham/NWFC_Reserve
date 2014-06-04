//
//  EQRCheckPageRenderer.m
//  NWFC Reserve
//
//  Created by Ray Smith on 6/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckPageRenderer.h"

@implementation EQRCheckPageRenderer


#pragma mark - header

- (void)drawHeaderForPageAtIndex:(NSInteger)index inRect:(CGRect)headerRect{
    
    //__________KEEP BELOW
    
    NSString* name_textContent = self.name_text_value;
    NSString* phone_textContent = self.phone_text_value;
    NSString* email_textContent = self.email_text_value;
    
    //__________KEEP ABOVE
    
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 0.899 green: 0 blue: 0.111 alpha: 1];
    UIColor* color1 = [UIColor colorWithRed: 0.862 green: 0.126 blue: 0.113 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Abstracted Attributes
    NSString* text4Content = @"RESERVE IN PERSON (24 HOURS NOTICE)\rOR BY EMAIL (48 HOURS NOTICE) AT reserve@nwfilm.org";
    NSString* text5Content = @"STUDENT EQUIPMENT REQUEST FORM";
    NSString* text6Content = @"FOR CURRENT NWFC\rSTUDENT PROJECTS ONLY";
    NSString* text7Content = @"STAFF / INTERN ONLY";
    NSString* text8Content = @"Reservation Witness:__________ Date: _____ /_____";
    NSString* text9Content = @"TRACKED & CONFIRMED";
    NSString* text10Content = @"PHONE";
    NSString* text11Content = @"EMAIL";
    NSString* text12Content = @"IN PERSON";
    NSString* text13Content = @"Will you be shooting any EXT. locations?";
    NSString* text14Content = @"YES   •   NO";

    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(37, 120, 40, 19);
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: textStyle};
    
    [@"Name:" drawInRect: textRect withAttributes: textFontAttributes];
    
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(37, 145, 40, 19);
    NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text2Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text2Style};
    
    [@"Phone:" drawInRect: text2Rect withAttributes: text2FontAttributes];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(37, 168, 40, 19);
    NSMutableParagraphStyle* text3Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text3Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text3FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text3Style};
    
    [@"Email: " drawInRect: text3Rect withAttributes: text3FontAttributes];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(404.5, 120, 185, 58)];
    [[UIColor blackColor] setStroke];
    rectanglePath.lineWidth = 0.5;
    [rectanglePath stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(70.5, 131.5)];
    [bezierPath addLineToPoint: CGPointMake(320.5, 131.5)];
    [bezierPath addLineToPoint: CGPointMake(70.5, 131.5)];
    [bezierPath closePath];
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 0.5;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(70.5, 154.5)];
    [bezier2Path addLineToPoint: CGPointMake(320.5, 154.5)];
    [bezier2Path addLineToPoint: CGPointMake(70.5, 154.5)];
    [bezier2Path closePath];
    [[UIColor blackColor] setStroke];
    bezier2Path.lineWidth = 0.5;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(70.5, 177.5)];
    [bezier3Path addLineToPoint: CGPointMake(320.5, 177.5)];
    [bezier3Path addLineToPoint: CGPointMake(70.5, 177.5)];
    [bezier3Path closePath];
    [[UIColor blackColor] setStroke];
    bezier3Path.lineWidth = 0.5;
    [bezier3Path stroke];
    
    
    //// Group
    {
        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
        [bezier4Path moveToPoint: CGPointMake(44.12, 59.88)];
        [bezier4Path addCurveToPoint: CGPointMake(44.12, 54.27) controlPoint1: CGPointMake(44.12, 59.88) controlPoint2: CGPointMake(44.12, 56.55)];
        [bezier4Path addCurveToPoint: CGPointMake(40.36, 54.27) controlPoint1: CGPointMake(44.12, 52.26) controlPoint2: CGPointMake(40.36, 52.34)];
        [bezier4Path addCurveToPoint: CGPointMake(40.36, 58.59) controlPoint1: CGPointMake(40.36, 56.47) controlPoint2: CGPointMake(40.36, 57.18)];
        [bezier4Path addCurveToPoint: CGPointMake(46.44, 65.92) controlPoint1: CGPointMake(40.36, 60.39) controlPoint2: CGPointMake(45.24, 63.45)];
        [bezier4Path addCurveToPoint: CGPointMake(47.48, 68.9) controlPoint1: CGPointMake(47.22, 67.54) controlPoint2: CGPointMake(47.4, 68.27)];
        [bezier4Path addCurveToPoint: CGPointMake(47, 75.1) controlPoint1: CGPointMake(47.56, 69.53) controlPoint2: CGPointMake(47.96, 73.45)];
        [bezier4Path addCurveToPoint: CGPointMake(42.2, 78) controlPoint1: CGPointMake(46.04, 76.75) controlPoint2: CGPointMake(44.92, 78)];
        [bezier4Path addCurveToPoint: CGPointMake(37.16, 73.61) controlPoint1: CGPointMake(39.48, 78) controlPoint2: CGPointMake(37.16, 75.18)];
        [bezier4Path addCurveToPoint: CGPointMake(37.16, 67.73) controlPoint1: CGPointMake(37.16, 72.04) controlPoint2: CGPointMake(37.16, 67.73)];
        [bezier4Path addLineToPoint: CGPointMake(40.2, 67.73)];
        [bezier4Path addCurveToPoint: CGPointMake(40.2, 72.9) controlPoint1: CGPointMake(40.2, 67.73) controlPoint2: CGPointMake(40.2, 71.49)];
        [bezier4Path addCurveToPoint: CGPointMake(42.4, 75.1) controlPoint1: CGPointMake(40.2, 74.31) controlPoint2: CGPointMake(40.99, 75.1)];
        [bezier4Path addCurveToPoint: CGPointMake(44.6, 73.14) controlPoint1: CGPointMake(43.8, 75.1) controlPoint2: CGPointMake(44.6, 74.71)];
        [bezier4Path addCurveToPoint: CGPointMake(44.6, 69.76) controlPoint1: CGPointMake(44.6, 71.57) controlPoint2: CGPointMake(44.6, 71.02)];
        [bezier4Path addCurveToPoint: CGPointMake(42.84, 66.16) controlPoint1: CGPointMake(44.6, 68.51) controlPoint2: CGPointMake(43.88, 67.1)];
        [bezier4Path addCurveToPoint: CGPointMake(37.64, 59.96) controlPoint1: CGPointMake(41.8, 65.22) controlPoint2: CGPointMake(37.88, 61.61)];
        [bezier4Path addCurveToPoint: CGPointMake(37.64, 53.69) controlPoint1: CGPointMake(37.4, 58.31) controlPoint2: CGPointMake(37.16, 55.26)];
        [bezier4Path addCurveToPoint: CGPointMake(42.4, 50.16) controlPoint1: CGPointMake(38.12, 52.12) controlPoint2: CGPointMake(39.23, 50.16)];
        [bezier4Path addCurveToPoint: CGPointMake(47.24, 54.94) controlPoint1: CGPointMake(45.56, 50.16) controlPoint2: CGPointMake(47.24, 53.22)];
        [bezier4Path addCurveToPoint: CGPointMake(47.24, 59.86) controlPoint1: CGPointMake(47.24, 56.67) controlPoint2: CGPointMake(47.24, 59.86)];
        [bezier4Path addLineToPoint: CGPointMake(44.12, 59.88)];
        [bezier4Path closePath];
        bezier4Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier4Path fill];
        
        
        //// Bezier 5 Drawing
        UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
        [bezier5Path moveToPoint: CGPointMake(57.36, 61.57)];
        [bezier5Path addCurveToPoint: CGPointMake(57.36, 66.31) controlPoint1: CGPointMake(57.36, 63.49) controlPoint2: CGPointMake(57.36, 66.31)];
        [bezier5Path addLineToPoint: CGPointMake(55, 66.31)];
        [bezier5Path addCurveToPoint: CGPointMake(55, 61.85) controlPoint1: CGPointMake(55, 66.31) controlPoint2: CGPointMake(55, 62.68)];
        [bezier5Path addCurveToPoint: CGPointMake(53.56, 60.51) controlPoint1: CGPointMake(55, 61.03) controlPoint2: CGPointMake(54.4, 60.51)];
        [bezier5Path addCurveToPoint: CGPointMake(51.96, 61.94) controlPoint1: CGPointMake(52.54, 60.51) controlPoint2: CGPointMake(51.96, 61.2)];
        [bezier5Path addCurveToPoint: CGPointMake(51.96, 74.15) controlPoint1: CGPointMake(51.96, 62.69) controlPoint2: CGPointMake(51.96, 73.17)];
        [bezier5Path addCurveToPoint: CGPointMake(53.42, 75.59) controlPoint1: CGPointMake(51.96, 75.13) controlPoint2: CGPointMake(52.98, 75.59)];
        [bezier5Path addCurveToPoint: CGPointMake(55, 74.32) controlPoint1: CGPointMake(53.86, 75.59) controlPoint2: CGPointMake(55, 75.22)];
        [bezier5Path addCurveToPoint: CGPointMake(55, 69.61) controlPoint1: CGPointMake(55, 73.77) controlPoint2: CGPointMake(55, 69.61)];
        [bezier5Path addLineToPoint: CGPointMake(57.36, 69.61)];
        [bezier5Path addCurveToPoint: CGPointMake(57.36, 74.16) controlPoint1: CGPointMake(57.36, 69.61) controlPoint2: CGPointMake(57.36, 72.59)];
        [bezier5Path addCurveToPoint: CGPointMake(53.16, 77.8) controlPoint1: CGPointMake(57.36, 75.73) controlPoint2: CGPointMake(55.84, 77.8)];
        [bezier5Path addCurveToPoint: CGPointMake(49.48, 74.24) controlPoint1: CGPointMake(50.48, 77.8) controlPoint2: CGPointMake(49.48, 75.57)];
        [bezier5Path addCurveToPoint: CGPointMake(49.48, 62) controlPoint1: CGPointMake(49.48, 72.9) controlPoint2: CGPointMake(49.48, 63.92)];
        [bezier5Path addCurveToPoint: CGPointMake(53.42, 58.31) controlPoint1: CGPointMake(49.48, 60.08) controlPoint2: CGPointMake(50.88, 58.31)];
        [bezier5Path addCurveToPoint: CGPointMake(57.36, 61.57) controlPoint1: CGPointMake(55.96, 58.31) controlPoint2: CGPointMake(57.36, 59.45)];
        [bezier5Path closePath];
        bezier5Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier5Path fill];
        
        
        //// Bezier 6 Drawing
        UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
        [bezier6Path moveToPoint: CGPointMake(67.8, 60.68)];
        [bezier6Path addCurveToPoint: CGPointMake(67.8, 77.14) controlPoint1: CGPointMake(67.8, 61.89) controlPoint2: CGPointMake(67.8, 77.14)];
        [bezier6Path addLineToPoint: CGPointMake(65.28, 77.14)];
        [bezier6Path addCurveToPoint: CGPointMake(65.28, 61.33) controlPoint1: CGPointMake(65.28, 77.14) controlPoint2: CGPointMake(65.28, 62.47)];
        [bezier6Path addCurveToPoint: CGPointMake(63.64, 60.63) controlPoint1: CGPointMake(65.28, 60.2) controlPoint2: CGPointMake(64.24, 60.24)];
        [bezier6Path addCurveToPoint: CGPointMake(62.32, 62.82) controlPoint1: CGPointMake(63.04, 61.02) controlPoint2: CGPointMake(62.32, 62.12)];
        [bezier6Path addCurveToPoint: CGPointMake(62.32, 77.14) controlPoint1: CGPointMake(62.32, 63.53) controlPoint2: CGPointMake(62.32, 77.14)];
        [bezier6Path addLineToPoint: CGPointMake(59.62, 77.14)];
        [bezier6Path addLineToPoint: CGPointMake(59.62, 50.59)];
        [bezier6Path addLineToPoint: CGPointMake(62.08, 50.59)];
        [bezier6Path addCurveToPoint: CGPointMake(62.08, 60.79) controlPoint1: CGPointMake(62.08, 50.59) controlPoint2: CGPointMake(62.08, 60.36)];
        [bezier6Path addCurveToPoint: CGPointMake(65.44, 58.44) controlPoint1: CGPointMake(62.59, 59.76) controlPoint2: CGPointMake(64.18, 58.31)];
        [bezier6Path addCurveToPoint: CGPointMake(67.8, 60.68) controlPoint1: CGPointMake(66.6, 58.56) controlPoint2: CGPointMake(67.8, 59.46)];
        [bezier6Path closePath];
        bezier6Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier6Path fill];
        
        
        //// Bezier 7 Drawing
        UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
        [bezier7Path moveToPoint: CGPointMake(78.52, 61.76)];
        [bezier7Path addLineToPoint: CGPointMake(78.52, 74)];
        [bezier7Path addCurveToPoint: CGPointMake(74.56, 77.8) controlPoint1: CGPointMake(78.52, 74) controlPoint2: CGPointMake(78.2, 77.8)];
        [bezier7Path addCurveToPoint: CGPointMake(70.32, 73.84) controlPoint1: CGPointMake(70.92, 77.8) controlPoint2: CGPointMake(70.32, 75.14)];
        [bezier7Path addCurveToPoint: CGPointMake(70.32, 61.76) controlPoint1: CGPointMake(70.32, 72.55) controlPoint2: CGPointMake(70.32, 63.69)];
        [bezier7Path addCurveToPoint: CGPointMake(74.42, 58.31) controlPoint1: CGPointMake(70.32, 59.84) controlPoint2: CGPointMake(72, 58.31)];
        [bezier7Path addCurveToPoint: CGPointMake(78.52, 61.76) controlPoint1: CGPointMake(76.84, 58.31) controlPoint2: CGPointMake(78.52, 59.84)];
        [bezier7Path closePath];
        [bezier7Path moveToPoint: CGPointMake(74.42, 60.47)];
        [bezier7Path addCurveToPoint: CGPointMake(72.6, 62.27) controlPoint1: CGPointMake(73.6, 60.47) controlPoint2: CGPointMake(72.6, 61.1)];
        [bezier7Path addCurveToPoint: CGPointMake(72.6, 73.33) controlPoint1: CGPointMake(72.6, 63.45) controlPoint2: CGPointMake(72.6, 72.08)];
        [bezier7Path addCurveToPoint: CGPointMake(74.42, 75.45) controlPoint1: CGPointMake(72.6, 74.59) controlPoint2: CGPointMake(73.44, 75.45)];
        [bezier7Path addCurveToPoint: CGPointMake(76.16, 73.26) controlPoint1: CGPointMake(75.4, 75.45) controlPoint2: CGPointMake(76.16, 74.82)];
        [bezier7Path addCurveToPoint: CGPointMake(76.16, 62.27) controlPoint1: CGPointMake(76.16, 71.69) controlPoint2: CGPointMake(76.16, 63.61)];
        [bezier7Path addCurveToPoint: CGPointMake(74.42, 60.47) controlPoint1: CGPointMake(76.16, 61.41) controlPoint2: CGPointMake(75.24, 60.47)];
        [bezier7Path closePath];
        bezier7Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier7Path fill];
        
        
        //// Bezier 8 Drawing
        UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
        [bezier8Path moveToPoint: CGPointMake(89.28, 61.76)];
        [bezier8Path addLineToPoint: CGPointMake(89.28, 74)];
        [bezier8Path addCurveToPoint: CGPointMake(85.32, 77.8) controlPoint1: CGPointMake(89.28, 74) controlPoint2: CGPointMake(88.96, 77.8)];
        [bezier8Path addCurveToPoint: CGPointMake(81.08, 73.84) controlPoint1: CGPointMake(81.68, 77.8) controlPoint2: CGPointMake(81.08, 75.14)];
        [bezier8Path addCurveToPoint: CGPointMake(81.08, 61.76) controlPoint1: CGPointMake(81.08, 72.55) controlPoint2: CGPointMake(81.08, 63.69)];
        [bezier8Path addCurveToPoint: CGPointMake(85.18, 58.31) controlPoint1: CGPointMake(81.08, 59.84) controlPoint2: CGPointMake(82.76, 58.31)];
        [bezier8Path addCurveToPoint: CGPointMake(89.28, 61.76) controlPoint1: CGPointMake(87.6, 58.31) controlPoint2: CGPointMake(89.28, 59.84)];
        [bezier8Path closePath];
        [bezier8Path moveToPoint: CGPointMake(85.18, 60.47)];
        [bezier8Path addCurveToPoint: CGPointMake(83.36, 62.27) controlPoint1: CGPointMake(84.36, 60.47) controlPoint2: CGPointMake(83.36, 61.1)];
        [bezier8Path addCurveToPoint: CGPointMake(83.36, 73.33) controlPoint1: CGPointMake(83.36, 63.45) controlPoint2: CGPointMake(83.36, 72.08)];
        [bezier8Path addCurveToPoint: CGPointMake(85.18, 75.45) controlPoint1: CGPointMake(83.36, 74.59) controlPoint2: CGPointMake(84.2, 75.45)];
        [bezier8Path addCurveToPoint: CGPointMake(86.92, 73.26) controlPoint1: CGPointMake(86.16, 75.45) controlPoint2: CGPointMake(86.92, 74.82)];
        [bezier8Path addCurveToPoint: CGPointMake(86.92, 62.27) controlPoint1: CGPointMake(86.92, 71.69) controlPoint2: CGPointMake(86.92, 63.61)];
        [bezier8Path addCurveToPoint: CGPointMake(85.18, 60.47) controlPoint1: CGPointMake(86.92, 61.41) controlPoint2: CGPointMake(86, 60.47)];
        [bezier8Path closePath];
        bezier8Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier8Path fill];
        
        
        //// Bezier 9 Drawing
        UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
        [bezier9Path moveToPoint: CGPointMake(107.36, 61.76)];
        [bezier9Path addLineToPoint: CGPointMake(107.36, 74)];
        [bezier9Path addCurveToPoint: CGPointMake(103.4, 77.8) controlPoint1: CGPointMake(107.36, 74) controlPoint2: CGPointMake(107.04, 77.8)];
        [bezier9Path addCurveToPoint: CGPointMake(99.16, 73.84) controlPoint1: CGPointMake(99.76, 77.8) controlPoint2: CGPointMake(99.16, 75.14)];
        [bezier9Path addCurveToPoint: CGPointMake(99.16, 61.76) controlPoint1: CGPointMake(99.16, 72.55) controlPoint2: CGPointMake(99.16, 63.69)];
        [bezier9Path addCurveToPoint: CGPointMake(103.26, 58.31) controlPoint1: CGPointMake(99.16, 59.84) controlPoint2: CGPointMake(100.84, 58.31)];
        [bezier9Path addCurveToPoint: CGPointMake(107.36, 61.76) controlPoint1: CGPointMake(105.68, 58.31) controlPoint2: CGPointMake(107.36, 59.84)];
        [bezier9Path closePath];
        [bezier9Path moveToPoint: CGPointMake(103.26, 60.47)];
        [bezier9Path addCurveToPoint: CGPointMake(101.44, 62.27) controlPoint1: CGPointMake(102.44, 60.47) controlPoint2: CGPointMake(101.44, 61.1)];
        [bezier9Path addCurveToPoint: CGPointMake(101.44, 73.33) controlPoint1: CGPointMake(101.44, 63.45) controlPoint2: CGPointMake(101.44, 72.08)];
        [bezier9Path addCurveToPoint: CGPointMake(103.26, 75.45) controlPoint1: CGPointMake(101.44, 74.59) controlPoint2: CGPointMake(102.28, 75.45)];
        [bezier9Path addCurveToPoint: CGPointMake(105, 73.26) controlPoint1: CGPointMake(104.24, 75.45) controlPoint2: CGPointMake(105, 74.82)];
        [bezier9Path addCurveToPoint: CGPointMake(105, 62.27) controlPoint1: CGPointMake(105, 71.69) controlPoint2: CGPointMake(105, 63.61)];
        [bezier9Path addCurveToPoint: CGPointMake(103.26, 60.47) controlPoint1: CGPointMake(105, 61.41) controlPoint2: CGPointMake(104.08, 60.47)];
        [bezier9Path closePath];
        bezier9Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier9Path fill];
        
        
        //// Bezier 10 Drawing
        UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
        [bezier10Path moveToPoint: CGPointMake(91.76, 50.9)];
        [bezier10Path addLineToPoint: CGPointMake(94.24, 50.9)];
        [bezier10Path addLineToPoint: CGPointMake(94.24, 77.33)];
        [bezier10Path addLineToPoint: CGPointMake(91.76, 77.33)];
        [bezier10Path addLineToPoint: CGPointMake(91.76, 50.9)];
        [bezier10Path closePath];
        bezier10Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier10Path fill];
        
        
        //// Bezier 11 Drawing
        UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
        [bezier11Path moveToPoint: CGPointMake(135.14, 50.9)];
        [bezier11Path addLineToPoint: CGPointMake(137.62, 50.9)];
        [bezier11Path addLineToPoint: CGPointMake(137.62, 77.33)];
        [bezier11Path addLineToPoint: CGPointMake(135.14, 77.33)];
        [bezier11Path addLineToPoint: CGPointMake(135.14, 50.9)];
        [bezier11Path closePath];
        bezier11Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier11Path fill];
        
        
        //// Bezier 12 Drawing
        UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
        [bezier12Path moveToPoint: CGPointMake(113.88, 50.39)];
        [bezier12Path addCurveToPoint: CGPointMake(116.4, 50.39) controlPoint1: CGPointMake(114.88, 50.39) controlPoint2: CGPointMake(116.4, 50.39)];
        [bezier12Path addLineToPoint: CGPointMake(116.4, 52.71)];
        [bezier12Path addCurveToPoint: CGPointMake(114.12, 52.71) controlPoint1: CGPointMake(116.4, 52.71) controlPoint2: CGPointMake(114.6, 52.71)];
        [bezier12Path addCurveToPoint: CGPointMake(113.24, 53.57) controlPoint1: CGPointMake(113.64, 52.71) controlPoint2: CGPointMake(113.24, 53.25)];
        [bezier12Path addCurveToPoint: CGPointMake(113.24, 58.51) controlPoint1: CGPointMake(113.24, 53.88) controlPoint2: CGPointMake(113.24, 58.51)];
        [bezier12Path addLineToPoint: CGPointMake(115.16, 58.51)];
        [bezier12Path addLineToPoint: CGPointMake(115.16, 60.31)];
        [bezier12Path addLineToPoint: CGPointMake(113.24, 60.31)];
        [bezier12Path addLineToPoint: CGPointMake(113.24, 77.29)];
        [bezier12Path addLineToPoint: CGPointMake(110.6, 77.29)];
        [bezier12Path addLineToPoint: CGPointMake(110.6, 60.43)];
        [bezier12Path addLineToPoint: CGPointMake(109.04, 60.43)];
        [bezier12Path addLineToPoint: CGPointMake(109.04, 58.55)];
        [bezier12Path addLineToPoint: CGPointMake(110.6, 58.55)];
        [bezier12Path addCurveToPoint: CGPointMake(110.6, 53.73) controlPoint1: CGPointMake(110.6, 58.55) controlPoint2: CGPointMake(110.6, 55.73)];
        [bezier12Path addCurveToPoint: CGPointMake(113.88, 50.39) controlPoint1: CGPointMake(110.6, 51.73) controlPoint2: CGPointMake(111.76, 50.39)];
        [bezier12Path closePath];
        bezier12Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier12Path fill];
        
        
        //// Bezier 13 Drawing
        UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
        [bezier13Path moveToPoint: CGPointMake(119.36, 50.67)];
        [bezier13Path addLineToPoint: CGPointMake(128, 50.67)];
        [bezier13Path addLineToPoint: CGPointMake(128, 53.26)];
        [bezier13Path addLineToPoint: CGPointMake(122.28, 53.26)];
        [bezier13Path addLineToPoint: CGPointMake(122.28, 62.16)];
        [bezier13Path addLineToPoint: CGPointMake(126.8, 62.16)];
        [bezier13Path addLineToPoint: CGPointMake(126.8, 64.86)];
        [bezier13Path addLineToPoint: CGPointMake(122.32, 64.86)];
        [bezier13Path addLineToPoint: CGPointMake(122.32, 77.29)];
        [bezier13Path addLineToPoint: CGPointMake(119.36, 77.29)];
        [bezier13Path addLineToPoint: CGPointMake(119.36, 50.67)];
        [bezier13Path closePath];
        bezier13Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier13Path fill];
        
        
        //// Bezier 14 Drawing
        UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
        [bezier14Path moveToPoint: CGPointMake(129.88, 50.67)];
        [bezier14Path addLineToPoint: CGPointMake(132.32, 50.67)];
        [bezier14Path addLineToPoint: CGPointMake(132.32, 53.88)];
        [bezier14Path addLineToPoint: CGPointMake(129.88, 53.88)];
        [bezier14Path addLineToPoint: CGPointMake(129.88, 50.67)];
        [bezier14Path closePath];
        bezier14Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier14Path fill];
        
        
        //// Bezier 15 Drawing
        UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
        [bezier15Path moveToPoint: CGPointMake(129.88, 58.67)];
        [bezier15Path addLineToPoint: CGPointMake(132.32, 58.67)];
        [bezier15Path addLineToPoint: CGPointMake(132.32, 77.29)];
        [bezier15Path addLineToPoint: CGPointMake(129.88, 77.29)];
        [bezier15Path addLineToPoint: CGPointMake(129.88, 58.67)];
        [bezier15Path closePath];
        bezier15Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier15Path fill];
        
        
        //// Bezier 16 Drawing
        UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
        [bezier16Path moveToPoint: CGPointMake(154.27, 60.59)];
        [bezier16Path addCurveToPoint: CGPointMake(154.27, 77.29) controlPoint1: CGPointMake(154.27, 61.5) controlPoint2: CGPointMake(154.27, 77.29)];
        [bezier16Path addLineToPoint: CGPointMake(151.84, 77.29)];
        [bezier16Path addCurveToPoint: CGPointMake(151.84, 61.68) controlPoint1: CGPointMake(151.84, 77.29) controlPoint2: CGPointMake(151.84, 62.68)];
        [bezier16Path addCurveToPoint: CGPointMake(149.85, 60.57) controlPoint1: CGPointMake(151.84, 60.68) controlPoint2: CGPointMake(150.67, 60.24)];
        [bezier16Path addCurveToPoint: CGPointMake(148.42, 62.59) controlPoint1: CGPointMake(149.28, 60.81) controlPoint2: CGPointMake(148.42, 61.65)];
        [bezier16Path addCurveToPoint: CGPointMake(148.42, 77.29) controlPoint1: CGPointMake(148.42, 63.53) controlPoint2: CGPointMake(148.42, 77.29)];
        [bezier16Path addLineToPoint: CGPointMake(145.78, 77.29)];
        [bezier16Path addCurveToPoint: CGPointMake(145.78, 61.62) controlPoint1: CGPointMake(145.78, 77.29) controlPoint2: CGPointMake(145.78, 62.82)];
        [bezier16Path addCurveToPoint: CGPointMake(143.77, 60.82) controlPoint1: CGPointMake(145.78, 60.41) controlPoint2: CGPointMake(144.61, 60.15)];
        [bezier16Path addCurveToPoint: CGPointMake(142.6, 62.59) controlPoint1: CGPointMake(142.93, 61.5) controlPoint2: CGPointMake(142.6, 62.09)];
        [bezier16Path addCurveToPoint: CGPointMake(142.6, 77.29) controlPoint1: CGPointMake(142.6, 63.09) controlPoint2: CGPointMake(142.6, 77.29)];
        [bezier16Path addLineToPoint: CGPointMake(139.96, 77.29)];
        [bezier16Path addLineToPoint: CGPointMake(139.96, 58.82)];
        [bezier16Path addLineToPoint: CGPointMake(142.39, 58.82)];
        [bezier16Path addCurveToPoint: CGPointMake(142.39, 60.82) controlPoint1: CGPointMake(142.39, 58.82) controlPoint2: CGPointMake(142.39, 59.59)];
        [bezier16Path addCurveToPoint: CGPointMake(146.71, 58.53) controlPoint1: CGPointMake(142.93, 59.82) controlPoint2: CGPointMake(145.39, 58.24)];
        [bezier16Path addCurveToPoint: CGPointMake(148.18, 60.71) controlPoint1: CGPointMake(147.79, 58.76) controlPoint2: CGPointMake(148.42, 59.21)];
        [bezier16Path addCurveToPoint: CGPointMake(152.89, 58.59) controlPoint1: CGPointMake(149.23, 59.03) controlPoint2: CGPointMake(151.78, 58.29)];
        [bezier16Path addCurveToPoint: CGPointMake(154.27, 60.59) controlPoint1: CGPointMake(153.83, 58.84) controlPoint2: CGPointMake(154.27, 59.71)];
        [bezier16Path closePath];
        bezier16Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier16Path fill];
        
        
        //// Group 2
        {
            //// Bezier 17 Drawing
            UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
            [bezier17Path moveToPoint: CGPointMake(181.08, 51.2)];
            [bezier17Path addLineToPoint: CGPointMake(184.74, 54.86)];
            [bezier17Path addLineToPoint: CGPointMake(184.74, 74.99)];
            [bezier17Path addLineToPoint: CGPointMake(181.64, 71.89)];
            [bezier17Path addLineToPoint: CGPointMake(181.25, 71.49)];
            [bezier17Path addLineToPoint: CGPointMake(180.69, 71.54)];
            [bezier17Path addLineToPoint: CGPointMake(176.26, 71.96)];
            [bezier17Path addLineToPoint: CGPointMake(176.26, 51.2)];
            [bezier17Path addLineToPoint: CGPointMake(181.08, 51.2)];
            [bezier17Path closePath];
            [bezier17Path moveToPoint: CGPointMake(181.58, 50)];
            [bezier17Path addLineToPoint: CGPointMake(175.06, 50)];
            [bezier17Path addLineToPoint: CGPointMake(175.06, 73.27)];
            [bezier17Path addLineToPoint: CGPointMake(180.8, 72.74)];
            [bezier17Path addLineToPoint: CGPointMake(185.94, 77.88)];
            [bezier17Path addLineToPoint: CGPointMake(185.94, 54.37)];
            [bezier17Path addLineToPoint: CGPointMake(181.58, 50)];
            [bezier17Path addLineToPoint: CGPointMake(181.58, 50)];
            [bezier17Path closePath];
            bezier17Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier17Path fill];
        }
        
        
        //// Group 3
        {
            //// Rectangle 2 Drawing
            UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(158.25, 50, 23.25, 22.25)];
            [color1 setFill];
            [rectangle2Path fill];
        }
        
        
        //// Group 4
        {
            //// Bezier 18 Drawing
            UIBezierPath* bezier18Path = [UIBezierPath bezierPath];
            [bezier18Path moveToPoint: CGPointMake(179.21, 72.21)];
            [bezier18Path addLineToPoint: CGPointMake(183.25, 76.67)];
            [bezier18Path addLineToPoint: CGPointMake(163.73, 76.67)];
            [bezier18Path addLineToPoint: CGPointMake(160.16, 72.97)];
            [bezier18Path addLineToPoint: CGPointMake(160.16, 72.21)];
            [bezier18Path addLineToPoint: CGPointMake(179.21, 72.21)];
            [bezier18Path closePath];
            [bezier18Path moveToPoint: CGPointMake(179.72, 71)];
            [bezier18Path addLineToPoint: CGPointMake(159, 71)];
            [bezier18Path addLineToPoint: CGPointMake(159, 73.47)];
            [bezier18Path addLineToPoint: CGPointMake(163.25, 77.88)];
            [bezier18Path addLineToPoint: CGPointMake(185.94, 77.88)];
            [bezier18Path addLineToPoint: CGPointMake(179.72, 71)];
            [bezier18Path addLineToPoint: CGPointMake(179.72, 71)];
            [bezier18Path closePath];
            bezier18Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier18Path fill];
        }
        
        
        //// Bezier 19 Drawing
        UIBezierPath* bezier19Path = [UIBezierPath bezierPath];
        [bezier19Path moveToPoint: CGPointMake(164.92, 55.71)];
        [bezier19Path addLineToPoint: CGPointMake(164.92, 68.82)];
        [bezier19Path addLineToPoint: CGPointMake(176.5, 62.26)];
        [bezier19Path addLineToPoint: CGPointMake(164.92, 55.71)];
        [bezier19Path closePath];
        bezier19Path.miterLimit = 4;
        
        [color2 setFill];
        [bezier19Path fill];
        
        
        //// Group 5
        {
            //// Bezier 20 Drawing
            UIBezierPath* bezier20Path = [UIBezierPath bezierPath];
            [bezier20Path moveToPoint: CGPointMake(212.07, 51.2)];
            [bezier20Path addLineToPoint: CGPointMake(215.65, 54.86)];
            [bezier20Path addLineToPoint: CGPointMake(215.65, 74.99)];
            [bezier20Path addLineToPoint: CGPointMake(212.62, 71.89)];
            [bezier20Path addLineToPoint: CGPointMake(212.23, 71.49)];
            [bezier20Path addLineToPoint: CGPointMake(211.68, 71.54)];
            [bezier20Path addLineToPoint: CGPointMake(207.35, 71.96)];
            [bezier20Path addLineToPoint: CGPointMake(207.35, 51.2)];
            [bezier20Path addLineToPoint: CGPointMake(212.07, 51.2)];
            [bezier20Path closePath];
            [bezier20Path moveToPoint: CGPointMake(212.55, 50)];
            [bezier20Path addLineToPoint: CGPointMake(206.18, 50)];
            [bezier20Path addLineToPoint: CGPointMake(206.18, 73.27)];
            [bezier20Path addLineToPoint: CGPointMake(211.79, 72.74)];
            [bezier20Path addLineToPoint: CGPointMake(216.82, 77.88)];
            [bezier20Path addLineToPoint: CGPointMake(216.82, 54.37)];
            [bezier20Path addLineToPoint: CGPointMake(212.55, 50)];
            [bezier20Path addLineToPoint: CGPointMake(212.55, 50)];
            [bezier20Path closePath];
            bezier20Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier20Path fill];
        }
        
        
        //// Group 6
        {
            //// Rectangle 3 Drawing
            UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(189.75, 50, 22.25, 22.25)];
            [color1 setFill];
            [rectangle3Path fill];
        }
        
        
        //// Group 7
        {
            //// Bezier 21 Drawing
            UIBezierPath* bezier21Path = [UIBezierPath bezierPath];
            [bezier21Path moveToPoint: CGPointMake(209.9, 72.21)];
            [bezier21Path addLineToPoint: CGPointMake(214.06, 76.67)];
            [bezier21Path addLineToPoint: CGPointMake(193.98, 76.67)];
            [bezier21Path addLineToPoint: CGPointMake(190.32, 72.97)];
            [bezier21Path addLineToPoint: CGPointMake(190.32, 72.21)];
            [bezier21Path addLineToPoint: CGPointMake(209.9, 72.21)];
            [bezier21Path closePath];
            [bezier21Path moveToPoint: CGPointMake(210.42, 71)];
            [bezier21Path addLineToPoint: CGPointMake(189.12, 71)];
            [bezier21Path addLineToPoint: CGPointMake(189.12, 73.47)];
            [bezier21Path addLineToPoint: CGPointMake(193.49, 77.88)];
            [bezier21Path addLineToPoint: CGPointMake(216.82, 77.88)];
            [bezier21Path addLineToPoint: CGPointMake(210.42, 71)];
            [bezier21Path addLineToPoint: CGPointMake(210.42, 71)];
            [bezier21Path closePath];
            bezier21Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier21Path fill];
        }
        
        
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(194.5, 55.75, 12.75, 11.75)];
        [color2 setFill];
        [ovalPath fill];
    }
    
    
    //// Text 4 Drawing
    CGRect text4Rect = CGRectMake(37, 79, 219, 24);
    NSMutableParagraphStyle* text4Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text4Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text4FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text4Style};
    
    [text4Content drawInRect: text4Rect withAttributes: text4FontAttributes];
    
    
    //// Text 5 Drawing
    CGRect text5Rect = CGRectMake(260, 68, 215, 24);
    NSMutableParagraphStyle* text5Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text5Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text5FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text5Style};
    
    [text5Content drawInRect: text5Rect withAttributes: text5FontAttributes];
    
    
    //// Text 6 Drawing
    CGRect text6Rect = CGRectMake(497, 56, 96, 28);
    NSMutableParagraphStyle* text6Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text6Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text6FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Oblique" size: 7], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text6Style};
    
    [text6Content drawInRect: text6Rect withAttributes: text6FontAttributes];
    
    
    //// Text 7 Drawing
    CGRect text7Rect = CGRectMake(407, 123, 142, 15);
    NSMutableParagraphStyle* text7Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text7Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text7FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text7Style};
    
    [text7Content drawInRect: text7Rect withAttributes: text7FontAttributes];
    
    
    //// Text 8 Drawing
    CGRect text8Rect = CGRectMake(407, 142, 178, 13);
    NSMutableParagraphStyle* text8Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text8Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text8FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text8Style};
    
    [text8Content drawInRect: text8Rect withAttributes: text8FontAttributes];
    
    
    //// Text 9 Drawing
    CGRect text9Rect = CGRectMake(427, 156, 40, 18);
    NSMutableParagraphStyle* text9Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text9Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text9FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text9Style};
    
    [text9Content drawInRect: text9Rect withAttributes: text9FontAttributes];
    
    
    //// Text 10 Drawing
    CGRect text10Rect = CGRectMake(480, 160, 34, 10);
    NSMutableParagraphStyle* text10Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text10Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text10FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text10Style};
    
    [text10Content drawInRect: text10Rect withAttributes: text10FontAttributes];
    
    
    //// Text 11 Drawing
    CGRect text11Rect = CGRectMake(518, 160, 34, 10);
    NSMutableParagraphStyle* text11Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text11Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text11FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text11Style};
    
    [text11Content drawInRect: text11Rect withAttributes: text11FontAttributes];
    
    
    //// Text 12 Drawing
    CGRect text12Rect = CGRectMake(551, 160, 34, 10);
    NSMutableParagraphStyle* text12Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text12Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text12FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text12Style};
    
    [text12Content drawInRect: text12Rect withAttributes: text12FontAttributes];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(407.5, 156.5, 17, 16)];
    [[UIColor whiteColor] setFill];
    [rectangle4Path fill];
    [[UIColor blackColor] setStroke];
    rectangle4Path.lineWidth = 1;
    [rectangle4Path stroke];
    
    
    //// Rectangle 5 Drawing
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(468.5, 159.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle5Path fill];
    [[UIColor blackColor] setStroke];
    rectangle5Path.lineWidth = 1;
    [rectangle5Path stroke];
    
    
    //// Rectangle 6 Drawing
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRect: CGRectMake(507.5, 159.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle6Path fill];
    [[UIColor blackColor] setStroke];
    rectangle6Path.lineWidth = 1;
    [rectangle6Path stroke];
    
    
    //// Rectangle 7 Drawing
    UIBezierPath* rectangle7Path = [UIBezierPath bezierPathWithRect: CGRectMake(540.5, 159.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle7Path fill];
    [[UIColor blackColor] setStroke];
    rectangle7Path.lineWidth = 1;
    [rectangle7Path stroke];
    
    
    //// Text 13 Drawing
    CGRect text13Rect = CGRectMake(37, 189, 180, 13);
    NSMutableParagraphStyle* text13Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text13Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text13FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text13Style};
    
    [text13Content drawInRect: text13Rect withAttributes: text13FontAttributes];
    
    
    //// Text 14 Drawing
    CGRect text14Rect = CGRectMake(207, 189, 64, 13);
    NSMutableParagraphStyle* text14Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text14Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text14FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text14Style};
    
    [text14Content drawInRect: text14Rect withAttributes: text14FontAttributes];
    
    
    //// name_text Drawing
    CGRect name_textRect = CGRectMake(71, 118, 241, 14);
    NSMutableParagraphStyle* name_textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [name_textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* name_textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: name_textStyle};
    
    [name_textContent drawInRect: name_textRect withAttributes: name_textFontAttributes];
    
    
    //// phone_text Drawing
    CGRect phone_textRect = CGRectMake(72, 141, 241, 14);
    NSMutableParagraphStyle* phone_textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [phone_textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* phone_textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: phone_textStyle};
    
    [phone_textContent drawInRect: phone_textRect withAttributes: phone_textFontAttributes];
    
    
    //// email_text Drawing
    CGRect email_textRect = CGRectMake(71, 164, 241, 14);
    NSMutableParagraphStyle* email_textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [email_textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* email_textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: email_textStyle};
    
    [email_textContent drawInRect: email_textRect withAttributes: email_textFontAttributes];
    
    


    
}


//- (void)drawContentForPageAtIndex:(NSInteger)index inRect:(CGRect)contentRect{
//    
//    
//    
//}

#pragma mark - printerFormatter

- (void)drawPrintFormatter:(UIPrintFormatter *)printFormatter forPageAtIndex:(NSInteger)index{
    
    [super drawPrintFormatter:printFormatter forPageAtIndex:index];
    
}


#pragma mark - footer

- (void)drawFooterForPageAtIndex:(NSInteger)index inRect:(CGRect)footerRect{
    

    //________KEEP BELOW
    
    //// Frames
//    CGRect frame = CGRectMake(0, 0, 668, 300);
    CGRect frame = footerRect;
    
    //exit the method if this page index is any other than the last page
    NSInteger numOfPage = [self numberOfPages];
    if ((index + 1) < numOfPage){
        
        return;
    }
    
    
    //________KEEP ABOVE
    
    
    //// Abstracted Attributes
    NSString* textContent = @"Please read and initial the following:";
    NSString* text2Content = @"I hereby assume full responsibility for the above listed equipment provided by the Northwest Film Center. Financial responsibility includes payment for all repairs, up to teh full replacement value of equipment, and the full replacement value for all stolen or lost equipment. Financial responsibility also includes the rental fee for the time period in which damaged equipment is out for repair, or until replacement payment is received. I have inspected the contents of rental equipment and acknowledge that all parts and pieces are present and in working order unless otherwise noted.";
    NSString* text3Content = @"Projects produced through School of Film classes must include www.nwfilm.org and the following phrase in the credits: Produced through the Northwest Film Center School of Film (spelling out \"Northwest Film Center\").";
    NSString* text4Content = @"Penalties will be given to students for the following reasons: Returns equipment after teh assigned date and time, shows blatant disregard for equipments's well being, no-shows for equipment reservations.";
    NSString* text5Content = @"I confirm that the equipment is in working order upon check-out and have been mae aware of any pre-existing conditions. If returned equipment requres more than 10 min. cleaning, a $25 cleaning fee will be assessed.";
    NSString* text6Content = @"(Renter's Initials)";
    NSString* text7Content = @"(Renter's Initials)";
    NSString* text8Content = @"(Renter's Initials)";
    NSString* text9Content = @"(Renter's Initials)";
    NSString* text10Content = @"Student Signature:";
    NSString* text11Content = @"Date:";
    NSString* text12Content = @"STAFF ONLY";
    NSString* text13Content = @"Rental Prep:";
    NSString* text14Content = @"Check Out:";
    NSString* text15Content = @"Check In:";
    NSString* text16Content = @"Date:";
    NSString* text17Content = @"Date:";
    NSString* text18Content = @"Date:";
    NSString* text19Content = @"Time:";
    NSString* text20Content = @"Time:";
    NSString* text21Content = @"AM / PM";
    NSString* text22Content = @"AM / PM";
    NSString* text23Content = @"/";
    NSString* text24Content = @"/";
    NSString* text25Content = @"/";
    NSString* text26Content = @"STAFF ONLY";
    NSString* text27Content = @"Additional Fee:  $";
    NSString* text28Content = @"paid";
    NSString* text29Content = @"ON TIME";
    NSString* text30Content = @"LATE";
    NSString* text31Content = @"date:";
    NSString* text32Content = @"/";
    NSString* text33Content = @"Staff Initials";
    NSString* text34Content = @"Staff Initials";
    NSString* text35Content = @"Staff Initials";
    NSString* text36Content = @"Staff Initials";
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) - 2, 264, 15);
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: textStyle};
    
    [textContent drawInRect: textRect withAttributes: textFontAttributes];
    
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 15, 469, 65);
    NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text2Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text2Style};
    
    [text2Content drawInRect: text2Rect withAttributes: text2FontAttributes];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 80, 469, 26);
    NSMutableParagraphStyle* text3Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text3Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text3FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text3Style};
    
    [text3Content drawInRect: text3Rect withAttributes: text3FontAttributes];
    
    
    //// Text 4 Drawing
    CGRect text4Rect = CGRectMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 110, 469, 26);
    NSMutableParagraphStyle* text4Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text4Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text4FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text4Style};
    
    [text4Content drawInRect: text4Rect withAttributes: text4FontAttributes];
    
    
    //// Text 5 Drawing
    CGRect text5Rect = CGRectMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 142, 469, 26);
    NSMutableParagraphStyle* text5Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text5Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text5FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text5Style};
    
    [text5Content drawInRect: text5Rect withAttributes: text5FontAttributes];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 71.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 583.5, CGRectGetMinY(frame) + 71.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 71.5)];
    [bezierPath closePath];
    [[UIColor grayColor] setFill];
    [bezierPath fill];
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 0.5;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 103.5)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 583.5, CGRectGetMinY(frame) + 103.5)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 103.5)];
    [bezier2Path closePath];
    [[UIColor grayColor] setFill];
    [bezier2Path fill];
    [[UIColor blackColor] setStroke];
    bezier2Path.lineWidth = 0.5;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 130.5)];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 583.5, CGRectGetMinY(frame) + 130.5)];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 130.5)];
    [bezier3Path closePath];
    [[UIColor grayColor] setFill];
    [bezier3Path fill];
    [[UIColor blackColor] setStroke];
    bezier3Path.lineWidth = 0.5;
    [bezier3Path stroke];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 162.5)];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 583.5, CGRectGetMinY(frame) + 162.5)];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 519.5, CGRectGetMinY(frame) + 162.5)];
    [bezier4Path closePath];
    [[UIColor grayColor] setFill];
    [bezier4Path fill];
    [[UIColor blackColor] setStroke];
    bezier4Path.lineWidth = 0.5;
    [bezier4Path stroke];
    
    
    //// Text 6 Drawing
    CGRect text6Rect = CGRectMake(CGRectGetMinX(frame) + 519, CGRectGetMinY(frame) + 72, 64, 11);
    NSMutableParagraphStyle* text6Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text6Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text6FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text6Style};
    
    [text6Content drawInRect: text6Rect withAttributes: text6FontAttributes];
    
    
    //// Text 7 Drawing
    CGRect text7Rect = CGRectMake(CGRectGetMinX(frame) + 520, CGRectGetMinY(frame) + 104, 64, 11);
    NSMutableParagraphStyle* text7Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text7Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text7FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text7Style};
    
    [text7Content drawInRect: text7Rect withAttributes: text7FontAttributes];
    
    
    //// Text 8 Drawing
    CGRect text8Rect = CGRectMake(CGRectGetMinX(frame) + 520, CGRectGetMinY(frame) + 131, 64, 11);
    NSMutableParagraphStyle* text8Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text8Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text8FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text8Style};
    
    [text8Content drawInRect: text8Rect withAttributes: text8FontAttributes];
    
    
    //// Text 9 Drawing
    CGRect text9Rect = CGRectMake(CGRectGetMinX(frame) + 520, CGRectGetMinY(frame) + 163, 64, 11);
    NSMutableParagraphStyle* text9Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text9Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text9FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text9Style};
    
    [text9Content drawInRect: text9Rect withAttributes: text9FontAttributes];
    
    
    //// Text 10 Drawing
    CGRect text10Rect = CGRectMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 185, 264, 15);
    NSMutableParagraphStyle* text10Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text10Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text10FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text10Style};
    
    [text10Content drawInRect: text10Rect withAttributes: text10FontAttributes];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 123.5, CGRectGetMinY(frame) + 197.5)];
    [bezier5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 382, CGRectGetMinY(frame) + 197.5)];
    [bezier5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 123.5, CGRectGetMinY(frame) + 197.5)];
    [bezier5Path closePath];
    [[UIColor grayColor] setFill];
    [bezier5Path fill];
    [[UIColor blackColor] setStroke];
    bezier5Path.lineWidth = 0.5;
    [bezier5Path stroke];
    
    
    //// Text 11 Drawing
    CGRect text11Rect = CGRectMake(CGRectGetMinX(frame) + 387, CGRectGetMinY(frame) + 185, 29, 15);
    NSMutableParagraphStyle* text11Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text11Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text11FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text11Style};
    
    [text11Content drawInRect: text11Rect withAttributes: text11FontAttributes];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 418.5, CGRectGetMinY(frame) + 197.5)];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 512, CGRectGetMinY(frame) + 197.5)];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 418.5, CGRectGetMinY(frame) + 197.5)];
    [bezier6Path closePath];
    [[UIColor grayColor] setFill];
    [bezier6Path fill];
    [[UIColor blackColor] setStroke];
    bezier6Path.lineWidth = 0.5;
    [bezier6Path stroke];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 207.5, 330, 41)];
    [[UIColor whiteColor] setFill];
    [rectanglePath fill];
    [[UIColor blackColor] setStroke];
    rectanglePath.lineWidth = 0.5;
    [rectanglePath stroke];
    
    
    //// Text 12 Drawing
    CGRect text12Rect = CGRectMake(CGRectGetMinX(frame) + 27, CGRectGetMinY(frame) + 215, 31, 28);
    NSMutableParagraphStyle* text12Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text12Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text12FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text12Style};
    
    [text12Content drawInRect: text12Rect withAttributes: text12FontAttributes];
    
    
    //// Text 13 Drawing
    CGRect text13Rect = CGRectMake(CGRectGetMinX(frame) + 63, CGRectGetMinY(frame) + 210, 46, 12);
    NSMutableParagraphStyle* text13Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text13Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text13FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text13Style};
    
    [text13Content drawInRect: text13Rect withAttributes: text13FontAttributes];
    
    
    //// Text 14 Drawing
    CGRect text14Rect = CGRectMake(CGRectGetMinX(frame) + 63, CGRectGetMinY(frame) + 222, 46, 12);
    NSMutableParagraphStyle* text14Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text14Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text14FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text14Style};
    
    [text14Content drawInRect: text14Rect withAttributes: text14FontAttributes];
    
    
    //// Text 15 Drawing
    CGRect text15Rect = CGRectMake(CGRectGetMinX(frame) + 63, CGRectGetMinY(frame) + 234, 46, 12);
    NSMutableParagraphStyle* text15Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text15Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text15FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text15Style};
    
    [text15Content drawInRect: text15Rect withAttributes: text15FontAttributes];
    
    
    //// Text 16 Drawing
    CGRect text16Rect = CGRectMake(CGRectGetMinX(frame) + 178, CGRectGetMinY(frame) + 210, 61, 12);
    NSMutableParagraphStyle* text16Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text16Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text16FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text16Style};
    
    [text16Content drawInRect: text16Rect withAttributes: text16FontAttributes];
    
    
    //// Text 17 Drawing
    CGRect text17Rect = CGRectMake(CGRectGetMinX(frame) + 178, CGRectGetMinY(frame) + 222, 61, 12);
    NSMutableParagraphStyle* text17Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text17Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text17FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text17Style};
    
    [text17Content drawInRect: text17Rect withAttributes: text17FontAttributes];
    
    
    //// Text 18 Drawing
    CGRect text18Rect = CGRectMake(CGRectGetMinX(frame) + 178, CGRectGetMinY(frame) + 234, 61, 12);
    NSMutableParagraphStyle* text18Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text18Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text18FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text18Style};
    
    [text18Content drawInRect: text18Rect withAttributes: text18FontAttributes];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 111.5, CGRectGetMinY(frame) + 219.5)];
    [bezier7Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 172.5, CGRectGetMinY(frame) + 219.5)];
    [bezier7Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 111.5, CGRectGetMinY(frame) + 219.5)];
    [bezier7Path closePath];
    [[UIColor grayColor] setFill];
    [bezier7Path fill];
    [[UIColor blackColor] setStroke];
    bezier7Path.lineWidth = 0.5;
    [bezier7Path stroke];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 111.5, CGRectGetMinY(frame) + 231.5)];
    [bezier8Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 172.5, CGRectGetMinY(frame) + 231.5)];
    [bezier8Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 111.5, CGRectGetMinY(frame) + 231.5)];
    [bezier8Path closePath];
    [[UIColor grayColor] setFill];
    [bezier8Path fill];
    [[UIColor blackColor] setStroke];
    bezier8Path.lineWidth = 0.5;
    [bezier8Path stroke];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 111.5, CGRectGetMinY(frame) + 242.5)];
    [bezier9Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 172.5, CGRectGetMinY(frame) + 242.5)];
    [bezier9Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 111.5, CGRectGetMinY(frame) + 242.5)];
    [bezier9Path closePath];
    [[UIColor grayColor] setFill];
    [bezier9Path fill];
    [[UIColor blackColor] setStroke];
    bezier9Path.lineWidth = 0.5;
    [bezier9Path stroke];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 198.5, CGRectGetMinY(frame) + 219.5)];
    [bezier10Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 256, CGRectGetMinY(frame) + 219.5)];
    [bezier10Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 198.5, CGRectGetMinY(frame) + 219.5)];
    [bezier10Path closePath];
    [[UIColor grayColor] setFill];
    [bezier10Path fill];
    [[UIColor blackColor] setStroke];
    bezier10Path.lineWidth = 0.5;
    [bezier10Path stroke];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 198.5, CGRectGetMinY(frame) + 231.5)];
    [bezier11Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 256, CGRectGetMinY(frame) + 231.5)];
    [bezier11Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 198.5, CGRectGetMinY(frame) + 231.5)];
    [bezier11Path closePath];
    [[UIColor grayColor] setFill];
    [bezier11Path fill];
    [[UIColor blackColor] setStroke];
    bezier11Path.lineWidth = 0.5;
    [bezier11Path stroke];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 198.5, CGRectGetMinY(frame) + 242.5)];
    [bezier12Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 256, CGRectGetMinY(frame) + 242.5)];
    [bezier12Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 198.5, CGRectGetMinY(frame) + 242.5)];
    [bezier12Path closePath];
    [[UIColor grayColor] setFill];
    [bezier12Path fill];
    [[UIColor blackColor] setStroke];
    bezier12Path.lineWidth = 0.5;
    [bezier12Path stroke];
    
    
    //// Text 19 Drawing
    CGRect text19Rect = CGRectMake(CGRectGetMinX(frame) + 263, CGRectGetMinY(frame) + 222, 61, 12);
    NSMutableParagraphStyle* text19Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text19Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text19FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text19Style};
    
    [text19Content drawInRect: text19Rect withAttributes: text19FontAttributes];
    
    
    //// Text 20 Drawing
    CGRect text20Rect = CGRectMake(CGRectGetMinX(frame) + 263, CGRectGetMinY(frame) + 234, 61, 12);
    NSMutableParagraphStyle* text20Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text20Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text20FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text20Style};
    
    [text20Content drawInRect: text20Rect withAttributes: text20FontAttributes];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 284.5, CGRectGetMinY(frame) + 231.5)];
    [bezier13Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 323, CGRectGetMinY(frame) + 231.5)];
    [bezier13Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 284.5, CGRectGetMinY(frame) + 231.5)];
    [bezier13Path closePath];
    [[UIColor grayColor] setFill];
    [bezier13Path fill];
    [[UIColor blackColor] setStroke];
    bezier13Path.lineWidth = 0.5;
    [bezier13Path stroke];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 284.5, CGRectGetMinY(frame) + 242.5)];
    [bezier14Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 323.5, CGRectGetMinY(frame) + 242.5)];
    [bezier14Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 284.5, CGRectGetMinY(frame) + 242.5)];
    [bezier14Path closePath];
    [[UIColor grayColor] setFill];
    [bezier14Path fill];
    [[UIColor blackColor] setStroke];
    bezier14Path.lineWidth = 0.5;
    [bezier14Path stroke];
    
    
    //// Text 21 Drawing
    CGRect text21Rect = CGRectMake(CGRectGetMinX(frame) + 324, CGRectGetMinY(frame) + 225, 61, 12);
    NSMutableParagraphStyle* text21Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text21Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text21FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 6.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text21Style};
    
    [text21Content drawInRect: text21Rect withAttributes: text21FontAttributes];
    
    
    //// Text 22 Drawing
    CGRect text22Rect = CGRectMake(CGRectGetMinX(frame) + 324, CGRectGetMinY(frame) + 236, 61, 12);
    NSMutableParagraphStyle* text22Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text22Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text22FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 6.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text22Style};
    
    [text22Content drawInRect: text22Rect withAttributes: text22FontAttributes];
    
    
    //// Text 23 Drawing
    CGRect text23Rect = CGRectMake(CGRectGetMinX(frame) + 218, CGRectGetMinY(frame) + 209, 21, 14);
    NSMutableParagraphStyle* text23Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text23Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text23FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text23Style};
    
    [text23Content drawInRect: text23Rect withAttributes: text23FontAttributes];
    
    
    //// Text 24 Drawing
    CGRect text24Rect = CGRectMake(CGRectGetMinX(frame) + 217, CGRectGetMinY(frame) + 221, 21, 14);
    NSMutableParagraphStyle* text24Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text24Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text24FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text24Style};
    
    [text24Content drawInRect: text24Rect withAttributes: text24FontAttributes];
    
    
    //// Text 25 Drawing
    CGRect text25Rect = CGRectMake(CGRectGetMinX(frame) + 217, CGRectGetMinY(frame) + 232, 21, 14);
    NSMutableParagraphStyle* text25Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text25Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text25FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text25Style};
    
    [text25Content drawInRect: text25Rect withAttributes: text25FontAttributes];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 382.5, CGRectGetMinY(frame) + 207.5, 200.5, 41)];
    [[UIColor whiteColor] setFill];
    [rectangle2Path fill];
    [[UIColor blackColor] setStroke];
    rectangle2Path.lineWidth = 0.5;
    [rectangle2Path stroke];
    
    
    //// Text 26 Drawing
    CGRect text26Rect = CGRectMake(CGRectGetMinX(frame) + 385, CGRectGetMinY(frame) + 215, 31, 28);
    NSMutableParagraphStyle* text26Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text26Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text26FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text26Style};
    
    [text26Content drawInRect: text26Rect withAttributes: text26FontAttributes];
    
    
    //// Text 27 Drawing
    CGRect text27Rect = CGRectMake(CGRectGetMinX(frame) + 423, CGRectGetMinY(frame) + 216, 65, 12);
    NSMutableParagraphStyle* text27Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text27Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text27FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text27Style};
    
    [text27Content drawInRect: text27Rect withAttributes: text27FontAttributes];
    
    
    //// Text 28 Drawing
    CGRect text28Rect = CGRectMake(CGRectGetMinX(frame) + 423, CGRectGetMinY(frame) + 230, 46, 12);
    NSMutableParagraphStyle* text28Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text28Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text28FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text28Style};
    
    [text28Content drawInRect: text28Rect withAttributes: text28FontAttributes];
    
    
    //// Text 29 Drawing
    CGRect text29Rect = CGRectMake(CGRectGetMinX(frame) + 545, CGRectGetMinY(frame) + 216, 38, 11);
    NSMutableParagraphStyle* text29Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text29Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text29FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text29Style};
    
    [text29Content drawInRect: text29Rect withAttributes: text29FontAttributes];
    
    
    //// Text 30 Drawing
    CGRect text30Rect = CGRectMake(CGRectGetMinX(frame) + 545, CGRectGetMinY(frame) + 230, 38, 11);
    NSMutableParagraphStyle* text30Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text30Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text30FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text30Style};
    
    [text30Content drawInRect: text30Rect withAttributes: text30FontAttributes];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 533.5, CGRectGetMinY(frame) + 216.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle3Path fill];
    [[UIColor blackColor] setStroke];
    rectangle3Path.lineWidth = 0.5;
    [rectangle3Path stroke];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 533.5, CGRectGetMinY(frame) + 229.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle4Path fill];
    [[UIColor blackColor] setStroke];
    rectangle4Path.lineWidth = 0.5;
    [rectangle4Path stroke];
    
    
    //// Rectangle 5 Drawing
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 440.5, CGRectGetMinY(frame) + 232.5, 6, 6)];
    [[UIColor whiteColor] setFill];
    [rectangle5Path fill];
    [[UIColor blackColor] setStroke];
    rectangle5Path.lineWidth = 0.5;
    [rectangle5Path stroke];
    
    
    //// Text 31 Drawing
    CGRect text31Rect = CGRectMake(CGRectGetMinX(frame) + 453, CGRectGetMinY(frame) + 230, 46, 12);
    NSMutableParagraphStyle* text31Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text31Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text31FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text31Style};
    
    [text31Content drawInRect: text31Rect withAttributes: text31FontAttributes];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 486.5, CGRectGetMinY(frame) + 225.5)];
    [bezier15Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 529.5, CGRectGetMinY(frame) + 225.5)];
    [bezier15Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 486.5, CGRectGetMinY(frame) + 225.5)];
    [bezier15Path closePath];
    [[UIColor grayColor] setFill];
    [bezier15Path fill];
    [[UIColor blackColor] setStroke];
    bezier15Path.lineWidth = 0.5;
    [bezier15Path stroke];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 471.5, CGRectGetMinY(frame) + 239.5)];
    [bezier16Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 502.5, CGRectGetMinY(frame) + 239.5)];
    [bezier16Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 471.5, CGRectGetMinY(frame) + 239.5)];
    [bezier16Path closePath];
    [[UIColor grayColor] setFill];
    [bezier16Path fill];
    [[UIColor blackColor] setStroke];
    bezier16Path.lineWidth = 0.5;
    [bezier16Path stroke];
    
    
    //// Text 32 Drawing
    CGRect text32Rect = CGRectMake(CGRectGetMinX(frame) + 477, CGRectGetMinY(frame) + 229, 21, 14);
    NSMutableParagraphStyle* text32Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text32Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text32FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text32Style};
    
    [text32Content drawInRect: text32Rect withAttributes: text32FontAttributes];
    
    
    //// Text 33 Drawing
    CGRect text33Rect = CGRectMake(CGRectGetMinX(frame) + 507, CGRectGetMinY(frame) + 241, 46, 12);
    NSMutableParagraphStyle* text33Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text33Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text33FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text33Style};
    
    [text33Content drawInRect: text33Rect withAttributes: text33FontAttributes];
    
    
    //// Rectangle 6 Drawing
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 510.5, CGRectGetMinY(frame) + 231, 19, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle6Path fill];
    [[UIColor blackColor] setStroke];
    rectangle6Path.lineWidth = 0.5;
    [rectangle6Path stroke];
    
    
    //// Text 34 Drawing
    CGRect text34Rect = CGRectMake(CGRectGetMinX(frame) + 147, CGRectGetMinY(frame) + 213, 30, 8);
    NSMutableParagraphStyle* text34Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text34Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text34FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text34Style};
    
    [text34Content drawInRect: text34Rect withAttributes: text34FontAttributes];
    
    
    //// Text 35 Drawing
    CGRect text35Rect = CGRectMake(CGRectGetMinX(frame) + 147, CGRectGetMinY(frame) + 225, 30, 8);
    NSMutableParagraphStyle* text35Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text35Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text35FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text35Style};
    
    [text35Content drawInRect: text35Rect withAttributes: text35FontAttributes];
    
    
    //// Text 36 Drawing
    CGRect text36Rect = CGRectMake(CGRectGetMinX(frame) + 147, CGRectGetMinY(frame) + 236, 30, 8);
    NSMutableParagraphStyle* text36Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text36Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text36FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text36Style};
    
    [text36Content drawInRect: text36Rect withAttributes: text36FontAttributes];
    
    

    
    
    
    
}


#pragma mark - other page renderer methods to override


//- (NSInteger)numberOfPages{
//    
//    
//    return 1;
//}



@end
