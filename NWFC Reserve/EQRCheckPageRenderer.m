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
    CGRect textRect = CGRectMake(23, 110, 40, 19);
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: textStyle};
    
    [@"Name:" drawInRect: textRect withAttributes: textFontAttributes];
    
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(23, 135, 40, 19);
    NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text2Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text2Style};
    
    [@"Phone:" drawInRect: text2Rect withAttributes: text2FontAttributes];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(23, 158, 40, 19);
    NSMutableParagraphStyle* text3Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text3Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text3FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text3Style};
    
    [@"Email: " drawInRect: text3Rect withAttributes: text3FontAttributes];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(390.5, 110, 185, 58)];
    [[UIColor blackColor] setStroke];
    rectanglePath.lineWidth = 0.5;
    [rectanglePath stroke];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(56.5, 121.5)];
    [bezierPath addLineToPoint: CGPointMake(306.5, 121.5)];
    [bezierPath addLineToPoint: CGPointMake(56.5, 121.5)];
    [bezierPath closePath];
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 0.5;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(56.5, 144.5)];
    [bezier2Path addLineToPoint: CGPointMake(306.5, 144.5)];
    [bezier2Path addLineToPoint: CGPointMake(56.5, 144.5)];
    [bezier2Path closePath];
    [[UIColor blackColor] setStroke];
    bezier2Path.lineWidth = 0.5;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(56.5, 167.5)];
    [bezier3Path addLineToPoint: CGPointMake(306.5, 167.5)];
    [bezier3Path addLineToPoint: CGPointMake(56.5, 167.5)];
    [bezier3Path closePath];
    [[UIColor blackColor] setStroke];
    bezier3Path.lineWidth = 0.5;
    [bezier3Path stroke];
    
    
    //// Group
    {
        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
        [bezier4Path moveToPoint: CGPointMake(30.12, 49.88)];
        [bezier4Path addCurveToPoint: CGPointMake(30.12, 44.27) controlPoint1: CGPointMake(30.12, 49.88) controlPoint2: CGPointMake(30.12, 46.55)];
        [bezier4Path addCurveToPoint: CGPointMake(26.36, 44.27) controlPoint1: CGPointMake(30.12, 42.26) controlPoint2: CGPointMake(26.36, 42.34)];
        [bezier4Path addCurveToPoint: CGPointMake(26.36, 48.59) controlPoint1: CGPointMake(26.36, 46.47) controlPoint2: CGPointMake(26.36, 47.18)];
        [bezier4Path addCurveToPoint: CGPointMake(32.44, 55.92) controlPoint1: CGPointMake(26.36, 50.39) controlPoint2: CGPointMake(31.24, 53.45)];
        [bezier4Path addCurveToPoint: CGPointMake(33.48, 58.9) controlPoint1: CGPointMake(33.22, 57.54) controlPoint2: CGPointMake(33.4, 58.27)];
        [bezier4Path addCurveToPoint: CGPointMake(33, 65.1) controlPoint1: CGPointMake(33.56, 59.53) controlPoint2: CGPointMake(33.96, 63.45)];
        [bezier4Path addCurveToPoint: CGPointMake(28.2, 68) controlPoint1: CGPointMake(32.04, 66.75) controlPoint2: CGPointMake(30.92, 68)];
        [bezier4Path addCurveToPoint: CGPointMake(23.16, 63.61) controlPoint1: CGPointMake(25.48, 68) controlPoint2: CGPointMake(23.16, 65.18)];
        [bezier4Path addCurveToPoint: CGPointMake(23.16, 57.73) controlPoint1: CGPointMake(23.16, 62.04) controlPoint2: CGPointMake(23.16, 57.73)];
        [bezier4Path addLineToPoint: CGPointMake(26.2, 57.73)];
        [bezier4Path addCurveToPoint: CGPointMake(26.2, 62.9) controlPoint1: CGPointMake(26.2, 57.73) controlPoint2: CGPointMake(26.2, 61.49)];
        [bezier4Path addCurveToPoint: CGPointMake(28.4, 65.1) controlPoint1: CGPointMake(26.2, 64.31) controlPoint2: CGPointMake(26.99, 65.1)];
        [bezier4Path addCurveToPoint: CGPointMake(30.6, 63.14) controlPoint1: CGPointMake(29.8, 65.1) controlPoint2: CGPointMake(30.6, 64.71)];
        [bezier4Path addCurveToPoint: CGPointMake(30.6, 59.76) controlPoint1: CGPointMake(30.6, 61.57) controlPoint2: CGPointMake(30.6, 61.02)];
        [bezier4Path addCurveToPoint: CGPointMake(28.84, 56.16) controlPoint1: CGPointMake(30.6, 58.51) controlPoint2: CGPointMake(29.88, 57.1)];
        [bezier4Path addCurveToPoint: CGPointMake(23.64, 49.96) controlPoint1: CGPointMake(27.8, 55.22) controlPoint2: CGPointMake(23.88, 51.61)];
        [bezier4Path addCurveToPoint: CGPointMake(23.64, 43.69) controlPoint1: CGPointMake(23.4, 48.31) controlPoint2: CGPointMake(23.16, 45.26)];
        [bezier4Path addCurveToPoint: CGPointMake(28.4, 40.16) controlPoint1: CGPointMake(24.12, 42.12) controlPoint2: CGPointMake(25.23, 40.16)];
        [bezier4Path addCurveToPoint: CGPointMake(33.24, 44.94) controlPoint1: CGPointMake(31.56, 40.16) controlPoint2: CGPointMake(33.24, 43.22)];
        [bezier4Path addCurveToPoint: CGPointMake(33.24, 49.86) controlPoint1: CGPointMake(33.24, 46.67) controlPoint2: CGPointMake(33.24, 49.86)];
        [bezier4Path addLineToPoint: CGPointMake(30.12, 49.88)];
        [bezier4Path closePath];
        bezier4Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier4Path fill];
        
        
        //// Bezier 5 Drawing
        UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
        [bezier5Path moveToPoint: CGPointMake(43.36, 51.57)];
        [bezier5Path addCurveToPoint: CGPointMake(43.36, 56.31) controlPoint1: CGPointMake(43.36, 53.49) controlPoint2: CGPointMake(43.36, 56.31)];
        [bezier5Path addLineToPoint: CGPointMake(41, 56.31)];
        [bezier5Path addCurveToPoint: CGPointMake(41, 51.85) controlPoint1: CGPointMake(41, 56.31) controlPoint2: CGPointMake(41, 52.68)];
        [bezier5Path addCurveToPoint: CGPointMake(39.56, 50.51) controlPoint1: CGPointMake(41, 51.03) controlPoint2: CGPointMake(40.4, 50.51)];
        [bezier5Path addCurveToPoint: CGPointMake(37.96, 51.94) controlPoint1: CGPointMake(38.54, 50.51) controlPoint2: CGPointMake(37.96, 51.2)];
        [bezier5Path addCurveToPoint: CGPointMake(37.96, 64.15) controlPoint1: CGPointMake(37.96, 52.69) controlPoint2: CGPointMake(37.96, 63.17)];
        [bezier5Path addCurveToPoint: CGPointMake(39.42, 65.59) controlPoint1: CGPointMake(37.96, 65.13) controlPoint2: CGPointMake(38.98, 65.59)];
        [bezier5Path addCurveToPoint: CGPointMake(41, 64.32) controlPoint1: CGPointMake(39.86, 65.59) controlPoint2: CGPointMake(41, 65.22)];
        [bezier5Path addCurveToPoint: CGPointMake(41, 59.61) controlPoint1: CGPointMake(41, 63.77) controlPoint2: CGPointMake(41, 59.61)];
        [bezier5Path addLineToPoint: CGPointMake(43.36, 59.61)];
        [bezier5Path addCurveToPoint: CGPointMake(43.36, 64.16) controlPoint1: CGPointMake(43.36, 59.61) controlPoint2: CGPointMake(43.36, 62.59)];
        [bezier5Path addCurveToPoint: CGPointMake(39.16, 67.8) controlPoint1: CGPointMake(43.36, 65.73) controlPoint2: CGPointMake(41.84, 67.8)];
        [bezier5Path addCurveToPoint: CGPointMake(35.48, 64.24) controlPoint1: CGPointMake(36.48, 67.8) controlPoint2: CGPointMake(35.48, 65.57)];
        [bezier5Path addCurveToPoint: CGPointMake(35.48, 52) controlPoint1: CGPointMake(35.48, 62.9) controlPoint2: CGPointMake(35.48, 53.92)];
        [bezier5Path addCurveToPoint: CGPointMake(39.42, 48.31) controlPoint1: CGPointMake(35.48, 50.08) controlPoint2: CGPointMake(36.88, 48.31)];
        [bezier5Path addCurveToPoint: CGPointMake(43.36, 51.57) controlPoint1: CGPointMake(41.96, 48.31) controlPoint2: CGPointMake(43.36, 49.45)];
        [bezier5Path closePath];
        bezier5Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier5Path fill];
        
        
        //// Bezier 6 Drawing
        UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
        [bezier6Path moveToPoint: CGPointMake(53.8, 50.68)];
        [bezier6Path addCurveToPoint: CGPointMake(53.8, 67.14) controlPoint1: CGPointMake(53.8, 51.89) controlPoint2: CGPointMake(53.8, 67.14)];
        [bezier6Path addLineToPoint: CGPointMake(51.28, 67.14)];
        [bezier6Path addCurveToPoint: CGPointMake(51.28, 51.33) controlPoint1: CGPointMake(51.28, 67.14) controlPoint2: CGPointMake(51.28, 52.47)];
        [bezier6Path addCurveToPoint: CGPointMake(49.64, 50.63) controlPoint1: CGPointMake(51.28, 50.2) controlPoint2: CGPointMake(50.24, 50.24)];
        [bezier6Path addCurveToPoint: CGPointMake(48.32, 52.82) controlPoint1: CGPointMake(49.04, 51.02) controlPoint2: CGPointMake(48.32, 52.12)];
        [bezier6Path addCurveToPoint: CGPointMake(48.32, 67.14) controlPoint1: CGPointMake(48.32, 53.53) controlPoint2: CGPointMake(48.32, 67.14)];
        [bezier6Path addLineToPoint: CGPointMake(45.62, 67.14)];
        [bezier6Path addLineToPoint: CGPointMake(45.62, 40.59)];
        [bezier6Path addLineToPoint: CGPointMake(48.08, 40.59)];
        [bezier6Path addCurveToPoint: CGPointMake(48.08, 50.79) controlPoint1: CGPointMake(48.08, 40.59) controlPoint2: CGPointMake(48.08, 50.36)];
        [bezier6Path addCurveToPoint: CGPointMake(51.44, 48.44) controlPoint1: CGPointMake(48.59, 49.76) controlPoint2: CGPointMake(50.18, 48.31)];
        [bezier6Path addCurveToPoint: CGPointMake(53.8, 50.68) controlPoint1: CGPointMake(52.6, 48.56) controlPoint2: CGPointMake(53.8, 49.46)];
        [bezier6Path closePath];
        bezier6Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier6Path fill];
        
        
        //// Bezier 7 Drawing
        UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
        [bezier7Path moveToPoint: CGPointMake(64.52, 51.76)];
        [bezier7Path addLineToPoint: CGPointMake(64.52, 64)];
        [bezier7Path addCurveToPoint: CGPointMake(60.56, 67.8) controlPoint1: CGPointMake(64.52, 64) controlPoint2: CGPointMake(64.2, 67.8)];
        [bezier7Path addCurveToPoint: CGPointMake(56.32, 63.84) controlPoint1: CGPointMake(56.92, 67.8) controlPoint2: CGPointMake(56.32, 65.14)];
        [bezier7Path addCurveToPoint: CGPointMake(56.32, 51.76) controlPoint1: CGPointMake(56.32, 62.55) controlPoint2: CGPointMake(56.32, 53.69)];
        [bezier7Path addCurveToPoint: CGPointMake(60.42, 48.31) controlPoint1: CGPointMake(56.32, 49.84) controlPoint2: CGPointMake(58, 48.31)];
        [bezier7Path addCurveToPoint: CGPointMake(64.52, 51.76) controlPoint1: CGPointMake(62.84, 48.31) controlPoint2: CGPointMake(64.52, 49.84)];
        [bezier7Path closePath];
        [bezier7Path moveToPoint: CGPointMake(60.42, 50.47)];
        [bezier7Path addCurveToPoint: CGPointMake(58.6, 52.27) controlPoint1: CGPointMake(59.6, 50.47) controlPoint2: CGPointMake(58.6, 51.1)];
        [bezier7Path addCurveToPoint: CGPointMake(58.6, 63.33) controlPoint1: CGPointMake(58.6, 53.45) controlPoint2: CGPointMake(58.6, 62.08)];
        [bezier7Path addCurveToPoint: CGPointMake(60.42, 65.45) controlPoint1: CGPointMake(58.6, 64.59) controlPoint2: CGPointMake(59.44, 65.45)];
        [bezier7Path addCurveToPoint: CGPointMake(62.16, 63.26) controlPoint1: CGPointMake(61.4, 65.45) controlPoint2: CGPointMake(62.16, 64.82)];
        [bezier7Path addCurveToPoint: CGPointMake(62.16, 52.27) controlPoint1: CGPointMake(62.16, 61.69) controlPoint2: CGPointMake(62.16, 53.61)];
        [bezier7Path addCurveToPoint: CGPointMake(60.42, 50.47) controlPoint1: CGPointMake(62.16, 51.41) controlPoint2: CGPointMake(61.24, 50.47)];
        [bezier7Path closePath];
        bezier7Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier7Path fill];
        
        
        //// Bezier 8 Drawing
        UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
        [bezier8Path moveToPoint: CGPointMake(75.28, 51.76)];
        [bezier8Path addLineToPoint: CGPointMake(75.28, 64)];
        [bezier8Path addCurveToPoint: CGPointMake(71.32, 67.8) controlPoint1: CGPointMake(75.28, 64) controlPoint2: CGPointMake(74.96, 67.8)];
        [bezier8Path addCurveToPoint: CGPointMake(67.08, 63.84) controlPoint1: CGPointMake(67.68, 67.8) controlPoint2: CGPointMake(67.08, 65.14)];
        [bezier8Path addCurveToPoint: CGPointMake(67.08, 51.76) controlPoint1: CGPointMake(67.08, 62.55) controlPoint2: CGPointMake(67.08, 53.69)];
        [bezier8Path addCurveToPoint: CGPointMake(71.18, 48.31) controlPoint1: CGPointMake(67.08, 49.84) controlPoint2: CGPointMake(68.76, 48.31)];
        [bezier8Path addCurveToPoint: CGPointMake(75.28, 51.76) controlPoint1: CGPointMake(73.6, 48.31) controlPoint2: CGPointMake(75.28, 49.84)];
        [bezier8Path closePath];
        [bezier8Path moveToPoint: CGPointMake(71.18, 50.47)];
        [bezier8Path addCurveToPoint: CGPointMake(69.36, 52.27) controlPoint1: CGPointMake(70.36, 50.47) controlPoint2: CGPointMake(69.36, 51.1)];
        [bezier8Path addCurveToPoint: CGPointMake(69.36, 63.33) controlPoint1: CGPointMake(69.36, 53.45) controlPoint2: CGPointMake(69.36, 62.08)];
        [bezier8Path addCurveToPoint: CGPointMake(71.18, 65.45) controlPoint1: CGPointMake(69.36, 64.59) controlPoint2: CGPointMake(70.2, 65.45)];
        [bezier8Path addCurveToPoint: CGPointMake(72.92, 63.26) controlPoint1: CGPointMake(72.16, 65.45) controlPoint2: CGPointMake(72.92, 64.82)];
        [bezier8Path addCurveToPoint: CGPointMake(72.92, 52.27) controlPoint1: CGPointMake(72.92, 61.69) controlPoint2: CGPointMake(72.92, 53.61)];
        [bezier8Path addCurveToPoint: CGPointMake(71.18, 50.47) controlPoint1: CGPointMake(72.92, 51.41) controlPoint2: CGPointMake(72, 50.47)];
        [bezier8Path closePath];
        bezier8Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier8Path fill];
        
        
        //// Bezier 9 Drawing
        UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
        [bezier9Path moveToPoint: CGPointMake(93.36, 51.76)];
        [bezier9Path addLineToPoint: CGPointMake(93.36, 64)];
        [bezier9Path addCurveToPoint: CGPointMake(89.4, 67.8) controlPoint1: CGPointMake(93.36, 64) controlPoint2: CGPointMake(93.04, 67.8)];
        [bezier9Path addCurveToPoint: CGPointMake(85.16, 63.84) controlPoint1: CGPointMake(85.76, 67.8) controlPoint2: CGPointMake(85.16, 65.14)];
        [bezier9Path addCurveToPoint: CGPointMake(85.16, 51.76) controlPoint1: CGPointMake(85.16, 62.55) controlPoint2: CGPointMake(85.16, 53.69)];
        [bezier9Path addCurveToPoint: CGPointMake(89.26, 48.31) controlPoint1: CGPointMake(85.16, 49.84) controlPoint2: CGPointMake(86.84, 48.31)];
        [bezier9Path addCurveToPoint: CGPointMake(93.36, 51.76) controlPoint1: CGPointMake(91.68, 48.31) controlPoint2: CGPointMake(93.36, 49.84)];
        [bezier9Path closePath];
        [bezier9Path moveToPoint: CGPointMake(89.26, 50.47)];
        [bezier9Path addCurveToPoint: CGPointMake(87.44, 52.27) controlPoint1: CGPointMake(88.44, 50.47) controlPoint2: CGPointMake(87.44, 51.1)];
        [bezier9Path addCurveToPoint: CGPointMake(87.44, 63.33) controlPoint1: CGPointMake(87.44, 53.45) controlPoint2: CGPointMake(87.44, 62.08)];
        [bezier9Path addCurveToPoint: CGPointMake(89.26, 65.45) controlPoint1: CGPointMake(87.44, 64.59) controlPoint2: CGPointMake(88.28, 65.45)];
        [bezier9Path addCurveToPoint: CGPointMake(91, 63.26) controlPoint1: CGPointMake(90.24, 65.45) controlPoint2: CGPointMake(91, 64.82)];
        [bezier9Path addCurveToPoint: CGPointMake(91, 52.27) controlPoint1: CGPointMake(91, 61.69) controlPoint2: CGPointMake(91, 53.61)];
        [bezier9Path addCurveToPoint: CGPointMake(89.26, 50.47) controlPoint1: CGPointMake(91, 51.41) controlPoint2: CGPointMake(90.08, 50.47)];
        [bezier9Path closePath];
        bezier9Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier9Path fill];
        
        
        //// Bezier 10 Drawing
        UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
        [bezier10Path moveToPoint: CGPointMake(77.76, 40.9)];
        [bezier10Path addLineToPoint: CGPointMake(80.24, 40.9)];
        [bezier10Path addLineToPoint: CGPointMake(80.24, 67.33)];
        [bezier10Path addLineToPoint: CGPointMake(77.76, 67.33)];
        [bezier10Path addLineToPoint: CGPointMake(77.76, 40.9)];
        [bezier10Path closePath];
        bezier10Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier10Path fill];
        
        
        //// Bezier 11 Drawing
        UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
        [bezier11Path moveToPoint: CGPointMake(121.14, 40.9)];
        [bezier11Path addLineToPoint: CGPointMake(123.62, 40.9)];
        [bezier11Path addLineToPoint: CGPointMake(123.62, 67.33)];
        [bezier11Path addLineToPoint: CGPointMake(121.14, 67.33)];
        [bezier11Path addLineToPoint: CGPointMake(121.14, 40.9)];
        [bezier11Path closePath];
        bezier11Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier11Path fill];
        
        
        //// Bezier 12 Drawing
        UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
        [bezier12Path moveToPoint: CGPointMake(99.88, 40.39)];
        [bezier12Path addCurveToPoint: CGPointMake(102.4, 40.39) controlPoint1: CGPointMake(100.88, 40.39) controlPoint2: CGPointMake(102.4, 40.39)];
        [bezier12Path addLineToPoint: CGPointMake(102.4, 42.71)];
        [bezier12Path addCurveToPoint: CGPointMake(100.12, 42.71) controlPoint1: CGPointMake(102.4, 42.71) controlPoint2: CGPointMake(100.6, 42.71)];
        [bezier12Path addCurveToPoint: CGPointMake(99.24, 43.57) controlPoint1: CGPointMake(99.64, 42.71) controlPoint2: CGPointMake(99.24, 43.25)];
        [bezier12Path addCurveToPoint: CGPointMake(99.24, 48.51) controlPoint1: CGPointMake(99.24, 43.88) controlPoint2: CGPointMake(99.24, 48.51)];
        [bezier12Path addLineToPoint: CGPointMake(101.16, 48.51)];
        [bezier12Path addLineToPoint: CGPointMake(101.16, 50.31)];
        [bezier12Path addLineToPoint: CGPointMake(99.24, 50.31)];
        [bezier12Path addLineToPoint: CGPointMake(99.24, 67.29)];
        [bezier12Path addLineToPoint: CGPointMake(96.6, 67.29)];
        [bezier12Path addLineToPoint: CGPointMake(96.6, 50.43)];
        [bezier12Path addLineToPoint: CGPointMake(95.04, 50.43)];
        [bezier12Path addLineToPoint: CGPointMake(95.04, 48.55)];
        [bezier12Path addLineToPoint: CGPointMake(96.6, 48.55)];
        [bezier12Path addCurveToPoint: CGPointMake(96.6, 43.73) controlPoint1: CGPointMake(96.6, 48.55) controlPoint2: CGPointMake(96.6, 45.73)];
        [bezier12Path addCurveToPoint: CGPointMake(99.88, 40.39) controlPoint1: CGPointMake(96.6, 41.73) controlPoint2: CGPointMake(97.76, 40.39)];
        [bezier12Path closePath];
        bezier12Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier12Path fill];
        
        
        //// Bezier 13 Drawing
        UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
        [bezier13Path moveToPoint: CGPointMake(105.36, 40.67)];
        [bezier13Path addLineToPoint: CGPointMake(114, 40.67)];
        [bezier13Path addLineToPoint: CGPointMake(114, 43.26)];
        [bezier13Path addLineToPoint: CGPointMake(108.28, 43.26)];
        [bezier13Path addLineToPoint: CGPointMake(108.28, 52.16)];
        [bezier13Path addLineToPoint: CGPointMake(112.8, 52.16)];
        [bezier13Path addLineToPoint: CGPointMake(112.8, 54.86)];
        [bezier13Path addLineToPoint: CGPointMake(108.32, 54.86)];
        [bezier13Path addLineToPoint: CGPointMake(108.32, 67.29)];
        [bezier13Path addLineToPoint: CGPointMake(105.36, 67.29)];
        [bezier13Path addLineToPoint: CGPointMake(105.36, 40.67)];
        [bezier13Path closePath];
        bezier13Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier13Path fill];
        
        
        //// Bezier 14 Drawing
        UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
        [bezier14Path moveToPoint: CGPointMake(115.88, 40.67)];
        [bezier14Path addLineToPoint: CGPointMake(118.32, 40.67)];
        [bezier14Path addLineToPoint: CGPointMake(118.32, 43.88)];
        [bezier14Path addLineToPoint: CGPointMake(115.88, 43.88)];
        [bezier14Path addLineToPoint: CGPointMake(115.88, 40.67)];
        [bezier14Path closePath];
        bezier14Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier14Path fill];
        
        
        //// Bezier 15 Drawing
        UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
        [bezier15Path moveToPoint: CGPointMake(115.88, 48.67)];
        [bezier15Path addLineToPoint: CGPointMake(118.32, 48.67)];
        [bezier15Path addLineToPoint: CGPointMake(118.32, 67.29)];
        [bezier15Path addLineToPoint: CGPointMake(115.88, 67.29)];
        [bezier15Path addLineToPoint: CGPointMake(115.88, 48.67)];
        [bezier15Path closePath];
        bezier15Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier15Path fill];
        
        
        //// Bezier 16 Drawing
        UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
        [bezier16Path moveToPoint: CGPointMake(140.27, 50.59)];
        [bezier16Path addCurveToPoint: CGPointMake(140.27, 67.29) controlPoint1: CGPointMake(140.27, 51.5) controlPoint2: CGPointMake(140.27, 67.29)];
        [bezier16Path addLineToPoint: CGPointMake(137.84, 67.29)];
        [bezier16Path addCurveToPoint: CGPointMake(137.84, 51.68) controlPoint1: CGPointMake(137.84, 67.29) controlPoint2: CGPointMake(137.84, 52.68)];
        [bezier16Path addCurveToPoint: CGPointMake(135.85, 50.57) controlPoint1: CGPointMake(137.84, 50.68) controlPoint2: CGPointMake(136.67, 50.24)];
        [bezier16Path addCurveToPoint: CGPointMake(134.42, 52.59) controlPoint1: CGPointMake(135.28, 50.81) controlPoint2: CGPointMake(134.42, 51.65)];
        [bezier16Path addCurveToPoint: CGPointMake(134.42, 67.29) controlPoint1: CGPointMake(134.42, 53.53) controlPoint2: CGPointMake(134.42, 67.29)];
        [bezier16Path addLineToPoint: CGPointMake(131.78, 67.29)];
        [bezier16Path addCurveToPoint: CGPointMake(131.78, 51.62) controlPoint1: CGPointMake(131.78, 67.29) controlPoint2: CGPointMake(131.78, 52.82)];
        [bezier16Path addCurveToPoint: CGPointMake(129.77, 50.82) controlPoint1: CGPointMake(131.78, 50.41) controlPoint2: CGPointMake(130.61, 50.15)];
        [bezier16Path addCurveToPoint: CGPointMake(128.6, 52.59) controlPoint1: CGPointMake(128.93, 51.5) controlPoint2: CGPointMake(128.6, 52.09)];
        [bezier16Path addCurveToPoint: CGPointMake(128.6, 67.29) controlPoint1: CGPointMake(128.6, 53.09) controlPoint2: CGPointMake(128.6, 67.29)];
        [bezier16Path addLineToPoint: CGPointMake(125.96, 67.29)];
        [bezier16Path addLineToPoint: CGPointMake(125.96, 48.82)];
        [bezier16Path addLineToPoint: CGPointMake(128.39, 48.82)];
        [bezier16Path addCurveToPoint: CGPointMake(128.39, 50.82) controlPoint1: CGPointMake(128.39, 48.82) controlPoint2: CGPointMake(128.39, 49.59)];
        [bezier16Path addCurveToPoint: CGPointMake(132.71, 48.53) controlPoint1: CGPointMake(128.93, 49.82) controlPoint2: CGPointMake(131.39, 48.24)];
        [bezier16Path addCurveToPoint: CGPointMake(134.18, 50.71) controlPoint1: CGPointMake(133.79, 48.76) controlPoint2: CGPointMake(134.42, 49.21)];
        [bezier16Path addCurveToPoint: CGPointMake(138.89, 48.59) controlPoint1: CGPointMake(135.23, 49.03) controlPoint2: CGPointMake(137.78, 48.29)];
        [bezier16Path addCurveToPoint: CGPointMake(140.27, 50.59) controlPoint1: CGPointMake(139.83, 48.84) controlPoint2: CGPointMake(140.27, 49.71)];
        [bezier16Path closePath];
        bezier16Path.miterLimit = 4;
        
        [[UIColor blackColor] setFill];
        [bezier16Path fill];
        
        
        //// Group 2
        {
            //// Bezier 17 Drawing
            UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
            [bezier17Path moveToPoint: CGPointMake(167.08, 41.2)];
            [bezier17Path addLineToPoint: CGPointMake(170.74, 44.86)];
            [bezier17Path addLineToPoint: CGPointMake(170.74, 64.99)];
            [bezier17Path addLineToPoint: CGPointMake(167.64, 61.89)];
            [bezier17Path addLineToPoint: CGPointMake(167.25, 61.49)];
            [bezier17Path addLineToPoint: CGPointMake(166.69, 61.54)];
            [bezier17Path addLineToPoint: CGPointMake(162.26, 61.96)];
            [bezier17Path addLineToPoint: CGPointMake(162.26, 41.2)];
            [bezier17Path addLineToPoint: CGPointMake(167.08, 41.2)];
            [bezier17Path closePath];
            [bezier17Path moveToPoint: CGPointMake(167.58, 40)];
            [bezier17Path addLineToPoint: CGPointMake(161.06, 40)];
            [bezier17Path addLineToPoint: CGPointMake(161.06, 63.27)];
            [bezier17Path addLineToPoint: CGPointMake(166.8, 62.74)];
            [bezier17Path addLineToPoint: CGPointMake(171.94, 67.88)];
            [bezier17Path addLineToPoint: CGPointMake(171.94, 44.37)];
            [bezier17Path addLineToPoint: CGPointMake(167.58, 40)];
            [bezier17Path addLineToPoint: CGPointMake(167.58, 40)];
            [bezier17Path closePath];
            bezier17Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier17Path fill];
        }
        
        
        //// Group 3
        {
            //// Rectangle 2 Drawing
            UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(144.25, 40, 23.25, 22.25)];
            [color1 setFill];
            [rectangle2Path fill];
        }
        
        
        //// Group 4
        {
            //// Bezier 18 Drawing
            UIBezierPath* bezier18Path = [UIBezierPath bezierPath];
            [bezier18Path moveToPoint: CGPointMake(165.21, 62.21)];
            [bezier18Path addLineToPoint: CGPointMake(169.25, 66.67)];
            [bezier18Path addLineToPoint: CGPointMake(149.73, 66.67)];
            [bezier18Path addLineToPoint: CGPointMake(146.16, 62.97)];
            [bezier18Path addLineToPoint: CGPointMake(146.16, 62.21)];
            [bezier18Path addLineToPoint: CGPointMake(165.21, 62.21)];
            [bezier18Path closePath];
            [bezier18Path moveToPoint: CGPointMake(165.72, 61)];
            [bezier18Path addLineToPoint: CGPointMake(145, 61)];
            [bezier18Path addLineToPoint: CGPointMake(145, 63.47)];
            [bezier18Path addLineToPoint: CGPointMake(149.25, 67.88)];
            [bezier18Path addLineToPoint: CGPointMake(171.94, 67.88)];
            [bezier18Path addLineToPoint: CGPointMake(165.72, 61)];
            [bezier18Path addLineToPoint: CGPointMake(165.72, 61)];
            [bezier18Path closePath];
            bezier18Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier18Path fill];
        }
        
        
        //// Bezier 19 Drawing
        UIBezierPath* bezier19Path = [UIBezierPath bezierPath];
        [bezier19Path moveToPoint: CGPointMake(150.92, 45.71)];
        [bezier19Path addLineToPoint: CGPointMake(150.92, 58.82)];
        [bezier19Path addLineToPoint: CGPointMake(162.5, 52.26)];
        [bezier19Path addLineToPoint: CGPointMake(150.92, 45.71)];
        [bezier19Path closePath];
        bezier19Path.miterLimit = 4;
        
        [color2 setFill];
        [bezier19Path fill];
        
        
        //// Group 5
        {
            //// Bezier 20 Drawing
            UIBezierPath* bezier20Path = [UIBezierPath bezierPath];
            [bezier20Path moveToPoint: CGPointMake(198.07, 41.2)];
            [bezier20Path addLineToPoint: CGPointMake(201.65, 44.86)];
            [bezier20Path addLineToPoint: CGPointMake(201.65, 64.99)];
            [bezier20Path addLineToPoint: CGPointMake(198.62, 61.89)];
            [bezier20Path addLineToPoint: CGPointMake(198.23, 61.49)];
            [bezier20Path addLineToPoint: CGPointMake(197.68, 61.54)];
            [bezier20Path addLineToPoint: CGPointMake(193.35, 61.96)];
            [bezier20Path addLineToPoint: CGPointMake(193.35, 41.2)];
            [bezier20Path addLineToPoint: CGPointMake(198.07, 41.2)];
            [bezier20Path closePath];
            [bezier20Path moveToPoint: CGPointMake(198.55, 40)];
            [bezier20Path addLineToPoint: CGPointMake(192.18, 40)];
            [bezier20Path addLineToPoint: CGPointMake(192.18, 63.27)];
            [bezier20Path addLineToPoint: CGPointMake(197.79, 62.74)];
            [bezier20Path addLineToPoint: CGPointMake(202.82, 67.88)];
            [bezier20Path addLineToPoint: CGPointMake(202.82, 44.37)];
            [bezier20Path addLineToPoint: CGPointMake(198.55, 40)];
            [bezier20Path addLineToPoint: CGPointMake(198.55, 40)];
            [bezier20Path closePath];
            bezier20Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier20Path fill];
        }
        
        
        //// Group 6
        {
            //// Rectangle 3 Drawing
            UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(175.75, 40, 22.25, 22.25)];
            [color1 setFill];
            [rectangle3Path fill];
        }
        
        
        //// Group 7
        {
            //// Bezier 21 Drawing
            UIBezierPath* bezier21Path = [UIBezierPath bezierPath];
            [bezier21Path moveToPoint: CGPointMake(195.9, 62.21)];
            [bezier21Path addLineToPoint: CGPointMake(200.06, 66.67)];
            [bezier21Path addLineToPoint: CGPointMake(179.98, 66.67)];
            [bezier21Path addLineToPoint: CGPointMake(176.32, 62.97)];
            [bezier21Path addLineToPoint: CGPointMake(176.32, 62.21)];
            [bezier21Path addLineToPoint: CGPointMake(195.9, 62.21)];
            [bezier21Path closePath];
            [bezier21Path moveToPoint: CGPointMake(196.42, 61)];
            [bezier21Path addLineToPoint: CGPointMake(175.12, 61)];
            [bezier21Path addLineToPoint: CGPointMake(175.12, 63.47)];
            [bezier21Path addLineToPoint: CGPointMake(179.49, 67.88)];
            [bezier21Path addLineToPoint: CGPointMake(202.82, 67.88)];
            [bezier21Path addLineToPoint: CGPointMake(196.42, 61)];
            [bezier21Path addLineToPoint: CGPointMake(196.42, 61)];
            [bezier21Path closePath];
            bezier21Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier21Path fill];
        }
        
        
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(180.5, 45.75, 12.75, 11.75)];
        [color2 setFill];
        [ovalPath fill];
    }
    
    
    //// Text 4 Drawing
    CGRect text4Rect = CGRectMake(23, 69, 219, 24);
    NSMutableParagraphStyle* text4Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text4Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text4FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text4Style};
    
    [text4Content drawInRect: text4Rect withAttributes: text4FontAttributes];
    
    
    //// Text 5 Drawing
    CGRect text5Rect = CGRectMake(246, 58, 215, 24);
    NSMutableParagraphStyle* text5Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text5Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text5FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text5Style};
    
    [text5Content drawInRect: text5Rect withAttributes: text5FontAttributes];
    
    
    //// Text 6 Drawing
    CGRect text6Rect = CGRectMake(483, 46, 96, 28);
    NSMutableParagraphStyle* text6Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text6Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text6FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Oblique" size: 7], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text6Style};
    
    [text6Content drawInRect: text6Rect withAttributes: text6FontAttributes];
    
    
    //// Text 7 Drawing
    CGRect text7Rect = CGRectMake(393, 113, 142, 15);
    NSMutableParagraphStyle* text7Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text7Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text7FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 10], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text7Style};
    
    [text7Content drawInRect: text7Rect withAttributes: text7FontAttributes];
    
    
    //// Text 8 Drawing
    CGRect text8Rect = CGRectMake(393, 132, 178, 13);
    NSMutableParagraphStyle* text8Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text8Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text8FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text8Style};
    
    [text8Content drawInRect: text8Rect withAttributes: text8FontAttributes];
    
    
    //// Text 9 Drawing
    CGRect text9Rect = CGRectMake(413, 146, 40, 18);
    NSMutableParagraphStyle* text9Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text9Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text9FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text9Style};
    
    [text9Content drawInRect: text9Rect withAttributes: text9FontAttributes];
    
    
    //// Text 10 Drawing
    CGRect text10Rect = CGRectMake(466, 150, 34, 10);
    NSMutableParagraphStyle* text10Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text10Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text10FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text10Style};
    
    [text10Content drawInRect: text10Rect withAttributes: text10FontAttributes];
    
    
    //// Text 11 Drawing
    CGRect text11Rect = CGRectMake(504, 150, 34, 10);
    NSMutableParagraphStyle* text11Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text11Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text11FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text11Style};
    
    [text11Content drawInRect: text11Rect withAttributes: text11FontAttributes];
    
    
    //// Text 12 Drawing
    CGRect text12Rect = CGRectMake(537, 150, 34, 10);
    NSMutableParagraphStyle* text12Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text12Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text12FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 6], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text12Style};
    
    [text12Content drawInRect: text12Rect withAttributes: text12FontAttributes];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(393.5, 146.5, 17, 16)];
    [[UIColor whiteColor] setFill];
    [rectangle4Path fill];
    [[UIColor blackColor] setStroke];
    rectangle4Path.lineWidth = 1;
    [rectangle4Path stroke];
    
    
    //// Rectangle 5 Drawing
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(454.5, 149.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle5Path fill];
    [[UIColor blackColor] setStroke];
    rectangle5Path.lineWidth = 1;
    [rectangle5Path stroke];
    
    
    //// Rectangle 6 Drawing
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRect: CGRectMake(493.5, 149.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle6Path fill];
    [[UIColor blackColor] setStroke];
    rectangle6Path.lineWidth = 1;
    [rectangle6Path stroke];
    
    
    //// Rectangle 7 Drawing
    UIBezierPath* rectangle7Path = [UIBezierPath bezierPathWithRect: CGRectMake(526.5, 149.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle7Path fill];
    [[UIColor blackColor] setStroke];
    rectangle7Path.lineWidth = 1;
    [rectangle7Path stroke];
    
    
    //// Text 13 Drawing
    CGRect text13Rect = CGRectMake(23, 179, 180, 13);
    NSMutableParagraphStyle* text13Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text13Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text13FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text13Style};
    
    [text13Content drawInRect: text13Rect withAttributes: text13FontAttributes];
    
    
    //// Text 14 Drawing
    CGRect text14Rect = CGRectMake(193, 179, 64, 13);
    NSMutableParagraphStyle* text14Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text14Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text14FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text14Style};
    
    [text14Content drawInRect: text14Rect withAttributes: text14FontAttributes];
    
    
    //// name_text Drawing
    CGRect name_textRect = CGRectMake(57, 108, 241, 14);
    NSMutableParagraphStyle* name_textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [name_textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* name_textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: name_textStyle};
    
    [name_textContent drawInRect: name_textRect withAttributes: name_textFontAttributes];
    
    
    //// phone_text Drawing
    CGRect phone_textRect = CGRectMake(58, 131, 241, 14);
    NSMutableParagraphStyle* phone_textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [phone_textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* phone_textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: phone_textStyle};
    
    [phone_textContent drawInRect: phone_textRect withAttributes: phone_textFontAttributes];
    
    
    //// email_text Drawing
    CGRect email_textRect = CGRectMake(57, 154, 241, 14);
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
    
    
    /// Abstracted Attributes
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
    CGRect textRect = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame), 264, 15);
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: textStyle};
    
    [textContent drawInRect: textRect withAttributes: textFontAttributes];
    
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 17, 469, 65);
    NSMutableParagraphStyle* text2Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text2Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text2Style};
    
    [text2Content drawInRect: text2Rect withAttributes: text2FontAttributes];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 82, 469, 26);
    NSMutableParagraphStyle* text3Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text3Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text3FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text3Style};
    
    [text3Content drawInRect: text3Rect withAttributes: text3FontAttributes];
    
    
    //// Text 4 Drawing
    CGRect text4Rect = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 112, 469, 26);
    NSMutableParagraphStyle* text4Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text4Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text4FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text4Style};
    
    [text4Content drawInRect: text4Rect withAttributes: text4FontAttributes];
    
    
    //// Text 5 Drawing
    CGRect text5Rect = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 144, 469, 26);
    NSMutableParagraphStyle* text5Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text5Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text5FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text5Style};
    
    [text5Content drawInRect: text5Rect withAttributes: text5FontAttributes];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 73.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 575.5, CGRectGetMinY(frame) + 73.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 73.5)];
    [bezierPath closePath];
    [[UIColor grayColor] setFill];
    [bezierPath fill];
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 0.5;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 105.5)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 575.5, CGRectGetMinY(frame) + 105.5)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 105.5)];
    [bezier2Path closePath];
    [[UIColor grayColor] setFill];
    [bezier2Path fill];
    [[UIColor blackColor] setStroke];
    bezier2Path.lineWidth = 0.5;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 132.5)];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 575.5, CGRectGetMinY(frame) + 132.5)];
    [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 132.5)];
    [bezier3Path closePath];
    [[UIColor grayColor] setFill];
    [bezier3Path fill];
    [[UIColor blackColor] setStroke];
    bezier3Path.lineWidth = 0.5;
    [bezier3Path stroke];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 164.5)];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 575.5, CGRectGetMinY(frame) + 164.5)];
    [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 511.5, CGRectGetMinY(frame) + 164.5)];
    [bezier4Path closePath];
    [[UIColor grayColor] setFill];
    [bezier4Path fill];
    [[UIColor blackColor] setStroke];
    bezier4Path.lineWidth = 0.5;
    [bezier4Path stroke];
    
    
    //// Text 6 Drawing
    CGRect text6Rect = CGRectMake(CGRectGetMinX(frame) + 511, CGRectGetMinY(frame) + 74, 64, 11);
    NSMutableParagraphStyle* text6Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text6Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text6FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text6Style};
    
    [text6Content drawInRect: text6Rect withAttributes: text6FontAttributes];
    
    
    //// Text 7 Drawing
    CGRect text7Rect = CGRectMake(CGRectGetMinX(frame) + 512, CGRectGetMinY(frame) + 106, 64, 11);
    NSMutableParagraphStyle* text7Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text7Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text7FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text7Style};
    
    [text7Content drawInRect: text7Rect withAttributes: text7FontAttributes];
    
    
    //// Text 8 Drawing
    CGRect text8Rect = CGRectMake(CGRectGetMinX(frame) + 512, CGRectGetMinY(frame) + 133, 64, 11);
    NSMutableParagraphStyle* text8Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text8Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text8FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text8Style};
    
    [text8Content drawInRect: text8Rect withAttributes: text8FontAttributes];
    
    
    //// Text 9 Drawing
    CGRect text9Rect = CGRectMake(CGRectGetMinX(frame) + 512, CGRectGetMinY(frame) + 165, 64, 11);
    NSMutableParagraphStyle* text9Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text9Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text9FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 7.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text9Style};
    
    [text9Content drawInRect: text9Rect withAttributes: text9FontAttributes];
    
    
    //// Text 10 Drawing
    CGRect text10Rect = CGRectMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 187, 264, 15);
    NSMutableParagraphStyle* text10Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text10Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text10FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text10Style};
    
    [text10Content drawInRect: text10Rect withAttributes: text10FontAttributes];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 115.5, CGRectGetMinY(frame) + 199.5)];
    [bezier5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 374, CGRectGetMinY(frame) + 199.5)];
    [bezier5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 115.5, CGRectGetMinY(frame) + 199.5)];
    [bezier5Path closePath];
    [[UIColor grayColor] setFill];
    [bezier5Path fill];
    [[UIColor blackColor] setStroke];
    bezier5Path.lineWidth = 0.5;
    [bezier5Path stroke];
    
    
    //// Text 11 Drawing
    CGRect text11Rect = CGRectMake(CGRectGetMinX(frame) + 379, CGRectGetMinY(frame) + 187, 29, 15);
    NSMutableParagraphStyle* text11Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text11Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text11FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text11Style};
    
    [text11Content drawInRect: text11Rect withAttributes: text11FontAttributes];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 410.5, CGRectGetMinY(frame) + 199.5)];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 504, CGRectGetMinY(frame) + 199.5)];
    [bezier6Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 410.5, CGRectGetMinY(frame) + 199.5)];
    [bezier6Path closePath];
    [[UIColor grayColor] setFill];
    [bezier6Path fill];
    [[UIColor blackColor] setStroke];
    bezier6Path.lineWidth = 0.5;
    [bezier6Path stroke];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 209.5, 330, 41)];
    [[UIColor whiteColor] setFill];
    [rectanglePath fill];
    [[UIColor blackColor] setStroke];
    rectanglePath.lineWidth = 0.5;
    [rectanglePath stroke];
    
    
    //// Text 12 Drawing
    CGRect text12Rect = CGRectMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 217, 31, 28);
    NSMutableParagraphStyle* text12Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text12Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text12FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text12Style};
    
    [text12Content drawInRect: text12Rect withAttributes: text12FontAttributes];
    
    
    //// Text 13 Drawing
    CGRect text13Rect = CGRectMake(CGRectGetMinX(frame) + 55, CGRectGetMinY(frame) + 212, 46, 12);
    NSMutableParagraphStyle* text13Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text13Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text13FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text13Style};
    
    [text13Content drawInRect: text13Rect withAttributes: text13FontAttributes];
    
    
    //// Text 14 Drawing
    CGRect text14Rect = CGRectMake(CGRectGetMinX(frame) + 55, CGRectGetMinY(frame) + 224, 46, 12);
    NSMutableParagraphStyle* text14Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text14Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text14FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text14Style};
    
    [text14Content drawInRect: text14Rect withAttributes: text14FontAttributes];
    
    
    //// Text 15 Drawing
    CGRect text15Rect = CGRectMake(CGRectGetMinX(frame) + 55, CGRectGetMinY(frame) + 236, 46, 12);
    NSMutableParagraphStyle* text15Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text15Style setAlignment: NSTextAlignmentRight];
    
    NSDictionary* text15FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text15Style};
    
    [text15Content drawInRect: text15Rect withAttributes: text15FontAttributes];
    
    
    //// Text 16 Drawing
    CGRect text16Rect = CGRectMake(CGRectGetMinX(frame) + 170, CGRectGetMinY(frame) + 212, 61, 12);
    NSMutableParagraphStyle* text16Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text16Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text16FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text16Style};
    
    [text16Content drawInRect: text16Rect withAttributes: text16FontAttributes];
    
    
    //// Text 17 Drawing
    CGRect text17Rect = CGRectMake(CGRectGetMinX(frame) + 170, CGRectGetMinY(frame) + 224, 61, 12);
    NSMutableParagraphStyle* text17Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text17Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text17FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text17Style};
    
    [text17Content drawInRect: text17Rect withAttributes: text17FontAttributes];
    
    
    //// Text 18 Drawing
    CGRect text18Rect = CGRectMake(CGRectGetMinX(frame) + 170, CGRectGetMinY(frame) + 236, 61, 12);
    NSMutableParagraphStyle* text18Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text18Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text18FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text18Style};
    
    [text18Content drawInRect: text18Rect withAttributes: text18FontAttributes];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 103.5, CGRectGetMinY(frame) + 221.5)];
    [bezier7Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 164.5, CGRectGetMinY(frame) + 221.5)];
    [bezier7Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 103.5, CGRectGetMinY(frame) + 221.5)];
    [bezier7Path closePath];
    [[UIColor grayColor] setFill];
    [bezier7Path fill];
    [[UIColor blackColor] setStroke];
    bezier7Path.lineWidth = 0.5;
    [bezier7Path stroke];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 103.5, CGRectGetMinY(frame) + 233.5)];
    [bezier8Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 164.5, CGRectGetMinY(frame) + 233.5)];
    [bezier8Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 103.5, CGRectGetMinY(frame) + 233.5)];
    [bezier8Path closePath];
    [[UIColor grayColor] setFill];
    [bezier8Path fill];
    [[UIColor blackColor] setStroke];
    bezier8Path.lineWidth = 0.5;
    [bezier8Path stroke];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 103.5, CGRectGetMinY(frame) + 244.5)];
    [bezier9Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 164.5, CGRectGetMinY(frame) + 244.5)];
    [bezier9Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 103.5, CGRectGetMinY(frame) + 244.5)];
    [bezier9Path closePath];
    [[UIColor grayColor] setFill];
    [bezier9Path fill];
    [[UIColor blackColor] setStroke];
    bezier9Path.lineWidth = 0.5;
    [bezier9Path stroke];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 190.5, CGRectGetMinY(frame) + 221.5)];
    [bezier10Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 248, CGRectGetMinY(frame) + 221.5)];
    [bezier10Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 190.5, CGRectGetMinY(frame) + 221.5)];
    [bezier10Path closePath];
    [[UIColor grayColor] setFill];
    [bezier10Path fill];
    [[UIColor blackColor] setStroke];
    bezier10Path.lineWidth = 0.5;
    [bezier10Path stroke];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 190.5, CGRectGetMinY(frame) + 233.5)];
    [bezier11Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 248, CGRectGetMinY(frame) + 233.5)];
    [bezier11Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 190.5, CGRectGetMinY(frame) + 233.5)];
    [bezier11Path closePath];
    [[UIColor grayColor] setFill];
    [bezier11Path fill];
    [[UIColor blackColor] setStroke];
    bezier11Path.lineWidth = 0.5;
    [bezier11Path stroke];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 190.5, CGRectGetMinY(frame) + 244.5)];
    [bezier12Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 248, CGRectGetMinY(frame) + 244.5)];
    [bezier12Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 190.5, CGRectGetMinY(frame) + 244.5)];
    [bezier12Path closePath];
    [[UIColor grayColor] setFill];
    [bezier12Path fill];
    [[UIColor blackColor] setStroke];
    bezier12Path.lineWidth = 0.5;
    [bezier12Path stroke];
    
    
    //// Text 19 Drawing
    CGRect text19Rect = CGRectMake(CGRectGetMinX(frame) + 255, CGRectGetMinY(frame) + 224, 61, 12);
    NSMutableParagraphStyle* text19Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text19Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text19FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text19Style};
    
    [text19Content drawInRect: text19Rect withAttributes: text19FontAttributes];
    
    
    //// Text 20 Drawing
    CGRect text20Rect = CGRectMake(CGRectGetMinX(frame) + 255, CGRectGetMinY(frame) + 236, 61, 12);
    NSMutableParagraphStyle* text20Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text20Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text20FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text20Style};
    
    [text20Content drawInRect: text20Rect withAttributes: text20FontAttributes];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 276.5, CGRectGetMinY(frame) + 233.5)];
    [bezier13Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 315, CGRectGetMinY(frame) + 233.5)];
    [bezier13Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 276.5, CGRectGetMinY(frame) + 233.5)];
    [bezier13Path closePath];
    [[UIColor grayColor] setFill];
    [bezier13Path fill];
    [[UIColor blackColor] setStroke];
    bezier13Path.lineWidth = 0.5;
    [bezier13Path stroke];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 276.5, CGRectGetMinY(frame) + 244.5)];
    [bezier14Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 315.5, CGRectGetMinY(frame) + 244.5)];
    [bezier14Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 276.5, CGRectGetMinY(frame) + 244.5)];
    [bezier14Path closePath];
    [[UIColor grayColor] setFill];
    [bezier14Path fill];
    [[UIColor blackColor] setStroke];
    bezier14Path.lineWidth = 0.5;
    [bezier14Path stroke];
    
    
    //// Text 21 Drawing
    CGRect text21Rect = CGRectMake(CGRectGetMinX(frame) + 316, CGRectGetMinY(frame) + 227, 61, 12);
    NSMutableParagraphStyle* text21Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text21Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text21FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 6.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text21Style};
    
    [text21Content drawInRect: text21Rect withAttributes: text21FontAttributes];
    
    
    //// Text 22 Drawing
    CGRect text22Rect = CGRectMake(CGRectGetMinX(frame) + 316, CGRectGetMinY(frame) + 238, 61, 12);
    NSMutableParagraphStyle* text22Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text22Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text22FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 6.5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text22Style};
    
    [text22Content drawInRect: text22Rect withAttributes: text22FontAttributes];
    
    
    //// Text 23 Drawing
    CGRect text23Rect = CGRectMake(CGRectGetMinX(frame) + 210, CGRectGetMinY(frame) + 211, 21, 14);
    NSMutableParagraphStyle* text23Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text23Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text23FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text23Style};
    
    [text23Content drawInRect: text23Rect withAttributes: text23FontAttributes];
    
    
    //// Text 24 Drawing
    CGRect text24Rect = CGRectMake(CGRectGetMinX(frame) + 209, CGRectGetMinY(frame) + 223, 21, 14);
    NSMutableParagraphStyle* text24Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text24Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text24FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text24Style};
    
    [text24Content drawInRect: text24Rect withAttributes: text24FontAttributes];
    
    
    //// Text 25 Drawing
    CGRect text25Rect = CGRectMake(CGRectGetMinX(frame) + 209, CGRectGetMinY(frame) + 234, 21, 14);
    NSMutableParagraphStyle* text25Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text25Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text25FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text25Style};
    
    [text25Content drawInRect: text25Rect withAttributes: text25FontAttributes];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 374.5, CGRectGetMinY(frame) + 209.5, 200.5, 41)];
    [[UIColor whiteColor] setFill];
    [rectangle2Path fill];
    [[UIColor blackColor] setStroke];
    rectangle2Path.lineWidth = 0.5;
    [rectangle2Path stroke];
    
    
    //// Text 26 Drawing
    CGRect text26Rect = CGRectMake(CGRectGetMinX(frame) + 377, CGRectGetMinY(frame) + 217, 31, 28);
    NSMutableParagraphStyle* text26Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text26Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text26FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text26Style};
    
    [text26Content drawInRect: text26Rect withAttributes: text26FontAttributes];
    
    
    //// Text 27 Drawing
    CGRect text27Rect = CGRectMake(CGRectGetMinX(frame) + 415, CGRectGetMinY(frame) + 218, 65, 12);
    NSMutableParagraphStyle* text27Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text27Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text27FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text27Style};
    
    [text27Content drawInRect: text27Rect withAttributes: text27FontAttributes];
    
    
    //// Text 28 Drawing
    CGRect text28Rect = CGRectMake(CGRectGetMinX(frame) + 415, CGRectGetMinY(frame) + 232, 46, 12);
    NSMutableParagraphStyle* text28Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text28Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text28FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text28Style};
    
    [text28Content drawInRect: text28Rect withAttributes: text28FontAttributes];
    
    
    //// Text 29 Drawing
    CGRect text29Rect = CGRectMake(CGRectGetMinX(frame) + 537, CGRectGetMinY(frame) + 218, 38, 11);
    NSMutableParagraphStyle* text29Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text29Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text29FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text29Style};
    
    [text29Content drawInRect: text29Rect withAttributes: text29FontAttributes];
    
    
    //// Text 30 Drawing
    CGRect text30Rect = CGRectMake(CGRectGetMinX(frame) + 537, CGRectGetMinY(frame) + 232, 38, 11);
    NSMutableParagraphStyle* text30Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text30Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text30FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text30Style};
    
    [text30Content drawInRect: text30Rect withAttributes: text30FontAttributes];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 525.5, CGRectGetMinY(frame) + 218.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle3Path fill];
    [[UIColor blackColor] setStroke];
    rectangle3Path.lineWidth = 0.5;
    [rectangle3Path stroke];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 525.5, CGRectGetMinY(frame) + 231.5, 9, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle4Path fill];
    [[UIColor blackColor] setStroke];
    rectangle4Path.lineWidth = 0.5;
    [rectangle4Path stroke];
    
    
    //// Rectangle 5 Drawing
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 432.5, CGRectGetMinY(frame) + 234.5, 6, 6)];
    [[UIColor whiteColor] setFill];
    [rectangle5Path fill];
    [[UIColor blackColor] setStroke];
    rectangle5Path.lineWidth = 0.5;
    [rectangle5Path stroke];
    
    
    //// Text 31 Drawing
    CGRect text31Rect = CGRectMake(CGRectGetMinX(frame) + 445, CGRectGetMinY(frame) + 232, 46, 12);
    NSMutableParagraphStyle* text31Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text31Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text31FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 8], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text31Style};
    
    [text31Content drawInRect: text31Rect withAttributes: text31FontAttributes];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 478.5, CGRectGetMinY(frame) + 227.5)];
    [bezier15Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 521.5, CGRectGetMinY(frame) + 227.5)];
    [bezier15Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 478.5, CGRectGetMinY(frame) + 227.5)];
    [bezier15Path closePath];
    [[UIColor grayColor] setFill];
    [bezier15Path fill];
    [[UIColor blackColor] setStroke];
    bezier15Path.lineWidth = 0.5;
    [bezier15Path stroke];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 463.5, CGRectGetMinY(frame) + 241.5)];
    [bezier16Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 494.5, CGRectGetMinY(frame) + 241.5)];
    [bezier16Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 463.5, CGRectGetMinY(frame) + 241.5)];
    [bezier16Path closePath];
    [[UIColor grayColor] setFill];
    [bezier16Path fill];
    [[UIColor blackColor] setStroke];
    bezier16Path.lineWidth = 0.5;
    [bezier16Path stroke];
    
    
    //// Text 32 Drawing
    CGRect text32Rect = CGRectMake(CGRectGetMinX(frame) + 469, CGRectGetMinY(frame) + 231, 21, 14);
    NSMutableParagraphStyle* text32Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text32Style setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* text32FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text32Style};
    
    [text32Content drawInRect: text32Rect withAttributes: text32FontAttributes];
    
    
    //// Text 33 Drawing
    CGRect text33Rect = CGRectMake(CGRectGetMinX(frame) + 499, CGRectGetMinY(frame) + 243, 46, 12);
    NSMutableParagraphStyle* text33Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text33Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text33FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text33Style};
    
    [text33Content drawInRect: text33Rect withAttributes: text33FontAttributes];
    
    
    //// Rectangle 6 Drawing
    UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 502.5, CGRectGetMinY(frame) + 233, 19, 9)];
    [[UIColor whiteColor] setFill];
    [rectangle6Path fill];
    [[UIColor blackColor] setStroke];
    rectangle6Path.lineWidth = 0.5;
    [rectangle6Path stroke];
    
    
    //// Text 34 Drawing
    CGRect text34Rect = CGRectMake(CGRectGetMinX(frame) + 139, CGRectGetMinY(frame) + 215, 30, 8);
    NSMutableParagraphStyle* text34Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text34Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text34FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text34Style};
    
    [text34Content drawInRect: text34Rect withAttributes: text34FontAttributes];
    
    
    //// Text 35 Drawing
    CGRect text35Rect = CGRectMake(CGRectGetMinX(frame) + 139, CGRectGetMinY(frame) + 227, 30, 8);
    NSMutableParagraphStyle* text35Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text35Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text35FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 5], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text35Style};
    
    [text35Content drawInRect: text35Rect withAttributes: text35FontAttributes];
    
    
    //// Text 36 Drawing
    CGRect text36Rect = CGRectMake(CGRectGetMinX(frame) + 139, CGRectGetMinY(frame) + 238, 30, 8);
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
