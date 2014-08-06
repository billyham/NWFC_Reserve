//
//  EQRStaffUserPickerViewController.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/4/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffUserPickerViewController.h"

@interface EQRStaffUserPickerViewController ()

@end

@implementation EQRStaffUserPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _arrayOfContactObjects = [NSArray arrayWithObjects:@"Tommy", @"Billy", @"Randall", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - uipicker delegate methods (provides content)

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    
    return [self.arrayOfContactObjects objectAtIndex:row];
}


#pragma mark - uipicker datasource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    
    
    return [self.arrayOfContactObjects count];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end