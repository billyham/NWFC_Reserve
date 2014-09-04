//
//  EQRInboxLeftTableVC.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/27/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRInboxLeftTableVC.h"
#import "EQRGlobals.h"
#import "EQRWebData.h"
#import "EQRScheduleRequestItem.h"


@interface EQRInboxLeftTableVC ()

@property (strong, nonatomic) NSArray* arrayOfRequests;


@end

@implementation EQRInboxLeftTableVC

- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    [self renewTheView];
    
    [super viewWillAppear:animated];
}


-(void)renewTheView{
    
    //load the local array ONLY with upcoming unconfirmed requests
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSMutableArray* tempMuteArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = thisLocale;
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"request_date_begin", [dateFormatter stringFromDate:[NSDate date]], nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    [webData queryWithLink:@"EQGetScheduleRequestsUpcomingUnconfirmed.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
        
        for (id object in muteArray){
            
            [tempMuteArray addObject: object];
        }
    }];
    
    
    //______*****   sort on date   ******______
    
    self.arrayOfRequests = [NSArray arrayWithArray:tempMuteArray];
    
    [self.tableView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.arrayOfRequests count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //get date in format
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = thisLocale;
    dateFormatter.dateFormat = @"EEEE, MMM d";
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.locale = thisLocale;
    timeFormatter.dateFormat = @"h:mm aaa";
    
    NSDate* beginDate = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] request_date_begin];
    NSDate* beginTime = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] request_time_begin];
    NSString* dateString = [dateFormatter stringFromDate:beginDate];
    NSString* timeString = [timeFormatter stringFromDate:beginTime];
    
    
    //name
    NSString* nameString = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] contact_name];
    
    //string for title
    NSString* titleString = [NSString stringWithFormat:@"%@\n %@, %@", nameString, dateString, timeString];

    //assign title to cell
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.text = titleString;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - table delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

}



#pragma mark - InboxRightDelegate methods

-(void)selectedRequest:(EQRScheduleRequestItem *)request{
    
    NSLog(@"selectedRequest method did fire");

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"this is the segue: %@", segue.identifier);
    

}



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



@end
