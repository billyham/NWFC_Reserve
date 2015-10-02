//
//  EQRSettings1TableVC.m
//  Gear
//
//  Created by Ray Smith on 4/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRSettings1TableVC.h"
#import "EQRModeManager.h"
#import "EQRGlobals.h"
#import "EQRStaffUserManager.h"
#import "EQRColors.h"
#import "EQRSettingsLeftTableVC.h"

@interface EQRSettings1TableVC ()

//@property (strong, nonatomic) IBOutlet UIView* lockableItemsView;
@property (strong, nonatomic) IBOutlet UILabel* termString;
@property (strong, nonatomic) IBOutlet UILabel* campTermString;
@property (strong, nonatomic) IBOutlet UISwitch* demoModeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch* kioskModeSwitch;

@property (strong, nonatomic) UIPopoverController* passwordPopover;

@property (strong, nonatomic) EQRGenericTextEditor* genericTextEditor;

@end

@implementation EQRSettings1TableVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //populate text field with information from user settings
    NSString* currentTerm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"term"] objectForKey:@"term"];
    NSString* currentCampTerm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"campTerm"] objectForKey:@"campTerm"];
    
    self.termString.text = currentTerm;
    self.campTermString.text = currentCampTerm;
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    BOOL isInKioskMode = [staffUserManager currentKioskMode];
    if (isInKioskMode){
        self.kioskModeSwitch.on = YES;
        
        [self.termString setUserInteractionEnabled:NO];
        [self.campTermString setUserInteractionEnabled:NO];
        [self.demoModeSwitch setUserInteractionEnabled:NO];
        
        //dim lockable items
//        self.lockableItemsView.alpha = 0.25;
    }
    
    //set left side as delegate
    UINavigationController *navCon = [[[self splitViewController] viewControllers] objectAtIndex:0];
    EQRSettingsLeftTableVC *leftTable = (EQRSettingsLeftTableVC *)[navCon topViewController];
    self.delegate = leftTable;
    
    //set background color on cells by looping through all cells
    for (int section = 0; section < [self.tableView numberOfSections]; section++){
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];
            
            //set custom bg color on selection
            EQRColors *colors = [EQRColors sharedInstance];
            UIView *bgColorView = [[UIView alloc] init];
            bgColorView.backgroundColor = [colors.colorDic objectForKey:EQRColorSelectionBlue];
            [cell setSelectedBackgroundView:bgColorView];
        }
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        [UIView setAnimationsEnabled:YES];
        
        [self.demoModeSwitch setOn:YES];
        
    }else{
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
        [UIView setAnimationsEnabled:YES];
        
        [self.demoModeSwitch setOn:NO];
    }
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    
    EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
    BOOL isInKioskMode = [staffUserManager currentKioskMode];
    if (isInKioskMode){
        [self changeUserInteractionAndAlphaForKioskMode:YES];
    }else{
        [self changeUserInteractionAndAlphaForKioskMode:NO];
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
    
    //de-select cell
    NSArray *selectedIndexes = self.tableView.indexPathsForSelectedRows;
    for (NSIndexPath *indexPath in selectedIndexes){
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
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
    
    //this reloads the information in the request view
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheDatabaseSource object:nil];
    
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
    
    //this reloads the information in the request view
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheDatabaseSource object:nil];
    
}


-(IBAction)demoModeDidChange:(id)sender{
    
    if (self.demoModeSwitch.on){
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        [UIView setAnimationsEnabled:YES];
        
        //set singleton
        EQRModeManager* modeManager = [EQRModeManager sharedInstance];
        [modeManager enableDemoMode:YES];
        
        [self.delegate demoModeChanged:YES];
        
    }else{
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
        [UIView setAnimationsEnabled:YES];
        
        //set singleton
        EQRModeManager* modeManager = [EQRModeManager sharedInstance];
        [modeManager enableDemoMode:NO];
        
        [self.delegate demoModeChanged:NO];
    }
    
    //inform other VCs that they need to reload their data
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    //tell app that all info has changed
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheDatabaseSource object:nil];
}


-(IBAction)kioskModeDidChange:(id)sender{
    
    if (self.kioskModeSwitch.on){
        
        EQRStaffUserManager* staffUserManager = [EQRStaffUserManager sharedInstance];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* setStringForDefaults;
        
        [staffUserManager goToKioskMode:YES];
        
        [self changeUserInteractionAndAlphaForKioskMode:YES];
        
        setStringForDefaults = @"yes";
        
        //change user defaults with new string text
        NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                setStringForDefaults, @"kioskModeIsOn"
                                , nil];
        
        [defaults setObject:newDic forKey:@"kioskModeIsOn"];
        [defaults synchronize];
        
        [self.delegate kioskModeChanged:YES];
        
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
        
        [self changeUserInteractionAndAlphaForKioskMode:NO];
        
        setStringForDefaults = @"no";
        
        //change user defaults with new string text
        NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                setStringForDefaults, @"kioskModeIsOn"
                                , nil];
        
        [defaults setObject:newDic forKey:@"kioskModeIsOn"];
        [defaults synchronize];
        
        [self.passwordPopover dismissPopoverAnimated:YES];
        self.passwordPopover = nil;
        
        [self.delegate kioskModeChanged:NO];
    }
    
}

-(void)changeUserInteractionAndAlphaForKioskMode:(BOOL)isInKioskMode{
    
    if (isInKioskMode == YES){
        
        [self.demoModeSwitch setUserInteractionEnabled:NO];
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        UITableViewCell *cell3 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UITableViewCell *cell4 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [cell2 setUserInteractionEnabled:NO];
        cell2.alpha = 0.5;
        [cell3 setUserInteractionEnabled:NO];
        cell3.alpha = 0.5;
        [cell4 setUserInteractionEnabled:NO];
        cell4.alpha = 0.5;
        
    }else{
        
        [self.demoModeSwitch setUserInteractionEnabled:YES];
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        UITableViewCell *cell3 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UITableViewCell *cell4 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [cell2 setUserInteractionEnabled:YES];
        cell2.alpha = 1.0;
        [cell3 setUserInteractionEnabled:YES];
        cell3.alpha = 1.0;
        [cell4 setUserInteractionEnabled:YES];
        cell4.alpha = 1.0;
        
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

#pragma mark - table view delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1){
        
        if (indexPath.row == 0){
            
            [self tapInAdultTermField:nil];
            
        }else if (indexPath.row == 1){
            
            [self tapInCampField:nil];
            
        }
        
    }
    
    if (indexPath.section == 2){  //Email
        
        if (indexPath.row == 0){   //Email Signature
            
            
        }
    }
}





//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
