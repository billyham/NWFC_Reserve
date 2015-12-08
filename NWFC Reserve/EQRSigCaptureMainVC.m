//
//  EQRSigCaptureMainVC.m
//  Gear
//
//  Created by Ray Smith on 6/23/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRSigCaptureMainVC.h"
#import "PPSSignatureView.h"
#import <OpenGLES/ES2/glext.h>
//#import "EQRSigConfirmationVC.h"
#import "EQRWebData.h"
#import "EQRDataStructure.h"
#import "EQRPricingWidgetSigVC.h"
#import "EQRGlobals.h"
#import "EQRTransaction.h"
#import "EQRTextElement.h"
#import "EQRSigAgreementVC.h"
#import "EQRColors.h"
#import "EQRCheckPrintPage.h"

@interface EQRSigCaptureMainVC ()<EQRWebDataDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *returnDateLabel;
@property (strong, nonatomic) IBOutlet PPSSignatureView *signatureView;
@property (strong, nonatomic) EQRScheduleRequestItem *requestItem;
@property (strong, nonatomic) EQRPricingWidgetSigVC *myPricingWidget;
@property (strong, nonatomic) UIView *pricingWidgetView;
@property (strong, nonatomic) EQRTransaction *myTransaction;

@property (strong, nonatomic) NSMutableArray *arrayOfAgreementTextElements;
@property (strong, nonatomic) EQRSigAgreementVC *agreementVC;
@property (strong, nonatomic) UIScrollView *agreementScrollView;
@property (strong, nonatomic) NSMutableArray *arrayOfYOrigins;
@property (strong, nonatomic) NSMutableArray *arrayOfTextViews;

@property (strong, nonatomic) IBOutlet UIImageView *roundedRect;

@end

@implementation EQRSigCaptureMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.childViewControllers count] > 0){
        
        for (UIViewController *childViewController in self.childViewControllers){
            
            if ([childViewController class] == [GLKViewController class]){
                self.signatureView = (PPSSignatureView *)childViewController.view;
            }
            
            if ([childViewController class] == [EQRPricingWidgetSigVC class]){
                
//                NSLog(@"recognizes child view controller as pricing widget");
                self.pricingWidgetView = childViewController.view;
                self.pricingWidgetView.hidden = YES;
                
                self.myPricingWidget = (EQRPricingWidgetSigVC *)childViewController;
            }
            
        }
    }
    
    // ____COLORS_____
    
    EQRColors *colors = [EQRColors sharedInstance];
    UIImage *originalImage = self.roundedRect.image;
    UIImage *tintedImage = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.roundedRect setImage:tintedImage];
    self.roundedRect.tintColor = [colors.colorDic objectForKey:EQRColorEditModeBGBlue];
    
    self.view.backgroundColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];
    
}

-(void)loadTheDataWithRequestItem:(EQRScheduleRequestItem *)requestItem{
    
    if (requestItem){
        
        self.requestItem = requestItem;
        
        self.nameLabel.text = self.requestItem.contactNameItem.first_and_last;
        
        NSDate *fullDate = [EQRDataStructure dateFromCombinedDay:self.requestItem.request_date_end And8HourShiftedTime:self.requestItem.request_time_end];
        
        NSString *baseString = @"To be returned on ";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setDateFormat:@"EEEE, MMM d, h:mm a"];
        
        NSString *extendedText = [NSString stringWithFormat:@"%@%@", baseString, [dateFormatter stringFromDate:fullDate]];
        
        self.returnDateLabel.text = extendedText;
        
        //only show pricing information for public renters
        if ([requestItem.renter_type isEqualToString:EQRRenterPublic]){
            self.pricingWidgetView.hidden = NO;
            
            [self getTransactionInfo];
            
        }else{
            self.pricingWidgetView.hidden = YES;
        }
    }
    
    
    
    
    
    
    //______Misc Join List_______
    //gather any misc joins
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", self.requestItem.key_id];
    NSArray* omegaArray = @[alphaArray];
    EQRWebData* webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    SEL selector = @selector(addMiscItem:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRScheduleRequestItem" selector:selector completion:^(BOOL isLoadingFlagUp) {
            
            [self loadTheDataStage2];
        }];
    });
    
    
}

-(void)loadTheDataStage2{  // add misc items to the array of joins
    

    
    [self loadDataStage3];
}

-(void)loadDataStage3{  // get agreement items
    
    if (self.arrayOfAgreementTextElements){
        [self.arrayOfAgreementTextElements removeAllObjects];
    }
    
    NSArray *alphaArray = @[@"context", @"checkoutAgreement"];
    NSArray *topArray = @[alphaArray];
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    SEL selector = @selector(addAgreementTextElement:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       
        [webData queryWithAsync:@"EQGetTextElementsWithContext" parameters:topArray class:@"EQRTextElement" selector:selector completion:^(BOOL isLoadingFlagUp) {
            
            [self loadDataStage4];
        }];
    });
}

-(void)loadDataStage4{   // present agreement text
    
    //only continue if agreement text elements exist
    if (self.arrayOfAgreementTextElements){
        if ([self.arrayOfAgreementTextElements count] < 1){
            return;
        }
    }else{
        return;
    }
    
    //set of UITextFields
    float savedYValue = 0;
    float widthOfText = 440;
    float heightOfLastTextView = 0;
    float alphaForText = 1.0;
    
    self.arrayOfTextViews = [NSMutableArray arrayWithCapacity:1];
    self.arrayOfYOrigins = [NSMutableArray arrayWithCapacity:1];

    for (EQRTextElement *textElement in self.arrayOfAgreementTextElements){
        
        CGPoint newPoint = CGPointMake(0, savedYValue);
        CGSize newSize = CGSizeMake(widthOfText, 10);
        CGRect newRect = CGRectMake(newPoint.x, newPoint.y, newSize.width, newSize.height);
        UITextView *newTextView = [[UITextView alloc] initWithFrame:newRect textContainer:nil];
        newTextView.text = textElement.text;
        
        newTextView.font = [UIFont systemFontOfSize:16.0];
        newTextView.textAlignment = NSTextAlignmentJustified;
        newTextView.alpha = alphaForText;
        
        //resize textView to size of text
        CGSize evenNewerSize = [newTextView sizeThatFits:CGSizeMake(widthOfText, MAXFLOAT)];
        CGRect newFrame = newTextView.frame;
        newFrame.size = CGSizeMake(fmaxf(evenNewerSize.width, widthOfText), evenNewerSize.height);
        newTextView.frame = newFrame;
        
        newTextView.userInteractionEnabled = NO;
        newTextView.allowsEditingTextAttributes = NO;

        
        [self.arrayOfTextViews addObject:newTextView];
        
        //save origin.y for later
        [self.arrayOfYOrigins addObject:[NSNumber numberWithFloat:savedYValue]];
        
        savedYValue = savedYValue + newTextView.frame.size.height;
        //add a little extra space between clauses
        savedYValue = savedYValue + 30;
        
        heightOfLastTextView = newTextView.frame.size.height;
        
        alphaForText = alphaForText * .66;
    }
    
    NSLog(@"this is the final height: %5.2f", savedYValue);
    
    float distanceBetweenTextAndButton = 20.0;
    float widthOfButton = 44.0;
    float heightOfButton = 44.0;
    
    CGRect totalRect = CGRectMake(20, 45, (widthOfText + distanceBetweenTextAndButton + widthOfButton), 500);
    UIScrollView *tryScroll = [[UIScrollView alloc] initWithFrame:totalRect];
    
    //add some extra space to the bottom of the contentView so it doesn't jump weird when scrolling from the bottom up
    float contentHeight = savedYValue + 500 - heightOfLastTextView;
    tryScroll.contentSize = CGSizeMake(totalRect.size.width, contentHeight);

    UIView *tryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalRect.size.width, savedYValue)];
    [tryScroll addSubview:tryView];

    NSInteger buttonTag = 0;
    
    for (UITextView *textView in self.arrayOfTextViews){
        [tryView addSubview:textView];
        
        //also add a button at the same origin.Y
        
        CGRect buttonRect = CGRectMake(textView.frame.size.width + distanceBetweenTextAndButton, textView.frame.origin.y + 10, widthOfButton, heightOfButton);
        UIButton *OKButton = [[UIButton alloc] initWithFrame:buttonRect];
        [OKButton setBackgroundColor:[UIColor redColor]];
        [OKButton setTitle:@"Tap" forState:UIControlStateNormal];
        [OKButton setTitle:@"" forState:UIControlStateSelected];
        OKButton.tag = buttonTag;
        [OKButton addTarget:self action:@selector(OKButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        //set state changes
        [tryView addSubview:OKButton];
        
        buttonTag = buttonTag + 1;
    }
    
    self.agreementScrollView = tryScroll;
    
    self.agreementVC = [[EQRSigAgreementVC alloc] initWithNibName:@"EQRSigAgreementVC" bundle:nil];
    [self.agreementVC.view addSubview:self.agreementScrollView];
    [self.agreementVC.cancelButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];

    self.agreementVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:self.agreementVC animated:YES completion:^{
        
    }];
}


#pragma mark - get pricing info

-(void)getTransactionInfo{
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    NSArray *firstArray = @[@"scheduleTracking_foreignKey", self.requestItem.key_id];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQGetTransactionWithScheduleRequestKey.php" parameters:topArray completion:^(EQRTransaction *transaction) {
            
            if (transaction){
                
                self.myTransaction = transaction;
                
                //found a matching transaction for this schedule Request, go on...
                [self populatePricingWidget];
                
            }else{
                
                //no matching transaction, create a fresh one.
                NSLog(@"didn't find a matching Transaction");
                [self.myPricingWidget deleteExistingData];
            }
        }];
    });
}

-(void)populatePricingWidget{
    
    if (self.myTransaction){
        [self.myPricingWidget initialSetupWithTransaction:self.myTransaction];
    }else{
        [self.myPricingWidget deleteExistingData];
    }
    
}


#pragma mark - webdata delegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"inside EQRCheckVC, cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    [self performSelector:action withObject:currentThing];
    
#pragma clang diagnostic pop
    
}

-(void)addMiscItem:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    
    
}

-(void)addAgreementTextElement:(id)currentThing{
    
    if (!currentThing){
        return;
    }
    
    if (!self.arrayOfAgreementTextElements){
        self.arrayOfAgreementTextElements = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.arrayOfAgreementTextElements addObject:currentThing];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - buttons
-(IBAction)enterButton:(id)sender{
    
//    EQRSigConfirmationVC *confirmVC = [[EQRSigConfirmationVC alloc] initWithNibName:@"EQRSigConfirmationVC" bundle:nil];
//    
//    [self.navigationController pushViewController:confirmVC animated:YES];
    
    [self performSegueWithIdentifier:@"sigConfirmation" sender:self];
}

-(IBAction)otherOptionsButton:(id)sender{
    
}

-(IBAction)showAgreementText:(id)sender{
    
}

-(IBAction)showEquipList:(id)sender{
    
    
}

-(IBAction)clearButton:(id)sender{
    
    [self.signatureView erase];
}

-(IBAction)cancelSigCapture:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(IBAction)generatePDF:(id)sender{
    
    
    //get complete scheduleRequest item info
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstRequestArray = [NSArray arrayWithObjects:@"key_id", self.requestItem.key_id, nil];
    NSArray* secondRequestArray = [NSArray arrayWithObjects:firstRequestArray, nil];
    __block EQRScheduleRequestItem* chosenItem;
    [webData queryWithLink:@"EQGetScheduleRequestInComplete.php" parameters:secondRequestArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        if ([muteArray count] > 0){
            
            chosenItem = [muteArray objectAtIndex:0];
        }
    }];
    
    //add the notes
    chosenItem.notes = self.requestItem.notes;
    //    NSLog(@"these are the notes >>%@<<", chosenItem.notes);
    
    //add contact information
    NSString* email;
    NSString* phone;
    if (self.requestItem.contactNameItem){
        email = self.requestItem.contactNameItem.email;
        phone = self.requestItem.contactNameItem.phone;
        
        chosenItem.contactNameItem = self.requestItem.contactNameItem;
    }
    
    
    //create printable page view controller
    EQRCheckPrintPage* pageForPrint = [[EQRCheckPrintPage alloc] initWithNibName:@"EQRCheckPrintPage" bundle:nil];
    
    //add the request item to the view controller
    [pageForPrint initialSetupWithScheduleRequestItem:chosenItem forPDF:YES];
    
    //if a signatue exists, add it to the CheckPrintPage object
    if (self.signatureView.hasSignature){
        [pageForPrint addSignatureImage:self.signatureView.signatureImage];
    }
    
    
    //assign ivar variables
    pageForPrint.rentorNameAtt = chosenItem.contact_name;
    pageForPrint.rentorEmailAtt = email;
    pageForPrint.rentorPhoneAtt = phone;
    
    
    //show the view controller
    [self presentViewController:pageForPrint animated:YES completion:^{
        
        
    }];
    
}


#pragma mark - agreement view actions

-(IBAction)OKButtonTapped:(id)sender{
    
    //look at the sender's tag...
    //move the scroll view to show the next block of text
    //or exit if all buttons are selected
    
    NSInteger tagNumber = [sender tag];
    
    //only move the scroll view if it isn't the last section
    if ([self.arrayOfYOrigins count] > (tagNumber + 1)){
        
        float originY = [[self.arrayOfYOrigins objectAtIndex:(tagNumber + 1)] floatValue];
        CGPoint myPoint = CGPointMake(0, originY);
        [self.agreementScrollView setContentOffset:myPoint animated:YES];
        
        //update testView alpha values
        __block float alphaForTextView = 1.0;
        [self.arrayOfTextViews enumerateObjectsUsingBlock:^(UITextView *textView, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSInteger tagNumberPlusOne = tagNumber + 1;
            
            if (idx <= tagNumberPlusOne){
                
                 textView.alpha = 1.0;
                
            }else{
                
                alphaForTextView = alphaForTextView * 0.66;
                textView.alpha = alphaForTextView;
            }
        }];
        
    }
    
    //if all buttons are selected, then dismiss the VC
    if (![sender isSelected]){
        [sender setSelected:YES];
        [sender setBackgroundColor:[UIColor greenColor]];
    }else{
        [sender setSelected:NO];
        [sender setBackgroundColor:[UIColor redColor]];
    }
    
    
    NSMutableArray *tempMuteArrayOfButtons = [NSMutableArray arrayWithCapacity:1];
    for (UIView *thisView in [[self.agreementScrollView.subviews objectAtIndex:0] subviews]){
        
        if ([thisView class] == [UIButton class]){
            [tempMuteArrayOfButtons addObject:thisView];
        }
    }
    
    BOOL dismissAgreementView = YES;
    for (UIButton *buttonView in tempMuteArrayOfButtons){
        if (!buttonView.selected){
            dismissAgreementView = NO;
        }
    }
    
    if (dismissAgreementView){
        [self.agreementVC dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

-(IBAction)cancelButton:(id)sender{  //This is the cancdl button inside the Agreement Model View
    
    //_____!!!!! This is weird calling to dismissals but it works... so far...
    [self.agreementVC dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//-(IBAction)viewGearListButton:(id)sender{
//
//    
//}


@end
