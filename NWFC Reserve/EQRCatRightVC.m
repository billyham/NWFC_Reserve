//
//  EQRCatalogRightVC.m
//  Gear
//
//  Created by Ray Smith on 9/14/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRCatRightVC.h"
#import "EQRModeManager.h"

@interface EQRCatRightVC ()

@end

@implementation EQRCatRightVC

-(void)awakeFromNib{
    
    [super awakeFromNib];
    [self.splitViewController setDelegate:self];
//    [self.navigationItem setLeftBarButtonItem:self.splitViewController.displayModeButtonItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // UIBar Buttons
    // Create fixed spaces
//    UIBarButtonItem *twentySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
//    twentySpace.width = 20;
//    UIBarButtonItem *thirtySpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
//    thirtySpace.width = 30;
    
    // Right buttons
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    // Update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        // Set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"DEMO MODE";
        
        // Set colors of navigation bar and item
        [modeManager alterNavigationBar:self.navigationController.navigationBar navigationItem:self.navigationItem isInDemo:YES];
        
        [UIView setAnimationsEnabled:YES];
        
    }else{
        
        // Set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        // Set colors of navigation bar and item
        [modeManager alterNavigationBar:self.navigationController.navigationBar navigationItem:self.navigationItem isInDemo:NO];
        
        [UIView setAnimationsEnabled:YES];
    }
    [super viewWillAppear:animated];
    
    UIStoryboard *equipTitleDetailStoryboard = [UIStoryboard storyboardWithName:@"EquipTitleDetail" bundle:nil];
    UITableViewController *tableView = [equipTitleDetailStoryboard instantiateViewControllerWithIdentifier:@"EquipTitleDetail"];
    
    [self.navigationController pushViewController:tableView animated:YES];
}

#pragma mark - split view delegate methods

-(void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
//    NSLog(@"displayMode is: %ld", (long)displayMode);
    
}

-(void)collapseSecondaryViewController:(UIViewController *)secondaryViewController forSplitViewController:(UISplitViewController *)splitViewController {
    
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

@end
