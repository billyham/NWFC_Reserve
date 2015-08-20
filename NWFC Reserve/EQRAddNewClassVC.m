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
#import "EQRClassCatalog.h"

@interface EQRAddNewClassVC () <UITextFieldDelegate, EQRClassPickerDelegate, EQRContactPickerDelegate, EQRWebDataDelegate>

@property (strong, nonatomic) IBOutlet UITextView *titleView;
@property (strong, nonatomic) IBOutlet UITextField *sectionStartDate;
@property (strong, nonatomic) IBOutlet UITextField *term;
@property (strong, nonatomic) IBOutlet UIButton *instructorButton;

@property (strong, nonatomic) EQRClassItem *myClassItem;
@property (strong, nonatomic) EQRClassItem *referenceClassItem;
@property (strong, nonatomic) EQRContactNameItem *instructorContactItem;

@property BOOL isMakingNewClassCatalogItem;
@property BOOL hasInstructorID;

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
    
    //determine if classCatalog is new or not
    //if new, submit information to database and receive the catalogObject (or at least the key)
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    if (self.isMakingNewClassCatalogItem){  //create a classCatalog item
        
        if (!self.titleView.text || [self.titleView.text isEqualToString:@""]){
            //error handling if no title exists.
            //
            [self.delegate informClassAdditionHasHappended:nil];
        }
        
        EQRClassCatalog *classCatalogItem = [[EQRClassCatalog alloc] init];
        classCatalogItem.title = self.titleView.text;
        classCatalogItem.instructor_foreign_key = @"";
        classCatalogItem.instructor_name = @"";
        
        if (self.hasInstructorID){
            classCatalogItem.instructor_foreign_key = self.instructorContactItem.key_id;
            classCatalogItem.instructor_name = self.instructorContactItem.first_and_last;
        }
        
        NSArray *firstArray = @[@"title", classCatalogItem.title];
        NSArray *secondArray = @[@"instructor_foreign_key", classCatalogItem.instructor_foreign_key];
        NSArray *thirdArray = @[@"instructor_name", classCatalogItem.instructor_name];
        NSArray *topArray = @[firstArray, secondArray, thirdArray];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            
            [webData queryForStringwithAsync:@"EQSetNewClassCatalog.php" parameters:topArray completion:^(NSString *returnKey) {
                
                if (returnKey){
                    [self doneButtonStage2:returnKey];
                }else{
                    //error handle failed return key
                    NSLog(@"EQRAddNewClassVC > dontButton, failed to get a returnString classCatalog key");
                    [self.delegate informClassAdditionHasHappended:nil];
                }
            }];
        });
        
    }else{    //use existing classCatalog item
        
        if (self.referenceClassItem) {
            
            if (self.referenceClassItem.catalog_foreign_key){
                
                [self doneButtonStage2:self.referenceClassItem.catalog_foreign_key];
                
            }else{
                //error handling if no catalog foreign key exists
                NSLog(@"EQRAddNewClassVC > doneButton, expects a reference class item, but its catalog foreign key is nil");
                [self.delegate informClassAdditionHasHappended:nil];
            }
        }else{
            //error handling if no reference class object exists
            NSLog(@"EQRAddNewClassVC > doneButton, expects a reference class item, but property is nil");
            [self.delegate informClassAdditionHasHappended:nil];
        }
    }
}


-(void)doneButtonStage2:(NSString *)classCatalogForeignKey{
    
    EQRWebData *webData = [EQRWebData sharedInstance];
    webData.delegateDataFeed = self;
    
    //submit information about new class section to database and receive sectionObject
    EQRClassItem *classItem = [[EQRClassItem alloc] init];
    classItem.catalog_foreign_key = classCatalogForeignKey;
    classItem.section_name = [NSString stringWithFormat:@"%@ - Starts %@", self.titleView.text, self.sectionStartDate.text];
    classItem.term = self.term.text;
    
    NSArray *firstArray = @[@"section_name", classItem.section_name];
    NSArray *secondArray = @[@"catalog_foreign_key", classItem.catalog_foreign_key];
    NSArray *thirdArray = @[@"term", classItem.term];
    NSArray *topArray = @[firstArray, secondArray, thirdArray];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQSetNewClassSection.php" parameters:topArray completion:^(NSString *returnKey) {
            
            if (returnKey){
            
                classItem.key_id = returnKey;
                [self.delegate informClassAdditionHasHappended:classItem];

            }else{
                //error handle failed return key
                NSLog(@"EQRAddNewClassVC > dontButtonStage2, failed to get a return from classSection key");
                [self.delegate informClassAdditionHasHappended:nil];
            }
        }];
    });
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
    //this is a required method in the protocol, but
    //no need to do anything because the next method does the work
}


-(void)retrieveSelectedNameItemWithObject:(id)contactObject{
    
    if (contactObject){
        self.hasInstructorID = YES;
    }
    
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
