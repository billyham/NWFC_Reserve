//
//  EQRDateRangeVC.m
//  Gear
//
//  Created by Ray Smith on 2/16/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import "EQRDateRangeVC.h"
#import "EQRGlobals.h"

@interface EQRDateRangeVC ()

@property (strong, nonatomic) IBOutlet UIDatePicker* pickUpPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker* returnPicker;

@property BOOL datePickupSelectionFlag;
@property BOOL dateReturnSelectionFlag;
@property (strong, nonatomic) NSString* segueSelectionType;


@end

@implementation EQRDateRangeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)receivePickupDate:(id)sender{
    
    NSComparisonResult compareResult = [self.pickUpPicker.date compare:self.returnPicker.date];
    
    if (compareResult == NSOrderedDescending){
        
        [self.returnPicker setDate:self.pickUpPicker.date animated:YES];
    }
}

-(IBAction)receiveReturnDate:(id)sender{
    
    self.dateReturnSelectionFlag = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    self.segueSelectionType = segue.identifier;
    
    //assign this class as the delegate for the presented VC
    EQRInboxLeftTableVC* viewController = [segue destinationViewController];
    
    viewController.delegateForLeftSide = self;
}

#pragma mark - InboxLeftVC delegate method

-(NSString*)selectedInboxOrArchive{
    
    return self.segueSelectionType;
}

-(NSDictionary*)getDateRange{
    
    NSDictionary* dateRange = @{@"beginDate":self.pickUpPicker.date, @"endDate":self.returnPicker.date};
    return dateRange;
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
