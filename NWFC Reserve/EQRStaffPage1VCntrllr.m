//
//  EQRStaffPage1VCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffPage1VCntrllr.h"

@interface EQRStaffPage1VCntrllr ()

@property (strong, nonatomic) IBOutlet UITextField* urlString;
@property (strong, nonatomic) IBOutlet UITextField* termString;

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

    self.termString.text = currentTerm;
    self.urlString.text = currentUrl;
    
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
