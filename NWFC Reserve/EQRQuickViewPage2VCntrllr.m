//
//  EQRQuickViewPage2VCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 8/8/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRQuickViewPage2VCntrllr.h"

@interface EQRQuickViewPage2VCntrllr ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.myTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
//    [self.myTable registerClass:[UITableViewCell class] forHeaderFooterViewReuseIdentifier:@"SuppCell"];
    
    
}


#pragma mark - table view data source


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.myArray count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell =[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    for (UIView* view in cell.contentView.subviews){
        
        [view removeFromSuperview];
    }
    
    if ([self.myArray objectAtIndex:indexPath.row]){
        
        cell.textLabel.text = [self.myArray objectAtIndex:indexPath.row];
        
    }else{
        
        cell.textLabel.text = @"LIL FRX";
    }
    
    
    
    return cell;
}

//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    
//    
//    
//    
//    return @"Title";
//    
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
