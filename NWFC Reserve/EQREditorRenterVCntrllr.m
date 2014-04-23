//
//  EQREditorRenterVCntrllrViewController.m
//  NWFC Reserve
//
//  Created by Ray Smith on 4/17/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorRenterVCntrllr.h"
#import "EQRGlobals.h"

@interface EQREditorRenterVCntrllr ()

@end

@implementation EQREditorRenterVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

}

-(void)initialSetup{
    
    //set the renterpicker to the correct value
    if ([self.renter_type isEqualToString:EQRRenterStudent]){
        
        [self.renterTypePicker selectRow:0 inComponent:0 animated:NO];
        
    }else if([self.renter_type isEqualToString:EQRRenterPublic]){
        
        [self.renterTypePicker selectRow:1 inComponent:0 animated:NO];
        
    }else if([self.renter_type isEqualToString:EQRRenterFaculty]){
        
        [self.renterTypePicker selectRow:2 inComponent:0 animated:NO];
        
    }else if([self.renter_type isEqualToString:EQRRenterStaff]){
        
        [self.renterTypePicker selectRow:3 inComponent:0 animated:NO];
        
    }else if([self.renter_type isEqualToString:EQRRenterYouth]){
        
        [self.renterTypePicker selectRow:4 inComponent:0 animated:NO];
    }
}

#pragma mark - picker view datasource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return 5;
}




#pragma mark - picker view delegate methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSDictionary* arrayAttA = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:8] forKey:NSFontAttributeName];
    
    if (row == 0){
        
        return [[NSAttributedString alloc] initWithString:EQRRenterStudent attributes:arrayAttA];
        
    } else if(row == 1){
        
        return [[NSAttributedString alloc] initWithString:EQRRenterPublic attributes:arrayAttA];
        
    }else if(row == 2){
        
        return [[NSAttributedString alloc] initWithString:EQRRenterFaculty attributes:arrayAttA];
        
    }else if (row == 3){
        
        return [[NSAttributedString alloc] initWithString:EQRRenterStaff attributes:arrayAttA];
        
    }else if (row == 4){
        
        return [[NSAttributedString alloc] initWithString:EQRRenterYouth attributes:arrayAttA];
        
    }else{
        
        return [[NSAttributedString alloc] initWithString:@"NA" attributes:arrayAttA];
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 25.f;  //30.f
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    
    return 200.f;  //210.f
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    switch (row) {
        case 0:
            self.renter_type = EQRRenterStudent;
            break;
            
        case 1:
            self.renter_type = EQRRenterPublic;
            break;
            
        case 2:
            self.renter_type = EQRRenterFaculty;
            break;
            
        case 3:
            self.renter_type = EQRRenterStaff;
            break;
            
        case 4:
            self.renter_type = EQRRenterYouth;
            break;
            
        default:
            self.renter_type = @"";
            break;
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
