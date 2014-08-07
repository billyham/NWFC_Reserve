//
//  EQRStaffUserPickerViewController.m
//  NWFC Reserve
//
//  Created by Ray Smith on 8/4/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRStaffUserPickerViewController.h"
#import "EQRWebData.h"
#import "EQRContactNameItem.h"

@interface EQRStaffUserPickerViewController ()



@end

@implementation EQRStaffUserPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        EQRWebData* webData = [EQRWebData sharedInstance];
        
        NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
        
        //get array of staff and interns
        [webData queryWithLink:@"EQGetEQRoomStaffAndInterns.php" parameters:nil class:@"EQRContactNameItem" completion:^(NSMutableArray *muteArray) {
            
            for (id object in muteArray){
                
                [tempMuteArray addObject:object];
            }
        }];
        
        _arrayOfContactObjects = [NSArray arrayWithArray:tempMuteArray];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
}


#pragma mark - uipicker delegate methods (provides content)

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    
    return [(EQRContactNameItem*)[self.arrayOfContactObjects objectAtIndex:row] first_and_last];
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
