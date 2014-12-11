//
//  EQRDistIDPickerTableVC.m
//  Gear
//
//  Created by Ray Smith on 12/10/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRDistIDPickerTableVC.h"
#import "EQRScheduleRequestManager.h"
#import "EQREquipUniqueItem.h"

@interface EQRDistIDPickerTableVC ()

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
@property (strong, nonatomic) NSArray* arrayOfEquipUniques;

@end

@implementation EQRDistIDPickerTableVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:([UITableViewCell class]) forCellReuseIdentifier:@"Cell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)initialSetupWithIndexPath:(NSIndexPath*)indexPath equipTitleKey:(NSString*)equipTitleKey scheduleItem:(EQRScheduleRequestItem*)scheduleItem{
    
    //____set up private request manager______
    if (!self.privateRequestManager){
        
        self.privateRequestManager = [[EQRScheduleRequestManager alloc] init];
    }
    
    //set the request as ivar in requestManager
    self.privateRequestManager.request = scheduleItem;
    
    //two important methods that initiate requestManager ivar arrays
    [self.privateRequestManager resetEquipListAndAvailableQuantites];
    [self.privateRequestManager retrieveAllEquipUniqueItems];
    
    
    //now activate method to get just this title item's avaliable dist ids
    self.arrayOfEquipUniques = [self.privateRequestManager retrieveAvailableEquipUniquesForTitleKey:equipTitleKey];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrayOfEquipUniques count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [(EQREquipUniqueItem*)[self.arrayOfEquipUniques objectAtIndex:indexPath.row] name],
                           [(EQREquipUniqueItem*)[self.arrayOfEquipUniques objectAtIndex:indexPath.row] distinquishing_id]];
    
    return cell;
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate distIDSelectionMade];
    
    self.privateRequestManager = nil;
    
}


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
