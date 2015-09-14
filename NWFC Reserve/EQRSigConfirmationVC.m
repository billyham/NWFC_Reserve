//
//  EQRSigConfirmationVCViewController.m
//  Gear
//
//  Created by Ray Smith on 9/11/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRSigConfirmationVC.h"

@interface EQRSigConfirmationVC ()

@end

@implementation EQRSigConfirmationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"EQRSigConfirmationVC > viewDidLoad");
    
    // Do any additional setup after loading the view.
}



-(IBAction)confirmButton:(id)sender{
    
    
    [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:^{

        
    }];
}


-(IBAction)cancelButton:(id)sender{
    
    
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
