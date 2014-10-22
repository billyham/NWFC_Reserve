//
//  EQRStaffPage1VCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffPage1VCntrllr.h"
#import "EQRModeManager.h"

@interface EQRStaffPage1VCntrllr ()

@property (strong, nonatomic) IBOutlet UITextField* urlString;
@property (strong, nonatomic) IBOutlet UITextField* termString;
@property (strong, nonatomic) IBOutlet UITextField* campTermString;
@property (strong, nonatomic) IBOutlet UISwitch* demoModeSwitch;

@end

@implementation EQRStaffPage1VCntrllr

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

    //populate text field with information from user settings
    NSString* currentUrl = [[[NSUserDefaults standardUserDefaults] objectForKey:@"url"] objectForKey:@"url"];
    NSString* currentTerm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"term"] objectForKey:@"term"];
    NSString* currentCampTerm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"campTerm"] objectForKey:@"campTerm"];

    self.termString.text = currentTerm;
    self.urlString.text = currentUrl;
    self.campTermString.text = currentCampTerm;
    
    
}


-(IBAction)urlTextFieldDidChange:(id)sender{
    
    //change user defaults with new string text
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.urlString.text, @"url"
                            , nil];
    
    [defaults setObject:newDic forKey:@"url"];
    [defaults synchronize];
    
}


-(IBAction)termTextFieldDidChange:(id)sender{
    
    //change user defaults with new string text
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.termString.text, @"term"
                            , nil];
    
    [defaults setObject:newDic forKey:@"term"];
    [defaults synchronize];
    
}


-(IBAction)campTermTextFieldDidChange:(id)sender{
    
    //change user defaults with new string text
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.campTermString.text, @"campTerm"
                            , nil];
    
    [defaults setObject:newDic forKey:@"campTerm"];
    [defaults synchronize];
    
}


-(IBAction)demoModeDidChange:(id)sender{
        
    if (self.demoModeSwitch.on){
        
        //set prompt
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        
        //set singleton
        EQRModeManager* modeManager = [EQRModeManager sharedInstance];
        modeManager.isInDemoMode = YES;
        
        
    }else{
        
        //set prompt
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
        
        //set singleton
        EQRModeManager* modeManager = [EQRModeManager sharedInstance];
        modeManager.isInDemoMode = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
