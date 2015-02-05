//
//  EQRMiscEditVC.m
//  Gear
//
//  Created by Dave Hanagan on 2/4/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRMiscEditVC.h"
#import "EQRMiscJoin.h"
#import "EQRWebData.h"


@interface EQRMiscEditVC ()

@property (strong, nonatomic) IBOutlet UITextView *textViewField;
@property (strong, nonatomic) IBOutlet UITableView *itemsTable;
@property (strong, nonatomic) NSArray* arrayOfMiscJoins;
@property (strong, nonatomic) NSString* miscItemString;

@end

@implementation EQRMiscEditVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



-(void)initialSetupWithScheduleTrackingKey:(NSString*)scheduleTracking_foreignKey{
    
    //register table cell
    [self.itemsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self renewTheViewWithScheduleKey:scheduleTracking_foreignKey];
}


-(void)renewTheViewWithScheduleKey:(NSString*)scheduleTracking_foreignKey{
    
    //clear out any existing value in the text field
    self.textViewField.text = @"";
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //gather any misc joins
    NSMutableArray* tempMiscMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", scheduleTracking_foreignKey];
    NSArray* omegaArray = @[alphaArray];
    [webData queryWithLink:@"EQGetMiscJoinsWithScheduleTrackingKey.php" parameters:omegaArray class:@"EQRMiscJoin" completion:^(NSMutableArray *muteArray2) {
        for (id object in muteArray2){
            [tempMiscMuteArray addObject:object];
        }
    }];
    self.arrayOfMiscJoins = [NSArray arrayWithArray:tempMiscMuteArray];
    
    [self.itemsTable reloadData];
}



#pragma mark - buttons

-(IBAction)addItemButtonTapped:(id)sender{
    
//    self.miscItemString = self.textViewField.text;
    
    //tell delegate to complete the deed.
    [delegate receiveMiscData:self.textViewField.text];
}



#pragma mark - table data methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.arrayOfMiscJoins count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [self.itemsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //remove subviews
    for (UIView* subview in [cell.contentView subviews]){
        [subview removeFromSuperview];
    }
    
    cell.textLabel.text = [(EQRMiscJoin*)[self.arrayOfMiscJoins objectAtIndex:indexPath.row] name];
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    return cell;
}





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
