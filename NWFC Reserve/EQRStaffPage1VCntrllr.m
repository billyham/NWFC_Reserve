//
//  EQRStaffPage1VCntrllr.m
//  NWFC Reserve
//
//  Created by Ray Smith on 1/2/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffPage1VCntrllr.h"
#import "EQRModeManager.h"
#import "EQRGlobals.h"
#import "EQRStaffUserManager.h"
#import "EQRColors.h"


@interface EQRStaffPage1VCntrllr ()

@property (strong, nonatomic) IBOutlet UIView* lockableItemsView;
@property (strong, nonatomic) IBOutlet UITextField* urlString;
@property (strong, nonatomic) IBOutlet UITextField* termString;
@property (strong, nonatomic) IBOutlet UITextField* campTermString;
@property (strong, nonatomic) IBOutlet UISwitch* demoModeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch* kioskModeSwitch;

@property (strong, nonatomic) UIPopoverController* passwordPopover;

@property (strong, nonatomic) EQRGenericTextEditor* genericTextEditor;

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
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    BOOL isInKioskMode = [staffUserManager currentKioskMode];
    if (isInKioskMode){
        self.kioskModeSwitch.on = YES;
        
        [self.urlString setUserInteractionEnabled:NO];
        [self.termString setUserInteractionEnabled:NO];
        [self.campTermString setUserInteractionEnabled:NO];
        [self.demoModeSwitch setUserInteractionEnabled:NO];
        
        //dim lockable items
        self.lockableItemsView.alpha = 0.25;
    }
    
}

#pragma mark - tap inside text field

-(IBAction)tapInAdultTermField:(id)sender{
    
    self.genericTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.genericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericTextEditor.delegate = self;
    [self.genericTextEditor initalSetupWithTitle:@"Enter the current adult term" subTitle:nil currentText:self.termString.text keyboard:nil returnMethod:@"termTextFieldDidChange:"];

    [self presentViewController:self.genericTextEditor animated:YES completion:^{
    }];
}

-(IBAction)tapInCampField:(id)sender{
    
    self.genericTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.genericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericTextEditor.delegate = self;
    [self.genericTextEditor initalSetupWithTitle:@"Enter the current camp term" subTitle:nil currentText:self.campTermString.text keyboard:nil returnMethod:@"campTermTextFieldDidChange:"];
    
    [self presentViewController:self.genericTextEditor animated:YES completion:^{
    }];
}

-(IBAction)tapInDatabaseURL:(id)sender{
    
    self.genericTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.genericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericTextEditor.delegate = self;
    [self.genericTextEditor initalSetupWithTitle:@"Enter the database URL" subTitle:nil currentText:self.urlString.text keyboard:@"UIKeyboardTypeURL" returnMethod:@"urlTextFieldDidChange:"];
    
    [self presentViewController:self.genericTextEditor animated:YES completion:^{
    }];
}


#pragma mark - EQRGenericTextEditor delegate methods

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod{
    
    self.genericTextEditor.delegate = nil;
    
    [self.genericTextEditor dismissViewControllerAnimated:YES completion:^{
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(returnMethod) withObject:returnText];
#pragma clang diagnostic pop
        
        self.genericTextEditor = nil;
    }];
    
}


-(void)urlTextFieldDidChange:(NSString *)returnText{
    
    self.urlString.text = returnText;
    
    //change user defaults with new string text
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.urlString.text, @"url"
                            , nil];
    
    [defaults setObject:newDic forKey:@"url"];
    [defaults synchronize];
    
}


-(void)termTextFieldDidChange:(NSString *)returnText{
    
    self.termString.text = returnText;
    
    //change user defaults with new string text
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.termString.text, @"term"
                            , nil];
    
    [defaults setObject:newDic forKey:@"term"];
    [defaults synchronize];
    
}


-(void)campTermTextFieldDidChange:(NSString *)returnText{
    
    self.campTermString.text = returnText;
    
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
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        
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
    
    //inform other VCs that they need to reload their data
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
}


-(IBAction)kioskModeDidChange:(id)sender{
    
    if (self.kioskModeSwitch.on){
        
        EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* setStringForDefaults;
        
        [staffUserManager goToKioskMode:YES];
        
        [self.urlString setUserInteractionEnabled:NO];
        [self.termString setUserInteractionEnabled:NO];
        [self.campTermString setUserInteractionEnabled:NO];
        [self.demoModeSwitch setUserInteractionEnabled:NO];
        
        //dim lockable items
        self.lockableItemsView.alpha = 0.25;
        
        setStringForDefaults = @"yes";
        
        //change user defaults with new string text
        NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                setStringForDefaults, @"kioskModeIsOn"
                                , nil];
        
        [defaults setObject:newDic forKey:@"kioskModeIsOn"];
        [defaults synchronize];
        
        
        
    }else{
        
        //need password to change back to kiosk off
        
        EQRPasswordEntryVC* passEntry = [[EQRPasswordEntryVC alloc] initWithNibName:@"EQRPasswordEntryVC" bundle:nil];
        passEntry.delegate = self;
        
        UIPopoverController* passPopover = [[UIPopoverController alloc] initWithContentViewController:passEntry];
        self.passwordPopover = passPopover;
        self.passwordPopover.delegate = self;
        [self.passwordPopover setPopoverContentSize:CGSizeMake(320.f, 300.f)];
        
        CGRect thisRect = [self.kioskModeSwitch.superview.superview convertRect:self.kioskModeSwitch.frame fromView:self.kioskModeSwitch.superview];
        
        [self.passwordPopover presentPopoverFromRect:thisRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


#pragma mark - password methods

-(void)passwordEntered:(BOOL)passwordSuccessful{
    
    if (passwordSuccessful){
        
        EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* setStringForDefaults;
        
        [staffUserManager goToKioskMode:NO];
        
        [self.urlString setUserInteractionEnabled:YES];
        [self.termString setUserInteractionEnabled:YES];
        [self.campTermString setUserInteractionEnabled:YES];
        [self.demoModeSwitch setUserInteractionEnabled:YES];
        
        //make lockable items opaque
        self.lockableItemsView.alpha = 1.0;
        
        setStringForDefaults = @"no";
        
        //change user defaults with new string text
        NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                setStringForDefaults, @"kioskModeIsOn"
                                , nil];
        
        [defaults setObject:newDic forKey:@"kioskModeIsOn"];
        [defaults synchronize];
        
        [self.passwordPopover dismissPopoverAnimated:YES];
        self.passwordPopover = nil;
    }
    
}


#pragma mark - popover delegate methods

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    if (popoverController == self.passwordPopover){
        
        self.passwordPopover = nil;
        
        //a failed password entry, should flip kiosk mode back
        [self.kioskModeSwitch setOn:YES animated:YES];
    }
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
