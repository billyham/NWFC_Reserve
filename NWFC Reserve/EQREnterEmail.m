//
//  EQREnterEmail.m
//  Gear
//
//  Created by Dave Hanagan on 2/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQREnterEmail.h"
#import "EQRDataStructure.h"

@interface EQREnterEmail ()

@property (strong, nonatomic) IBOutlet UITextField *emailAddress;
@property (strong, nonatomic) IBOutlet UILabel *labelWithError;

@end

@implementation EQREnterEmail

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.emailAddress becomeFirstResponder];
}

-(IBAction)enterButton:(id)sender{
    
    if ([EQRDataStructure emailValidationAndSecureForDisplay:self.emailAddress.text]){
        self.labelWithError.text = @"Enter an email address";
        self.labelWithError.textColor = [UIColor blackColor];
        [self.delegate emailEntered:self.emailAddress.text];
    }else{
        self.labelWithError.text = @"Please enter a valid email address";
        self.labelWithError.textColor = [UIColor redColor];
    }
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
