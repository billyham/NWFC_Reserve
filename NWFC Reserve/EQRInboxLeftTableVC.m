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

@property BOOL aChangeWasMade;


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
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(raiseFlagThatAChangeHasBeenMade:) name:EQRAChangeWasMadeToTheSchedule object:nil];
    [nc addObserver:self selector:@selector(raiseFlagThatAChangeHasBeenMade:) name:EQRAChangeWasMadeToTheSchedule object:nil];
    
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

    
    [self renewTheView];
}


- (void)viewWillAppear:(BOOL)animated{
    
    if (self.aChangeWasMade){
        self.aChangeWasMade = NO;
        [self renewTheView];
    }
    
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


-(void)raiseFlagThatAChangeHasBeenMade:(NSNotification *)note{
    self.aChangeWasMade = YES;
}


-(void)renewTheView{
    
    // Refresh or initiate the array of objects
    if (!self.arrayOfRequests){
        self.arrayOfRequests = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfRequests removeAllObjects];
    
    // Load the local array ONLY with upcoming unconfirmed requests
    EQRWebData* webData = [EQRWebData sharedInstance];
    self.myWebData = webData;

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* thisLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.locale = thisLocale;
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    // Need to subtract a day off of the date (strange)
    NSDate* adjustedDate = [[NSDate date] dateByAddingTimeInterval:-86400]; //86400 seconds is one day
    
    NSArray* topArray = @[ @[@"request_date_begin", [dateFormatter stringFromDate:adjustedDate]] ];
    
    self.indexOfLastReturnedItem = -1;
    
    // Determine which selection was made from top VC (Inbox or Archive)
    NSString* selectionType = [self.delegateForLeftSide selectedInboxOrArchive];
    
    if ([selectionType isEqualToString:@"NeedsConfirmation"]){
        
        // Set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Inbox";
        
        [self fetchDataWithCountRequest:@"EQGetCountOfRequestsUpcomingUnconfirmed.php" andDataRequest:@"EQGetScheduleRequestsUpcomingUnconfirmed.php" withParams:topArray];
        
    }else if ([selectionType isEqualToString:@"PastDue"]){
        
        // Set nav bar title
        self.navigationItem.title = @"Past Due";
        
        [self fetchDataWithCountRequest:@"EQGetCountOfRequestsPastDue.php" andDataRequest:@"EQGetScheduleRequestsPastDue.php" withParams:topArray];
    
    }else if ([selectionType isEqualToString:@"AllRequestsByName"]){
    
        // Set the search bar placeholder text
        self.mySearchController.searchBar.placeholder = @"Search by Name";
        
        // Set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        [self fetchDataWithCountRequest:@"EQGetCountOfScheduleRequestsAll.php" andDataRequest:@"EQGetScheduleRequestsAll.php" withParams:nil];
        
    }else if ([selectionType isEqualToString:@"AllRequestsByClassTitle"]){
        
        // Set the search bar placeholder text
        self.mySearchController.searchBar.placeholder = @"Search by Class";
        
        // Set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        [self fetchDataWithCountRequest:@"EQGetCountOfScheduleRequestsAll.php" andDataRequest:@"EQGetScheduleRequestsAll.php" withParams:nil];
    
    }else if ([selectionType isEqualToString:@"datesToTable"]){
    
        // Set nav bar title (override nav bar title from nib)
        self.navigationItem.title = @"Archive";
        
        // Get dates
        NSDictionary* dateRange = [self.delegateForLeftSide getDateRange];
        NSDate* beginDate = [dateRange objectForKey:@"beginDate"];
        NSDate* endDate = [dateRange objectForKey:@"endDate"];
        NSString* beginDateString = [EQRDataStructure dateAsStringSansTime:beginDate];
        NSString* endDateString = [EQRDataStructure dateAsStringSansTime:endDate];
        NSArray* topArray = @[ @[@"request_date_begin", beginDateString],
                               @[@"request_date_end", endDateString] ];

        [self fetchDataWithCountRequest:@"EQGetCountOfRequestsInDateRange.php" andDataRequest:@"EQGetScheduleItemsCompleteInDateRange.php" withParams:topArray];
        
    }else{
        
        NSLog(@"EQRInboxLeftTable > renewTheView, failed to create delegate or idenfity the segue");
    }
    
    [self.tableView reloadData];
}

-(void)fetchDataWithCountRequest:(NSString *)countReq andDataRequest:(NSString *)dataReq withParams:(NSArray *)params{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"fetchDataWithCountRequest";
    queue.maxConcurrentOperationCount = 1;

    
    NSBlockOperation *requestCount = [NSBlockOperation blockOperationWithBlock:^{
        EQRWebData *webData = [EQRWebData sharedInstance];
        NSString *countOfRequests = [webData queryForStringWithLink:countReq parameters:params];
        self.countOfUltimageReturnedItems = [countOfRequests integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    
    NSBlockOperation *requestData = [NSBlockOperation blockOperationWithBlock:^{

        EQRWebData *webData = [EQRWebData sharedInstance];
        
        [webData queryWithLink:dataReq parameters:params class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
            self.finishedAsyncDBCall = YES;
            if (!muteArray) return NSLog(@"EQRInboxLeftVC > fetchDataWith..., failed to retrieve array");
            self.arrayOfRequests = [NSMutableArray arrayWithArray:muteArray];
            
            self.indexOfLastReturnedItem = [muteArray count] -1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }];
    [requestData addDependency:requestCount];

    
    [queue addOperation:requestCount];
    [queue addOperation:requestData];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Determine either search results table or normal table
    if (self.mySearchController.active) {
        return 1;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Determine either search results table or normal table
    if (self.mySearchController.active) {
        return [self.searchResultArrayOfRequests count];
    }else{
        return self.countOfUltimageReturnedItems;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell* cell;
    
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
    
    
    // Determine either search results table or normal table
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
        
    } else {
        
        // Determine if data has been loaded
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
    
    // Prevent cell selection if data is still loading
    if (self.finishedAsyncDBCall == NO) {
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
        return;
    }
    
    // Determine if search view is present
    if (self.mySearchController.active) {
        self.chosenRequest = [self.searchResultArrayOfRequests objectAtIndex:indexPath.row];
    }else{
        self.chosenRequest = [self.arrayOfRequests objectAtIndex:indexPath.row];
    }
    
    // Send message to InboxRightVC to renew the view
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
    
//    NSLog(@"this is the segue: %@", segue.identifier);
    

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
