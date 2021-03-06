//
//  EQRCheckPrintPage.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 6/4/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRCheckPrintPage.h"
#import "EQRWebData.h"
#import "EQREquipItem.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRCheckPageRenderer.h"
#import "EQRDataStructure.h"
#import "EQRMultiColumnTextView.h"
#import "EQRMiscJoin.h"
#import "EQRPDFGenerator.h"

@interface EQRCheckPrintPage ()

@property (strong, nonatomic) EQRScheduleRequestItem* request;
@property (nonatomic, strong) IBOutlet EQRMultiColumnTextView* myTwoColumnView;
@property NSInteger countOfColumns;
@property float additionalXAdjustment;
@property BOOL isPDF;
@property (strong, nonatomic) UIImage *sigImage;
@property BOOL hasSigImage;
@property (strong, nonatomic) NSMutableArray *miscJoins;
@property (strong, nonatomic) NSDictionary *styles;

@end

@implementation EQRCheckPrintPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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
        
        _styles = @{@"normalFont": normalFont,
                    @"boldFont":boldFont,
                    @"headerFont":headerFont,
                    @"paraStyle": paraStyle,
                    @"headerParaStyle": headerParaStyle,
                    @"notesHeaderParaStyle": notesHeaderParaStyle
                    };
    }
    return self;
}


#pragma mark - setup methods

-(void)initialSetupWithScheduleRequestItem:(EQRScheduleRequestItem*)request forPDF:(BOOL)isPDF{
    
    if (request){
        self.request = request;
    }
    
    self.isPDF = isPDF;
    self.countOfColumns = 0;
    self.additionalXAdjustment = 0.f;
}

-(void)addSignatureImage:(UIImage *)sigImage{
    
    self.hasSigImage = YES;
    self.sigImage = sigImage;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"viewDidLoad";
    queue.maxConcurrentOperationCount = 5;
    
    
    NSBlockOperation *getScheduleEquipJoins = [NSBlockOperation blockOperationWithBlock:^{
        // Build the request's array of equip joins
        NSArray* topArray = @[ @[@"scheduleTracking_foreignKey", self.request.key_id] ];
        NSMutableArray* returnArrayOfJoins = [NSMutableArray arrayWithCapacity:1];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleEquipJoins.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
            for (id object in muteArray){
                [returnArrayOfJoins addObject:object];
            }
        }];
        
        if (!self.request.arrayOfEquipmentJoins){
            self.request.arrayOfEquipmentJoins = [NSMutableArray arrayWithCapacity:1];
        }
        [self.request.arrayOfEquipmentJoins removeAllObjects];
        
        [self.request.arrayOfEquipmentJoins addObjectsFromArray:returnArrayOfJoins];
    }];
    
    
    NSBlockOperation *headerProperties = [NSBlockOperation blockOperationWithBlock:^{
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
        
        //begin the total attribute string
        self.datesAtt = [[NSMutableAttributedString alloc] initWithString:@""];
        
        //_______PICKUP DATE_____
        NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:self.styles[@"normalFont"] forKey:NSFontAttributeName];
        NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"Pick Up: " attributes:arrayAtt6];
        [self.datesAtt appendAttributedString:pickupHead];
        
        NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:self.styles[@"boldFont"] forKey:NSFontAttributeName];
        NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:combinedDateAndTimeBegin  attributes:arrayAtt7];
        [self.datesAtt appendAttributedString:pickupAtt];
        
        //______RETURN DATE________
        NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:self.styles[@"normalFont"] forKey:NSFontAttributeName];
        NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"            Return: " attributes:arrayAtt8];
        [self.datesAtt appendAttributedString:returnHead];
        
        NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:self.styles[@"boldFont"] forKey:NSFontAttributeName];
        NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:combinedDateAndTimeEnd  attributes:arrayAtt9];
        [self.datesAtt appendAttributedString:returnAtt];
    }];
    
    
    __block NSMutableAttributedString *equipmentAttr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSBlockOperation *equipment = [NSBlockOperation blockOperationWithBlock:^{
        
        //________EQUIP LIST________
        //cycle through array of equipItems and build a string
        
        // 2. first, cycle through scheduleTracking_equip_joins and get equipUniques
        NSMutableArray* arrayOfUniques = [NSMutableArray arrayWithCapacity:1];
        for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in self.request.arrayOfEquipmentJoins){
            
            NSArray* thisArray2 = @[ @[@"key_id", joinItem.equipUniqueItem_foreignKey] ];
            EQRWebData *webData = [EQRWebData sharedInstance];
            [webData queryWithLink:@"EQGetEquipmentUnique.php" parameters:thisArray2 class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
                
                for (EQREquipUniqueItem* equipItemObj in muteArray){
                    [arrayOfUniques addObject:equipItemObj];
                }
            }];
        }
        
        // Sort and add structure to the array (with category, not schedule_grouping)
        NSArray* arrayOfUniquesWithStructure = [EQRDataStructure convertFlatArrayofUniqueItemsToStructureWithCategory:arrayOfUniques];
        
        //cyle through structured equipUniques and print line to summaryMutableString
        for (NSArray* subArray in arrayOfUniquesWithStructure){
            
            // And printer headers with category titles
            NSDictionary* arrayAttForHeaderText = [NSDictionary dictionaryWithObjectsAndKeys:self.styles[@"headerFont"], NSFontAttributeName,
                                                   self.styles[@"headerParaStyle"], NSParagraphStyleAttributeName,
                                                   nil];
            
            // Text for the header
            NSAttributedString* headerAttString;
            
            //if item is first, eliminate the first carriage return
            if ([arrayOfUniquesWithStructure objectAtIndex:0] == subArray){
                headerAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r",[(EQREquipUniqueItem*)[subArray objectAtIndex:0] category]] attributes:arrayAttForHeaderText];
            }else{
                headerAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r%@\r",[(EQREquipUniqueItem*)[subArray objectAtIndex:0] category]] attributes:arrayAttForHeaderText];
            }
            
            [equipmentAttr appendAttributedString:headerAttString];
            
            for (EQREquipUniqueItem* equipUniqueObj in subArray){
                
                //add the text of the equip item names to the textField's attributed string
                NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObjectsAndKeys:self.styles[@"normalFont"], NSFontAttributeName,
                                            self.styles[@"paraStyle"], NSParagraphStyleAttributeName,
                                            nil];
                NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"      %@  #%@\r", equipUniqueObj.name, equipUniqueObj.distinquishing_id] attributes:arrayAtt11];
                
                [equipmentAttr appendAttributedString:thisHereAttString];
            }
        }
    }];
    [equipment addDependency:getScheduleEquipJoins];
    
    
    __block NSMutableAttributedString *miscAttr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSBlockOperation *misc = [NSBlockOperation blockOperationWithBlock:^{
        // Add misc joins if any exist
        if (!self.miscJoins){
            self.miscJoins = [NSMutableArray arrayWithCapacity:1];
        }
        [self.miscJoins removeAllObjects];
        
        NSArray* omegaArray = @[ @[@"scheduleTracking_foreignKey", self.request.key_id] ];
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray) {
            for (id miscJoin in muteArray){
                [self.miscJoins addObject:miscJoin];
            }
            
            if ([self.miscJoins count] > 0){
                
                //print miscellaneous section
                NSDictionary* arrayAtt13 = [NSDictionary dictionaryWithObjectsAndKeys:self.styles[@"headerFont"], NSFontAttributeName,
                                            self.styles[@"headerParaStyle"], NSParagraphStyleAttributeName,
                                            nil];
                NSAttributedString *thisHereString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r%@\r",@"Miscellaneous"] attributes:arrayAtt13];
                [miscAttr appendAttributedString:thisHereString];
                
                for (EQRMiscJoin* miscJoin in self.miscJoins){
                    
                    NSDictionary* arrayAtt14 = [NSDictionary dictionaryWithObjectsAndKeys:self.styles[@"normalFont"], NSFontAttributeName,
                                                self.styles[@"paraStyle"], NSParagraphStyleAttributeName,
                                                nil];
                    NSAttributedString* thisHereAttStringAgain = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"      %@\r", miscJoin.name] attributes:arrayAtt14];
                    
                    [miscAttr appendAttributedString:thisHereAttStringAgain];
                }
            }
        }];
    }];
    
    
    __block NSMutableAttributedString *notesAttr = [[NSMutableAttributedString alloc] initWithString:@""];
    NSBlockOperation *notes = [NSBlockOperation blockOperationWithBlock:^{
        //____ NOW ADD THE NOTES (if they exist)______
        if (self.request.notes){
            if (![self.request.notes isEqualToString:@""]){
                
                //if notes exist, add them
                NSDictionary* arrayAtt12 = [NSDictionary dictionaryWithObjectsAndKeys:self.styles[@"headerFont"], NSFontAttributeName,
                                            self.styles[@"notesHeaderParaStyle"], NSParagraphStyleAttributeName,
                                            nil];
                NSAttributedString* notesHeaderAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\r\rNotes:\r"] attributes:arrayAtt12];
                [notesAttr appendAttributedString:notesHeaderAttString];
                
                NSDictionary* arrayAtt13 = [NSDictionary dictionaryWithObject:self.styles[@"normalFont"] forKey:NSFontAttributeName];
                NSAttributedString* notesAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r", self.request.notes] attributes:arrayAtt13];
                [notesAttr appendAttributedString:notesAttString];
            }
        }
    }];
    
    
    NSBlockOperation *printOrRenderPDF = [NSBlockOperation blockOperationWithBlock:^{
        
        self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];
        [self.summaryTotalAtt appendAttributedString:equipmentAttr];
        [self.summaryTotalAtt appendAttributedString:miscAttr];
        [self.summaryTotalAtt appendAttributedString:notesAttr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
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
            
            if (self.isPDF){
                
                //_________  AUTOMATICALLY DO THE PDF GENERATION  _____________
                EQRPDFGenerator *pdfGenerator = [[EQRPDFGenerator alloc] init];
                
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
                                              renterType:[self.request.renter_type capitalizedString]
                                                   class:self.request.title
                                              agreements:nil
                                              completion:^(NSString *pdf_name, NSDate *pdf_timestamp){
                                                  
                                                  
                                              }];
            }else{
                //__________   OR... AUTOMATICALLY DO THE PRINTING  ___________
                [self performSelector:@selector(justPrint) withObject:nil afterDelay:1.0];
            }
        });
    }];
    [printOrRenderPDF addDependency:headerProperties];
    [printOrRenderPDF addDependency:equipment];
    [printOrRenderPDF addDependency:misc];
    [printOrRenderPDF addDependency:notes];
   
    
    [queue addOperation:getScheduleEquipJoins];
    [queue addOperation:headerProperties];
    [queue addOperation:equipment];
    [queue addOperation:misc];
    [queue addOperation:notes];
    [queue addOperation:printOrRenderPDF];
}


-(BOOL)justPrint{
    
    //_______PRINTING_________!
    
    UIPrintInteractionController* printIntCont = [UIPrintInteractionController sharedPrintController];
    
    //__1__ only necessary if using a printFormatter
//    UIViewPrintFormatter* viewPrintFormatter = [self.summaryTextView viewPrintFormatter];
//    //add contect insets to printFormatter
//    UIEdgeInsets myInsets = UIEdgeInsetsMake (0, 90, 0, 20);
//    viewPrintFormatter.contentInsets = myInsets;
    
    
    UIPrintInfo* printInfo = [UIPrintInfo printInfo] ;
    printInfo.jobName = @"NWFC Equip Request";
    printInfo.outputType = UIPrintInfoOutputGrayscale;
    //assign printinfo to int cntrllr
    printIntCont.printInfo = printInfo;
    
    //create page renderer
    EQRCheckPageRenderer* pageRenderer = [[EQRCheckPageRenderer alloc] init];
    
    //assign renderer properties
    pageRenderer.headerHeight = 210.f;
    pageRenderer.footerHeight = 260.f;
    
    //ivars
    pageRenderer.additionalXAdjustment = self.additionalXAdjustment;
    
    //add info to renderer properties
    pageRenderer.name_text_value = self.rentorNameAtt;
    pageRenderer.phone_text_value = self.rentorPhoneAtt;
    pageRenderer.email_text_value = self.rentorEmailAtt;
    
    
    //__1__ add printer formatter object to the page renderer
//    [pageRenderer addPrintFormatter:viewPrintFormatter startingAtPageAtIndex:0];
    
    //.... or
    
    //__2__ add a textview
//    EQRTwoColumnTextView* thisTwoColumnView = [[EQRTwoColumnTextView alloc] initWithFrame:CGRectMake(50.f, 210.f, 650.f, 400.f)];
    pageRenderer.aTwoColumnView = self.myTwoColumnView;
    pageRenderer.aTextView = self.summaryTextView;
    
    //assign page renderer to int cntrllr
    printIntCont.printPageRenderer = pageRenderer;

    
    __block BOOL successOrNot;
    
    [printIntCont presentFromRect:self.dismissButton.frame inView:self.view animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController,BOOL completed, NSError *error){
        
        //unless the printing in cancelled...
        
        if (completed){
            
            successOrNot = YES;
            
            //dismiss the view
            [self dismissViewControllerAnimated:YES completion:^{
        
            }];
            
            
        } else {
            
            successOrNot = NO;
            
            //dismiss the view
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }];
    
    return successOrNot;
}


#pragma mark - buttons

-(IBAction)dismissMe:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - nslayoutmanager delegate methods

- (void)layoutManager:(NSLayoutManager *)aLayoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)aTextContainer atEnd:(BOOL)flag{
    
//    NSLog(@"This is the BOOL flag for layoutManager: %u  for text Container %@", flag, aTextContainer);
    
    self.countOfColumns = self.countOfColumns + 1;
    
    if (flag == YES){
        

        
        switch (self.countOfColumns) {
            case 1:
                
                if (self.myTwoColumnView.myColumnCount == 3){
                    
                    //reposition view for printing
                    self.additionalXAdjustment = 180.f;
                }
                break;
                
            case 2:
                
                if (self.myTwoColumnView.myColumnCount == 3){
                    
                    //reposition view for printing
                    self.additionalXAdjustment = 80.f;
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
        
        //filled all three columns with overflow
        //_____!!!!!!  need to re-format  !!!!!!________
        
//        self.countOfColumns = 0;
    }
    
    //if atEnd is never YES then the text does not fill the available space and we need more pages.
    
    //(NSUInteger) firstUnlaidCharacterIndex
    
    
    //call this on layoutManager invalidateDisplayForCharacterRange:(NSRange)charRange
    
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
