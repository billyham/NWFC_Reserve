//
//  EQRItineraryCellContentVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryCellContentVCntrllr.h"
#import "EQRColors.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRQuickViewPage1VCntrllr.h"
#import "EQRDayDatePickerVCntrllr.h"
#import "EQRStaffUserManager.h"

@interface EQRItineraryCellContentVCntrllr ()

@property (strong, nonatomic) UIColor* myAssignedColor;
@property (strong, nonatomic) UIButton* myQuickViewButton;
//@property (strong, nonatomic) UIPopoverController* myPopOver;


@end

@implementation EQRItineraryCellContentVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //register for notes
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //receive complete or incomplete for this rows individual items editor
    [nc addObserver:self selector:@selector(dismissedCheckInOut:) name:EQRMarkItineraryAsCompleteOrNot object:nil];
    
    //initially... hide the caution labels
    self.cautionLabel1.hidden = YES;
    self.cautionLabel2.hidden = YES;
    
    EQRColors* colors = [EQRColors sharedInstance];
    
    //______create tap radio "buttons"
    CGRect thisFirstRect = CGRectMake(314, 8, 30, 30);
    self.switchTap1 = [[EQRTapRadioButtonView alloc] initWithFrame:thisFirstRect];
    self.switchTap1.opaque = NO;
    self.switchTap1.backgroundColor = [UIColor clearColor];
    self.switchTap1.IAmSwitch2 = NO;
    
    //assign self as button's delegate
    self.switchTap1.delegate = self;
    
    CGRect thisSecondRect = CGRectMake(465, 8, 30, 30);
    self.switchTap2 = [[EQRTapRadioButtonView alloc] initWithFrame:thisSecondRect];
    self.switchTap2.opaque = NO;
    self.switchTap2.backgroundColor = [UIColor clearColor];
    self.switchTap2.IAmSwitch2 = YES;
    
    //assign self as button's delegate
    self.switchTap2.delegate = self;
    

    //______create quickView button
//    CGRect thisThirdRect = CGRectMake(640, 8, 30, 30);
    self.myQuickViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.myQuickViewButton.frame = CGRectMake(600, 15, 30, 30);
    [self.myQuickViewButton addTarget:self action:@selector(showQuickView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    //_____create status bar
    if (!self.markedForReturning){
        self.myAssignedColor = [colors.colorDic objectForKey:EQRColorStatusGoing];
    }else{
        self.myAssignedColor = [colors.colorDic objectForKey:EQRColorStatusReturning];
    }
    
    self.firstStatusBar = [[EQRStatusBarView alloc] initWithFrame:CGRectMake(3, 8, 320, 70)];
    self.firstStatusBar.intID = 1;
    self.firstStatusBar.opaque = NO;
    self.firstStatusBar.backgroundColor = [UIColor clearColor];
    self.firstStatusBar.myColor = self.myAssignedColor;
    
    self.secondStatusBar = [[EQRStatusBarView alloc] initWithFrame:CGRectMake(3, 8, 320, 70)];
    self.secondStatusBar.intID =2;
    self.secondStatusBar.opaque = NO;
    self.secondStatusBar.backgroundColor = [UIColor clearColor];
    self.secondStatusBar.myColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];

    
    self.thirdStatusBar = [[EQRStatusBarView alloc] initWithFrame:CGRectMake(3, 8, 320, 70)];
    self.thirdStatusBar.intID = 3;
    self.thirdStatusBar.opaque = NO;
    self.thirdStatusBar.backgroundColor = [UIColor clearColor];
    self.thirdStatusBar.myColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];
    
    
    //determine which status bars should be turned on
    //second bar
    if (self.myStatus > 0){
        
        self.secondStatusBar.myColor = self.myAssignedColor;
        
        //change color of inside of tap button
        self.switchTap1.innerCircleColor = [UIColor colorWithRed: 0 green: 0.657 blue: 0 alpha: 1];
        
    } else {
        
        //change color of inside of tap button
        self.switchTap1.innerCircleColor = [UIColor whiteColor];
    }
    
    //third bar
    if (self.myStatus > 1){
        
        self.thirdStatusBar.myColor = self.myAssignedColor;
    }
    
    [self.view addSubview:self.firstStatusBar];
    [self.view addSubview:self.secondStatusBar];
    [self.view addSubview:self.thirdStatusBar];
    
    [self.view addSubview:self.switchTap1];
    [self.view addSubview:self.switchTap2];
    [self.view addSubview:self.myQuickViewButton];

}


#pragma mark - switch methods


-(IBAction)switch1Fires:(id)sender{
    
    if ([(EQRTapRadioButtonView*)sender IAmSwitch2] == YES){
        
        return;
    }
    
    //_______show check in out view
    NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.requestKeyId, @"scheduleKey",
                             [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                              [NSNumber numberWithInteger:1], @"switch_num",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentCheckInOut object:nil userInfo:userDic];
        
}


-(IBAction)switch2Fires:(id)sender{
    
    if ([(EQRTapRadioButtonView*)sender IAmSwitch2] == NO){
        
        return;
    }
    
    //_______show check in out view
    NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.requestKeyId, @"scheduleKey",
                             [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                             [NSNumber numberWithInteger:2], @"switch_num",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentCheckInOut object:nil userInfo:userDic];
    
}


-(IBAction)showQuickView:(id)sender{
    
    NSValue* rectValue = [NSValue valueWithCGRect:self.myQuickViewButton.frame];
    UIView* thisView = self.view;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.requestKeyId, @"key_ID",
                         [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                         rectValue, @"rectValue",
                         thisView, @"thisView", nil];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentItineraryQuickView object:nil userInfo:dic];
    
    
}



#pragma mark - notes

-(void)dismissedCheckInOut:(NSNotification*)note{
    
    NSString* scheduleKey = [[note userInfo] objectForKey:@"scheduleKey"];
    NSString* completeOrIncomplete = [[note userInfo] objectForKey:@"comleteOrIncomplete"];
    BOOL markedForReturning = [(NSNumber*)[[note userInfo] objectForKey:@"marked_for_returning"] boolValue];
    NSUInteger switch_num = [[[note userInfo] objectForKey:@"switch_num"] integerValue];
    BOOL foundOutstandingItem = [[[note userInfo] objectForKey:@"foundOutstandingItem"] boolValue];
    
    if (([self.requestKeyId isEqualToString:scheduleKey]) && (markedForReturning == self.markedForReturning)){
        
        if ([completeOrIncomplete isEqualToString:@"complete"]){
            
            if (switch_num == 1){
                
                // Don't change status if it's at 2
                if (self.myStatus == 0){
                    self.myStatus = 1;
                }
                
                // Change color of inside of tap button
                self.switchTap1.innerCircleColor = [UIColor colorWithRed: 0 green: 0.657 blue: 0 alpha: 1];
                [self.switchTap1 setNeedsDisplay];
                
                // Enable switch2
                self.switchTap2.alpha = 1.0;
                self.switchLabel2.alpha = 1.0;
                self.switchTap2.userInteractionEnabled = YES;
                
                // Change status color
                self.secondStatusBar.myColor = self.myAssignedColor;
                
                if (self.myStatus < 2){
                    
                    self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                    
                } else {
                    
                   self.thirdStatusBar.myColor = self.myAssignedColor;
                }
                
                // Change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                // Turn on caution label
                if (foundOutstandingItem){
                    self.cautionLabel1.hidden = NO;
                    
                }else{
                    
                    self.cautionLabel1.hidden = YES;
                }
                
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_prep_date";
                }else {
                    tag = @"staff_checkin_date";
                }
                
                [self updateData:tag nix:NO callback:^{

                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning] };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];

            }else{
                
                // SwtichNum == 2
                
                self.myStatus = 2;
                
                // Change color of inside of tap button
                self.switchTap2.innerCircleColor = [UIColor colorWithRed: 0 green: 0.657 blue: 0 alpha: 1];
                [self.switchTap2 setNeedsDisplay];
                
                // Change status color
                self.secondStatusBar.myColor = self.myAssignedColor;
                self.thirdStatusBar.myColor = self.myAssignedColor;
                
                // Change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                // Turn on caution label
                if (foundOutstandingItem){
                    
                    self.cautionLabel2.hidden = NO;
                    
                }else{
                    
                    self.cautionLabel2.hidden = YES;
                }
                
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_checkout_date";
                }else {
                    tag = @"staff_shelf_date";
                }
                
                [self updateData:tag nix:NO callback:^{

                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning] };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];
            }
            
        }else{
            // Marked as incomplete
            
            if (switch_num == 1){
                
                self.myStatus = 0;
                
                // Change color of inside of tap button
                self.switchTap1.innerCircleColor = [UIColor whiteColor];
                [self.switchTap1 setNeedsDisplay];
                
                // Disable switch2
                self.switchTap2.alpha = 0.3;
                self.switchLabel2.alpha = 0.3;
                self.switchTap2.userInteractionEnabled = NO;
                
                // Also change color of inside of switch2 tap button
                self.switchTap2.innerCircleColor = [UIColor whiteColor];
                [self.switchTap2 setNeedsDisplay];
                
                // Change status color
                self.secondStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                
                // Change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                self.cautionLabel1.hidden = YES;
                self.cautionLabel2.hidden = YES;
                
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_prep_date";
                }else {
                    tag = @"staff_checkin_date";
                }
                
                [self updateData:tag nix:YES callback:^{

                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning] };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];
                
                // Need to accommodate when switch 2 is ON and remove that from model as well
                if (self.myStatus == 2){
                    
                    NSString* secondTag;
                    if (!self.markedForReturning){
                        secondTag = @"staff_checkout_date";
                    }else {
                        secondTag = @"staff_shelf_date";
                    }
                    
                    [self updateData:secondTag nix:YES callback:^{
                        
                    }];
                }
                
            }else{
                
                // SwtichNum == 2
                
                self.myStatus = 1;
                
                // Change color of inside of tap button
                self.switchTap2.innerCircleColor = [UIColor whiteColor];
                [self.switchTap2 setNeedsDisplay];
                
                // Change status color
                self.secondStatusBar.myColor = self.myAssignedColor;
                self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                
                // Change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                self.cautionLabel2.hidden = YES;
                
                NSString* tag;
                if (!self.markedForReturning){
                    tag = @"staff_checkout_date";
                }else {
                    tag = @"staff_shelf_date";
                }
                
                [self updateData:tag nix:YES callback:^{

                    NSDictionary* infoDic = @{ @"status": [NSNumber numberWithInteger:self.myStatus],
                                               @"markedForReturning": [NSNumber numberWithBool:self.markedForReturning] };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                }];
            }
        }
    }
}

-(void)updateData:(NSString*)tag nix:(BOOL)nix callback:(void (^)(void))cb{

    // Update the model
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];

    NSString *tagValue;

    if (nix){
        tagValue = @"nix";
    }else{
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        tagValue = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    NSArray* topArray = @[ @[@"key_id", self.requestKeyId],
                           @[tag, tagValue],
                           @[@"staff_id", staffUserManager.currentStaffUser.key_id] ];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    [webData queryForStringwithAsync:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray completion:^(NSString *returnString) {
        cb();
    }];
}

#pragma mark - popover delegate methods

//never uses the popover actually
//-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
//
//    //there is 1 popover
//    if (popoverController == self.myPopOver){
//        
//        self.myPopOver = nil;
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
