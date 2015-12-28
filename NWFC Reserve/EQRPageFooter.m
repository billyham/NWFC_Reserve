//
//  EQRPageFooter.m
//  Gear
//
//  Created by Ray Smith on 12/27/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPageFooter.h"

@implementation EQRPageFooter

+(void)drawFooter{
    
    //________KEEP BELOW
    
    
    NSDate *todaysDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    NSString *dateAsString = [dateFormatter stringFromDate:todaysDate];
    
    NSString* dateValueContent = dateAsString;


    
    //________KEEP ABOVE
    
    
    
    
    //// Abstracted Attributes
    NSString* text10Content = @"Signature:";
    NSString* text11Content = @"Date:";
//    NSString* dateValueContent = @"Date Value";
    
    
    //// Text 10 Drawing
    CGRect text10Rect = CGRectMake(82, 50, 220, 15);
    NSMutableParagraphStyle* text10Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text10Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text10FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text10Style};
    
    [text10Content drawInRect: text10Rect withAttributes: text10FontAttributes];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(138.5, 62.5)];
    [bezier5Path addLineToPoint: CGPointMake(397, 62.5)];
    [bezier5Path addLineToPoint: CGPointMake(138.5, 62.5)];
    [bezier5Path closePath];
    [[UIColor grayColor] setFill];
    [bezier5Path fill];
    [[UIColor blackColor] setStroke];
    bezier5Path.lineWidth = 0.5;
    [bezier5Path stroke];
    
    
    //// Text 11 Drawing
    CGRect text11Rect = CGRectMake(435, 50, 29, 15);
    NSMutableParagraphStyle* text11Style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [text11Style setAlignment: NSTextAlignmentLeft];
    
    NSDictionary* text11FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica-Bold" size: 11], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: text11Style};
    
    [text11Content drawInRect: text11Rect withAttributes: text11FontAttributes];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(466.5, 62.5)];
    [bezier6Path addLineToPoint: CGPointMake(560, 62.5)];
    [bezier6Path addLineToPoint: CGPointMake(466.5, 62.5)];
    [bezier6Path closePath];
    [[UIColor grayColor] setFill];
    [bezier6Path fill];
    [[UIColor blackColor] setStroke];
    bezier6Path.lineWidth = 0.5;
    [bezier6Path stroke];
    
    
    //// DateValue Drawing
    CGRect dateValueRect = CGRectMake(468, 48, 92, 14);
    NSMutableParagraphStyle* dateValueStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [dateValueStyle setAlignment: NSTextAlignmentCenter];
    
    NSDictionary* dateValueFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 12], NSForegroundColorAttributeName: [UIColor blackColor], NSParagraphStyleAttributeName: dateValueStyle};
    
    [dateValueContent drawInRect: dateValueRect withAttributes: dateValueFontAttributes];
    
    
    
  
    

    
}

@end
