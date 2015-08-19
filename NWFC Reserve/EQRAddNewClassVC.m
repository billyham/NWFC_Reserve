//
//  EQRAddNewClassVC.m
//  Gear
//
//  Created by Ray Smith on 8/18/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRAddNewClassVC.h"
#import "EQRClassPickerVC.h"
#import "EQRContactPickerVC.h"
#import "EQRGlobals.h"
#import "EQRWebData.h"

@interface EQRAddNewClassVC () <UITextFieldDelegate, EQRClassPickerDelegate, EQRContactPickerDelegate, EQRWebDataDelegate>

@property (strong, nonatomic) IBOutlet UITextView *titleView;
@property (strong, nonatomic) IBOutlet UITextField *sectionStartDate;
@property (strong, nonatomic) IBOutlet UITextField *term;
@property (strong, nonatomic) IBOutlet UIButton *instructorButton;

@property (strong, nonatomic) EQRClassItem *myClassItem;
@property (strong, nonatomic) EQRClassItem *referenceClassItem;
@property (strong, nonatomic) EQRContactNameItem *instructorContactItem;

@property BOOL isMakingNewClassCatalogItem;

@end

@implementation EQRAddNewClassVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* currentTerm = [[[NSUserDefaults standardUserDefaults] objectForKey:@"term"] objectForKey:@"term"];
    self.term.text = currentTerm;
    
}

#pragma mark - actions

-(IBAction)doneButton:(id)sender{
    
    [self.delegate informClassAdditionHasHappended:self.myClassItem];
 
}


-(IBAction)cancelButton:(id)sender{
    
    //go back to previous VC
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)selectTitleFromClassListButton:(id)sender{
    
    EQRClassPickerVC *classPickerVC = [[EQRClassPickerVC alloc] initWithNibName:@"EQRClassPickerVC" bundle:nil];
    
    classPickerVC.delegate = self;
    
    [self.navigationController pushViewController:classPickerVC animated:YES];

}


-(IBAction)selectInstructorButton:(id)sender{
    
    EQRContactPickerVC *contactPickerVC = [[EQRContactPickerVC alloc] initWithNibName:@"EQRContactPickerVC" bundle:nil];
    
    contactPickerVC.delegate = self;
    
    [self.navigationController pushViewController:contactPickerVC animated:YES];
    
}


#pragma mark - textView delegate methods

- (void)textViewDidChange:(UITextView *)textView{
    
    self.isMakingNewClassCatalogItem = YES;
    
}



#pragma mark - classPicker delegate methods (funny!)

-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem{
    
    self.isMakingNewClassCatalogItem = NO;
    
    self.referenceClassItem = selectedClassItem;
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
//    SEL thisSelector = NSSelectorFromString(@"retrieveClassCatalogTitle:");
   
    NSArray *firstArray = @[@"key_id", selectedClassItem.catalog_foreign_key];
    NSArray *topArray = @[firstArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQGetClassCatalogTitleWithKey.php" parameters:topArray completion:^(NSString *catalogTitle) {
            
            self.titleView.text = catalogTitle;
            
        }];
    
    });
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - contact picker delegate methods

-(void)retrieveSelectedNameItem{
    
    
    
    
}


-(void)retrieveSelectedNameItemWithObject:(id)contactObject{
    
    self.instructorContactItem = contactObject;
    
    [self.instructorButton setTitle:self.instructorContactItem.first_and_last forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];

    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - webData delegate methods

-(void)addASyncDataItem:(id)currentThing toSelector:(SEL)action{
    
    
}

//-(void)retrieveClassCatalogTitle:(id)currentObject{
//    
//    
//}




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
