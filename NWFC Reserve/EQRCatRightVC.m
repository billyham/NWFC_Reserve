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
//#import "EQRGenericTextEditor.h"

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
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}


#pragma mark - split view delegate methods
-(BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(id)sender {
    return NO;
}

-(void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    
}

-(void)collapseSecondaryViewController:(UIViewController *)secondaryViewController forSplitViewController:(UISplitViewController *)splitViewController {
    
}


#pragma mark - memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
