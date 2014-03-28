//
//  EQREditorTopVCntrllr.m
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQREditorTopVCntrllr.h"

@interface EQREditorTopVCntrllr ()

@property (strong, nonatomic) IBOutlet UITextField* nameTextField;
@property (strong, nonatomic) IBOutlet UITextField* renterTypeField;
@property (strong, nonatomic) IBOutlet UIDatePicker* pickupDateField;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnDateField;

@property (strong, nonatomic) NSDictionary* myUserInfo;

@end

@implementation EQREditorTopVCntrllr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    //set title
    self.navigationItem.title = @"Editor Request";
    
    //get scheduleTrackingRequest info and...
    //get array of schedule_equipUnique_joins
    //user self.scheduleRequestKeyID
    
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    //set local ivars with provided dictionary
    //must do this AFTER loading the view
    self.nameTextField.text =[self.myUserInfo objectForKey:@"contact_name"];
    self.renterTypeField.text = [self.myUserInfo objectForKey:@"renter_type"];
    self.pickupDateField.date = [dateFormatter dateFromString:[self.myUserInfo objectForKey:@"request_date_begin"]];
    self.returnDateField.date = [dateFormatter dateFromString:[self.myUserInfo objectForKey:@"request_date_end"]];
    
    NSLog(@"this is the key id: %@", [self.myUserInfo objectForKey:@"key_ID"]);
    
    
}


-(void)initialSetupWithInfo:(NSDictionary*)userInfo{
    
    self.myUserInfo = userInfo;
    
}


-(void)saveAction{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
