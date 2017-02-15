//
//  EQRSettings2TableVC.m
//  Gear
//
//  Created by Ray Smith on 4/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRSettings2TableVC.h"
#import "EQRStaffUserManager.h"
#import "EQRModeManager.h"
#import "EQRColors.h"
#import "EQRGlobals.h"

@interface EQRSettings2TableVC () <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel* urlString;
@property (strong, nonatomic) IBOutlet UILabel *backupUrlString;
@property (strong, nonatomic) IBOutlet UISwitch *useBackupSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *useCloudKitSwitch;
@property (strong, nonatomic) EQRGenericTextEditor* genericTextEditor;
@property (strong, nonatomic) IBOutlet UILabel *versionNumber;
@property (strong, nonatomic) IBOutlet UILabel *bundleNumber;

@end

@implementation EQRSettings2TableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //populate text field with information from user settings
    NSString* currentUrl = [[[NSUserDefaults standardUserDefaults] objectForKey:@"url"] objectForKey:@"url"];
    NSString *currentBackupUrl = [[[NSUserDefaults standardUserDefaults] objectForKey:@"backupUrl"] objectForKey:@"backupUrl"];
    self.urlString.text = currentUrl;
    self.backupUrlString.text = currentBackupUrl;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.bundleNumber.text = [infoDictionary objectForKey:@"CFBundleVersion"];
    self.versionNumber.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    //hide the back button
    self.navigationItem.hidesBackButton = YES;
    
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
//     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    [self updateNavItemPromptWithDemoModeState];
    
    //set useBackup switch
    NSString *useBackup = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useBackup"] objectForKey:@"useBackup"];
    if ([useBackup isEqualToString:@"yes"]){
        [self.useBackupSwitch setOn:YES];
    }else{
        [self.useBackupSwitch setOn:NO];
    }
    
    //set useCloudKit switch
    NSString* useCloudKit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"useCloudKit"] objectForKey:@"useCloudKit"];
    if ([useCloudKit isEqualToString:@"yes"]){
        [self.useCloudKitSwitch setOn:YES];
    }else{
        [self.useCloudKitSwitch setOn:NO];
    }
    
    [super viewWillAppear:animated];
}


-(void)updateNavItemPromptWithDemoModeState{
    
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
    
}


-(IBAction)tapInDatabaseURL:(id)sender{
    
    self.genericTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.genericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericTextEditor.delegate = self;
    [self.genericTextEditor initalSetupWithTitle:@"Enter the database URL" subTitle:nil currentText:self.urlString.text keyboard:@"UIKeyboardTypeURL" returnMethod:@"urlTextFieldDidChange:"];
    
    [self presentViewController:self.genericTextEditor animated:YES completion:^{
    }];
}

-(IBAction)tapInBackupURL:(id)sender{
    
    self.genericTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.genericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericTextEditor.delegate = self;
    [self.genericTextEditor initalSetupWithTitle:@"Enter the backup database URL" subTitle:nil currentText:self.backupUrlString.text keyboard:@"UIKeyboardTypeURL" returnMethod:@"backupUrlTextFieldDidChange:"];
    
    [self presentViewController:self.genericTextEditor animated:YES completion:^{
    }];
    
    
}

-(IBAction)tapInShowPDF:(id)sender{
    
//    NSLog(@"viewPDF fires");
    
//    NSString *urlString = [[self applicationDocumentDirectory] stringByAppendingPathComponent:@"/testFile"];
//    NSURL *myUrl = [[NSURL alloc] initFileURLWithPath:urlString];
    
    
    NSURL *baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file:%@",[self applicationCacheDirectory]]];
    NSURL *url = [NSURL URLWithString:@"Caches/testFile.pdf" relativeToURL:baseUrl];
    NSURL *absUrl = [url absoluteURL];
    
//    NSLog(@"this is the url: %@", absUrl);
    
    NSError *error;
    if ([absUrl checkResourceIsReachableAndReturnError:&error]){
//        NSLog(@"yes, url is good");
    }else{
//        NSLog(@"no, url is BAD");
    }
    
    
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:absUrl];
    //    self.documentController = documentController;
    documentController.delegate = self;
    
    [documentController presentPreviewAnimated:YES];
//    NSLog(@"says this about presenting the documentController: %u", presentBool);
    
    // ___ This presents an action sheet, which isn't really all the helpful ___
    //    [controller presentOptionsMenuFromRect:[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] frame]     inView:self.view animated:YES];
}

-(IBAction)tapInShowDocumentsFolderContents:(id)sender{
    
    // For now, just list the contents of the folder
    
    NSString *docPath = [NSString stringWithFormat:@"file:%@",[self applicationDocumentDirectory]];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:NULL];
    
//    NSLog(@"count of directoryContent: %lu", (unsigned long)[directoryContent count]);
//    NSLog(@"path: %@", docPath);
    
    [directoryContent enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        NSLog(@"File %lu: %@", (unsigned long)idx, [directoryContent objectAtIndex:idx]);
    }];
    
    NSString *cachePath = [NSString stringWithFormat:@"file:%@", [self applicationCacheDirectory]];
    NSArray *cacheContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:NULL];
    
//    NSLog(@"count of cacheContent: %lu", (unsigned long)[cacheContent count]);
    [cacheContent enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        NSLog(@"Cache file: %lu: %@", (unsigned long)idx, [cacheContent objectAtIndex:idx]);
    }];
    
}

- (NSString*)applicationCacheDirectory {
    
    //Returns the path to the application's documents directory.
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSString*)applicationDocumentDirectory {
    
    //Returns the path to the application's documents directory.
    
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//    return basePath;
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return documentsDirectory;

}

#pragma mark - UIDocumentationInteractionControllerDelegate method

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    
    //    NSLog(@"documentInteractionControllerViewControllerForPreview fires");
    
    // ___ This presents an action sheet, but it's unresponsive... ___
//    [controller presentOptionsMenuFromRect:[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] frame]     inView:self.view animated:YES];
    
    return  [self navigationController];

}

#pragma mark - EQRGenericTextEditor delegate methods

//a delegate method
-(void)cancelByDismissingVC;{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        //de-select cell
        NSArray *selectedIndexes = self.tableView.indexPathsForSelectedRows;
        for (NSIndexPath *indexPath in selectedIndexes){
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }];
}

-(void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod{
    
    self.genericTextEditor.delegate = nil;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
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

-(void)backupUrlTextFieldDidChange:(NSString *)returnText{
    
    self.backupUrlString.text = returnText;
    
    //change user defaults with new string text
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.backupUrlString.text, @"backupUrl"
                            , nil];
    
    [defaults setObject:newDic forKey:@"backupUrl"];
    [defaults synchronize];
}


-(IBAction)useBackupDidChange:(id)sender{
    
    NSString* setStringForDefaults;
    
    if (self.useBackupSwitch.on){
        setStringForDefaults = @"yes";
    }else{
        setStringForDefaults = @"no";
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //change user defaults with new string text
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            setStringForDefaults, @"useBackup"
                            , nil];
    
    [defaults setObject:newDic forKey:@"useBackup"];
    [defaults synchronize];
    
    //inform other VCs that they need to reload their data
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    //this informs reqeust view to reload classes and contacts (among other things???)
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheDatabaseSource object:nil];
    
}

-(IBAction)cloudKitDidChange:(id)sender{
    
    NSString* setStringForDefaults;
    
    if (self.useCloudKitSwitch.on){
        setStringForDefaults = @"yes";
    }else{
        setStringForDefaults = @"no";
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //change user defaults with new string text
    NSDictionary* newDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            setStringForDefaults, @"useCloudKit"
                            , nil];
    
    [defaults setObject:newDic forKey:@"useCloudKit"];
    [defaults synchronize];
    
    //inform other VCs that they need to reload their data
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheSchedule object:nil];
    //this informs reqeust view to reload classes and contacts (among other things???)
    [[NSNotificationCenter defaultCenter] postNotificationName:EQRAChangeWasMadeToTheDatabaseSource object:nil];
}

#pragma mark - table view delegate methods


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.section == 1){
        
        if (indexPath.row == 0){
            
            [self tapInDatabaseURL:nil];
            
        }else if (indexPath.row == 1){
            
            [self tapInBackupURL:nil];
        }
    }
    
    if (indexPath.section == 2){
        
        if (indexPath.row == 0){
            
            [self tapInShowPDF:nil];
            
        } else if(indexPath.row == 1){
            
            [self tapInShowDocumentsFolderContents:nil];
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

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
