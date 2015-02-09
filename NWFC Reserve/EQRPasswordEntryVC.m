//
//  EQRPasswordEntryVC.m
//  Gear
//
//  Created by Ray Smith on 2/9/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPasswordEntryVC.h"
#import "EQRWebData.h"
#import "EQRTextElement.h"
#import "EQRGlobals.h"

@interface EQRPasswordEntryVC ()

@property (strong, nonatomic) IBOutlet UITextField* passwordField;
@property (strong, nonatomic) IBOutlet UILabel* incorrectWarning;

@end

@implementation EQRPasswordEntryVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)enterButton:(id)sender{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    NSMutableArray* tempMuteArray = [NSMutableArray arrayWithCapacity:1];
    NSArray* firstArray = @[@"context", @"passwordUser"];
    NSArray* topArray = @[firstArray];
    [webData queryWithLink:@"EQGetTextElementsWithContext.php" parameters:topArray class:@"EQRTextElement" completion:^(NSMutableArray *muteArray) {
        
        for (EQRTextElement* textElementObject in muteArray){
            [tempMuteArray addObject:textElementObject];
        }
    }];
    
    BOOL passwordSuccess = NO;
    
//    NSLog(@"count of passwords from db: %u", [tempMuteArray count]);
    
    if ([tempMuteArray count] > 0){
        
        for (EQRTextElement* textElement in tempMuteArray){
            
            NSLog(@"this is the password from the db >>%@<<", textElement.text);
            
            //check all user passwords
            if ([self.passwordField.text isEqualToString:textElement.text]){
                passwordSuccess = YES;
                break;
            }
        }
    }else{
        //error handling for no returns
    }
    
    //hardcoded password
    if (EQRAllowHardcodedPassword){
        
        if ([EQRHardcodedPassword isEqualToString:self.passwordField.text]){
            passwordSuccess = YES;
        }
    }
    
    
    if (passwordSuccess){
        
        [self.incorrectWarning setHidden:YES];
        //tell presenting VC if successful or not
        [self.delegate passwordEntered:passwordSuccess];
        
    }else{
        
        //inform user of incorrect password and try again
        [self.incorrectWarning setHidden:NO];
        self.passwordField.text = @"";
    }
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


