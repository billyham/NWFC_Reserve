//
//  EQInboxLeftTopVC.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRInboxLeftTopVC.h"
#import "EQRInboxLeftTableVC.h"
#import "EQRModeManager.h"
#import "EQRColors.h"

@interface EQRInboxLeftTopVC ()

@property (strong, nonatomic) NSString* segueSelectionType;
@property NSInteger indexPathSection;
@property NSInteger indexPathRow;

@end

@implementation EQRInboxLeftTopVC

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        _indexPathSection = 0;
        _indexPathRow = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //immediately go to the needs confirmation option when first loading
//    [self performSegueWithIdentifier:@"NeedsConfirmation" sender:self];
    [self performSegueWithIdentifier:@"NeedsConfirmation" sender:self];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Initial selection
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}


-(void)viewWillAppear:(BOOL)animated{
    
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
    
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated{
    

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    
//    NSLog(@"this is the seque: %@", segue.identifier);
//}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.indexPathSection == indexPath.section && self.indexPathRow == indexPath.row){
        // Didn't change selection
        return;
    }
    
    self.indexPathSection = indexPath.section;
    self.indexPathRow = indexPath.row;
    
    // Send message to InboxRightVC to remove an existing request detail view
    [(EQRInboxRightVC*) [[(UINavigationController*) [self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] renewTheViewWithRequest:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"NeedsConfirmation"]){
        
        self.segueSelectionType = @"NeedsConfirmation";
    }
    
    if ([segue.identifier isEqualToString:@"PastDue"]){
        
        self.segueSelectionType = @"PastDue";
    }
    
    if ([segue.identifier isEqualToString:@"AllRequestsByName"]){
        
        self.segueSelectionType = @"AllRequestsByName";
    }
    
    if ([segue.identifier isEqualToString:@"AllRequestsByClassTitle"]){
        
        self.segueSelectionType = @"AllRequestsByClassTitle";
    }
    
    if ([segue.identifier isEqualToString:@"pickupDateRange"]){
        
        self.segueSelectionType = @"pickupDateRange";
        
        //VC getting pushed is NOT EQRInboxLeftTableVC
        return;
    }
    
    //assign this class as the delegate for the presented VC
    EQRInboxLeftTableVC* viewController = [segue destinationViewController];
    
    viewController.delegateForLeftSide = self;
    
}



#pragma mark - delegate methods

-(NSString*)selectedInboxOrArchive{
    
    return self.segueSelectionType;
}




//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - memory warning


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
