//
//  EQRGenericTextEditor.m
//  Gear
//
//  Created by Ray Smith on 3/10/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRGenericTextEditor.h"

@interface EQRGenericTextEditor ()

@property (copy) void (^enterAction)(NSString *value);

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textViewText;
@property (strong, nonatomic) IBOutlet UIButton *enterButton;

@property (strong, nonatomic) NSString* titleString;
@property (strong, nonatomic) NSString* subTitleString;
@property (strong, nonatomic) NSString* textFieldString;
@property (strong, nonatomic) NSString* keyboardPreference;
@property (strong, nonatomic) NSString* returnMethod;


@end

@implementation EQRGenericTextEditor

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.titleString;
    self.textViewText.text = self.textFieldString;
    
    if (self.subTitleString){
        self.subTitleLabel.text = self.subTitleString;
    }else{
        [self.subTitleLabel setHidden:YES];
    }
    
    
    if ([self.keyboardPreference isEqualToString:@"UIKeyboardTypeEmailAddress"]){
        self.textViewText.keyboardType = UIKeyboardTypeEmailAddress;
    }else if ([self.keyboardPreference isEqualToString:@"UIKeyboardTypeURL"]){
        self.textViewText.keyboardType = UIKeyboardTypeURL;
    }else if ([self.keyboardPreference isEqualToString:@"UIKeyboardTypeNumbersAndPunctuation"]){
        self.textViewText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }else {
        self.textViewText.keyboardType = UIKeyboardTypeDefault;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textViewText becomeFirstResponder];
}


- (void)initalSetupWithTitle:(NSString *)title
                   subTitle:(NSString *)subtitle
                currentText:(NSString *)currentText
                   keyboard:(NSString *)keyboard
               returnMethod:(NSString *)returnMethod{
    
    self.titleString = title;
    self.textFieldString = currentText;
    self.subTitleString = subtitle;
    self.keyboardPreference = keyboard;
    self.returnMethod = returnMethod;
}

- (void)setEnterButtonBlock:(void(^)(NSString *value))returnMethod {
    self.enterAction = returnMethod;
}

- (IBAction)enterButton:(id)sender{
    if (self.enterAction != nil) {
        self.enterAction(self.textViewText.text);
    } else {
        [self.delegate returnWithText:self.textViewText.text method:self.returnMethod];
    }
}

- (IBAction)cancelButton:(id)sender{
    [self.delegate cancelByDismissingVC];
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
