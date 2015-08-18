//
//  EQRClassPickerVC.m
//  Gear
//
//  Created by Ray Smith on 11/19/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRClassPickerVC.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"
#import "EQRClassItem.h"
#import "EQRColors.h"

@interface EQRClassPickerVC () <UISearchResultsUpdating, UISearchBarDelegate, EQRWebDataDelegate>

@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentButton;

@property (strong, nonatomic) NSArray* arrayOfClasses;
@property (strong, nonatomic) NSArray* arrayOfClassesWithAlphaStructure;
@property (strong, nonatomic) NSArray *arrayOfAllClassesForPreservation;
@property (strong, nonatomic) NSArray* arrayOfIndexLetter;
@property (strong, nonatomic) EQRClassItem* myClassItem;

@property (strong, nonatomic) NSArray* searchResultsArrayOfClasses;

@property (strong, nonatomic) UISearchController *mySearchController;

@end

@implementation EQRClassPickerVC

@synthesize delegate;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //register table view cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    
    self.mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.mySearchController.searchResultsUpdater = self;
    
    self.mySearchController.dimsBackgroundDuringPresentation = NO;
    self.mySearchController.hidesNavigationBarDuringPresentation = NO;
    
    self.mySearchController.searchBar.frame = CGRectMake(self.mySearchController.searchBar.frame.origin.x, self.mySearchController.searchBar.frame.origin.y, self.mySearchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.mySearchController.searchBar;
    
    self.mySearchController.searchBar.delegate = self;
    
    //__________Scope Buttons when Search bar is activated...
//    NSArray *scopeButtonTitles = @[@"All", @"Current Term"];
//    self.mySearchController.searchBar.scopeButtonTitles = scopeButtonTitles;
    //__________
    
    //what does this do?
    self.definesPresentationContext = YES;
    
    
    //get list of classes
    EQRWebData* webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    SEL thisSelector = @selector(addToArrayOfClasses:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryWithAsync:@"EQGetClassesAll.php" parameters:nil class:@"EQRClassItem" selector:thisSelector completion:^(BOOL isLoadingFlagUp) {
            
            if (isLoadingFlagUp){
                NSLog(@"isLoadingFlagUP is YES");
            }
            
            [self loadTheViewStage2];
        }];
    });
}


-(void)loadTheViewStage2{
    
    self.arrayOfClasses = [self sortArrayByAlphabetical:self.arrayOfClasses];
    self.arrayOfAllClassesForPreservation = [self.arrayOfClasses copy];
    
    self.arrayOfClassesWithAlphaStructure = [self expandFlatArrayToStructuredArray:self.arrayOfClasses];
    
    [self.tableView reloadData];
}


#pragma mark - Actions

-(IBAction)removeClassButton:(id)sender{
    
    self.myClassItem = nil;
    
    //tell delegate to retrieve the nil item
    [self.delegate initiateRetrieveClassItem];

}


-(IBAction)segmentButtonTapped:(id)sender{
    
    NSInteger index = [(UISegmentedControl *)sender selectedSegmentIndex];
    if (index == 1){    //current term selected
        
        NSMutableArray *muteArray = [NSMutableArray arrayWithCapacity:1];
        NSString* currentTerm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"term"] objectForKey:@"term"];
        
        //must not pass a nil parameter in localizedCaseInsensitiveCompare:
        if (currentTerm){
            for (EQRClassItem * classItem in self.arrayOfClasses){
                if ([classItem.term localizedCaseInsensitiveCompare:currentTerm] == NSOrderedSame){
                    [muteArray addObject:classItem];
                }
            }
            self.arrayOfClasses = [muteArray copy];
        }
            
        self.arrayOfClassesWithAlphaStructure = [self expandFlatArrayToStructuredArray:self.arrayOfClasses];
        [self.tableView reloadData];
        
    }else{     //all selected
        
        self.arrayOfClasses = [self.arrayOfAllClassesForPreservation copy];
        self.arrayOfClassesWithAlphaStructure = [self expandFlatArrayToStructuredArray:self.arrayOfClasses];
        [self.tableView reloadData];
    }
    
}

#pragma mark - retrieval methods

-(id)retrieveClassItem{
    
    
    return self.myClassItem;
}


-(NSArray*)sortArrayByAlphabetical:(NSArray*)thisArray{
    
    NSArray* newArray = [thisArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
       
        return [[(EQRClassItem*)obj1 section_name] compare:[(EQRClassItem*)obj2 section_name]];
        
    }];
    
    return newArray;
}


//-(NSArray*)sortArrayByChronological:(NSArray*)thisArray{
//    
//    
//    
//}


-(NSArray*)expandFlatArrayToStructuredArray:(NSArray*)thisArray{
    
    //_______read user defaults to determine if sort should be based on first or last name_____
    //    NSString* nameSorter = @"first_and_last";
    
    //an array of letters
    NSMutableArray* arrayOfLetters = [NSMutableArray arrayWithCapacity:1];
    
    //enumerate through the flat array and add the first letter
    for (EQRClassItem* classItem in thisArray){
        
        NSString* firstLetterSubstring = [[classItem performSelector:@selector(section_name)] substringToIndex:1];
        
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
    for (EQRClassItem* classItem in thisArray){
        
        NSString* firstLetterSubstring = [[classItem performSelector:@selector(section_name)] substringToIndex:1];
        
        __block NSInteger indexOfSubArray;
        __block BOOL foundAMatch = NO;
        
        //enumerate through the top array
        [topArray enumerateObjectsUsingBlock:^(NSMutableArray* obj, NSUInteger idx, BOOL *stop) {
            
            //get sample letter from subarray
            NSString* sampleLetter = [[(EQRClassItem*)[obj objectAtIndex:0] performSelector:@selector(section_name)] substringToIndex:1];
            
            if ([sampleLetter caseInsensitiveCompare:firstLetterSubstring] == NSOrderedSame){
                
                //tag for adding to the subarray
                foundAMatch = YES;
                indexOfSubArray = idx;
                *stop = YES;
            }
        }];
        
        if (foundAMatch == YES){
            
            [(NSMutableArray*)[topArray objectAtIndex:indexOfSubArray] addObject:classItem];
            
        } else {
            
            //create a new sub array
            NSMutableArray* newMuteArray = [NSMutableArray arrayWithObject:classItem];
            
            [topArray addObject:newMuteArray];
        }
    }
    
    return topArray;
}


#pragma mark - webdata delegate methods

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

-(void)addToArrayOfClasses:(id)currentThing{
    
    NSMutableArray *tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    if (currentThing){
        
        tempMuteArray = [NSMutableArray arrayWithArray:self.arrayOfClasses];
        [tempMuteArray addObject:currentThing];
    }
    
    self.arrayOfClasses = [NSArray arrayWithArray:tempMuteArray];
}


#pragma mark - table data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.mySearchController.active) {
        
        return 1;
        
    }else{
    
        return [self.arrayOfClassesWithAlphaStructure count];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.mySearchController.active) {
        
        return [self.searchResultsArrayOfClasses count];
        
    }else{
    
        return [[self.arrayOfClassesWithAlphaStructure objectAtIndex:section] count];
    }
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell* cell;
    
    //_______!!!!  This doesn't work with the search tool, must replace with the following...
//    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //set custom bg color on selection
        EQRColors *colors = [EQRColors sharedInstance];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [colors.colorDic objectForKey:EQRColorSelectionBlue];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    NSString* className;
    
    if (self.mySearchController.active) {
        
        className = [(EQRClassItem*)[self.searchResultsArrayOfClasses objectAtIndex:indexPath.row] section_name];
        
    }else{
        
        className = [(EQRClassItem*)[[self.arrayOfClassesWithAlphaStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] section_name];
    }
    
    cell.textLabel.text = className;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
    
}


#pragma mark - table view delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.mySearchController.active) {
        
        self.myClassItem = [self.searchResultsArrayOfClasses objectAtIndex:indexPath.row];
        
    }else{
        
        self.myClassItem = [[self.arrayOfClassesWithAlphaStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    //tell delegate to retrieve the selected class item
    [self.delegate initiateRetrieveClassItem];
    
}


#pragma mark - table index data source methods

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if (self.mySearchController.active){
        
        return nil;
    }
    
    return self.arrayOfIndexLetter;

}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    return index;
    
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

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"section_name contains[c] %@", searchText];
    self.searchResultsArrayOfClasses = [self.arrayOfClasses filteredArrayUsingPredicate:resultPredicate];
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
