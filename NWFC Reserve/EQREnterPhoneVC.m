//
//  EQREnterPhoneVC.m
//  Gear
//
//  Created by Ray Smith on 2/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQREnterPhoneVC.h"

@interface EQREnterPhoneVC ()

@property (strong, nonatomic) IBOutlet UITextField *phoneArea;
@property (strong, nonatomic) IBOutlet UITextField *phonePrefix;
@property (strong, nonatomic) IBOutlet UITextField *phoneFour;
@property (strong, nonatomic) IBOutlet UILabel *labelWithError;

@end

@implementation EQREnterPhoneVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(IBAction)changeInTextField:(id)sender{
        
    NSInteger buttonTag = [sender tag];
    
    switch (buttonTag) {
        case 0:
            if ([self.phoneArea.text length] > 2){
                [self.phonePrefix becomeFirstResponder];
            }
            break;
            
        case 1:
            if ([self.phonePrefix.text length] > 2){
                [self.phoneFour becomeFirstResponder];
            }
            break;
            
        case 2:
            if ([self.phoneFour.text length] > 3){
                [self.phoneFour resignFirstResponder];
            }
            break;
            
        default:
            break;
    }
    
}

-(IBAction)enterButton:(id)sender{
    
    NSInteger firstInt = [self.phoneArea.text length];
    NSInteger secondInt = [self.phonePrefix.text length];
    NSInteger thirdInt = [self.phoneFour.text length];
    
    if ((firstInt < 3) || (secondInt < 3) || (thirdInt < 4)){
        self.labelWithError.text = @"Please enter a valid phone number";
        self.labelWithError.textColor = [UIColor redColor];
        
    }else{
        
        self.labelWithError.text = @"Enter a phone number";
        self.labelWithError.textColor = [UIColor blackColor];
        
        NSString* stringToReturn = [NSString stringWithFormat:@"%@-%@-%@", self.phoneArea.text, self.phonePrefix.text, self.phoneFour.text];
        [self.delegate phoneEntered:stringToReturn];
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
