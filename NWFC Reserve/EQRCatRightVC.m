//
//  EQRCatalogRightVC.m
//  Gear
//
//  Created by Ray Smith on 9/14/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRCatRightVC.h"
#import "EQRModeManager.h"
#import "EQRCatLeftEquipTitlesVC.h"

@interface EQRCatRightVC () <UISplitViewControllerDelegate>

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
    
    [super viewWillAppear:animated];
}

#pragma mark - CatLeftEquipTitleDelegate methods
//-(void)didSelectEquipTitle:(NSString *)selectedEquipTitle {
//    NSLog(@"catRightVC says equip title is tapped: %@", selectedEquipTitle);
//
//    UIStoryboard *equipTitleDetailStoryboard = [UIStoryboard storyboardWithName:@"EquipTitleDetail" bundle:nil];
//    UITableViewController *tableView = [equipTitleDetailStoryboard instantiateViewControllerWithIdentifier:@"EquipTitleDetail"];
//
//    [self.navigationController pushViewController:tableView animated:YES];
//}

#pragma mark - split view delegate methods

-(BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(id)sender {
    

    return NO;
}

-(void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
//    NSLog(@"displayMode is: %ld", (long)displayMode);
    
}

-(void)collapseSecondaryViewController:(UIViewController *)secondaryViewController forSplitViewController:(UISplitViewController *)splitViewController {
    
}

#pragma mark - memory warning

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
