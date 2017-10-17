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

@interface EQRCatLeftCategoriesVC () <EQRCatEquipTitleDelegate>
@property (nonatomic, strong) NSArray *arrayOfCategories;
@end

@implementation EQRCatLeftCategoriesVC
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayOfCategories = @[];
}

-(void)viewWillAppear:(BOOL)animated{
    // Populate list
    [self loadCategories];
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"catEquipTitles"]) {
//    }
    
    EQRCatLeftEquipTitlesVC * destinationVC = [segue destinationViewController];
    destinationVC.delegate = self;
    destinationVC.selectedCategory = [[(UITableViewCell *)sender textLabel] text];
}

#pragma mark - EQRCatLeftEquipTitle delegate
- (void)didSelectEquipTitle:(NSDictionary *)selectedEquipTitle {
    NSLog(@"EQRCatLeftCategoriesVC fires didSelectEquipTitle: %@", [selectedEquipTitle objectForKey:@"shortName"]);
    [self.delegate didPassEquipTitleThroughCategory:selectedEquipTitle];
}

#pragma mark - data methods

-(void)loadCategories {
    
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
