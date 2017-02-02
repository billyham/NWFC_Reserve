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


@interface EQRMiscEditVC () <EQRWebDataDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textViewField;
@property (strong, nonatomic) IBOutlet UITableView *itemsTable;
@property (strong, nonatomic) NSMutableArray* arrayOfMiscJoins;
@property (strong, nonatomic) NSString* miscItemString;

@end

@implementation EQRMiscEditVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.itemsTable.rowHeight = UITableViewAutomaticDimension;
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
    webData.delegateDataFeed = self;
    
    //gather any misc joins
    NSArray* alphaArray = @[@"scheduleTracking_foreignKey", scheduleTracking_foreignKey];
    NSArray* omegaArray = @[alphaArray];
    
    if (!self.arrayOfMiscJoins){
        self.arrayOfMiscJoins = [NSMutableArray arrayWithCapacity:1];
    }
    [self.arrayOfMiscJoins removeAllObjects];
    
    SEL selector = @selector(addMiscJoin:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       [webData queryWithAsync:@"EQGetMiscJoinsWithScheduleTrackingKey.php"
                    parameters:omegaArray
                         class:@"EQRMiscJoin"
                      selector:selector
                    completion:^(BOOL isLoadingFlagUp) {
          
           [self.itemsTable reloadData];
       }];
    });
}

#pragma mark - buttons

-(IBAction)addItemButtonTapped:(id)sender{
    
//    self.miscItemString = self.textViewField.text;
    //tell delegate to complete the deed.
    [delegate receiveMiscData:self.textViewField.text];
}


#pragma mark - EQRWebData delegate methods
-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    if (![self respondsToSelector:action]){
        NSLog(@"EQRMiscEditVC > cannot perform selector");
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
}

-(void)addMiscJoin:(id)currentThing{
    if (!currentThing){
        return;
    }
    [self.arrayOfMiscJoins addObject:currentThing];
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
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.numberOfLines = 0;
    
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
