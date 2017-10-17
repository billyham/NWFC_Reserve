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

@interface EQRCatLeftEquipTitlesVC ()
@property (nonatomic, strong) NSArray *arrayOfTitles;
@end

@implementation EQRCatLeftEquipTitlesVC
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayOfTitles = @[];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadTitles];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//    return self.arrayOfTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTitles.count;
//    return 0;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}


@end
