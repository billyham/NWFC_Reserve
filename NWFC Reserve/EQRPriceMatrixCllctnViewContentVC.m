//
//  EQRPriceMatrixCllctnViewContentVC.m
//  Gear
//
//  Created by Ray Smith on 9/25/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPriceMatrixCllctnViewContentVC.h"

@interface EQRPriceMatrixCllctnViewContentVC ()

@property (strong, nonatomic) NSString *myName;
@property (strong, nonatomic) NSString *myDistID;
@property (strong, nonatomic) NSString *myCost;

@end

@implementation EQRPriceMatrixCllctnViewContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.equipNameLabel.text = self.myName;
    self.distIdLabel.text = self.myDistID;
    self.costField.text = self.myCost;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialSetupWithName:(NSString *)name distID:(NSString *)distID cost:(NSString *)cost{
    
    self.myName = name;
    self.myDistID = distID;
    self.myCost = cost;
    
    self.equipNameLabel.text = self.myName;
    self.distIdLabel.text = self.myDistID;
    self.costField.text = self.myCost;
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
