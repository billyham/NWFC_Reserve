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
@property (strong, nonatomic) NSString *myKeyID;
@property (strong, nonatomic) NSIndexPath *myIndexPath;

@end

@implementation EQRPriceMatrixCllctnViewContentVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.equipNameLabel.text = self.myName;
    self.distIdLabel.text = self.myDistID;
    self.costField.text = self.myCost;
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidLayoutSubviews{
    
    //add targets for tapping in text fields
    UITapGestureRecognizer* tapChangeCost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(costFieldTapped)];
    [self.costField addGestureRecognizer:tapChangeCost];
    
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialSetupWithName:(NSString *)name distID:(NSString *)distID cost:(NSString *)cost joinKeyID:(NSString *)keyID indexPath:(NSIndexPath *)indexPath{
    
    self.myName = name;
    self.myDistID = distID;
    self.myCost = cost;
    self.myKeyID = keyID;
    self.myIndexPath = indexPath;
    
    self.equipNameLabel.text = self.myName;
    self.distIdLabel.text = self.myDistID;
    self.costField.text = self.myCost;
}

-(void)costFieldTapped{
    
    //if it has a valid dist ID, then it must be an equipJoin
    if (self.myDistID){
        [self.delegate launchCostEditorWithJoinKeyID:self.myKeyID isEquipJoin:YES cost:self.myCost indexPath:self.myIndexPath];
    }else{
        [self.delegate launchCostEditorWithJoinKeyID:self.myKeyID isEquipJoin:NO cost:self.myCost indexPath:self.myIndexPath];
    }
    
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
