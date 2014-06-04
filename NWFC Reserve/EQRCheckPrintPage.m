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

@interface EQRCheckPrintPage ()

@property (strong, nonatomic) EQRScheduleRequestItem* request;

@end

@implementation EQRCheckPrintPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - setup methods

-(void)initialSetupWithScheduleRequestItem:(EQRScheduleRequestItem*)request{
    
    if (request){
        
        self.request = request;
    }
    
    
    //build the request's array of equip joins
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", request.key_id, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    NSMutableArray* returnArrayOfJoins = [NSMutableArray arrayWithCapacity:1];
    [webData queryWithLink:@"EQGetScheduleEquipJoins.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
        
        for (id object in muteArray){
            
            [returnArrayOfJoins addObject:object];
        }
    }];
    
    if (!self.request.arrayOfEquipmentJoins){
        
        self.request.arrayOfEquipmentJoins = [NSMutableArray arrayWithCapacity:1];
    }
    
    [self.request.arrayOfEquipmentJoins addObjectsFromArray:returnArrayOfJoins];
    
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

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
    [pickUpFormatter setDateStyle:NSDateFormatterLongStyle];
    [pickUpFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    
    //save values to ivar
    self.rentorNameAtt = self.request.contact_name;
    self.rentorPhoneAtt = contactItem.phone;
    self.rentorEmailAtt = contactItem.email;
    
    //nsattributedstrings
    UIFont* normalFont = [UIFont systemFontOfSize:10];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:10];
    
    //begin the total attribute string
    self.summaryTotalAtt = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    

    
    //_______PICKUP DATE_____
    NSDictionary* arrayAtt6 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* pickupHead = [[NSAttributedString alloc] initWithString:@"Pick Up: " attributes:arrayAtt6];
    [self.summaryTotalAtt appendAttributedString:pickupHead];
    
    NSDictionary* arrayAtt7 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* pickupAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:self.request.request_date_begin]  attributes:arrayAtt7];
    [self.summaryTotalAtt appendAttributedString:pickupAtt];
    
    //______RETURN DATE________
    NSDictionary* arrayAtt8 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
    NSAttributedString* returnHead = [[NSAttributedString alloc] initWithString:@"            Return: " attributes:arrayAtt8];
    [self.summaryTotalAtt appendAttributedString:returnHead];
    
    NSDictionary* arrayAtt9 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* returnAtt = [[NSAttributedString alloc] initWithString:[pickUpFormatter stringFromDate:self.request.request_date_end]  attributes:arrayAtt9];
    [self.summaryTotalAtt appendAttributedString:returnAtt];
    
    //________EQUIP LIST________
    
    NSDictionary* arrayAtt10 = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
    NSAttributedString* equipHead = [[NSAttributedString alloc] initWithString:@"\r\r\r Pick Up | Return   Equipment Items:\r\r" attributes:arrayAtt10];
    [self.summaryTotalAtt appendAttributedString:equipHead];
    
    //cycle through array of equipItems and build a string
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    
    

    
    // 2. first, cycle through scheduleTracking_equip_joins
    for (EQRScheduleTracking_EquipmentUnique_Join* joinItem in self.request.arrayOfEquipmentJoins){
        
        NSArray* thisArray1 = [NSArray arrayWithObjects:@"key_id", joinItem.equipUniqueItem_foreignKey, Nil];
        NSArray* thisArray2 = [NSArray arrayWithObject:thisArray1];
        [webData queryWithLink:@"EQGetEquipmentUnique.php" parameters:thisArray2 class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
            
            //add the text of the equip item names to the textField's attributed string
            for (EQREquipUniqueItem* equipItemObj in muteArray){
                
                NSDictionary* arrayAtt11 = [NSDictionary dictionaryWithObject:normalFont forKey:NSFontAttributeName];
                NSAttributedString* thisHereAttString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"   ______ | ______   %@  #%@\r", equipItemObj.name, equipItemObj.distinquishing_id] attributes:arrayAtt11];
                
                [self.summaryTotalAtt appendAttributedString:thisHereAttString];
            }
            
        }];
        
    }
    
    
    self.summaryTextView.attributedText = self.summaryTotalAtt;
    
    
    
    //__________   AUTOMATICALLY DO THE PRINTING  ___________
    
    [self performSelector:@selector(justPrint) withObject:nil afterDelay:1.0];
    
}


-(BOOL)justPrint{
    
    //_______PRINTING_________!
    
    UIPrintInteractionController* printIntCont = [UIPrintInteractionController sharedPrintController];
    
    UIViewPrintFormatter* viewPrintFormatter = [self.summaryTextView viewPrintFormatter];
    //add contect insets to printFormatter
    UIEdgeInsets myInsets = UIEdgeInsetsMake (0, 90, 0, 20);
    viewPrintFormatter.contentInsets = myInsets;
    
    
    UIPrintInfo* printInfo = [UIPrintInfo printInfo] ;
    printInfo.jobName = @"NWFC Equip Request";
    printInfo.outputType = UIPrintInfoOutputGrayscale;
    //assign printinfo to int cntrllr
    printIntCont.printInfo = printInfo;
    
    //create page renderer
    EQRCheckPageRenderer* pageRenderer = [[EQRCheckPageRenderer alloc] init];
    
    //assign renderer properties
    pageRenderer.headerHeight = 210.f;
    pageRenderer.footerHeight = 300.f;
    
    //add info to renderer properties
    pageRenderer.name_text_value = self.rentorNameAtt;
    pageRenderer.phone_text_value = self.rentorPhoneAtt;
    pageRenderer.email_text_value = self.rentorEmailAtt;
    
    
    //add printer formatter object to the page renderer
    [pageRenderer addPrintFormatter:viewPrintFormatter startingAtPageAtIndex:0];
    
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


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
