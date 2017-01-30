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

@interface EQRPasswordEntryVC () <EQRWebDataDelegate>

@property (strong, nonatomic) IBOutlet UITextField* passwordField;
@property (strong, nonatomic) IBOutlet UILabel* incorrectWarning;
@property (strong, nonatomic) NSMutableArray *passwords;

@end

@implementation EQRPasswordEntryVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.passwordField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)enterButton:(id)sender{
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    NSArray* firstArray = @[@"context", @"passwordUser"];
    NSArray* topArray = @[firstArray];
    
    if (!self.passwords){
        self.passwords = [NSMutableArray arrayWithCapacity:1];
    }
    [self.passwords removeAllObjects];
    
    SEL selector = @selector(addPassword:);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
       [webData queryWithAsync:@"EQGetTextElementsWithContext.php" parameters:topArray class:@"EQRTextElement" selector:selector completion:^(BOOL isLoadingFlagUp) {
          
           if (self.passwords.count < 1){
               NSLog(@"EQRPasswordEntryVC > failed to retrieve any password textElements");
           }
           
           BOOL passwordSuccess = NO;
           
           for (EQRTextElement* textElement in self.passwords){
               //check all user passwords
               if ([self.passwordField.text isEqualToString:textElement.text]){
                   passwordSuccess = YES;
                   break;
               }
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
           
       }];
    });
    
//    [webData queryWithLink:@"EQGetTextElementsWithContext.php" parameters:topArray class:@"EQRTextElement" completion:^(NSMutableArray *muteArray) {
//        
//        for (EQRTextElement* textElementObject in muteArray){
//            [tempMuteArray addObject:textElementObject];
//        }
//    }];
}

#pragma mark - EQRWebData delegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    if (![self respondsToSelector:action]){
        NSLog(@"EQRPasswordEntryVC > cannot perform selector: %@", NSStringFromSelector(action));
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:action withObject:currentThing];
#pragma clang diagnostic pop
}

-(void)addPassword:(id)currentThing{
    if (!currentThing){
        return;
    }
    [self.passwords addObject:currentThing];
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


