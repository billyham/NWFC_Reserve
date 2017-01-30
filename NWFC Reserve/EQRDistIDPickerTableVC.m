//
//  EQRDistIDPickerTableVC.m
//  Gear
//
//  Created by Ray Smith on 12/10/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRDistIDPickerTableVC.h"
#import "EQRGlobals.h"
#import "EQRScheduleRequestManager.h"
#import "EQREquipUniqueItem.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQRWebData.h"
#import "EQRDataStructure.h"
#import "EQRColors.h"

@interface EQRDistIDPickerTableVC () <EQRWebDataDelegate>

@property (strong, nonatomic) EQRScheduleRequestManager* privateRequestManager;
@property (strong, nonatomic) NSArray* arrayOfEquipUniques;
@property (strong, nonatomic) NSIndexPath* thisIndexPath;
@property (strong, nonatomic) NSString* originalKeyID;
@property (strong, nonatomic) NSMutableArray *joinsWithDateRange;

@end

@implementation EQRDistIDPickerTableVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:([UITableViewCell class]) forCellReuseIdentifier:@"Cell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)initialSetupWithOriginalUniqueKeyID:(NSString*)originalK
                             equipTitleKey:(NSString*)equipTitleKey
                              scheduleItem:(EQRScheduleRequestItem*)scheduleItem{
    
    //  1  use datastore call to get equipUniqueItems for a specified equipTitleItem_foreignKey
    //  2  use datastore call to get schedule_equip_joins in specfied date range
    //  3  keep only those with a matching titleItem_key
    //  4  mark as unavailable the equipUniques that are found in the filtered array of schedule_equip_joins to produce...
    //  5  a list of available equipUniqueItems and assign to ivar arrayOfEquipUniques
    
    //save indexpath to local ivar
    self.originalKeyID = originalK;
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;

    //get all joins for this date range
    NSString* beginDateString = [EQRDataStructure dateAsStringSansTime:scheduleItem.request_date_begin];
    NSString* endDateString = [EQRDataStructure dateAsStringSansTime:scheduleItem.request_date_end];
    
    NSArray* firstFirstArray = [NSArray arrayWithObjects:@"request_date_begin", beginDateString, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"request_date_end", endDateString, nil];
    NSArray* topTopArray = [NSArray arrayWithObjects:firstFirstArray, secondArray, nil];
    
    SEL thisSelector = @selector(addJoin:);
    
    if (!self.joinsWithDateRange){
        self.joinsWithDateRange = [NSMutableArray arrayWithCapacity:1];
    }
    [self.joinsWithDateRange removeAllObjects];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData    queryWithAsync:@"EQGetScheduleEquipUniqueJoinsWithDateRange.php"
                        parameters:topTopArray
                             class:@"EQRScheduleTracking_EquipmentUnique_Join"
                          selector:thisSelector
                        completion:^(BOOL isLoadingFlagUp) {
                            
                            if ([self.joinsWithDateRange count] < 1){
                                //error handling when no items are returned
                                NSLog(@"error, no items returned");
                            }
            
                            [self initialSetupStage2WithJoins:self.joinsWithDateRange equipTitleKey:equipTitleKey];
        }];
    });
}

-(void)initialSetupStage2WithJoins:(NSMutableArray *)tempMuteArray
                     equipTitleKey:(NSString*)equipTitleKey{
    
    //as an array of joins, tempMuteArray could have duplicate instances of an equipUniqueItem_keyID.
    //need to loop through and subtract out extras
    NSMutableArray* keepTheseJoinsWithNoDupes = [NSMutableArray arrayWithCapacity:1];
    for (EQRScheduleTracking_EquipmentUnique_Join* thisJoin in tempMuteArray){
        
        BOOL yesAddThisItem = YES;
        for (EQRScheduleTracking_EquipmentUnique_Join* thisJoinAgain in keepTheseJoinsWithNoDupes){
            
            if ([thisJoin.equipUniqueItem_foreignKey isEqualToString:thisJoinAgain.equipUniqueItem_foreignKey]){
                yesAddThisItem = NO;
            }
        }
        
        if (yesAddThisItem == YES){
            [keepTheseJoinsWithNoDupes addObject:thisJoin];
        }
    }
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    
    //get count of equipUniques
    NSArray* firstArray = [NSArray arrayWithObjects:@"equipTitleItem_foreignKey", equipTitleKey, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    NSMutableArray* arrayOfEquipUniquesWithSpecificTitle = [NSMutableArray arrayWithCapacity:1];
    [webData queryWithLink:@"EQGetEquipUniquesWithEquipTitleKey.php" parameters:topArray class:@"EQREquipUniqueItem" completion:^(NSMutableArray *muteArray) {
        
        for (id object in muteArray){
            [arrayOfEquipUniquesWithSpecificTitle addObject:object];
        }
    }];
    
    //now we have a clean array with a list of the equipUniques that are NOT available...
    for (EQREquipUniqueItem* thisEquipUniqueItem in arrayOfEquipUniquesWithSpecificTitle){
        
        for (EQRScheduleTracking_EquipmentUnique_Join* thisHereJoin in keepTheseJoinsWithNoDupes){
            
            if ([thisEquipUniqueItem.key_id isEqualToString:thisHereJoin.equipUniqueItem_foreignKey]){
                
                //                NSLog(@"marking flag is GO");
                //mark as unavailable using ivar BOOL
                thisEquipUniqueItem.unavailableFlag = YES;
            }
        }
    }
    
    //sort in asending order
    NSArray* sortedArrayOfEquipUniques = [arrayOfEquipUniquesWithSpecificTitle sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString* string1 = [(EQREquipUniqueItem*)obj1 distinquishing_id];
        NSString* string2 = [(EQREquipUniqueItem*)obj2 distinquishing_id];
        
        
        //_____need to accommodate dist ids in the hundreds.
        
        //______first change the single digits...
        
        //if dist id is only one character in length, add a 0 to the start.
        if ([string1 length] < 2){
            string1 = [NSString stringWithFormat:@"00%@", string1];
        }
        
        if ([string2 length] < 2){
            string2 = [NSString stringWithFormat:@"00%@", string2];
        }
        
        //______next change the double digits...
        
        //if dist id is only one character in length, add a 0 to the start.
        if ([string1 length] < 3){
            string1 = [NSString stringWithFormat:@"0%@", string1];
        }
        
        if ([string2 length] < 3){
            string2 = [NSString stringWithFormat:@"0%@", string2];
        }
        
        return [string1 compare:string2];
    }];
    
    //save as property
    self.arrayOfEquipUniques = [NSArray arrayWithArray:sortedArrayOfEquipUniques];
    
    //reload the table view
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrayOfEquipUniques count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell... with attributed strings
    //name and dist id
    NSString* nameAndDistID = [NSString stringWithFormat:@"%@: %@  ",
    [(EQREquipUniqueItem*)[self.arrayOfEquipUniques objectAtIndex:indexPath.row] name],
    [(EQREquipUniqueItem*)[self.arrayOfEquipUniques objectAtIndex:indexPath.row] distinquishing_id]];
    
    NSString* issueString = [(EQREquipUniqueItem*) [self.arrayOfEquipUniques objectAtIndex:indexPath.row] issue_short_name];
    NSString* status_level = [(EQREquipUniqueItem*) [self.arrayOfEquipUniques objectAtIndex:indexPath.row] status_level];
    NSInteger status_level_int = [status_level integerValue];
    
    UIFont* normalFont = [UIFont systemFontOfSize:12];
    UIColor* thisChosenColor;
    EQRColors* colors = [EQRColors sharedInstance];
    
    if (status_level_int >=EQRThresholdForSeriousIssue){
        thisChosenColor = [colors.colorDic objectForKey:EQRColorIssueSerious];  //serious issue
    }else if ((status_level_int >= EQRThresholdForMinorIssue) && (status_level_int < EQRThresholdForSeriousIssue)){
        thisChosenColor = [colors.colorDic objectForKey:EQRColorIssueMinor];   //issue not serious
    }else if ((status_level_int >= EQRThresholdForDescriptiveNote) && (status_level_int < EQRThresholdForMinorIssue)){
        thisChosenColor = [colors.colorDic objectForKey:EQRColorIssueDescriptive];  //issue is descriptive note
    }else{
        issueString = @"";  //status is resolved, so hide any issues
    }
    
    NSDictionary* arrayAttA = [NSDictionary dictionaryWithObjectsAndKeys:normalFont, NSFontAttributeName, nil];
    NSAttributedString* thisAttString = [[NSAttributedString alloc] initWithString:nameAndDistID attributes:arrayAttA];
    NSMutableAttributedString* finalAttString = [[NSMutableAttributedString alloc] initWithAttributedString:thisAttString];
    
    NSDictionary* arrayAttB = [NSDictionary dictionaryWithObjectsAndKeys:normalFont, NSFontAttributeName,
                               thisChosenColor, NSForegroundColorAttributeName, nil];
    NSAttributedString* thatAttString = [[NSAttributedString alloc] initWithString:issueString attributes:arrayAttB];
    [finalAttString appendAttributedString:thatAttString];

    //set text in cell
    [cell.textLabel setAttributedText:finalAttString];
    
    //gray out if unavailable
    if ([(EQREquipUniqueItem*)[self.arrayOfEquipUniques objectAtIndex:indexPath.row] unavailableFlag] == YES){
        
        //unavailable selection, gray out
        cell.contentView.alpha = 0.3;
        
    }else{
        
        cell.contentView.alpha = 1.0;
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
    
    if ([(EQREquipUniqueItem*)[self.arrayOfEquipUniques objectAtIndex:indexPath.row] unavailableFlag] == YES){
    
        //don't do anything when cell is grayed out
        return;
    }
    
    [self.delegate distIDSelectionMadeWithOriginalEquipUniqueKey:self.originalKeyID equipUniqueItem:[self.arrayOfEquipUniques objectAtIndex:indexPath.row]];
    
    self.privateRequestManager = nil;
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([(EQREquipUniqueItem*)[self.arrayOfEquipUniques objectAtIndex:indexPath.row] unavailableFlag] == YES){
        
        //don't allow highlighting if item is unavailable
        return NO;
        
    }else{
        
        return YES;
    }
    
}

#pragma mark - EQRWebData delegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    if(![self respondsToSelector:action]){
        NSLog(@"EQRDistIDPickerTableVC > cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
}

-(void)addJoin:(id)currentThing{
    if (!currentThing){
        return;
    }
    
    [self.joinsWithDateRange addObject:currentThing];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Dealloc

-(void)resetDistIdPicker{
    
    self.delegate = nil;
    self.privateRequestManager = nil;
    self.arrayOfEquipUniques = nil;
    
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
