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
#import "EQRModeManager.h"


@interface EQRInboxLeftTableVC ()

@property (strong, nonatomic) NSArray* arrayOfRequests;
@property (strong, nonatomic) NSArray* searchResultArrayOfRequests;
@property (strong, nonatomic) EQRScheduleRequestItem* chosenRequest;

@end

@implementation EQRInboxLeftTableVC

@synthesize delegateForLeftSide;



- (id)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //this didn't help...
    //register cells
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    
}


- (void)viewWillAppear:(BOOL)animated{
    
    [self renewTheView];
    
    
    //update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        
    }else{
        
        //set prompt
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
    }
    
    
    
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated{
    
    
}


-(void)renewTheView{
    
    //load the local array ONLY with upcoming unconfirmed requests
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSMutableArray* tempMuteArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = thisLocale;
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    //need to subtract a day off of the date (strange)
    NSDate* adjustedDate = [[NSDate date] dateByAddingTimeInterval:-86400]; //86400 seconds is one day
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"request_date_begin", [dateFormatter stringFromDate:adjustedDate], nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    
    //_________determine which selection was made from top VC (Inbox or Archive)
    NSString* selectionType = [delegateForLeftSide selectedInboxOrArchive];
    
    //get only needs confirmation
    if ([selectionType isEqualToString:@"NeedsConfirmation"]){
        
        [webData queryWithLink:@"EQGetScheduleRequestsUpcomingUnconfirmed.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            
            for (id object in muteArray){
                
                [tempMuteArray addObject: object];
            }
        }];
        
        //get ALL requests
    }else if ([selectionType isEqualToString:@"AllRequests"]){
        
        //set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        //populate array
        [webData queryWithLink:@"EQGetScheduleRequestsAll.php" parameters:nil class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            
            for (id object in muteArray){
                
                [tempMuteArray addObject: object];
            }
        }];
        
        //error handling
    }else{
        
        //error handling when failed to create delegate or idenfity the segue
    }
    
    
    
    
    //______*****   sort on date   ******______
    //alphabatize the list of unique items
    NSArray* tempMuteArrayAlpha = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        
        //__1.___________SORT BASED ON PICK UP DATE AND TIME_______________
        //compile date and time
//        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//        NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//        dateFormatter.locale = thisLocale;
//        dateFormatter.dateFormat = @"yyyy-MM-dd";
//        
//        NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
//        timeFormatter.locale = thisLocale;
//        timeFormatter.dateFormat = @"HH:mm:ss";
//        
//        //convert dates and times to timestamp strings
//        NSString* dateAsString1 = [NSString stringWithFormat:@"%@ %@",
//                                   [dateFormatter stringFromDate:[(EQRScheduleRequestItem*)obj1 request_date_begin]],
//                                    [timeFormatter stringFromDate:[(EQRScheduleRequestItem*)obj1 request_time_begin]]];
//        NSString* dateAsString2 = [NSString stringWithFormat:@"%@ %@",
//                                   [dateFormatter stringFromDate:[(EQRScheduleRequestItem*)obj2 request_date_begin]],
//                                   [timeFormatter stringFromDate:[(EQRScheduleRequestItem*)obj2 request_time_begin]]];
//        
//        //convert timestamp strings back to dates
//        NSDateFormatter* dateFormatter2 = [[NSDateFormatter alloc] init];
//        dateFormatter2.locale = thisLocale;
//        dateFormatter2.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//        
//        NSDate* date1 = [dateFormatter2 dateFromString:dateAsString1];
//        NSDate* date2 = [dateFormatter2 dateFromString:dateAsString2];
        
        
        //__2._____________SORT BASED ON TIME OF REQUEST_________________
        
        NSDate* date1 = [(EQRScheduleRequestItem*)obj1 time_of_request];
        NSDate* date2 = [(EQRScheduleRequestItem*)obj2 time_of_request];
        
        //________
        
        return [date1 compare:date2];
    }];
    
    
    //reverse the ascending order to descending order
    //_____There's probably a better way to do this reverse sorting...
    NSMutableArray* tempMuteArrayAlphaDescending = [NSMutableArray arrayWithCapacity:1];
    for (id item in tempMuteArrayAlpha){
        
        [tempMuteArrayAlphaDescending insertObject:item atIndex: 0];
    }
    
    //assign array to ivar
    self.arrayOfRequests = [NSArray arrayWithArray:tempMuteArrayAlphaDescending];
    
    //reload the table
    [self.tableView reloadData];
    
}


#pragma mark - search box methods

//Basically, a predicate is an expression that returns a Boolean value (true or false). You specify the search criteria in the format of NSPredicate and use it to filter data in the array. As the search is on the name of recipe, we specify the predicate as “name contains[c] %@”. The “name” refers to the name property of the Recipe object. NSPredicate supports a wide range of filters including: BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS. Here we choose to use the “contains” filter. The operator “[c]” means the comparison is case-insensitive.

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"contact_name contains[c] %@", searchText];
    self.searchResultArrayOfRequests = [self.arrayOfRequests filteredArrayUsingPredicate:resultPredicate];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    //determine either search results table or normal table
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return 1;
        
    }else{
        
        // Return the number of sections.
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //determine either search results table or normal table
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return [self.searchResultArrayOfRequests count];
        
    }else{
        
    // Return the number of rows in the section.
    return [self.arrayOfRequests count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    //determine either search results table or normal table
    
    
    //____________  NOTICE A KEY FEATURE: USING self.tableview INSTEAD OF tableview  !!!!!!_______________
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //name
    NSString* nameString;
    
    //_______determine either search results table or normal table
    if (tableView == self.searchDisplayController.searchResultsTableView) {
    
        nameString = [(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] contact_name];
        
    }else{
        
        nameString = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] contact_name];
    }
    
    //__1.___________DISPLAY PICK UP DATE AND TIME____________
    //get date in format
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    dateFormatter.locale = thisLocale;
//    dateFormatter.dateFormat = @"EEEE, MMM d";
//    
//    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
//    timeFormatter.locale = thisLocale;
//    timeFormatter.dateFormat = @"h:mm aaa";
//    
//    NSDate* beginDate = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] request_date_begin];
//    NSDate* beginTime = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] request_time_begin];
//    NSString* dateString = [dateFormatter stringFromDate:beginDate];
//    NSString* timeString = [timeFormatter stringFromDate:beginTime];
//
//    //string for title
//    NSString* titleString = [NSString stringWithFormat:@"%@\n For Pick Up: %@, %@", nameString, dateString, timeString];

    
    
    //__2.______________DISPLAY TIME OF REQUEST___________
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = thisLocale;
    dateFormatter.dateFormat = @"EEEE, MMM d, yyyy - h:mm aaa";
    
    NSString* dateString;
    
    //_______determine either search results table or normal table
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        dateString = [dateFormatter stringFromDate:[(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] time_of_request]];
        
    }else{
        
        dateString = [dateFormatter stringFromDate:[(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] time_of_request]];
    }
    
    //string for title
    NSString* titleString = [NSString stringWithFormat:@"%@\n Submitted: %@", nameString, dateString];
    
    //__________
    
    

    //assign title to cell
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.text = titleString;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - table delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //identify the selected request for later
    //____determine if search view is present
    if (self.searchDisplayController.active) {
        
        self.chosenRequest = [self.searchResultArrayOfRequests objectAtIndex:indexPath.row];
        
    }else{
        
        self.chosenRequest = [self.arrayOfRequests objectAtIndex:indexPath.row];
    }
    
    //send message to InboxRightVC to renew the view
    [(EQRInboxRightVC*) [[(UINavigationController*) [self.splitViewController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] renewTheViewWithRequest:self.chosenRequest];
    

}



#pragma mark - InboxRightDelegate methods

//-(EQRScheduleRequestItem*)selectedRequest{
//    
//    //return the schedule request object that has been selected
//    
//    NSLog(@"selectedRequest method did fire with self.selectedRequest:contatName: %@", self.selectedRequest.contact_name);
//    
//    return self.chosenRequest;
//}


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


#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
