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
    
    //gather any misc joins
    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", keyID];
    NSArray* omegaArray = @[alphaArray];
    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
        
        for (id object in muteArray2){
            [tempMiscMuteArray addObject:object];
        }
    }];
        
    //create structured array for headings
//    self.myArrayWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.myArray];
    self.myArrayWithStructure = [EQRDataStructure turnFlatArrayToStructuredArray:self.myArray withMiscJoins:tempMiscMuteArray];
    
    [self.myTable reloadData];
    
}


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
        
        cell.textLabel.text = @"ERROR: COUNT OF OBJECTS IS INCORRECT";
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
