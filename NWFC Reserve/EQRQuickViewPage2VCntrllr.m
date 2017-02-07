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
#import "EQRDataStructure.h"
#import "EQRMiscJoin.h"

@interface EQRQuickViewPage2VCntrllr ()

@property (strong, nonatomic) IBOutlet UITableView* myTable;
@property (strong, nonatomic) NSMutableArray* myArray;
@property (strong, nonatomic) NSArray* myArrayWithStructure;
@property (strong, nonatomic) NSMutableArray *miscJoins;

@end

@implementation EQRQuickViewPage2VCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


-(void)initialSetupWithKeyID:(NSString*)keyID{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"initialSetup";
    queue.maxConcurrentOperationCount = 3;
    
    NSBlockOperation *getScheduleEquipJoinsForCheckWithScheduleTrackingKey = [NSBlockOperation blockOperationWithBlock:^{
        NSArray* firstArray = @[@"scheduleTracking_foreignKey", keyID];
        NSArray* topArray = @[firstArray];
        
        if (!self.myArray) self.myArray = [NSMutableArray arrayWithCapacity:1];
        [self.myArray removeAllObjects];
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetScheduleEquipJoinsForCheckWithScheduleTrackingKey.php" parameters:topArray class:@"EQRScheduleTracking_EquipmentUnique_Join" completion:^(NSMutableArray *muteArray) {
            for (EQRScheduleTracking_EquipmentUnique_Join *join in muteArray){
                [self.myArray addObject:join];
            }
        }];
    }];
    
    
    NSBlockOperation *getMiscJoinsWithScheduleTrackingKey = [NSBlockOperation blockOperationWithBlock:^{
        // Gather any misc joins
        NSArray* alphaArray = @[@"scheduleTracking_foreignKey", keyID];
        NSArray* omegaArray = @[alphaArray];
        
        if (!self.miscJoins) self.miscJoins = [NSMutableArray arrayWithCapacity:1];
        [self.miscJoins removeAllObjects];
        
        EQRWebData *webData = [EQRWebData sharedInstance];
        [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray) {
            for (EQRMiscJoin *join in muteArray){
                [self.miscJoins addObject:join];
            }
        }];
    }];
    
    
    NSBlockOperation *createStructuredArray = [NSBlockOperation blockOperationWithBlock:^{
        // Create structured array for headings
        self.myArrayWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.myArray withMiscJoins:self.miscJoins];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myTable reloadData];
        });
        
    }];
    [createStructuredArray addDependency:getScheduleEquipJoinsForCheckWithScheduleTrackingKey];
    [createStructuredArray addDependency:getMiscJoinsWithScheduleTrackingKey];

    
    [queue addOperation:getScheduleEquipJoinsForCheckWithScheduleTrackingKey];
    [queue addOperation:getMiscJoinsWithScheduleTrackingKey];
    [queue addOperation:createStructuredArray];
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.myTable registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"SuppCell"];
}


#pragma mark - table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.myArrayWithStructure count];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.myArrayWithStructure objectAtIndex:section] count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell =[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    for (UIView* view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    //__1__ is normal equip join object
    //__2__ is miscJoin object
    
    if ([[self.myArrayWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]){
        
        if ([[[self.myArrayWithStructure objectAtIndex:indexPath.section] objectAtIndex:0] respondsToSelector:@selector(schedule_grouping)]){
            NSString* stringWithDistID = [NSString stringWithFormat:@"%@  # %@",[(EQRScheduleTracking_EquipmentUnique_Join*)[[self.myArrayWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name], [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.myArrayWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] distinquishing_id ]];
            cell.textLabel.text = stringWithDistID;
        }else{
            NSString* stringForMisc = [NSString stringWithFormat:@"%@",[(EQRScheduleTracking_EquipmentUnique_Join*)[[self.myArrayWithStructure objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name]];
            cell.textLabel.text = stringForMisc;
        }
        
    }else{
        cell.textLabel.text = @"EQRQuickViewPage2VC > ERROR: COUNT OF OBJECTS IS INCORRECT";
    }
    
    //set size
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    //__1__ is normal equip join object
    //__2__ is miscJoin object
    
    if ([[[self.myArrayWithStructure objectAtIndex:section] objectAtIndex:0] respondsToSelector:@selector(schedule_grouping)]){
        return [(EQRScheduleTracking_EquipmentUnique_Join*)[[self.myArrayWithStructure objectAtIndex:section] objectAtIndex:0] schedule_grouping];
    }else{
        return @"Miscellaneous";
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
