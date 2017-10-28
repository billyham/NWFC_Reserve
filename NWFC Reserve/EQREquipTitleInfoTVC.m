//
//  EQREquipTitleInfoTVC.m
//  Gear
//
//  Created by Ray Smith on 10/19/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQREquipTitleInfoTVC.h"

@interface EQREquipTitleInfoTVC ()

@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *longName;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *subcategory;
@property (strong, nonatomic) NSString *scheduleGrouping;

@property (weak, nonatomic) IBOutlet UILabel *shortNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *longNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *subcategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleGroupingLabel;

@end

@implementation EQREquipTitleInfoTVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self renderText];
    [super viewWillAppear:animated];
}


- (void)setText:(NSDictionary *)properties {
    self.shortName = properties[@"shortName"];
    self.longName = properties[@"name"];
    self.category = properties[@"category"];
    self.subcategory = properties[@"subcategory"];
    self.scheduleGrouping = properties[@"scheduleGrouping"];
    
    [self renderText];
}


- (void)renderText {
    self.shortNameLabel.text = self.shortName;
    self.longNameLabel.text = self.longName;
    self.categoryLabel.text = self.category;
    self.subcategoryLabel.text = self.subcategory;
    self.scheduleGroupingLabel.text = self.scheduleGrouping;
}

#pragma mark - tableview delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0:
            [self.delegate propertySelection:@"short_name" value:self.shortName];
            break;
        case 1:
            [self.delegate propertySelection:@"name" value:self.longName];
            break;
        case 2:
            [self.delegate propertySelection:@"category" value:self.category];
            break;
        case 3:
            [self.delegate propertySelection:@"subcategory" value:self.subcategory];
            break;
        case 4:
            [self.delegate propertySelection:@"schedule_grouping" value:self.scheduleGrouping];
            break;
        default:
            break;
    }
}



#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
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
