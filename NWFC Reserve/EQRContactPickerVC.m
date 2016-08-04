//
//  EQRContactPickerVC.m
//  Gear
//
//  Created by Ray Smith on 11/16/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRContactPickerVC.h"
#import "EQRContactNameItem.h"
#import "EQRContactAddNewVC.h"
#import "EQRColors.h"
#import "EQRGlobals.h"


@interface EQRContactPickerVC () <UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSArray* arrayOfContacts;
@property (strong, nonatomic) NSArray* arrayOfContactsWithStructure;
@property (strong, nonatomic) NSArray* arrayOfIndexLetter;
@property (strong, nonatomic) NSArray* searchResultArrayOfContacts;
@property (strong, nonatomic) EQRContactNameItem* selectedNameItem;
@property BOOL useSubstituteArrayFlag;

@property (strong, nonatomic) IBOutlet UIButton* addContactButton;
@property BOOL shouldUseShowAllContactsButton;
@property BOOL showAllContactsButtonHasBeenTapped;

@property (strong, nonatomic) EQRContactAddNewVC* addContactVC;

@property (strong, nonatomic) IBOutlet UIView *mySearchBarView;

//@property (strong, nonatomic) IBOutlet UISearchBar* mySearchBar;
//@property (strong, nonatomic) UISearchDisplayController* mySearchDisplayController;

@property (strong, nonatomic) UISearchController *mySearchController;

@property (strong, nonatomic) EQRWebData *webData;




@end

@implementation EQRContactPickerVC

@synthesize delegate;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //register cells
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    //_____!!!!!!!   DEPRECATED IN IOS8 - use UISearchController    !!!!!!_______
//    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.mySearchBar contentsController:self];
//    [searchController setDelegate:self];
//    [searchController setSearchResultsDelegate:self];
//    [searchController setSearchResultsDataSource:self];
//    [self setMySearchDisplayController:searchController];

    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.mySearchController.searchResultsUpdater = self;
    
    self.mySearchController.dimsBackgroundDuringPresentation = NO;
    self.mySearchController.hidesNavigationBarDuringPresentation = NO;
    
    //__1.__keep search bar attached to the top of the table view scroll view
    self.mySearchController.searchBar.frame = CGRectMake(self.mySearchController.searchBar.frame.origin.x, self.mySearchController.searchBar.frame.origin.y, self.mySearchController.searchBar.frame.size.width, 44.0);
    self.tableView.tableHeaderView = self.mySearchController.searchBar;
    
    //__2.__keep search above above and outside of table view
//    self.mySearchController.searchBar.frame = CGRectMake(0,0, self.mySearchBarView.frame.size.width, 44.0);
//    [self.mySearchBarView addSubview:self.mySearchController.searchBar];
        //___!!! also add 44 points to the tableview's Top constraint constant in the Nib
    

    
    self.mySearchController.searchBar.delegate = self;
    
    //what does this do?
    self.definesPresentationContext = YES;
    
    [self renewTheViewCompletion:^{
    }];
    
}


-(void)viewDidAppear:(BOOL)animated{
    

    
}


-(void)renewTheViewCompletion:(CompletionBlock)completeBlock{
    
    //when using a substitute array, just reload the data in the table call it good
    if (self.useSubstituteArrayFlag == YES){
        
        [self.tableView reloadData];
        return;
    }
    
    //not using a substitute array...
    self.shouldUseShowAllContactsButton = NO;
    self.showAllContactsButtonHasBeenTapped = YES;
    [self.addContactButton setTitle:@"Add New Contact" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
    
    self.arrayOfContacts = nil;
    self.arrayOfContactsWithStructure = nil;
    
    //get ALL contacts ???
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    self.webData = webData;
    self.webData.delegateDataFeed = self;
    SEL thisSelector = @selector(addToArrayOfContacts:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [self.webData queryWithAsync:@"EQGetAllContactNames.php" parameters:nil class:@"EQRContactNameItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            
            if (isLoadingFlagUp){
                NSLog(@"isLoadingFlagUP is YES");
            }
            
            //_____this is for moving the table to newly created contact
            completeBlock();
            
            [self renewTheViewStage2];
        }];
    });
}


-(void)renewTheViewStage2{
    
    //alphabatize the name list
    NSArray* sortedArray = [self.arrayOfContacts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
        NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
        
        return [string1 compare:string2];
    }];
    //__________
    
    self.arrayOfContacts = [NSArray arrayWithArray:sortedArray];
    
    //put some structure on that array of namesItems
    self.arrayOfContactsWithStructure = [NSArray arrayWithArray: [self expandFlatArrayToStructuredArray:sortedArray]];
    
    [self.tableView reloadData];
    
}




-(NSArray*)expandFlatArrayToStructuredArray:(NSArray*)thisArray{
    
    //_______read user defaults to determine if sort should be based on first or last name_____
//    NSString* nameSorter = @"first_and_last";
    
    //an array of letters
    NSMutableArray* arrayOfLetters = [NSMutableArray arrayWithCapacity:1];
    
    //enumerate through the flat array and add the first letter
    for (EQRContactNameItem* nameItem in thisArray){
        
        //error test for when no name exists
        if ([[nameItem performSelector:@selector(first_and_last)] length] < 1){
            
            nameItem.first_and_last = @" ";
        }
        
        NSString* firstLetterSubstring = [[nameItem performSelector:@selector(first_and_last)] substringToIndex:1];
        
        BOOL alreadyInArray = NO;
        
        //enumerate through array of letters to detemine if the letter already exists
        for (NSString* letter in arrayOfLetters){
            
            if ([letter caseInsensitiveCompare:firstLetterSubstring] == NSOrderedSame){
                
                alreadyInArray = YES;
                break;
            }
        }
        
        if (alreadyInArray == NO){
            
            //add the letter to the array
            [arrayOfLetters addObject:firstLetterSubstring];
        }
    }
    
    //assign letter array to ivar
    self.arrayOfIndexLetter = [NSArray arrayWithArray:arrayOfLetters];
    
    
    //new top array
    NSMutableArray* topArray = [NSMutableArray arrayWithCapacity:1];
    
    //enumerate through the chosen array again
    for (EQRContactNameItem* nameItem in thisArray){
        
        //error test for when no name exists
        if ([[nameItem performSelector:@selector(first_and_last)] length] < 1){
            continue;
        }
        
        NSString* firstLetterSubstring = [[nameItem performSelector:@selector(first_and_last)] substringToIndex:1];
        
        __block NSInteger indexOfSubArray;
        __block BOOL foundAMatch = NO;
        
        //enumerate through the top array
        [topArray enumerateObjectsUsingBlock:^(NSMutableArray* obj, NSUInteger idx, BOOL *stop) {
            
            //get sample letter from subarray
            NSString* sampleLetter = [[(EQRContactNameItem*)[obj objectAtIndex:0] performSelector:@selector(first_and_last)] substringToIndex:1];
            
            if ([sampleLetter caseInsensitiveCompare:firstLetterSubstring] == NSOrderedSame){
                
                //tag for adding to the subarray
                foundAMatch = YES;
                indexOfSubArray = idx;
                *stop = YES;
            }
        }];
        
        if (foundAMatch == YES){
            
            [(NSMutableArray*)[topArray objectAtIndex:indexOfSubArray] addObject:nameItem];
            
        } else {
            
            //create a new sub array
            NSMutableArray* newMuteArray = [NSMutableArray arrayWithObject:nameItem];
            
            [topArray addObject:newMuteArray];
        }
    }
    
    return topArray;
}


#pragma mark - add new contact selected

-(IBAction)addNewContactButton:(id)sender{
    
    //button serves two purposes
    //test if it should be a "show all contacts" button
    if ((self.shouldUseShowAllContactsButton == YES) && (self.showAllContactsButtonHasBeenTapped != YES)){
        
        self.useSubstituteArrayFlag = NO;
        self.showAllContactsButtonHasBeenTapped = YES;
        
        [self.addContactButton setTitle:@"Add New Contact" forState:UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted];
        
        [self renewTheViewCompletion:^{
        }];
        [self.tableView reloadData];
        
    }else{
        
        EQRContactAddNewVC* newContact = [[EQRContactAddNewVC alloc] initWithNibName:@"EQRContactAddNewVC" bundle:nil];
        
        self.addContactVC = newContact;
        self.addContactVC.delegate = self;
        
        [self.navigationController pushViewController:newContact animated:YES];
    }
    
}


-(void)informAdditionHasHappended:(EQRContactNameItem*)newContact{
    
//    NSLog(@"ContactPickerVC > informaAdditionHasHappened");
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //manually insert the new contact into the arrays
    NSMutableArray *tempMute = [NSMutableArray arrayWithArray:self.arrayOfContacts];
    [tempMute addObject:newContact];
    
    //alphabatize the name list
    NSArray* sortedArray = [tempMute sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
        NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
        
        return [string1 compare:string2];
    }];
    
    self.arrayOfContacts = [NSArray arrayWithArray:sortedArray];
    
    self.arrayOfContactsWithStructure = [self expandFlatArrayToStructuredArray:self.arrayOfContacts];
    
    [self.tableView reloadData];
    
    
    //______automatically choose the newly created contact______... BUT only if it's not currently displaying a search result
    if (self.mySearchController.active == NO){
        
        __block NSIndexPath* chosenIndexPath;
        
        [self.arrayOfContactsWithStructure enumerateObjectsUsingBlock:^(NSArray* subarray, NSUInteger idxSection, BOOL *stopInTop) {
            
            [subarray enumerateObjectsUsingBlock:^(EQRContactNameItem* contactItem, NSUInteger idxRow, BOOL *stopInSub) {
                
                if ([contactItem.key_id isEqualToString:newContact.key_id]){
                    
                    chosenIndexPath = [NSIndexPath indexPathForRow:idxRow inSection:idxSection];
                }
            }];
        }];
        
        //move table to new contact
        [self.tableView scrollToRowAtIndexPath:chosenIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }else{
        
        NSMutableArray *tempMuteArray = [NSMutableArray arrayWithArray:self.searchResultArrayOfContacts];
        [tempMuteArray insertObject:newContact atIndex:0];
        self.searchResultArrayOfContacts = [NSArray arrayWithArray:tempMuteArray];
        
        [self.tableView reloadData];
    }
}

#pragma mark - public methods

-(void)replaceDefaultContactArrayWith:(NSArray*)substituteContactArray{

    if (!substituteContactArray){   //error handling and used when public is selected from renters
        self.useSubstituteArrayFlag = NO;
        [self renewTheViewCompletion:^{
        }];
        [self.tableView reloadData];
        return;
    }
    
    //______raise the flag
    //_____to insure renew the view doesn't override the substitute array
    self.useSubstituteArrayFlag = YES;
    
    //change add contact item button to show all contacts and reset flags
    self.shouldUseShowAllContactsButton = YES;
    self.showAllContactsButtonHasBeenTapped = NO;
    [self.addContactButton setTitle:@"Show All Contacts in Database" forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];

    //remove the search display if it exists
    [self.mySearchController setActive:NO];
    
    //set arrays
    self.arrayOfContacts = substituteContactArray;
    self.arrayOfContactsWithStructure = [self expandFlatArrayToStructuredArray:self.arrayOfContacts];
    
    //reload the table
    [self.tableView reloadData];
    
    //scroll to the top (if table has any data)
    if ([self.tableView numberOfSections] > 0){
        if ([self.tableView numberOfRowsInSection:0] > 0){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}



-(id)retrieveContactItem{
    
    return self.selectedNameItem;
    
    //release self as delegate
    self.addContactVC.delegate = nil;
    
    //release addContactVC
    self.addContactVC = nil;
}


#pragma mark - webData dataFeedDelegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
//    NSLog(@"addSyncDataItem: received");
    
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

-(void)addToArrayOfContacts:(id)currentThing{
    
    NSMutableArray *tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    if (currentThing){
        
        tempMuteArray = [NSMutableArray arrayWithArray:self.arrayOfContacts];
        [tempMuteArray addObject:currentThing];
    }
    
    self.arrayOfContacts = [NSArray arrayWithArray:tempMuteArray];
}




#pragma mark - table data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.mySearchController.active){
        
        return 1;
        
    }else{
    
        return [self.arrayOfContactsWithStructure count];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.mySearchController.active) {
    
        return [self.searchResultArrayOfContacts count];
        
    }else{
        
        return [[self.arrayOfContactsWithStructure objectAtIndex:section] count];
    }
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //determine either search results table or normal table
    
    
    //____________  NOTICE A KEY FEATURE: USING self.tableview INSTEAD OF tableview  !!!!!!_______________
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    
    
    //_______!!!!  This doesn't work with the search tool, must replace with the following...
//    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //set custom bg color on selection
        EQRColors *colors = [EQRColors sharedInstance];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [colors.colorDic objectForKey:EQRColorSelectionBlue];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    //name
    NSString* nameString;
    
    //_______determine either search results table or normal table
    if (self.mySearchController.active) {
        
        nameString = [(EQRContactNameItem*)[self.searchResultArrayOfContacts objectAtIndex:indexPath.row] first_and_last];
        
    }else{
        
        nameString = [(EQRContactNameItem*)[(NSArray*)[self.arrayOfContactsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] first_and_last];
    }
    
    
    cell.textLabel.text = nameString;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (self.mySearchController.active){
        
        return @"";
        
    }else{
        
        NSString* letter = [[(EQRContactNameItem*)[[self.arrayOfContactsWithStructure objectAtIndex:section] objectAtIndex:0] first_and_last] substringToIndex:1];
        
        NSString* letterCaseInsensitive = [letter capitalizedString];
        
        return letterCaseInsensitive;
        
    }
}


#pragma mark - table index data source methods

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if (self.mySearchController.active) {
        return nil;
    }else{
        return self.arrayOfIndexLetter;
    }
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    return index;
    
}


#pragma mark - delegate method 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"delegate did fire in the contact picker VC");
    
    //identify the selected request for later
    //____determine if search view is present
    if (self.mySearchController.active) {
        
        self.selectedNameItem = [self.searchResultArrayOfContacts objectAtIndex:indexPath.row];
        
    }else{
        
        self.selectedNameItem = [[self.arrayOfContactsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [self.delegate retrieveSelectedNameItem];
    
    if ([self.delegate respondsToSelector:@selector(retrieveSelectedNameItemWithObject:)]){
        [self.delegate retrieveSelectedNameItemWithObject:self.selectedNameItem];
    }
    
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    
    NSString *searchString = [self.mySearchController.searchBar text];
    
    if ([searchString isEqualToString:@""]){
        searchString = @" ";
    }
    
//    NSLog(@"inside updateSearchResultsForSearchController with search text: %@", searchString);
    
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

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"first_and_last contains[c] %@", searchText];
    self.searchResultArrayOfContacts = [self.arrayOfContacts filteredArrayUsingPredicate:resultPredicate];
}


#pragma mark - search box methods

//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
//    
//    [self filterContentForSearchText:searchString
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
//    
//    return YES;
//}


-(void)viewDidDisappear:(BOOL)animated{
    
}


-(void)dealloc{
    
    //_______this doesn't help_________
    //must do this to lower the retain count as an offset for when we upped the retain count in viewDidLoad
//    self.mySearchDisplayController = CFBridgingRelease((__bridge void*)(self.mySearchDisplayController));
    
//    self.mySearchDisplayController = nil;
    
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
