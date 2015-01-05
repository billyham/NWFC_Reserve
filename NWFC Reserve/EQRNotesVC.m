//
//  EQRNotesVC.m
//  Gear
//
//  Created by Ray Smith on 12/15/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRNotesVC.h"
#import "EQRScheduleRequestItem.h"
#import "EQRWebData.h"

@interface EQRNotesVC ()

@property (strong, nonatomic) IBOutlet UITextView* myTextView;
@property (strong, nonatomic) EQRScheduleRequestItem* myRequestItem;

@end

@implementation EQRNotesVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(void)initialSetupWithScheduleRequest:(EQRScheduleRequestItem*)requestItem{
    
    self.myTextView.text = requestItem.notes;
    self.myRequestItem = requestItem;
    
    //get any existing notes text
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myRequestItem.key_id, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, nil];
    [webData queryWithLink:@"EQGetScheduleRequestQuickViewData.php" parameters:topArray class:@"EQRScheduleRequestItem" completion:^(NSMutableArray *muteArray) {
       
        for (EQRScheduleRequestItem* object in muteArray){
            
            self.myTextView.text = object.notes;
        }
    }];
    
    //present keyboard to begin editing
    [self.myTextView becomeFirstResponder];
}


-(void)beginEditing{
    
    [self.myTextView becomeFirstResponder];
}


-(IBAction)doneButtonTapped:(id)sender{
    
    //udpate data layer
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    //error handling when no myRequestItem.key_id exists
    if (self.myRequestItem == nil){
        
        return;
    }
    
    NSArray* firstArray = [NSArray arrayWithObjects:@"key_id", self.myRequestItem.key_id, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"notes", self.myTextView.text, nil];
    NSArray* topArray = [NSArray arrayWithObjects:firstArray, secondArray, nil];
    
    [webData queryForStringWithLink:@"EQAlterNotesInScheduleRequest.php" parameters:topArray];
    
    //inform delegate
    [self.delegate retrieveNotesData:self.myTextView.text];
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
