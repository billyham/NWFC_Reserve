//
//  EQREquipTitlePricesTVC.m
//  Gear
//
//  Created by Ray Smith on 10/19/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQREquipTitlePricesTVC.h"

@interface EQREquipTitlePricesTVC ()

@property (strong, nonatomic) NSString *commercial;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *student;
@property (strong, nonatomic) NSString *staff;
@property (strong, nonatomic) NSString *faculty;

@property (weak, nonatomic) IBOutlet UILabel *commercialLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentLabel;
@property (weak, nonatomic) IBOutlet UILabel *staffLabel;
@property (weak, nonatomic) IBOutlet UILabel *facultyLabel;

@end

@implementation EQREquipTitlePricesTVC
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
    
    self.commercial = properties[@"commercial"];
    self.artist = properties[@"artist"];
    self.student = properties[@"student"];
    self.staff = properties[@"staff"];
    self.faculty = properties[@"faculty"];
    
    [self renderText];
}

- (void)renderText {
    self.commercialLabel.text = self.commercial;
    self.artistLabel.text = self.artist;
    self.studentLabel.text = self.student;
    self.staffLabel.text = self.staff;
    self.facultyLabel.text = self.faculty;
}

#pragma mark - tableview delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self.delegate propertySelection:@"price_commercial" value:self.commercial];
            break;
        case 1:
            [self.delegate propertySelection:@"price_artist" value:self.artist];
            break;
        case 2:
            [self.delegate propertySelection:@"price_student" value:self.student];
            break;
        case 3:
            [self.delegate propertySelection:@"price_staff" value:self.staff];
            break;
        case 4:
            [self.delegate propertySelection:@"price_nonprofit" value:self.faculty];
            break;
        default:
            break;
    }
    
    [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
}

#pragma mark - Table view data source

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

#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
