//
//  EQRPageConstructor.m
//  Gear
//
//  Created by Dave Hanagan on 12/23/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPageConstructor.h"
#import "EQRMultiColumnTextView.h"
#import "EQRWebData.h"
#import "EQRMiscJoin.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRDataStructure.h"
#import "EQRGlobals.h"
#import "EQRPDFGenerator.h"

@interface EQRPageConstructor () <EQRWebDataDelegate, NSLayoutManagerDelegate>

@property (strong, nonatomic) EQRPDFGenerator *pdfGenerator;

@property (strong, nonatomic) EQRScheduleRequestItem* request;
@property (nonatomic, strong) IBOutlet EQRMultiColumnTextView* myTwoColumnView;
@property NSInteger countOfColumns;
@property float additionalXAdjustment;

@property (strong, nonatomic) UIImage *sigImage;
@property BOOL hasSigImage;

@property (strong, nonatomic) NSArray *arrayOfAgreements;
@property BOOL hasAgreements;

@property (nonatomic, strong) NSString* rentorNameAtt;
@property (nonatomic, strong) NSString* rentorPhoneAtt;
@property (nonatomic, strong) NSString* rentorEmailAtt;

@property (nonatomic, strong) IBOutlet UITextView* summaryTextView;
@property (nonatomic, strong) NSTextStorage* summaryTextStorage;

@property (nonatomic, strong) NSMutableAttributedString* datesAtt;
@property (nonatomic, strong) NSMutableAttributedString* summaryTotalAtt;

//block as property
@property (copy) CompletionBlockPageConstructor delayedCompletionBlock;

@end

@implementation EQRPageConstructor

-(void)generatePDFWithScheduleRequestItem:(EQRScheduleRequestItem*)request
                       withSignatureImage:(UIImage *)sigImage
                               agreements:(NSArray *)arrayOfAgreements
                               completion:(CompletionBlockPageConstructor)completeBlock{
    
    // Save the completion block for a different method to call
    self.delayedCompletionBlock = completeBlock;
    
    if (request){
        
        self.request = request;
    }
    
    if (sigImage){
        self.hasSigImage = YES;
        self.sigImage = sigImage;
    }
    
    if (arrayOfAgreements){
        self.hasAgreements = YES;
        self.arrayOfAgreements = arrayOfAgreements;
    }
    
    self.countOfColumns = 0;
    self.additionalXAdjustment = 0.f;
    
    if (self.request.arrayOfEquipmentJoins){
        [self.request.arrayOfEquipmentJoins removeAllObjects];
    }
    
    //build the request's array of equip joins
    EQRWebData* webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    SEL selector = @selector(addEquipmentJoin:);
    
    __block BOOL hasAllEquipJoins = NO;
    __block BOOL hasAllMiscJoins = NO;
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", request.key_id, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetScheduleEquipJoinsIncludingCategory.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" selector:selector completion:^(BOOL isLoadingFlagUp) {
            
            hasAllEquipJoins = YES;
            if (hasAllMiscJoins){
                [self setupStage2];
            }
            
        }];
    });

    EQRWebData *webData2 = [EQRWebData sharedInstance];
    webData2.delegateDataFeed = self;
    SEL selector2 = @selector(addMiscJoin:);

    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue2, ^{
        
        [webData2 queryWithAsync:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:topArray class:@"EQRMiscJoin" selector:selector2 completion:^(BOOL isLoadingFlagUp) {
            
            hasAllMiscJoins = YES;
            if (hasAllEquipJoins){
                [self setupStage2];
            }
            
        }];
    });
}


-(void)setupStage2{  // build the attributed string
    
    // Create views programmatically
    CGRect rect = CGRectMake(100.f, 150.f, 560.f, 100.f);
    self.summaryTextView = [[UITextView alloc] initWithFrame:rect];
    
    CGRect rectForMultiColumn = CGRectMake(100.f, 270.f, 560.f, 240.f);
    self.myTwoColumnView = [[EQRMultiColumnTextView alloc] initWithFrame:rectForMultiColumn];
    
    
    //    NSString* contactKeyID = requestManager.request.contact_foreignKey;
    NSString* contactCondensedName = self.request.contact_name;
    EQRContactNameItem* contactItem = self.request.contactNameItem;
    
    //error handling if contact_name is nil
    if (contactCondensedName == nil){
        contactCondensedName = @"NA";
    }
    
    NSDateFormatter* pickUpFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [pickUpFormatter setLocale:usLocale];
    
    [pickUpFormatter setDateFormat:@"EEE, MMM d, yyyy"];  // 'at' h:mm aaa
    //    [pickUpFormatter setDateStyle:NSDateFormatterFullStyle];
    //    [pickUpFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDateFormatter* pickUpTimeFormatter = [[NSDateFormatter alloc] init];
    [pickUpTimeFormatter setLocale:usLocale];
    [pickUpTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    //adjust the time by adding 9 hours... or 8 hours
    float secondsForOffset = 0;    //this is 9 hours = 32400, this is 8 hours = 28800;
    NSDate* newTimeBegin = [self.request.request_time_begin dateByAddingTimeInterval:secondsForOffset];
    NSDate* newTimeEnd = [self.request.request_time_end dateByAddingTimeInterval:secondsForOffset];
    
    NSString* combinedDateAndTimeBegin = [NSString stringWithFormat:@"%@ at %@", [pickUpFormatter stringFromDate:self.request.request_date_begin], [pickUpTimeFormatter stringFromDate:newTimeBegin]];
    NSString* combinedDateAndTimeEnd = [NSString stringWithFormat:@"%@ at %@", [pickUpFormatter stringFromDate:self.request.request_date_end], [pickUpTimeFormatter stringFromDate:newTimeEnd]];
    
    
    //save values to ivar
    self.rentorNameAtt = self.request.contact_name;
    self.rentorPhoneAtt = contactItem.phone;
    self.rentorEmailAtt = contactItem.email;
    
    //nsattributedstrings
    //font styles
    UIFont* normalFont = [UIFont systemFontOfSize:9];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:9];
    UIFont* headerFont = [UIFont boldSystemFontOfSize:7];
    
    //paragraph styles - indents paragraph except for after a \r
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paraStyle.firstLineHeadIndent = 0.f;
    paraStyle.headIndent = 50.f;
    
    NSMutableParagraphStyle* headerParaStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    headerParaStyle.firstLineHeadIndent = 20.f;
    headerParaStyle.headIndent = 40.f;
    
    NSMutableParagraphStyle* notesHeaderParaStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    notesHeaderParaStyle.firstLineHeadIndent = 20.f;
    
    
    //begin the total attribute string
    self.datesAtt = [[NSMutableAttributedString alloc] initWithString:@""];
    self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    
    
    
    //_______PICKUP DATE_____
    NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"Pick Up: " attributes:arrayAtt6];
    [self.datesAtt appendAttributedString:pickupHead];
    
    NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:combinedDateAndTimeBegin  attributes:arrayAtt7];
    [self.datesAtt appendAttributedString:pickupAtt];
    
    //______RETURN DATE________
    NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"            Return: " attributes:arrayAtt8];
    [self.datesAtt appendAttributedString:returnHead];
    
    NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:combinedDateAndTimeEnd  attributes:arrayAtt9];
    [self.datesAtt appendAttributedString:returnAtt];
    
    
    
    
    //________EQUIP LIST________
    
    // Cycle through array of equipItems and build a string
    // Sort and add structure to the array (with category, not schedule_grouping)
//    NSLog(@"count of items in array before the data structor method: %lu", (unsigned long)[self.request.arrayOfEquipmentJoins count]);
    
    NSArray* arrayOfUniquesWithStructure = [EQRDataStructure convertFlatArrayofUniqueItemsToStructureWithCategory:self.request.arrayOfEquipmentJoins];
    
//    NSLog(@"count of items in structured array: %lu", (unsigned long)[arrayOfUniquesWithStructure count]);
    //cyle through structured equipUniques and print line to summaryMutableString
    
    for (NSArray* subArray in arrayOfUniquesWithStructure){
        
        // ____And printer headers with category titles
        
//        NSLog(@"this is my category: %@", [(EQRScheduleTracking_EquipmentUnique_Join*)[subArray objectAtIndex:0] category]);
        
        
        NSDictionary* arrayAttForHeaderText = [NSDictionary dictionaryWithObjectsAndKeys:headerFont, NSFontAttributeName,
                                               headerParaStyle, NSParagraphStyleAttributeName,
                                               nil];
        
        //text for the header
        NSAttributedString* headerAttString;
        
        //if item is first, eliminate the first carriage return
        if ([arrayOfUniquesWithStructure objectAtIndex:0] == subArray){
            headerAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r",[(EQRScheduleTracking_EquipmentUnique_Join*)[subArray objectAtIndex:0] category]] attributes:arrayAttForHeaderText];
        }else{
            headerAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r%@\r",[(EQRScheduleTracking_EquipmentUnique_Join*)[subArray objectAtIndex:0] category]] attributes:arrayAttForHeaderText];
        }
        
        [self.summaryTotalAtt appendAttributedString:headerAttString];
        
        for (EQRScheduleTracking_EquipmentUnique_Join* equipUniqueObj in subArray){
            
            //add the text of the equip item names to the textField's attributed string
            NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObjectsAndKeys:normalFont, NSFontAttributeName,
                                        paraStyle, NSParagraphStyleAttributeName,
                                        nil];
            NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"      %@  #%@\r", equipUniqueObj.name, equipUniqueObj.distinquishing_id] attributes:arrayAtt11];
            
            [self.summaryTotalAtt appendAttributedString:thisHereAttString];
        }
    }
    
    

    
    //if miscJoins exist...
    if ([self.request.arrayOfMiscJoins count] > 0){
        
        //print miscellaneous section
        NSDictionary* arrayAtt13 = [NSDictionary dictionaryWithObjectsAndKeys:headerFont, NSFontAttributeName,
                                    headerParaStyle, NSParagraphStyleAttributeName,
                                    nil];
        NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r%@\r",@"Miscellaneous"] attributes:arrayAtt13];
        [self.summaryTotalAtt appendAttributedString:thisHereString];
        
        for (EQRMiscJoin* miscJoin in self.request.arrayOfMiscJoins){
            
            NSDictionary* arrayAtt14 = [NSDictionary dictionaryWithObjectsAndKeys:normalFont, NSFontAttributeName,
                                        paraStyle, NSParagraphStyleAttributeName,
                                        nil];
            NSAttributedString* thisHereAttStringAgain = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"      %@\r", miscJoin.name] attributes:arrayAtt14];
            
            [self.summaryTotalAtt appendAttributedString:thisHereAttStringAgain];
        }
    }
    
    
    //____ NOW ADD THE NOTES (if they exist)______
    if (self.request.notes){
        if (![self.request.notes isEqualToString:@""]){
            
            //if notes exist, add them
            NSDictionary* arrayAtt12 = [NSDictionary dictionaryWithObjectsAndKeys:headerFont, NSFontAttributeName,
                                        notesHeaderParaStyle, NSParagraphStyleAttributeName,
                                        nil];
            NSAttributedString* notesHeaderAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r\rNotes:\r"] attributes:arrayAtt12];
            [self.summaryTotalAtt appendAttributedString:notesHeaderAttString];
            
            NSDictionary* arrayAtt13 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
            NSAttributedString* notesAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", self.request.notes] attributes:arrayAtt13];
            [self.summaryTotalAtt appendAttributedString:notesAttString];
        }
    }
    
    
    //__1__ use a text view
    self.summaryTextView.attributedText = self.datesAtt;
    
    //.... and
    
    //__2__ use a custom view with two columns
    self.myTwoColumnView.myAttString = self.summaryTotalAtt;
    [self.myTwoColumnView manuallySetTextWithColumnCount:3];
    
    //_______set page renderer as delegate for layoutManager of MultiColumnTextView
    //so it can reflow the text between multiple pages
    //or re-position the text view and number of columns
    self.myTwoColumnView.layoutManager.delegate = self;
    
    //_________  AUTOMATICALLY DO THE PDF GENERATION  _____________
    EQRPDFGenerator *pdfGenerator = [[EQRPDFGenerator alloc] init];
    
    // The only reason for retaining pdfGenerator is update the additional X value after layoutManager delegate method is called
    self.pdfGenerator = pdfGenerator;
    
    pdfGenerator.myTextView = self.summaryTextView;
    pdfGenerator.myMultiColumnView = self.myTwoColumnView;
    pdfGenerator.additionalXAdjustment = self.additionalXAdjustment;
    
    if (self.hasSigImage){
        pdfGenerator.hasSigImage = YES;
        pdfGenerator.sigImage = self.sigImage;
    }
    
    [pdfGenerator launchPDFGeneratorWithName:self.request.contactNameItem.first_and_last
                                       phone:self.request.contactNameItem.phone
                                       email:self.request.contactNameItem.email
                                  agreements:self.arrayOfAgreements
                                  completion:^{
                                      
                                      // Sends completion block after pdf generator finishes its business
                                      self.delayedCompletionBlock();
                                      
                                  }];
}


#pragma mark - webdata delegate

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    if (![self respondsToSelector:action]){
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    [self performSelector:action withObject:currentThing];
    
#pragma clang diagnostic pop
    
}

-(void)addEquipmentJoin:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    if (!self.request.arrayOfEquipmentJoins){
        self.request.arrayOfEquipmentJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
    NSLog(@"is adding an item to the array of equipJoins");
    [self.request.arrayOfEquipmentJoins addObject:currentThing];
}

-(void)addMiscJoin:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    if (!self.request.arrayOfMiscJoins){
        self.request.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.request.arrayOfMiscJoins addObject:currentThing];
}


#pragma mark - nslayoutmanager delegate methods

- (void)layoutManager:(NSLayoutManager *)aLayoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)aTextContainer atEnd:(BOOL)flag{
    
//    NSLog(@"This is the BOOL flag for layoutManager: %u  for text Container %@", flag, aTextContainer);
    NSLog(@"EQRPageConstructor > layoutManager says countOfColumns: %lu  self.myTwoColumnView.myColumnCount: %lu", (long)self.countOfColumns, (long)self.myTwoColumnView.myColumnCount);
    
    self.countOfColumns = self.countOfColumns + 1;
    
    if (flag == YES){
        
        switch (self.countOfColumns) {
            case 1:
                
                if (self.myTwoColumnView.myColumnCount == 3){
                    
                    //reposition view for printing
                    self.additionalXAdjustment = 180.f;
                    self.pdfGenerator.additionalXAdjustment = 180.f;
                }
                break;
                
            case 2:
                
                if (self.myTwoColumnView.myColumnCount == 3){
                    
                    //reposition view for printing
                    self.additionalXAdjustment = 80.f;
                    self.pdfGenerator.additionalXAdjustment = 80.f;
                }
                
                break;
                
            case 3:
                
                //filled all three columns of text
                break;
                
            default:
                break;
        }
        
        //reset count of columns
        self.countOfColumns = 0;
        
    }else{
        
        if (self.countOfColumns >= 3){
            
            NSLog(@"indicates that there is overflow text");
            
            //filled all three columns with overflow
            //_____!!!!!!  need to re-format  !!!!!!________
            
        }
    }
    
    //if atEnd is never YES then the text does not fill the available space and we need more pages.
    
    //(NSUInteger) firstUnlaidCharacterIndex
    
    //call this on layoutManager invalidateDisplayForCharacterRange:(NSRange)charRange
}







@end
