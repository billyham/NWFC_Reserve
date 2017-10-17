//
//  EQREquipTitleDetailTableVC.m
//  Gear
//
//  Created by Ray Smith on 10/1/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQREquipTitleDetailTableVC.h"
#import "EQRWebData.h"
#import "EQREquipItem.h"

@interface EQREquipTitleDetailTableVC ()
@property (strong, nonatomic) NSString *equipTitleKeyId;
@property (strong, nonatomic) EQREquipItem *equipTitle;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *subcategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleGroupingLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceCommercialLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceStudentLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceStaffLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceNonprofitLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceDepositLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLongLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionShortLabel;

@property (weak, nonatomic) IBOutlet UISwitch *hideFromPublic;
@property (weak, nonatomic) IBOutlet UISwitch *hideFromStudent;

@end

@implementation EQREquipTitleDetailTableVC

#pragma mark - launch with title key
- (void)launchWithKey:(NSString *)keyId {
    self.equipTitleKeyId = keyId;
    self.countLabel.text = keyId;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"equipDetail";
    queue.maxConcurrentOperationCount = 1;
    
    __block EQREquipItem *currentItem;
    NSBlockOperation *getEquipTitle = [NSBlockOperation blockOperationWithBlock:^{
        EQRWebData *webData = [EQRWebData sharedInstance];
        NSArray *topArray = @[ @[@"key_id", self.equipTitleKeyId] ];
        [webData queryWithLink:@"EQGetEquipTitleWithKey.php" parameters:topArray class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
            
            if ([muteArray count] < 1) {
                NSLog(@"EQREquipTitleDetailTableVC > lauch, failed to retrieve equipTitleItem");
                return;
            }
            
            currentItem = [muteArray objectAtIndex:0];
        }];
        
    }];
    
    NSBlockOperation *showEquipItem = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.equipTitle = currentItem;
            [self renderInfo:self.equipTitle];
        });
    }];
    [showEquipItem addDependency:getEquipTitle];
    
    [queue addOperation:getEquipTitle];
    [queue addOperation:showEquipItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.equipTitle) {
        [self renderInfo:self.equipTitle];
    }
}

- (void)renderInfo:(EQREquipItem *)equipItem {
    self.nameLabel.text = equipItem.name;
    self.shortNameLabel.text = equipItem.short_name;
    self.categoryLabel.text = equipItem.category;
    self.subcategoryLabel.text = equipItem.subcategory;
    self.scheduleGroupingLabel.text = equipItem.schedule_grouping;
    
    self.priceCommercialLabel.text = equipItem.price_commercial;
    self.priceArtistLabel.text = equipItem.price_artist;
    self.priceStudentLabel.text = equipItem.price_student;
    self.priceStaffLabel.text = equipItem.price_staff;
    self.priceNonprofitLabel.text = equipItem.price_nonprofit;
    self.priceDepositLabel.text = equipItem.price_deposit;
    
    self.descriptionLongLabel.text = equipItem.description_long;
    self.descriptionShortLabel.text = equipItem.description_short;
    
    BOOL hideFromPublic = [equipItem.hide_from_public boolValue];
    [self.hideFromPublic setOn:hideFromPublic animated:NO];
    
    BOOL hideFromStudent = [equipItem.hide_from_student boolValue];
    [self.hideFromStudent setOn:hideFromStudent animated:NO];
    
    NSLog(@"description_long: %@", equipItem.description_long);
    NSLog(@"description_short: %@", equipItem.description_short);
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
    // Dispose of any resources that can be recreated.
}

@end
