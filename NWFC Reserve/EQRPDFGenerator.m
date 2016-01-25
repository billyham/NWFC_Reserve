//
//  EQRPDFGenerator.m
//  Gear
//
//  Created by Ray Smith on 12/7/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPDFGenerator.h"
#import <CoreText/CoreText.h>
#import "EQRPageHeader.h"
#import "EQRTextElement.h"
#import "EQRPageFooter.h"

typedef void (^CompletionBlockPDFSaved) ();
typedef void (^CompletionBlockPDFExported) ();

@interface EQRPDFGenerator ()

@property (strong, nonatomic) NSURL *URLForPDFFile;
@property (strong, nonatomic) NSString *emptyText;
@property (strong, nonatomic) NSString *myName;
@property (strong, nonatomic) NSString *myPhone;
@property (strong, nonatomic) NSString *myEmail;
@property (strong, nonatomic) NSArray *arrayOfAgreements;
@property (strong, nonatomic) NSDate *dateOfGeneration;

-(void)exportPDF:(CompletionBlockPDFExported)completeBlock;

@end

@implementation EQRPDFGenerator

#pragma mark - Public methods

// Much of this is copied straight from Apple documentation:
/*
https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/GeneratingPDF/GeneratingPDF.html#//apple_ref/doc/uid/TP40010156-CH10-SW1
*/

-(void)launchPDFGeneratorWithName:(NSString *)name
                            phone:(NSString *)phone
                            email:(NSString *)email
                       agreements:(NSArray *)arrayOfAgreements
                       completion:(CompletionBlockPDFGenerator)completeBlock{
    
    self.myName = name;
    self.myPhone = phone;
    self.myEmail = email;
    self.arrayOfAgreements = arrayOfAgreements;
    self.dateOfGeneration = [NSDate date];
    
    if (self.arrayOfMultiColumnTextViews){
        if ([self.arrayOfMultiColumnTextViews count] > 0){
            self.myMultiColumnView = [self.arrayOfMultiColumnTextViews objectAtIndex:0];
        }
    }
    
    [self savePDFFile:^(){
        
        [self exportPDF:^(){
            
            completeBlock();
        }];
    }];
}

#pragma mark - Export PDF File

-(void)exportPDF:(CompletionBlockPDFExported)completeBlock{
    
    // Get the root directory for storing the file on iCloud Drive
    [self rootDirectoryForICloud:^(NSURL *ubiquityURL) {
//        NSLog(@"1. ubiquityURL = %@", ubiquityURL);
        if (ubiquityURL) {
            
            // We also need the 'local' URL to the file we want to store
            NSURL *localURL = self.URLForPDFFile;
            NSLog(@"2. localURL = %@", localURL);
            
            // Now, append the local filename to the ubiquityURL
            ubiquityURL = [ubiquityURL URLByAppendingPathComponent:localURL.lastPathComponent];
            NSLog(@"3. ubiquityURL = %@", ubiquityURL);
            
            // And finish up the 'store' action
            NSError *error;
            if (![[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:localURL destinationURL:ubiquityURL error:&error]) {
                NSLog(@"Error occurred: %@", error);
            }
        }
        else {
            NSLog(@"Could not retrieve a ubiquityURL");
        }
        
        completeBlock();
    }];
}

// This was really helpful...
// http://stackoverflow.com/questions/27051437/save-ios-8-documents-to-icloud-drive
//
- (void)rootDirectoryForICloud:(void (^)(NSURL *))completionHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *rootDirectory = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
        
        if (rootDirectory) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:rootDirectory.path isDirectory:nil]) {
                NSLog(@"Create directory");
                [[NSFileManager defaultManager] createDirectoryAtURL:rootDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(rootDirectory);
        });
    });
}




#pragma mark - Saving PDF File

- (void)savePDFFile:(CompletionBlockPDFSaved)completeBlock{

    //Prepare the text using a Core Text Framesetter.
    
    // 1. Use provided agreements
    NSMutableString *agreementText = [NSMutableString stringWithString:@" "];
    if ([self.arrayOfAgreements count] > 0){
//        [agreementText appendString:@"User Agreement:\n"];
        
        for (EQRTextElement *textElement in self.arrayOfAgreements){
            [agreementText appendString:[NSString stringWithFormat:@"%@\n", textElement.text]];
        }
    }
    
    // Agreement attributes for CFAttributedString
    UIFont *attFont = [UIFont systemFontOfSize:9];
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paraStyle.firstLineHeadIndent = 10.f;
    NSDictionary *attFontDic = @{NSFontAttributeName: attFont, NSParagraphStyleAttributeName: paraStyle};
    
    // ____ An example of bridging between CF and NS ___
    CFDictionaryRef affFontCFDic = (__bridge CFDictionaryRef)attFontDic;
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (CFStringRef)agreementText, affFontCFDic);

    // 2. Or use sample text
//    NSString *sampleText = @"I hereby assume full responsibility for the above listed equipment provided by the Northwest Film Center. Financial responsibility includes payment for all repairs, up to teh full replacement value of equipment, and the full replacement value for all stolen or lost equipment. Financial responsibility also includes the rental fee for the time period in which damaged equipment is out for repair, or until replacement payment is received. I have inspected the contents of rental equipment and acknowledge that all parts and pieces are present and in working order unless otherwise noted. I hereby assume full responsibility for the above listed equipment provided by the Northwest Film Center. Financial responsibility includes payment for all repairs, up to teh full replacement value of equipment, and the full replacement value for all stolen or lost equipment. Financial responsibility also includes the rental fee for the time period in which damaged equipment is out for repair, or until replacement payment is received. I have inspected the contents of rental equipment and acknowledge that all parts and pieces are present and in working order unless otherwise noted. I hereby assume full responsibility for the above listed equipment provided by the Northwest Film Center. Financial responsibility includes payment for all repairs, up to teh full replacement value of equipment, and the full replacement value for all stolen or lost equipment. Financial responsibility also includes the rental fee for the time period in which damaged equipment is out for repair, or until replacement payment is received. I have inspected the contents of rental equipment and acknowledge that all parts and pieces are present and in working order unless otherwise noted.";
//    
//    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (CFStringRef)sampleText, NULL);
    
    
    if (currentText) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        if (framesetter) {
            
            // Create pdf file in the local directory
            NSString *pdfFileName = [NSString stringWithFormat:@"%@", [self getPDFFileLocationWithNameAndExtention]];
            UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
            
            //___ Save the NSURL for Exporting ___
            self.URLForPDFFile = [self localPathForResource];
            
//            self.URLForPDFFile = [NSURL URLWithString:[NSString stringWithFormat:@"file:///%@", pdfFileName]];
//            NSLog(@"this is the URL: %@", [NSString stringWithFormat:@"file:///%@", pdfFileName]);
//            NSLog(@"this is the NSURL: %@", self.URLForPDFFile);
            
            // Create the PDF context using the default page size of 612 x 792.
//            NSLog(@"this is the value for pdfFileName: %@", pdfFileName);
            
            
            CFRange currentRange = CFRangeMake(0, 0);
            NSInteger currentPage = 0;
            BOOL atEndOfAgreeemntText = NO;
            BOOL atEndOfGearText = NO;
            BOOL done = NO;
            NSInteger hasDrawnAllMultiColumn = NO;
            NSInteger indexOfMultiColumnArray = 0;
            
            do {
                NSLog(@"PDFGenerator begin the do-while loop");
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                
                // Draw a page number at the bottom of each page.
                currentPage++;
                [self drawPageNumber:currentPage];
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
                currentRange = [self renderPage:currentPage withTextRange:currentRange andFramesetter:framesetter];
                
                CGContextRef  currentContext = UIGraphicsGetCurrentContext();
                CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
                CGContextTranslateCTM(currentContext, 0, 792);
                CGContextScaleCTM(currentContext, 1.0, -1.0);
                
                if (!hasDrawnAllMultiColumn){
                    
                    //___ Draw MultiColumnText ___
                    [self drawMultiColumnTextForIndex:indexOfMultiColumnArray];
                    if (indexOfMultiColumnArray + 1 >= [self.arrayOfMultiColumnTextViews count]){
                        hasDrawnAllMultiColumn = YES;
                    }
                }
                
                [self drawDateText];
                
                CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
                CGContextTranslateCTM(currentContext, 0, 792);
                CGContextScaleCTM(currentContext, 0.25, 0.25);
                
                if (self.hasSigImage){
                    [self drawSignatureImage];
                }
                
                CGContextTranslateCTM(currentContext, 100, -3080);
                CGContextScaleCTM(currentContext, 3.6,3.6);
                
                [self drawHeader];
                
                CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
                CGContextTranslateCTM(currentContext, -40, 745);
                CGContextScaleCTM(currentContext, 1.0, 1.0);
                
                [self drawFooter];

                
                // If we're at the end of the text, exit the loop.
               
                
                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText)){
                    atEndOfAgreeemntText = YES;
                    if (atEndOfGearText == YES){
                        done = YES;
                    }
                }
                                
                if (indexOfMultiColumnArray + 1 >= [self.arrayOfMultiColumnTextViews count]){
                    atEndOfGearText = YES;
                    if (atEndOfAgreeemntText == YES){
                        done = YES;
                    }
                }else{
                    indexOfMultiColumnArray += 1;
                }
                
            } while (!done);
            
            NSLog(@"PDFGenerator has concluded the do-while loop in savePDF method");
            
            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            
            // Release the framewetter.
            CFRelease(framesetter);
            
        } else {
            NSLog(@"Could not create the framesetter needed to lay out the atrributed string.");
        }
        // Release the attributed string.
        CFRelease(currentText);
    } else {
        NSLog(@"Could not create the attributed string for the framesetter");
    }
    
    completeBlock();
}


// Use Core Text to draw the text in a frame on the page.
- (CFRange)renderPage:(NSInteger)pageNum withTextRange:(CFRange)currentRange
       andFramesetter:(CTFramesetterRef)framesetter{
    
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    CGRect    frameRect = CGRectMake(72, 100, 468, 190);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    // Update the current range based on what was drawn.
    currentRange = CTFrameGetVisibleStringRange(frameRef);
    currentRange.location += currentRange.length;
    currentRange.length = 0;
    CFRelease(frameRef);
    
    return currentRange;
}

-(void)drawDateText{
    
    // Notice there is none of the graphics context blather here...
    
    //first the dates then the rest of the text
    NSTextContainer *container = self.myTextView.layoutManager.textContainers[0];
    CGPoint datesOrigin = CGPointMake(120.f, 220.f);
    
    NSRange glyphRange = [self.myTextView.layoutManager glyphRangeForTextContainer:container];
    
    [self.myTextView.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:datesOrigin];
}

-(void)drawMultiColumnTextForIndex:(NSInteger)index{
    
    // Get the graphics context.
//    CGContextRef  currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
//    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
//    CGContextTranslateCTM(currentContext, 0, 792);
//    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    
    if ([self.arrayOfMultiColumnTextViews count] >= index + 1){
        self.myMultiColumnView = [self.arrayOfMultiColumnTextViews objectAtIndex:index];
    }
    
    //______ This is essentially EQRMultiColumnTextView's drawRect method... ___
    //now the equipment list
    for (NSUInteger i = 0; i < [self.myMultiColumnView.layoutManager.textContainers count]; i++) {
        
        NSTextContainer *container = self.myMultiColumnView.layoutManager.textContainers[i];
        CGPoint origin = [self.myMultiColumnView.textOrigins[i] CGPointValue];
        
        //add 220 to the y value to place below header
        NSRange glyphRange = [self.myMultiColumnView.layoutManager glyphRangeForTextContainer:container];

        NSLog(@"EQRPDFGenerator > drawMultiColumn says additionalXAdjustment: %5.2f", self.additionalXAdjustment);
        CGPoint newOrigin = CGPointMake(origin.x + 30.f + self.additionalXAdjustment, origin.y + 250.f);
        
        
        [self.myMultiColumnView.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:newOrigin];
    }
}


-(void)drawSignatureImage{
    
    // Get the graphics context.
//    CGContextRef  currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
//    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, and so does the UIImage!!
    // Scaled down to fit.
//    CGContextTranslateCTM(currentContext, 0, 792);
//    CGContextScaleCTM(currentContext, 0.35, 0.35);
    
    [self.sigImage drawAtPoint:CGPointMake(500.0, -440.0)];
}


-(void)drawHeader{
    
    // Get the graphics context.
//    CGContextRef  currentContext = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(currentContext, 100, -2200);
//    CGContextScaleCTM(currentContext, 2.6, 2.6);
    
    [EQRPageHeader drawHeaderWithName:self.myName Phone:self.myPhone Email:self.myEmail];
}


-(void)drawFooter{
    
    // Size is 668 x 100
    [EQRPageFooter drawFooter];
}

- (void)drawPageNumber:(NSInteger)pageNum{
    
    NSString *pageString = [NSString stringWithFormat:@"Page %ld", (long)pageNum];
    UIFont *theFont = [UIFont systemFontOfSize:9];
    CGSize maxSize = CGSizeMake(612, 72);
    
//    CGSize pageStringSize = [pageString sizeWithFont:theFont
//                                   constrainedToSize:maxSize
//                                       lineBreakMode:UILineBreakModeClip];
    
    NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
    drawingContext.minimumScaleFactor = 0.75;
    CGRect pageStringSizeRect = [pageString boundingRectWithSize:maxSize
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:theFont}
                                                      context:drawingContext];
    CGSize pageStringSize = pageStringSizeRect.size;
    
                                                                   
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
                                   720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                   pageStringSize.width,
                                   pageStringSize.height);
    
//    [pageString drawInRect:stringRect withFont:theFont];
    [pageString drawInRect:stringRect withAttributes:@{NSFontAttributeName:theFont}];
}



- (NSString *)getPDFFileLocationWithNameAndExtention{
    
    NSString *dateStringWithSuffix = [NSString stringWithFormat:@"%@.pdf", [self strictlyTheFileName]];
    
    NSString *entireString = [[self applicationDocumentDirectory] stringByAppendingPathComponent:dateStringWithSuffix];
    return entireString;
}

-(NSString *)strictlyTheFileName{
    
    if (self.dateOfGeneration){
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"yyyy-MM-dd_HHmmss";
        NSString *dateString = [dateFormatter stringFromDate:self.dateOfGeneration];
        
        return [NSString stringWithFormat:@"%@ %@", dateString, self.myName];
        
    }else{
        NSLog(@"PDFGenerator > stricltyTheFileName failed to find a valid dateOfGeneration");
        return nil;
    }
};


- (NSString*)applicationDocumentDirectory {
    
    // 1. Use Cache folder
    //Returns the path to the application's cache directory.
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//    return basePath;
    
    // 2. Or use Documents folder
    //Returns the path to the application's documents directory.
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//    return basePath;
    
    // 3. ... with alternate derivation
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return documentsDirectory;
}





- (NSURL *)localPathForResource{
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *resourcePath = [[documentsDirectory stringByAppendingPathComponent:
                               [self strictlyTheFileName]]stringByAppendingPathExtension:@"pdf"];
    return [NSURL fileURLWithPath:resourcePath];
}









@end
