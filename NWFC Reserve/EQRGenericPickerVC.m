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
@property (strong, nonatomic) IBOutlet UITextField *manualEntryField;

@property (copy) void (^enterAction)(NSString *value);

@property (strong, nonatomic) NSString* titleString;
@property (strong, nonatomic) NSString* subTitleString;
@property (strong, nonatomic) NSString *selectedValue;
@property BOOL isManualEntry;
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
    
    if (self.isManualEntry) {
        self.manualEntryField.text = self.selectedValue;
        self.manualEntryField.hidden = NO;
    } else {
        self.manualEntryField.hidden = YES;
    }
}


- (void)initialSetupWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                        array:(NSArray *)array
                selectedValue:(NSString *)selectedValue
             allowManualEntry:(BOOL)isManualEntry
                  callback:(void(^)(NSString *value))cb {
    
    self.array = array;
    self.titleString = title;
    self.subTitleString = subTitle;
    self.selectedValue = selectedValue;
    self.isManualEntry = isManualEntry;
    self.enterAction = cb;
}

- (void)setEnterButtonBlock:(void(^)(NSString *value))returnMethod {
    self.enterAction = returnMethod;
}

#pragma mark - cancel button
- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

- (IBAction)enterButton:(id)sender {
    self.enterAction(self.manualEntryField.text);
}

#pragma mark - text field action
//- (IBAction)onChange:(id)sender {
//    NSLog(@"onChange fires with %@", self.manualEntryField.text);
//    self.selectedValue = self.manualEntryField.text;
//}


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


#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedValue = [self.array objectAtIndex:indexPath.row];
    self.manualEntryField.text = self.selectedValue;
}


#pragma mark - memory warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
