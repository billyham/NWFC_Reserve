//
//  EQRGenericNumberEditor.m
//  Gear
//
//  Created by Dave Hanagan on 9/29/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRGenericNumberEditor.h"

@interface EQRGenericNumberEditor ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textViewText;
@property (strong, nonatomic) IBOutlet UIButton *enterButton;

@property (strong, nonatomic) NSString* titleString;
@property (strong, nonatomic) NSString* subTitleString;
@property (strong, nonatomic) NSString* textFieldString;
@property (strong, nonatomic) NSString* returnMethod;

@end

@implementation EQRGenericNumberEditor

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.titleString;
    self.textViewText.text = self.textFieldString;
    
    if (self.subTitleString){
        self.subTitleLabel.text = self.subTitleString;
    }else{
        [self.subTitleLabel setHidden:YES];
    }
    
    [self.textViewText becomeFirstResponder];
    
}


-(void)initalSetupWithTitle:(NSString *)title subTitle:(NSString *)subtitle currentText:(NSString *)currentText returnMethod:(NSString *)returnMethod{
    
    self.titleString = title;
    self.textFieldString = currentText;
    self.subTitleString = subtitle;
    self.returnMethod = returnMethod;
}


-(IBAction)enterButton:(id)sender{
    
    [self.delegate returnWithText:self.textViewText.text method:self.returnMethod];
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
