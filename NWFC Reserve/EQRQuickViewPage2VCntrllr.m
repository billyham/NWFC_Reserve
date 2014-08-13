//
//  EQRQuickViewPage2VCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/8/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRQuickViewPage2VCntrllr.h"
#import "EQRWebData.h"
#import "EQRScheduleTracking_EquipmentUnique_Join.h"
#import "EQREquipItem.h"
#import "EQRGlobals.h"

@interface EQRQuickViewPage2VCntrllr ()

@property (strong, nonatomic) IBOutlet UITableView* myTable;
@property (strong, nonatomic) NSArray* myArray;
@property (strong, nonatomic) NSArray* myArrayWithStructure;

@end

@implementation EQRQuickViewPage2VCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _myArray = [NSArray arrayWithObjects:@"one", @"two", @"three", @"four", @"five", nil];
        
        
    }
    return self;
}


-(void)initialSetupWithKeyID:(NSString*)keyID{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"scheduleTracking_foreignKey", keyID, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    
    [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
        
        for (EQRScheduleTracking_EquipmentUnique_Join* join in muteArray){
            
            [tempMuteArray addObject:join];
        }
        
    }];
    
    self.myArray = [NSArray arrayWithArray:tempMuteArray];
    
    //create structured array for headings
    self.myArrayWithStructure = [self turnFlatArrayToStructuredArray:self.myArray];
    
    [self.myTable reloadData];
    
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray{
    
    //first get array of grouping objects
    //get title items EQGetEquipmentTitlesAll (except items with hide_from_public set to YES)
    EQRWebData* webData = [EQRWebData sharedInstance];
    __block NSMutableSet* tempMuteSetOfGroupingStrings = [NSMutableSet setWithCapacity:1];
    __block NSMutableDictionary* tempMuteDicOfTitleKeysToGrouping = [NSMutableDictionary dictionaryWithCapacity:1];
    
    
    [webData queryWithLink:@"EQGetEquipmentTitlesAll.php" parameters:nil class:@"EQREquipItem" completion:^(NSMutableArray *muteArray) {
        
        //loop through entire title item array
        for (EQREquipItem* item in muteArray){
            
            //add item's schedule_grouping to the dictionary
            [tempMuteDicOfTitleKeysToGrouping setValue:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]forKey:item.key_id];
            
            BOOL foundTitleDontAdd = NO;
            
            for (NSString* titleString in tempMuteSetOfGroupingStrings){
                
                //identify items with schedule _grouping already in our muteable array
                if ([[item performSelector:NSSelectorFromString(EQRScheduleGrouping)] isEqualToString:titleString]){
                    
                    foundTitleDontAdd = YES;
                }
            }
            
            //advance to next title item
            if (foundTitleDontAdd == NO){
                
                //otherwise add grouping in set
                [tempMuteSetOfGroupingStrings addObject:[item performSelector:NSSelectorFromString(EQRScheduleGrouping)]];
            }
        }
    }];
    
    NSMutableArray* tempTopArray = [NSMutableArray arrayWithCapacity:1];
    
    //loop through ivar array of joins
    for (EQRScheduleTracking_EquipmentUnique_Join* join in flatArray){
        
        //find a matching key_id
        NSString* groupingString = [tempMuteDicOfTitleKeysToGrouping objectForKey:join.equipTitleItem_foreignKey];
        
        //assign to join object
        join.schedule_grouping = groupingString;
        
        BOOL createNewSubArray = YES;
        
        for (NSMutableArray* subArray in tempTopArray){
            
            if ([join.schedule_grouping isEqualToString:[(EQRScheduleTracking_EquipmentUnique_Join*)[subArray objectAtIndex:0] schedule_grouping]]){
                
                createNewSubArray = NO;
                
                //add join to this subArray
                [subArray addObject:join];
            }
        }
        
        if (createNewSubArray == YES){
            
            //create a new array
            NSMutableArray* newArray = [NSMutableArray arrayWithObject:join];
            
            //add the subarray to the top array
            [tempTopArray addObject:newArray];
        }
        
    }
    
    NSArray* arrayToReturn = [NSArray arrayWithArray:tempTopArray];
    
    //sort the array alphabetically
    NSArray* sortedTopArray = [arrayToReturn sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [[(EQRScheduleTracking_EquipmentUnique_Join*)[obj1 objectAtIndex:0] schedule_grouping]
                compare:[(EQRScheduleTracking_EquipmentUnique_Join*)[obj2 objectAtIndex:0] schedule_grouping]];
    }];
    
    return sortedTopArray;
}

#pragma clang diagnostic pop


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.myTable registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"SuppCell"];
    
}


#pragma mark - table view data source


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
//    return 1;
    
    return [self.myArrayWithStructure count];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    return [self.myArray count];
    
    return [[self.myArrayWithStructure objectAtIndex:section] count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell =[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    if ([self.myArray objectAtIndex:indexPath.row]){
        
        NSString* stringWithDistID = [NSString stringWithFormat:@"%@  # %@",[(EQRScheduleTracking_EquipmentUnique_Join*)[[self.myArrayWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name], [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.myArrayWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] distinquishing_id ]];
        
        cell.textLabel.text = stringWithDistID;
        
    }else{
        
        cell.textLabel.text = @"LIL FRX";
    }
    
    //set size
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.myArrayWithStructure objectAtIndex:section] objectAtIndex:0] schedule_grouping];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
