//
//  EQRItineraryCellContentVCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 5/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRItineraryCellContentVCntrllr.h"
#import "EQRColors.h"

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
        

    }else{
        //switched to off
        
        //change status color
        self.thirdStatusBar.myColor = [[[EQRColors sharedInstance] colorDic] objectForKey:EQRColorVeryLightGrey];
        
        //change color of second status bar
        [self.thirdStatusBar setNeedsDisplay];
        

    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
