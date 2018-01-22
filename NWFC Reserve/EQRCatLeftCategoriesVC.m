//
//  EQRCatLeftCategoriesVC.m
//  Gear
//
//  Created by Ray Smith on 9/18/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQRCatLeftCategoriesVC.h"
#import "EQRCatLeftEquipTitlesVC.h"
#import "EQRModeManager.h"
#import "EQRWebData.h"
#import "EQREquipCategory.h"
#import "EQRGenericTextEditor.h"
#import "EQRMultiTextEditorVC.h"
#import "EQRGenericPickerVC.h"

@interface EQRCatLeftCategoriesVC () <EQRCatEquipTitleDelegate, EQRMultiTextEditorDelegate>
@property (nonatomic, strong) NSArray *arrayOfCategories;
@property (nonatomic, strong) EQRMultiTextEditorVC *multiTextEditor;
@property (nonatomic, strong) EQRGenericPickerVC *pickerEditor;
@property (nonatomic, weak) EQRCatLeftEquipTitlesVC *titlesVC;
@end

@implementation EQRCatLeftCategoriesVC
@synthesize delegate;

#pragma mark - view methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayOfCategories = @[];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(newCategory:)];
    
    NSArray *rightButtons = @[addButton];
    
    [self.navigationItem setRightBarButtonItems:rightButtons];
}

- (void)viewWillAppear:(BOOL)animated{
    // Populate list
    [self loadCategories];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{

}


#pragma mark - button actions
- (IBAction)newCategory:(id)sender {
    EQRGenericPickerVC *genericPicker = [[EQRGenericPickerVC alloc] initWithNibName:@"EQRGenericPickerVC" bundle:nil];
    [genericPicker initialSetupWithTitle:@"Existing Category" subTitle:@"Select on or create a new one" array:@[@"one", @"two"] selectedValue:nil];
    [genericPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    
    
    [self presentViewController:genericPicker animated:YES completion:^{
        
    }];
    
    self.pickerEditor = genericPicker;

    
//    EQRGenericEditor *genericTextEditor = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
//    [genericTextEditor initalSetupWithTitle:@"Name" subTitle:@"Enter a new category" currentText:@"" keyboard:nil returnMethod:@""];
//
//    EQRGenericTextEditor *genericTextEditor2 = [[EQRGenericTextEditor alloc] initWithNibName:@"EQRGenericTextEditor" bundle:nil];
//    [genericTextEditor2 initalSetupWithTitle:@"Title" subTitle:@"Enter an item name" currentText:@"" keyboard:nil returnMethod:@""];
//
//    self.multiTextEditor = [[EQRMultiTextEditorVC alloc] init];
//    [self.multiTextEditor initialSetupWithReturnCallback:^(NSArray *values){
//        [self writeNewTitle:values[1] category:values[0]];
//    }];
//    [self.multiTextEditor pushNewTextEditor:genericTextEditor];
//    [self.multiTextEditor pushNewTextEditor:genericTextEditor2];
//
//    [self.multiTextEditor presentEditor:self];
}


- (void)writeNewTitle:(NSString *)title category:(NSString *)category {
    EQRWebData *webData = [EQRWebData sharedInstance];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    __block NSString *keyId;
    NSBlockOperation *createNewItem = [NSBlockOperation blockOperationWithBlock:^{
        NSArray *topArray = @[
                              @[@"short_name", title],
                              @[@"category", category]
                              ];
        
        keyId = [webData queryForStringWithLink:@"EQSetNewEquipTitle.php" parameters:topArray];
    }];
    
    NSBlockOperation *renderNewItem = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadCategories];
        });
    }];
    [renderNewItem addDependency:createNewItem];
    
    [queue addOperation:createNewItem];
    [queue addOperation:renderNewItem];
}

#pragma mark - generic editor delegate methods
//- (void)returnWithText:(NSString *)returnText method:(NSString *)returnMethod {
//    self.genericTextEditor.delegate = nil;
//    [self dismissViewControllerAnimated:YES completion:^{
//#   pragma clang diagnostic push
//#   pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [self performSelector:NSSelectorFromString(returnMethod) withObject:returnText];
//#   pragma clang diagnostic pop
//        self.genericTextEditor = nil;
//    }];
//}
//
//- (void)cancelByDismissingVC {
//    self.genericTextEditor.delegate = nil;
//    [self dismissViewControllerAnimated:YES completion:^{
//        self.genericTextEditor = nil;
//    }];
//}

//- (void)continueAddItem:(NSString *)currentText {
//    NSLog(@"========= continueAddItem fires =========, %@", currentText);
//}

#pragma mark - segue methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"catEquipTitles"]) {
//    }
    
    EQRCatLeftEquipTitlesVC * destinationVC = [segue destinationViewController];
    destinationVC.delegate = self;
    destinationVC.selectedCategory = [[(UITableViewCell *)sender textLabel] text];
    self.titlesVC = destinationVC;
}

#pragma mark - EQRCatLeftEquipTitle delegate
- (void)didSelectEquipTitle:(NSDictionary *)selectedEquipTitle {
    [self.delegate didPassEquipTitleThroughCategory:selectedEquipTitle];
}

#pragma mark - pass along to titlesVC
- (void)reloadTitles {
    [self.titlesVC reloadTitles];
}

- (void)reloadTitlesAndSelect:(NSString *)item {
    [self.titlesVC reloadTitlesAndSelect:item];
}

#pragma mark - data methods
- (void)loadCategories {
    
    self.arrayOfCategories = @[];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"allCategories";
    queue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *getEquipCategories = [NSBlockOperation blockOperationWithBlock:^{
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetEquipCategoriesAll.php" parameters:nil class:@"EQREquipCategory" completion:^(NSMutableArray *arrayOfEquipCategories) {
            NSMutableArray *muteArray = [NSMutableArray arrayWithCapacity:1];
            for (EQREquipCategory *cat in arrayOfEquipCategories) {
                [muteArray addObject:cat.category];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.arrayOfCategories = [NSArray arrayWithArray:muteArray];
                [self.tableView reloadData];
            });
        }];
    }];
    
    [queue addOperation:getEquipCategories];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfCategories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [self.arrayOfCategories objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didSelectCategory:[self.arrayOfCategories objectAtIndex:indexPath.row]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    EQRCatLeftEquipTitlesVC * destinationVC = [segue destinationViewController];
//    destinationVC.selectedCategory = [[(UITableViewCell *)sender textLabel] text];
//}


@end
