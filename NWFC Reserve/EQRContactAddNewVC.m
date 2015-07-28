//
//  EQRContactAddNewVC.m
//  Gear
//
//  Created by Ray Smith on 11/23/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import "EQRContactAddNewVC.h"
#import "EQRWebData.h"
#import "EQRGlobals.h"

@interface EQRContactAddNewVC ()

@property (strong, nonatomic) IBOutlet UITextField* firstNameTextF;
@property (strong, nonatomic) IBOutlet UITextField* lastNameTextF;
@property (strong, nonatomic) IBOutlet UITextField* phoneTextF;
@property (strong, nonatomic) IBOutlet UITextField* emailTextF;

@property (strong, nonatomic) IBOutlet UISwitch* facultySwitch;
@property (strong, nonatomic) IBOutlet UISwitch* staffSwitch;
@property (strong, nonatomic) IBOutlet UISwitch* studentSwitch;
@property (strong, nonatomic) IBOutlet UISwitch* eqroomStaffSwitch;
@property (strong, nonatomic) IBOutlet UISwitch* eqroomInternSwitch;


@end

@implementation EQRContactAddNewVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.firstNameTextF becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doneButton:(id)sender{
    
    //update data layer
    
    //attributes
    NSArray* firstArray = [NSArray arrayWithObjects:@"first_name", self.firstNameTextF.text, nil];
    NSArray* secondArray = [NSArray arrayWithObjects:@"last_name", self.lastNameTextF.text, nil];
    NSArray* thirdArray = [NSArray arrayWithObjects:@"phone", self.phoneTextF.text, nil];
    NSArray* fourthArray = [NSArray arrayWithObjects:@"email", self.emailTextF.text, nil];
    
    NSArray* fifthArray = [NSArray arrayWithObjects:@"rentor_type_staff", [NSString stringWithFormat:@"%u",self.staffSwitch.on], nil];
    NSArray* sixthArray = [NSArray arrayWithObjects:@"rentor_type_faculty", [NSString stringWithFormat:@"%u",self.facultySwitch.on], nil];
    NSArray* seventhArray = [NSArray arrayWithObjects:@"current_student", [NSString stringWithFormat:@"%u",self.studentSwitch.on], nil];
    NSArray* eighthArray = [NSArray arrayWithObjects:@"current_eq_staff", [NSString stringWithFormat:@"%u",self.eqroomStaffSwitch.on], nil];
    NSArray* ninthArray = [NSArray arrayWithObjects:@"current_eq_intern", [NSString stringWithFormat:@"%u",self.eqroomInternSwitch.on], nil];
    
    NSArray* tenthArray = [NSArray arrayWithObjects:@"first_and_last", [NSString stringWithFormat:@"%@ %@", self.firstNameTextF.text,
                                                                        self.lastNameTextF.text], nil];
    
    NSArray* topArray = [NSArray arrayWithObjects:
                         firstArray,
                         secondArray,
                         thirdArray,
                         fourthArray,
                         fifthArray,
                         sixthArray,
                         seventhArray,
                         eighthArray,
                         ninthArray,
                         tenthArray,
                         nil];
    
    EQRWebData* webData = [EQRWebData sharedInstance];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        [webData queryForStringwithAsync:@"EQSetNewContact.php" parameters:topArray completion:^(NSString *stringReturn) {
            
            NSLog(@"this is the return booger: %@", stringReturn);
            //    NSLog(@"key for new contact: %@", returnString);
            
            //continue...
            //alert contactPicker that an update has been made
            [self.delegate informAdditionHasHappended:stringReturn];
            
            //go back to previous VC
//            [self.navigationController popViewControllerAnimated:YES];
        }];
    });
}

-(IBAction)cancelButton:(id)sender{
    
    //go back to previous VC
    [self.navigationController popViewControllerAnimated:YES];
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
