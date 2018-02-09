//
//  EQREquipTitleInfoTVC.m
//  Gear
//
//  Created by Ray Smith on 10/19/17.
//  Copyright © 2017 Ham Again LLC. All rights reserved.
//

#import "EQREquipTitleInfoTVC.h"

@interface EQREquipTitleInfoTVC ()

@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *longName;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *subcategory;
@property (strong, nonatomic) NSString *scheduleGrouping;

@property (weak, nonatomic) IBOutlet UILabel *shortNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *longNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *subcategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *scheduleGroupingLabel;

@end

@implementation EQREquipTitleInfoTVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self renderText];
    [super viewWillAppear:animated];
}


- (void)setText:(NSDictionary *)properties {
    self.shortName = properties[@"shortName"];
    self.longName = properties[@"name"];
    self.category = properties[@"category"];
    self.subcategory = properties[@"subcategory"];
    self.scheduleGrouping = properties[@"scheduleGrouping"];
    
    [self renderText];
}


- (void)renderText {
    self.shortNameLabel.text = self.shortName;
    self.longNameLabel.text = self.longName;
    self.categoryLabel.text = self.category;
    self.subcategoryLabel.text = self.subcategory;
    self.scheduleGroupingLabel.text = self.scheduleGrouping;
}

#pragma mark - tableview delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0:
            [self.delegate propertySelection:@"short_name" value:self.shortName];
            break;
        case 1:
            [self.delegate propertySelection:@"name" value:self.longName];
            break;
        case 2:
            [self.delegate propertySelection:@"category" value:self.category];
            break;
        case 3:
            [self.delegate propertySelection:@"subcategory" value:self.subcategory];
            break;
        case 4:
            [self.delegate propertySelection:@"schedule_grouping" value:self.scheduleGrouping];
            break;
        default:
            break;
    }
}



#pragma mark - memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
