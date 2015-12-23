//
//  EQRPDFGenerator.m
//  Gear
//
//  Created by Ray Smith on 12/7/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPDFGenerator.h"
#import <CoreText/CoreText.h>


@interface EQRPDFGenerator () <UIDocumentPickerDelegate>

//@property (strong, nonatomic) NSString *UTIForPDF;
@property (strong, nonatomic) NSURL *URLForPDFFile;
@property (strong, nonatomic) UIDocumentPickerViewController *myDocumentPickerVC;

@end

@implementation EQRPDFGenerator

// Much of this is copied straight from Apple documentation:
/*
https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/GeneratingPDF/GeneratingPDF.html#//apple_ref/doc/uid/TP40010156-CH10-SW1
*/

-(void)launchPDFGenerator{
    
    [self savePDFFile:nil];
    
    [self exportPDFToICloudDrive];
}

-(void)exportPDFToICloudDrive{
    
    if (self.URLForPDFFile){
        UIDocumentPickerViewController *documentPickerVC = [[UIDocumentPickerViewController alloc] initWithURL:self.URLForPDFFile inMode:UIDocumentPickerModeExportToService];
        
        if (documentPickerVC){
            self.myDocumentPickerVC = documentPickerVC;
        }
    }else{
        
        NSLog(@"No valid file url: %@", self.URLForPDFFile);
    }
    
    
    
    //______  USE this method when IMPORTING a file  ______
    //need UTI representing the type of document
    //    NSArray *arrayOfDocTypes = @[@"com.adobe.pdf"];
    
//    UIDocumentPickerViewController *documentPickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:arrayOfDocTypes inMode:];
    

}

// Callback
-(void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker{
    
    documentPicker.delegate = self;
    //___!!!!!  Oh yeah, this needs to be called by a VC  !!!!____
//    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - Document Picker Delegate Methods

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
    
    if (url){
        //pass in the url of the file
        
        
    }else{
        
        NSLog(@"EQRPDFGenerator > documentPicker: didPickerDocumentAtURL failed to return url");
    }

}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    
    
}





#pragma mark - Saving PDF File

- (IBAction)savePDFFile:(id)sender{
    
    // Prepare the text using a Core Text Framesetter.
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (CFStringRef)self.myTextView.text, NULL);
    if (currentText) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        if (framesetter) {
            
            NSString *pdfFileName = [NSString stringWithFormat:@"%@", [self getPDFFileName]];
            
            //___ Save the URL for Exporting ___
            self.URLForPDFFile = [NSURL URLWithString:pdfFileName];
            
            
            // Create the PDF context using the default page size of 612 x 792.
//            NSLog(@"this is the value for pdfFileName: %@", pdfFileName);
            
            UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
            
            CFRange currentRange = CFRangeMake(0, 0);
            NSInteger currentPage = 0;
            BOOL done = NO;
            NSInteger hasDrawnMultiColumn = NO;
            
            do {
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                
                // Draw a page number at the bottom of each page.
                currentPage++;
                [self drawPageNumber:currentPage];
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
                currentRange = [self renderPage:currentPage withTextRange:currentRange andFramesetter:framesetter];
                
                
                if (!hasDrawnMultiColumn){
                    
                    //___ Draw MultiColumnText ___
                    [self drawMultiColumnText];
                    hasDrawnMultiColumn = YES;
                }
                
                if (self.hasSigImage){
                    [self drawSignatureImage];
                }
                
                // If we're at the end of the text, exit the loop.
                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                    done = YES;
            } while (!done);
            
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
    CGRect    frameRect = CGRectMake(72, 72, 468, 648);
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

-(void)drawMultiColumnText{
    
    // Get the graphics context.
    CGContextRef  currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    
    //______ This is essentially EQRMultiColumnTextView's drawRect method... ___
    //now the equipment list
    for (NSUInteger i = 0; i < [self.myMultiColumnView.layoutManager.textContainers count]; i++) {
        
        NSTextContainer *container = self.myMultiColumnView.layoutManager.textContainers[i];
        CGPoint origin = [self.myMultiColumnView.textOrigins[i] CGPointValue];
        
        //add 220 to the y value to place below header
        CGPoint newOrigin = CGPointMake(origin.x + 30.f + self.additionalXAdjustment, origin.y + 250.f);
        
        NSRange glyphRange = [self.myMultiColumnView.layoutManager glyphRangeForTextContainer:container];
        
        [self.myMultiColumnView.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:newOrigin];
    }
}

-(void)drawSignatureImage{
    
    // Get the graphics context.
    CGContextRef  currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, and so does the UIImage!!
    // Scaled down to fit.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 0.35, 0.35);
    
    
    [self.sigImage drawAtPoint:CGPointMake(550.0, -600.0)];
    
}


- (void)drawPageNumber:(NSInteger)pageNum{
    
    NSString *pageString = [NSString stringWithFormat:@"Page %ld", (long)pageNum];
    UIFont *theFont = [UIFont systemFontOfSize:12];
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



- (NSString *)getPDFFileName{
    
    NSString *entireString = [[self applicationDocumentDirectory] stringByAppendingPathComponent:@"testFile.pdf"];
    return entireString;
}

- (NSString*)applicationDocumentDirectory {
    
    //Returns the path to the application's documents directory.
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}



@end
