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
#import "EQRDataStructure.h"


@interface EQRInboxLeftTableVC ()

@property (strong, nonatomic) NSMutableArray* arrayOfRequests;
@property NSInteger countOfUltimageReturnedItems;
@property NSInteger indexOfLastReturnedItem;
@property BOOL finishedAsyncDBCall;
@property (strong, nonatomic) NSArray* searchResultArrayOfRequests;
@property (strong, nonatomic) EQRScheduleRequestItem* chosenRequest;

@property (strong, nonatomic) IBOutlet UISearchDisplayController* mySearechDisplayController;

@property (strong, nonatomic) EQRWebData* myWebData;

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
    
    //_______some messed up shit_______
    //bug in ios7 needs the retain count for the UISearchDisplayController bumped up by 1
    //http://stackoverflow.com/questions/19214286/having-a-zombie-issue-on-uisearchdisplaycontroller
//    self.mySearchDisplayController = (__bridge  UISearchDisplayController *)(CFBridgingRetain(self.searchDisplayController));
    //_______!!!!!! AAUUUGGGHHHH this is not a fix because it prevents self (the view controller) from getting deallocated properly
    //________!!!!! as evidenced when rotating the device after opening the contact VC at least twice
    //_______!!!!!!! Damned if you do, damned if you don't
 
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
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
    
    //refresh or initiate the array of objects
    if (!self.arrayOfRequests){
        self.arrayOfRequests = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfRequests removeAllObjects];
    
    //load the local array ONLY with upcoming unconfirmed requests
    EQRWebData* webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    self.myWebData = webData;

    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = thisLocale;
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    //need to subtract a day off of the date (strange)
    NSDate* adjustedDate = [[NSDate date] dateByAddingTimeInterval:-86400]; //86400 seconds is one day
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"request_date_begin", [dateFormatter stringFromDate:adjustedDate], nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    self.indexOfLastReturnedItem = -1;
    
    //_________determine which selection was made from top VC (Inbox or Archive)
    NSString* selectionType = [self.delegateForLeftSide selectedInboxOrArchive];
    
    //get only needs confirmation
    if ([selectionType isEqualToString:@"NeedsConfirmation"]){  //get only inbox
        
        //set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Inbox";
        
        //__1__ get total count of items that will be ultimately be returned
        NSString* countOfRequests = [webData queryForStringWithLink:@"EQGetCountOfRequestsUpcomingUnconfirmed.php" parameters:topArray];

        self.countOfUltimageReturnedItems = [countOfRequests integerValue];
        
        //__2__ do asynchronous call to webData
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleRequestsUpcomingUnconfirmed.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(BOOL isLoadingFlagUp) {
                
                //identify when loading is complete
                self.finishedAsyncDBCall = isLoadingFlagUp;
                
                NSLog(@"loading is DONE!!");
            }];
        });
        
    }else if ([selectionType isEqualToString:@"AllRequests"]){     //get ALL requests
    
        //set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        //__1__ get total count of items that will be ultimately be returned
        NSString* countOfRequests = [webData queryForStringWithLink:@"EQGetCountOfScheduleRequestsAll.php" parameters:nil];
//        NSLog(@"this is the count of all requests as a string: %@", countOfRequests);
        self.countOfUltimageReturnedItems = [countOfRequests integerValue];
        
        //__2__ do asynchronous call to webData
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleRequestsAll.php" parameters:nil class:@"EQRScheduleRequestItem" completion:^(BOOL isLoadingFlagUp) {
                
                //identify when loading is complete
                self.finishedAsyncDBCall = isLoadingFlagUp;
                
                NSLog(@"loading is DONE!!");
            }];
        });
        
    }else if ([selectionType isEqualToString:@"datesToTable"]){    //get request according to pickup date range
    
        //set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        //get dates
        NSDictionary* dateRange = [self.delegateForLeftSide getDateRange];
        NSDate* beginDate = [dateRange objectForKey:@"beginDate"];
        NSDate* endDate = [dateRange objectForKey:@"endDate"];
        NSString* beginDateString = [EQRDataStructure dateAsStringSansTime:beginDate];
        NSString* endDateString = [EQRDataStructure dateAsStringSansTime:endDate];
        NSArray* firstArray = @[@"request_date_begin", beginDateString];
        NSArray* secondArray = @[@"request_date_end", endDateString];
        NSArray* topArray = @[firstArray, secondArray];

        
        //__1__ get total count of items that will be ultimately be returned
        NSString* countOfRequests = [webData queryForStringWithLink:@"EQGetCountOfRequestsInDateRange.php" parameters:topArray];
        //        NSLog(@"this is the count of all requests as a string: %@", countOfRequests);
        self.countOfUltimageReturnedItems = [countOfRequests integerValue];
        
        //__2__ do asynchronous call to webData
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleItemsCompleteInDateRange.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(BOOL isLoadingFlagUp) {
                
                //identify when loading is complete
                self.finishedAsyncDBCall = isLoadingFlagUp;
                
                NSLog(@"loading is DONE!!");
            }];
        });
        
        
    }else{
        
        //error handling when failed to create delegate or idenfity the segue
    }
    
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


#pragma mark - webData dataFeedDelegate methods

-(void)addScheduleTrackingItem:(id)currentThing{
    
//    NSLog(@"is in addScheduleTrackingItem method");
    
    [self.arrayOfRequests addObject:currentThing];
    
    //uptick on the index
    self.indexOfLastReturnedItem = self.indexOfLastReturnedItem + 1;
    
    //test to see if the cell is visible and needs data...
    for (NSIndexPath* indexPath in [self.tableView indexPathsForVisibleRows]){
        
        if (self.indexOfLastReturnedItem == indexPath.row){
            
//            NSLog(@"Found a Matching indexpath to indexOfLastReturnedItem");
            NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:self.indexOfLastReturnedItem inSection:0];
            NSArray* rowsOfIndexPaths = @[newIndexPath];
            
            //delay the refresh, the object's don't appear in the array immediately
            [self performSelector:@selector(delayedCallToRefreshCellUITableViewRowAnimation:) withObject:rowsOfIndexPaths afterDelay:0.25];
        }
    }
}

-(void)delayedCallToRefreshCellUITableViewRowAnimation:(NSArray*)indexPaths{
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}


//______something else to think about (this is used in scheduleDisplayTopVC)
// [self.myWebData.xmlParser abortParsing]


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
    return self.countOfUltimageReturnedItems;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    //determine either search results table or normal table
    
    
    //____________  NOTICE A KEY FEATURE: USING self.tableview INSTEAD OF tableview  !!!!!!_______________
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell* cell;
    
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //name
    NSString* nameString;
    
    //_______determine either search results table or normal table
    if (tableView == self.searchDisplayController.searchResultsTableView) {
    
        nameString = [(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] contact_name];
        
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
        
    }else{  //is content table
        
        //determine if data has been loaded
        if ([self.arrayOfRequests count] > indexPath.row){  //yes, indexed indicate is has arrived
            
            nameString = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] contact_name];

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
            
        }else{  // no, the data is not loaded yet
            
            NSString* titleString = @"Loading Data...";
            
            //assign title to cell
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.text = titleString;
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
        
    }
    
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


- (void)viewWillDisappear:(BOOL)animated{
    
    //stop the async data loading
    [self.myWebData.xmlParser abortParsing];
    
    [super viewWillDisappear:animated];
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
