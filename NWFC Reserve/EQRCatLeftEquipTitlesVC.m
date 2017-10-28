//
//  EQRCatLeftEquipTitlesVC.m
//  Gear
//
//  Created by Ray Smith on 9/18/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRCatLeftEquipTitlesVC.h"
#import "EQRModeManager.h"
#import "EQRWebData.h"
#import "EQREquipItem.h"
#import "EQRGenericTextEditor.h"

@interface EQRCatLeftEquipTitlesVC () <EQRGenericEditorDelegate>
@property (nonatomic, strong) NSArray *arrayOfTitles;
@property (nonatomic, strong) EQRGenericTextEditor *genericTextEditor;
@end

@implementation EQRCatLeftEquipTitlesVC
@synthesize delegate;

#pragma mark - view methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayOfTitles = @[];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(newTitleItem:)];
    
    NSArray *rightButtons = @[addButton];
    
    [self.navigationItem setRightBarButtonItems:rightButtons];
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadTitles];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

#pragma mark - button actions
- (IBAction)newTitleItem:(id)sender {
    self.genericTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
    self.genericTextEditor.modalPresentationStyle = UIModalPresentationFormSheet;
    self.genericTextEditor.delegate = self;
    NSString *subtitle = [NSString stringWithFormat:@"Enter a new item in the %@ category", self.selectedCategory];
    [self.genericTextEditor initalSetupWithTitle:@"Name" subTitle:subtitle currentText:@"" keyboard:nil returnMethod:@"continueAddItem:"];
    [self presentViewController:self.genericTextEditor animated:YES completion:^{
        
    }];
}

#pragma mark - passed from detail view
- (void)reloadTitles {
    [self loadTitles];
}

- (void)reloadTitlesAndSelect:(NSString *)item {
    [self loadTitles];
}

#pragma mark - generic editor delegate methods
- (void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod {
    
    self.genericTextEditor.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:^{
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(returnMethod) withObject:returnText];
#   pragma clang diagnostic pop
        self.genericTextEditor = nil;
    }];
}

- (void)cancelByDismissingVC {
    self.genericTextEditor.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        self.genericTextEditor = nil;
    }];
}

- (void)continueAddItem:(NSString *)currentText {
    EQRWebData *webData = [EQRWebData sharedInstance];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    __block NSString *keyId;
    NSBlockOperation *createNewItem = [NSBlockOperation blockOperationWithBlock:^{
        NSArray *topArray = @[
                              @[@"short_name", currentText],
                              @[@"category", self.selectedCategory]
                              ];
        
        keyId = [webData queryForStringWithLink:@"EQSetNewEquipTitle.php" parameters:topArray];
    }];
    
    NSBlockOperation *renderNewItem = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadTitles];
        });
    }];
    [renderNewItem addDependency:createNewItem];
    
    [queue addOperation:createNewItem];
    [queue addOperation:renderNewItem];
}

#pragma mark - data methods

- (void)loadTitles{
    
    self.arrayOfTitles = @[];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"titlesByCategory";
    queue.maxConcurrentOperationCount = 1;
    
    NSArray *topArray = @[ @[@"category", self.selectedCategory] ];
    
    NSBlockOperation *getEquipTitles = [NSBlockOperation blockOperationWithBlock:^{
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetEquipTitlesWithCategory.php" parameters:topArray class:@"EQREquipItem" completion:^(NSMutableArray *arrayOfEquipTitles) {
            NSMutableArray *muteArray = [NSMutableArray arrayWithCapacity:1];
            for (EQREquipItem *equipTitleItem in arrayOfEquipTitles) {
                [muteArray addObject:@{@"shortName": equipTitleItem.short_name, @"keyId": equipTitleItem.key_id}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.arrayOfTitles = [NSArray arrayWithArray:muteArray];
                [self.tableView reloadData];
            });
        }];
    }];
    
    [queue addOperation:getEquipTitles];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTitles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipTitlesCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [[self.arrayOfTitles objectAtIndex:indexPath.row] objectForKey:@"shortName"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate didSelectEquipTitle:[self.arrayOfTitles objectAtIndex:indexPath.row]];
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [self.arrayOfTitles objectAtIndex:section];
//}

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


//#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

#pragma mark - memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
