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

@interface EQRSigCaptureMainVC ()<EQRWebDataDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *returnDateLabel;
//@property (strong, nonatomic) IBOutlet UITextView *agreementTextView;
@property (strong, nonatomic) IBOutlet PPSSignatureView *signatureView;
@property (strong, nonatomic) EQRScheduleRequestItem *requestItem;
@property (strong, nonatomic) EQRPricingWidgetSigVC *myPricingWidget;
@property (strong, nonatomic) UIView *pricingWidgetView;
@property (strong, nonatomic) EQRTransaction *myTransaction;

@property (strong, nonatomic) NSMutableArray *arrayOfAgreementTextElements;
@property (strong, nonatomic) EQRSigAgreementVC *agreementVC;

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
    
//    NSString* text2Content = @"I hereby assume full responsibility for the above listed equipment provided by the Northwest Film Center. Financial responsibility includes payment for all repairs, up to the full replacement value of equipment, and the full replacement value for all stolen or lost equipment. Financial responsibility also includes the rental fee for the time period in which damaged equipment is out for repair, or until replacement payment is received. I have inspected the contents of rental equipment and acknowledge that all parts and pieces are present and in working order unless otherwise noted.";
//    NSString* text3Content = @"Projects produced through School of Film classes must include www.nwfilm.org and the following phrase in the credits: Produced through the Northwest Film Center School of Film (spelling out \"Northwest Film Center\").";
//    NSString* text4Content = @"Penalties will be given to students for the following reasons: Returns equipment after the assigned date and time, shows blatant disregard for equipments's well being, no-shows for equipment reservations.";
//    NSString* text5Content = @"I confirm that the equipment is in working order upon check-out and have been made aware of any pre-existing conditions. If returned equipment requires more than 10 min. cleaning, a $25 cleaning fee will be assessed.";
//    
//    UIFont *bodyTypeFont = [UIFont systemFontOfSize:13];
////    UIFont *boldFont = [UIFont systemFontOfSize:13 weight:2.0];
//    
//    NSDictionary *fontDictionary = @{bodyTypeFont:NSFontAttributeName};
//    NSMutableAttributedString *attMuteString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:fontDictionary];
//    
//    NSAttributedString *attString1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", text2Content] attributes:fontDictionary];
//    NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", text3Content] attributes:fontDictionary];
//    NSAttributedString *attString3 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", text4Content] attributes:fontDictionary];
//    NSAttributedString *attString4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", text5Content] attributes:fontDictionary];
//    
//    [attMuteString appendAttributedString:attString1];
//    [attMuteString appendAttributedString:attString2];
//    [attMuteString appendAttributedString:attString3];
//    [attMuteString appendAttributedString:attString4];
//    
//    self.agreementTextView.attributedText = attMuteString;
    
    
    
}

-(void)loadTheDataWithRequestItem:(EQRScheduleRequestItem *)requestItem{
    
    if (requestItem){
        
        self.requestItem = requestItem;
        
        self.nameLabel.text = self.requestItem.contactNameItem.first_and_last;
        
        NSDate *fullDate = [EQRDataStructure dateFromCombinedDay:self.requestItem.request_date_end And8HourShiftedTime:self.requestItem.request_time_end];
        
        NSString *baseString = @"To be returned on ";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setDateFormat:@"EEEE, MMM d, hh:mm a"];
        
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
    }
    
    //set of UITextFields
    NSMutableSet *tempMuteSet = [NSMutableSet setWithCapacity:1];
    
    float savedYValue = 0;
    float widthOfText = 300;

    for (EQRTextElement *textElement in self.arrayOfAgreementTextElements){
        
        CGPoint newPoint = CGPointMake(0, savedYValue);
        CGSize newSize = CGSizeMake(widthOfText, 10);
        CGRect newRect = CGRectMake(newPoint.x, newPoint.y, newSize.width, newSize.height);
        UITextView *newTextView = [[UITextView alloc] initWithFrame:newRect textContainer:nil];
        newTextView.text = textElement.text;
        
        newTextView.font = [UIFont systemFontOfSize:15.0];
        
        //resize textView to size of text
        CGSize evenNewerSize = [newTextView sizeThatFits:CGSizeMake(widthOfText, MAXFLOAT)];
        CGRect newFrame = newTextView.frame;
        newFrame.size = CGSizeMake(fmaxf(evenNewerSize.width, widthOfText), evenNewerSize.height);
        newTextView.frame = newFrame;
        
        
        newTextView.userInteractionEnabled = NO;
        newTextView.allowsEditingTextAttributes = NO;
        
        [tempMuteSet addObject:newTextView];
        
        savedYValue = savedYValue + newTextView.frame.size.height;
        //add a little extra space between clauses
        savedYValue = savedYValue + 30;
    }
    
    NSLog(@"this is the final height: %5.2f", savedYValue);
    
    CGRect totalRect = CGRectMake(20, 0, widthOfText + 40, 500);
    UIScrollView *tryScroll = [[UIScrollView alloc] initWithFrame:totalRect];
    tryScroll.contentSize = CGSizeMake(totalRect.size.width, savedYValue);

    UIView *tryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthOfText + 40, savedYValue)];
    [tryScroll addSubview:tryView];

    
    for (UITextView *textView in tempMuteSet){
        [tryView addSubview:textView];
    }
    
    self.agreementVC = [[EQRSigAgreementVC alloc] initWithNibName:@"EQRSigAgreementVC" bundle:nil];
    [self.agreementVC.view addSubview:tryScroll];
    self.agreementVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:self.agreementVC animated:YES completion:^{
        
        
    }];
    
}


#pragma mark = get pricing info

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)enterButton:(id)sender{
    
//    EQRSigConfirmationVC *confirmVC = [[EQRSigConfirmationVC alloc] initWithNibName:@"EQRSigConfirmationVC" bundle:nil];
//    
//    [self.navigationController pushViewController:confirmVC animated:YES];
    
    [self performSegueWithIdentifier:@"sigConfirmation" sender:self];
}

-(IBAction)otherOptionsButton:(id)sender{
    
}

-(IBAction)clearButton:(id)sender{
    
    [self.signatureView erase];
}

//-(IBAction)viewGearListButton:(id)sender{
//    
//    
//}


@end
