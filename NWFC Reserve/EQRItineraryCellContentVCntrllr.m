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

@interface EQRItineraryCellContentVCntrllr ()

@property (strong, nonatomic) UIColor* myAssignedColor;

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
    }
    
    //third bar
    if (self.myStatus > 1){
        
        self.thirdStatusBar.myColor = self.myAssignedColor;
    }
    
    [self.view addSubview:self.firstStatusBar];
    [self.view addSubview:self.secondStatusBar];
    [self.view addSubview:self.thirdStatusBar];
}


#pragma mark - switch methods


-(IBAction)switch1Fires:(id)sender{
    
    //_______show check in out view
    NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.requestKeyId, @"scheduleKey",
                             [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                              [NSNumber numberWithInteger:1], @"switch_num",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentCheckInOut object:nil userInfo:userDic];
    
}


-(IBAction)switch2Fires:(id)sender{
    
    //_______show check in out view
    NSDictionary* userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.requestKeyId, @"scheduleKey",
                             [NSNumber numberWithBool:self.markedForReturning], @"marked_for_returning",
                             [NSNumber numberWithInteger:2], @"switch_num",
                             nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRPresentCheckInOut object:nil userInfo:userDic];
    
}



#pragma mark - notes

-(void)dismissedCheckInOut:(NSNotification*)note{
    
    //_______********  still need to update the data model and local ivar   *******_______
    
    //[NSNumber numberWithBool:self.marked_for_returning], @"marked_for_returning",
    //self.myProperty, @"propertyToUpdate",

    
    NSString* scheduleKey = [[note userInfo] objectForKey:@"scheduleKey"];
    NSString* completeOrIncomplete = [[note userInfo] objectForKey:@"comleteOrIncomplete"];
    NSUInteger switch_num = [[[note userInfo] objectForKey:@"switch_num"] integerValue];
    BOOL foundOutstandingItem = [[[note userInfo] objectForKey:@"foundOutstandingItem"] boolValue];
    
    if ([self.requestKeyId isEqualToString:scheduleKey]){
        
        if ([completeOrIncomplete isEqualToString:@"complete"]){
            
            if (switch_num == 1){
                
                self.myStatus = 1;
                
                [self.switch1 setOn:YES];
                
                //enable switch2
                self.switch2.alpha = 1.0;
                self.switchLabel2.alpha = 1.0;
                self.switch2.userInteractionEnabled = YES;
                
                //change status color
                self.secondStatusBar.myColor = self.myAssignedColor;
                self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                
                //change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                //turn on caution label
                if (foundOutstandingItem){
                    
                    self.cautionLabel1.hidden = NO;
                    
                }else{
                    
                    self.cautionLabel1.hidden = YES;
                }
                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_prep_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }else {
                    secondArray = [NSArray arrayWithObjects:@"staff_checkin_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
                
                NSString* resultString = [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                NSLog(@"%@", resultString);
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                //include the new status
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                
            }else{
                
                self.myStatus = 2;
                
                [self.switch2 setOn:YES];
                
                //change status color
                self.secondStatusBar.myColor = self.myAssignedColor;
                self.thirdStatusBar.myColor = self.myAssignedColor;
                
                //change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                //turn on caution label
                if (foundOutstandingItem){
                    
                    self.cautionLabel2.hidden = NO;
                    
                }else{
                    
                    self.cautionLabel2.hidden = YES;
                }
                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_checkout_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }else{
                    secondArray = [NSArray arrayWithObjects:@"staff_shelf_date",  [dateFormatter stringFromDate:[NSDate date]], nil];
                }
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
                
                NSString* resultString = [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                NSLog(@"%@", resultString);
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];
                
                
            }
            
        }else{
            //marked as incomplete
            
            if (switch_num == 1){
                
                self.myStatus = 0;
                
                [self.switch1 setOn:NO];
                
                //disable switch2
                self.switch2.alpha = 0.3;
                self.switchLabel2.alpha = 0.3;
                self.switch2.userInteractionEnabled = NO;
                
                //change status color
                self.secondStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                
                //change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                self.cautionLabel1.hidden = YES;
                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_prep_date",  @"nix", nil];
                }else {
                    secondArray = [NSArray arrayWithObjects:@"staff_checkin_date",  @"nix", nil];
                }
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
                
                NSString* resultString = [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                NSLog(@"%@", resultString);
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];

                
                
                //_______ need to accommodate when switch 2 is ON and remove that from model as well
                if (self.myStatus == 2){
                    
                    EQRWebData* webData = [EQRWebData sharedInstance];
                    
                    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                    NSArray* secondArray;
                    if (!self.markedForReturning){
                        secondArray = [NSArray arrayWithObjects:@"staff_checkout_date",  @"nix", nil];
                    }else{
                        secondArray = [NSArray arrayWithObjects:@"staff_shelf_date",  @"nix", nil];
                    }
                    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
                    
                    [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                }
                
                
            }else{
                
                self.myStatus = 1;
                
                [self.switch2 setOn:NO];
                
                //change status color
                self.secondStatusBar.myColor = self.myAssignedColor;
                self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
                
                //change color of second status bar
                [self.secondStatusBar setNeedsDisplay];
                [self.thirdStatusBar setNeedsDisplay];
                
                self.cautionLabel2.hidden = YES;
                
                
                //update the model
                EQRWebData* webData = [EQRWebData sharedInstance];
                
                NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.requestKeyId, nil];
                NSArray* secondArray;
                if (!self.markedForReturning){
                    secondArray = [NSArray arrayWithObjects:@"staff_checkout_date",  @"nix", nil];
                }else{
                    secondArray = [NSArray arrayWithObjects:@"staff_shelf_date",  @"nix", nil];
                }
                NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
                
                [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
                
                //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
                NSDictionary* infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:self.myStatus], @"status",
                                         [NSNumber numberWithBool:self.markedForReturning], @"markedForReturning",
                                         nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil userInfo:infoDic];

            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end