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
    
    EQRColors* colors = [EQRColors sharedInstance];
    
    if (!self.markedForReturning){
        self.myAssignedColor = [colors.colorDic objectForKey:EQRColorStatusGoing];
    }else{
        self.myAssignedColor = [colors.colorDic objectForKey:EQRColorStatusReturning];
    }
    
    self.firstStatusBar = [[EQRStatusBarView alloc] initWithFrame:CGRectMake(3, 3, 320, 70)];
    self.firstStatusBar.intID = 1;
    self.firstStatusBar.opaque = NO;
    self.firstStatusBar.backgroundColor = [UIColor clearColor];
    self.firstStatusBar.myColor = self.myAssignedColor;
    
    self.secondStatusBar = [[EQRStatusBarView alloc] initWithFrame:CGRectMake(3, 3, 320, 70)];
    self.secondStatusBar.intID =2;
    self.secondStatusBar.opaque = NO;
    self.secondStatusBar.backgroundColor = [UIColor clearColor];
    self.secondStatusBar.myColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];

    
    self.thirdStatusBar = [[EQRStatusBarView alloc] initWithFrame:CGRectMake(3, 3, 320, 70)];
    self.thirdStatusBar.intID = 3;
    self.thirdStatusBar.opaque = NO;
    self.thirdStatusBar.backgroundColor = [UIColor clearColor];
    self.thirdStatusBar.myColor = [colors.colorDic objectForKey:EQRColorVeryLightGrey];
    
    
    //determine which status bars should be on
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
    
    if (!self.markedForReturning){
        //when going
    }else{
        //when returning
    }
    
    
    if ([sender isOn]){
        //switched to on
        
        self.switch2.userInteractionEnabled = YES;
        
        //change status color (to both)
        self.secondStatusBar.myColor = self.myAssignedColor;
        
        //change color of second status bar
        [self.secondStatusBar setNeedsDisplay];

        
        
        [UIView animateWithDuration:0.25 animations:^{
            
            //enable switch2
            self.switch2.alpha = 1.0;
            self.switchLabel2.alpha = 1.0;
            
            
            
        }];
        
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
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil];
        
        
        
    }else{
        //switched to off
        
        [self.switch2 setOn:NO animated:YES];
        self.switch2.userInteractionEnabled = NO;
        
        //change status color
        self.secondStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
        self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];

        
        //change color of second status bar
        [self.secondStatusBar setNeedsDisplay];
        [self.thirdStatusBar setNeedsDisplay];
        
        [UIView animateWithDuration:0.23 animations:^{
            
            //disable switch 2
            self.switch2.alpha = 0.3;
            self.switchLabel2.alpha = 0.3;
        }];
        
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
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil];


        
    }
    
    
    
    
    
}


-(IBAction)switch2Fires:(id)sender{
    
    if (!self.markedForReturning){
        //when going
        
    }else{
        //when returning
    }
    
    
    if ([sender isOn]){
        //switched to on
        
        //change status color
        self.thirdStatusBar.myColor = self.myAssignedColor;
        
        //change color of second status bar
        [self.thirdStatusBar setNeedsDisplay];
        
        
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
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil];
        
        

    }else{
        //switched to off
        
        //change status color
        self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
        
        //change color of second status bar
        [self.thirdStatusBar setNeedsDisplay];
        

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
        
        NSString* resultString = [webData queryForStringWithLink:@"EQSetCheckOutInPrepScheduleRequest.php" parameters:topArray];
        NSLog(@"%@", resultString);
        
        //________*********  also update the value in the itinarary object's ivar arrayOfScheduleRequests
        [[NSNotificationCenter defaultCenter] postNotificationName:EQRPartialRefreshToItineraryArray object:nil];

        
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
