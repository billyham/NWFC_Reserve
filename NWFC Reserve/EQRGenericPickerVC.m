//
//  EQRGenericPickerVC.m
//  Gear
//
//  Created by Ray Smith on 1/18/18.
//  Copyright © 2018 Ham Again LLC. All rights reserved.
//

#import "EQRGenericPickerVC.h"

@interface EQRGenericPickerVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *array;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *enterButton;

@property (copy) void (^enterAction)(NSString *value);

@property (strong, nonatomic) NSString* titleString;
@property (strong, nonatomic) NSString* subTitleString;
@end

@implementation EQRGenericPickerVC

#pragma mark - view methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    
    self.titleLabel.text = self.titleString;
    
    if (self.subTitleString){
        self.subTitleLabel.text = self.subTitleString;
    }else{
        [self.subTitleLabel setHidden:YES];
    }
}


- (void)initialSetupWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                        array:(NSArray *)array
                selectedValue:(NSString *)selectedValue {
    
    self.array = array;
    self.titleString = title;
    self.subTitleString = subTitle;
}


#pragma mark - table data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.array[indexPath.row];
    
    return cell;
}


#pragma mark - memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
