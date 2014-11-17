//
//  EQRContactPickerVC.m
//  Gear
//
//  Created by Ray Smith on 11/16/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRContactPickerVC.h"
#import "EQRWebData.h"
#import "EQRContactNameItem.h"

@interface EQRContactPickerVC ()

@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSArray* arrayOfContacts;
@property (strong, nonatomic) NSArray* arrayOfContactsWithStructure;
@property (strong, nonatomic) NSArray* arrayOfIndexLetter;
@property (strong, nonatomic) NSArray* searchResultArrayOfContacts;
@property (strong, nonatomic) EQRContactNameItem* selectedNameItem;


@end

@implementation EQRContactPickerVC

@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //register cells
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        
    [self renewTheView];
    
}


-(void)renewTheView{
    
    //get ALL contacts ???
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetAllContactNames.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
       
        for (EQRContactNameItem* nameItem in muteArray){
            
            [tempMuteArray addObject:nameItem];
        }
    }];
    
    if ([tempMuteArray count] < 1){
        
        //error handling if 0 is returned
    }
    
    //_______move to expand method??_____
    //alphabatize the name list
    NSArray* sortedArray = [tempMuteArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
       
        NSString* string1 = [(EQRContactNameItem*)obj1 first_and_last];
        NSString* string2 = [(EQRContactNameItem*)obj2 first_and_last];
        
        return [string1 compare:string2];
    }];
    //__________
    
    self.arrayOfContacts = [NSArray arrayWithArray:sortedArray];
    
    //put some structure on that array of namesItems
    self.arrayOfContactsWithStructure = [NSArray arrayWithArray: [self expandFlatArrayToStructuredArray:sortedArray]];
}




-(NSArray*)expandFlatArrayToStructuredArray:(NSArray*)thisArray{
    
    //_______read user defaults to determine if sort should be based on first or last name_____
//    NSString* nameSorter = @"first_and_last";
    
    //an array of letters
    NSMutableArray* arrayOfLetters = [NSMutableArray arrayWithCapacity:1];
    
    //enumerate through the flat array and add the first letter
    for (EQRContactNameItem* nameItem in thisArray){
        
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


#pragma mark - retrieve selection

-(id)retrieveContactItem{
    
    return self.selectedNameItem;
}



#pragma mark - table data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        
        return 1;
        
    }else{
    
        return [self.arrayOfContactsWithStructure count];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
    
        return [self.searchResultArrayOfContacts count];
        
    }else{
        
        return [[self.arrayOfContactsWithStructure objectAtIndex:section] count];
    }
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //determine either search results table or normal table
    
    
    //____________  NOTICE A KEY FEATURE: USING self.tableview INSTEAD OF tableview  !!!!!!_______________
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //name
    NSString* nameString;
    
    //_______determine either search results table or normal table
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        nameString = [(EQRContactNameItem*)[self.searchResultArrayOfContacts objectAtIndex:indexPath.row] first_and_last];
        
    }else{
        
        nameString = [(EQRContactNameItem*)[(NSArray*)[self.arrayOfContactsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] first_and_last];
    }
    
    
    cell.textLabel.text = nameString;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        
        return @"";
        
    }else{
        
        NSString* letter = [[(EQRContactNameItem*)[[self.arrayOfContactsWithStructure objectAtIndex:section] objectAtIndex:0] first_and_last] substringToIndex:1];
        
        NSString* letterCaseInsensitive = [letter capitalizedString];
        
        return letterCaseInsensitive;
        
    }
}


#pragma mark - table index data source methods

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return self.arrayOfIndexLetter;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    return index;
    
}


#pragma mark - delegate method 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"delegate did fire in the contact picker VC");
    
    //identify the selected request for later
    //____determine if search view is present
    if (self.searchDisplayController.active) {
        
        self.selectedNameItem = [self.searchResultArrayOfContacts objectAtIndex:indexPath.row];
        
    }else{
        
        self.selectedNameItem = [[self.arrayOfContactsWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [self.delegate retrieveSelectedNameItem];
    
}


#pragma mark - search box methods

//Basically, a predicate is an expression that returns a Boolean value (true or false). You specify the search criteria in the format of NSPredicate and use it to filter data in the array. As the search is on the name of recipe, we specify the predicate as “name contains[c] %@”. The “name” refers to the name property of the Recipe object. NSPredicate supports a wide range of filters including: BEGINSWITH, ENDSWITH, LIKE, MATCHES, CONTAINS. Here we choose to use the “contains” filter. The operator “[c]” means the comparison is case-insensitive.

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"first_and_last contains[c] %@", searchText];
    self.searchResultArrayOfContacts = [self.arrayOfContacts filteredArrayUsingPredicate:resultPredicate];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
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
