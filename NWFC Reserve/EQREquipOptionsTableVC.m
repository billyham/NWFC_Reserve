//
//  EQREquipOptionsTableVC.m
//  Gear
//
//  Created by Ray Smith on 12/8/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREquipOptionsTableVC.h"

@interface EQREquipOptionsTableVC ()

@property (strong, nonatomic) NSArray* arrayOfOptions;

@end

@implementation EQREquipOptionsTableVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //cell reuse identified
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    //instantiate array
    NSArray* arrayForNow = [NSArray arrayWithObjects:@"Show All Items", @"Allow Same Day Turnaround", @"Allow Schedule Conflicts", nil];
    
    self.arrayOfOptions = arrayForNow;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrayOfOptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.arrayOfOptions objectAtIndex:indexPath.row];
    
    //show check mark if appropriate
    if (indexPath.row == 0){
        
        if (self.showAllEquipFlag == YES){
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else if (indexPath.row == 1){
        
        //____!!!!!!  AUGGHHHH THIS IS DYSFUNCTIONAL BECAUSE THE DATABASE STORE REQUEST TIME SEPARATE FROM REQEUST DATE. BOOO!!!  !!!!_____
        [cell setUserInteractionEnabled:NO];
        cell.textLabel.alpha = 0.3f;
        
        if (self.allowSameDayFlag == YES){
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else if (indexPath.row == 2){
        
        if (self.allowConflictFlag == YES){
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    
    
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

    //show check mark if appropriate
    if (indexPath.row == 0){
        
        if (self.showAllEquipFlag == YES){
            
            self.showAllEquipFlag = NO;
            
        }else{
            
            self.showAllEquipFlag = YES;
        }
        
    }else if (indexPath.row == 1){
        
        if (self.allowSameDayFlag == YES){
            
            self.allowSameDayFlag = NO;
            
        }else{
            
            self.allowSameDayFlag = YES;
        }
        
    }else if (indexPath.row == 2){
        
        if (self.allowConflictFlag == YES){
            
            self.allowConflictFlag = NO;
            
        }else{
            
            self.allowConflictFlag = YES;
        }
    }

    //tell delegate what the score is (maybe pass a bitMask????)
    [self.delegate optionsSelectionMade];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
