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
#import "EQRColors.h"


@interface EQRInboxLeftTableVC () <UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray* arrayOfRequests;
@property NSInteger countOfUltimageReturnedItems;
@property NSInteger indexOfLastReturnedItem;
@property BOOL finishedAsyncDBCall;
@property (strong, nonatomic) NSArray* searchResultArrayOfRequests;
@property (strong, nonatomic) EQRScheduleRequestItem* chosenRequest;

@property (strong, nonatomic) UISearchController *mySearchController;

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
    
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.mySearchController.searchResultsUpdater = self;
    
    self.mySearchController.dimsBackgroundDuringPresentation = NO;
    self.mySearchController.hidesNavigationBarDuringPresentation = NO;
    
    self.mySearchController.searchBar.frame = CGRectMake(self.mySearchController.searchBar.frame.origin.x, self.mySearchController.searchBar.frame.origin.y, self.mySearchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.mySearchController.searchBar;
    
    self.mySearchController.searchBar.delegate = self;
    
    //what does this do?
    self.definesPresentationContext = YES;
    
 
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

}


- (void)viewWillAppear:(BOOL)animated{
    
    //update navigation bar
    EQRModeManager* modeManager = [EQRModeManager sharedInstance];
    if (modeManager.isInDemoMode){
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = @"!!! DEMO MODE !!!";
        
        //set color of navigation bar
        EQRColors* colors = [EQRColors sharedInstance];
        self.navigationController.navigationBar.barTintColor = [colors.colorDic objectForKey:EQRColorDemoMode];
        [UIView setAnimationsEnabled:YES];
        
    }else{
        
        //set prompt
        [UIView setAnimationsEnabled:NO];
        self.navigationItem.prompt = nil;
        
        //set color of navigation bar
        self.navigationController.navigationBar.barTintColor = nil;
        [UIView setAnimationsEnabled:YES];
    }
    
    [self renewTheView];

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
        SEL thisSelector = @selector(addToArrayOfRequests:);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleRequestsUpcomingUnconfirmed.php" parameters:topArray class:@"EQRScheduleRequestItem" selector:thisSelector  completion:^(BOOL isLoadingFlagUp) {
                
                //identify when loading is complete
                self.finishedAsyncDBCall = isLoadingFlagUp;
                
                NSLog(@"loading is DONE!!");
            }];
        });
        
    }else if ([selectionType isEqualToString:@"AllRequestsByName"]){     //get ALL requests
    
        //set the search bar placeholder text
        self.mySearchController.searchBar.placeholder = @"Search by Name";
        
        //set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        //__1__ get total count of items that will be ultimately be returned
        NSString* countOfRequests = [webData queryForStringWithLink:@"EQGetCountOfScheduleRequestsAll.php" parameters:nil];
//        NSLog(@"this is the count of all requests as a string: %@", countOfRequests);
        self.countOfUltimageReturnedItems = [countOfRequests integerValue];
        
        //__2__ do asynchronous call to webData
        SEL thisSelector = @selector(addToArrayOfRequests:);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleRequestsAll.php" parameters:nil class:@"EQRScheduleRequestItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
                
                //identify when loading is complete
                self.finishedAsyncDBCall = isLoadingFlagUp;
                
                NSLog(@"loading is DONE!!");
            }];
        });
        
    }else if ([selectionType isEqualToString:@"AllRequestsByClassTitle"]){
        
        //set the search bar placeholder text
        self.mySearchController.searchBar.placeholder = @"Search by Class";
        
        //set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        NSString* countOfRequests = [webData queryForStringWithLink:@"EQGetCountOfScheduleRequestsAll.php" parameters:nil];
        self.countOfUltimageReturnedItems = [countOfRequests integerValue];
        
        SEL thisSelector = @selector(addToArrayOfRequests:);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleRequestsAll.php" parameters:nil class:@"EQRScheduleRequestItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
                
                //identify when loading is complete
                self.finishedAsyncDBCall = isLoadingFlagUp;
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
        SEL thisSelector = @selector(addToArrayOfRequests:);
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryWithAsync:@"EQGetScheduleItemsCompleteInDateRange.php" parameters:topArray class:@"EQRScheduleRequestItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
                
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


#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    
    NSString *searchString = [self.mySearchController.searchBar text];
    
    if ([searchString isEqualToString:@""]){
        searchString = @" ";
    }
    
    NSString *scope = nil;
    
    [self filterContentForSearchText:searchString scope:scope];
    
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.mySearchController];
}



#pragma mark - Content Filtering

//Basically, a predicate is an expression that returns a Boolean value (true or false). You specify the search criteria in the format of NSPredicate and use it to filter data in the array. As the search is on the name of recipe, we specify the predicate as “name contains[c] %@”. The “name” refers to the name property of the Recipe object. NSPredicate supports a wide range of filters including: BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS. Here we choose to use the “contains” filter. The operator “[c]” means the comparison is case-insensitive.

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    NSPredicate *resultPredicate;
    
    NSString* selectionType = [self.delegateForLeftSide selectedInboxOrArchive];
    if ([selectionType isEqualToString:@"AllRequestsByClassTitle"]){
        
        resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
        
    }else{
        
        resultPredicate = [NSPredicate predicateWithFormat:@"contact_name contains[c] %@", searchText];
    }
    
    self.searchResultArrayOfRequests = [self.arrayOfRequests filteredArrayUsingPredicate:resultPredicate];
}


#pragma mark - webData dataFeedDelegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    //abort if selector is unrecognized, otherwise crash
    if (![self respondsToSelector:action]){
        NSLog(@"cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
    
}

-(void)addToArrayOfRequests:(id)currentThing{
    
    if (currentThing){
        [self.arrayOfRequests addObject:currentThing];
    }
    
    //uptick on the index
    self.indexOfLastReturnedItem = self.indexOfLastReturnedItem + 1;
    
    //test to see if the cell is visible and needs data...
    for (NSIndexPath* indexPath in [self.tableView indexPathsForVisibleRows]){
        
        if (self.indexOfLastReturnedItem == indexPath.row){
            
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
    if (self.mySearchController.active) {
        
        return 1;
        
    }else{
        
        // Return the number of sections.
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //determine either search results table or normal table
    if (self.mySearchController.active) {
        
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
        
        //set custom bg color on selection
        EQRColors *colors = [EQRColors sharedInstance];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [colors.colorDic objectForKey:EQRColorSelectionBlue];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    //nsattributedstrings
    UIFont* smallFont = [UIFont systemFontOfSize:10];
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:14];
    UIFont* extraBoldFont = [UIFont boldSystemFontOfSize:17];
    NSDictionary* smallFontDictionary = @{NSFontAttributeName:smallFont};
    NSDictionary* normalFontDictionary = @{NSFontAttributeName:normalFont};
    NSDictionary* boldFontDictionary = @{NSFontAttributeName:boldFont};
    NSDictionary* boldClassDictionary = @{NSFontAttributeName:boldFont, NSForegroundColorAttributeName:[UIColor blueColor]};
    NSDictionary* extraBoldDictionary = @{NSFontAttributeName:extraBoldFont};
    
    //the strings
    NSString* nameString;
    NSString* dateString1;
    NSString* timeString1;
    
    //the attributed strings
    NSMutableAttributedString *totalAttString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString* classStringAttPrefix = [[NSMutableAttributedString alloc] initWithString:@"" attributes:normalFontDictionary];
    NSMutableAttributedString* classStringAtt = [[NSMutableAttributedString alloc] initWithString:@"" attributes:boldClassDictionary];
    
    //the date and time formatters
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = thisLocale;
    dateFormatter.dateFormat = @"EEEE, MMM d, yyyy - h:mm aaa";
    
    NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale1 = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter1.locale = thisLocale1;
    dateFormatter1.dateFormat = @"EEEE, MMM d, yyyy";
    
    NSDateFormatter* timeFormatter1 = [[NSDateFormatter alloc] init];
    timeFormatter1.locale = thisLocale1;
    timeFormatter1.dateFormat = @"h:mm aaa";
    
    
    //_______determine either search results table or normal table
    if (self.mySearchController.active) {         //search results!!!
        
        //this seems like a weird place to put the row height, but it works
        tableView.rowHeight = 80.f;
        
        nameString = [(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] contact_name];
        
        NSDate* beginDate = [(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] request_date_begin];
        NSDate* beginTime = [(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] request_time_begin];
        dateString1 = [dateFormatter1 stringFromDate:beginDate];
        timeString1 = [timeFormatter1 stringFromDate:beginTime];
        
        //__1B.___________CLASS (if it exists)_________
        if ([(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] classTitle_foreignKey]){
            if ((![[(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] classTitle_foreignKey] isEqualToString:@""]) &&
                (![[(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] classTitle_foreignKey] isEqualToString:EQRErrorCode88888888])){
                
                NSAttributedString* classStringAttPrefixAppendage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nClass: "] attributes:normalFontDictionary];
                NSAttributedString* classStringAttAppendage = [[NSAttributedString alloc] initWithString:[(EQRScheduleRequestItem*)[self.searchResultArrayOfRequests objectAtIndex:indexPath.row] title] attributes:boldClassDictionary];
                
                [classStringAttPrefix appendAttributedString:classStringAttPrefixAppendage];
                [classStringAtt appendAttributedString:classStringAttAppendage];
            }
        }
        
    } else {                                                                            //is content table
        
        //determine if data has been loaded
        if ([self.arrayOfRequests count] > indexPath.row){  //yes, indexed indicate is has arrived
            
            nameString = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] contact_name];
            
            NSDate* beginDate = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] request_date_begin];
            NSDate* beginTime = [(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] request_time_begin];
            dateString1 = [dateFormatter1 stringFromDate:beginDate];
            timeString1 = [timeFormatter1 stringFromDate:beginTime];
            
            //__1B.___________CLASS (if it exists)_________
            if ([(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] title]){
                if (![[(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] title] isEqualToString:@""]){
                    
                    NSAttributedString* classStringAttPrefixAppendage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nClass: "] attributes:normalFontDictionary];
                    NSAttributedString* classStringAttAppendage = [[NSAttributedString alloc] initWithString:[(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] title] attributes:boldClassDictionary];
                    
                    [classStringAttPrefix appendAttributedString:classStringAttPrefixAppendage];
                    [classStringAtt appendAttributedString:classStringAttAppendage];
                }
            }
            
        }else{  // no, the data is not loaded yet
            
            NSString* titleString = @"Loading Data...";
            
            //assign title to cell
            cell.textLabel.numberOfLines = 4;
            cell.textLabel.text = titleString;
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            
            return cell;
        }
    }
    
    //__1.__________ NAME_________
    NSAttributedString* nameStringAtt = [[NSAttributedString alloc] initWithString:nameString attributes:extraBoldDictionary];
    [totalAttString appendAttributedString:nameStringAtt];
    
    //__1A.__________RENTER TYPE__________
    
    //__1B.___________CLASS_________
    [totalAttString appendAttributedString:classStringAttPrefix];
    [totalAttString appendAttributedString:classStringAtt];
    
    //__C.______PICK UP DATE_______
    NSAttributedString* combinedDateStringPrefixAtt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nOut: "] attributes:smallFontDictionary];
    NSAttributedString* combinedDateStringAtt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", dateString1] attributes:boldFontDictionary];
    NSAttributedString* combinedDateStringSuffixAtt = [[NSAttributedString alloc] initWithString:timeString1 attributes:normalFontDictionary];
    [totalAttString appendAttributedString:combinedDateStringPrefixAtt];
    [totalAttString appendAttributedString:combinedDateStringAtt];
    [totalAttString appendAttributedString:combinedDateStringSuffixAtt];
    
    
    //__3.______________DISPLAY TIME OF REQUEST___________
    //            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //            NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //            dateFormatter.locale = thisLocale;
    //            dateFormatter.dateFormat = @"EEEE, MMM d, yyyy";  // - h:mm aaa
    //
    //            NSString* dateString = [dateFormatter stringFromDate:[(EQRScheduleRequestItem*)[self.arrayOfRequests objectAtIndex:indexPath.row] time_of_request]];
    //            NSAttributedString* titleStringAttPrefix = [[NSAttributedString alloc] initWithString:@"\n" attributes:normalFontDictionary];
    //
    //            NSAttributedString* titleStringAtt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Submitted: %@", dateString] attributes:smallFontDictionary];
    //            [totalAttString appendAttributedString:titleStringAttPrefix];
    //            [totalAttString appendAttributedString:titleStringAtt];
    
    //assign title to cell
    cell.textLabel.numberOfLines = 4;
    cell.textLabel.attributedText = totalAttString;
    
    return cell;
}


#pragma mark - table delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //identify the selected request for later
    //____determine if search view is present
    if (self.mySearchController.active) {
        
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
    [self.myWebData stopXMLParsing];
    
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
