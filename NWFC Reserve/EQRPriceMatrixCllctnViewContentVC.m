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
@property (strong, nonatomic) NSString *myDeposit;
@property (strong, nonatomic) NSString *myKeyID;
@property (strong, nonatomic) NSIndexPath *myIndexPath;
@property BOOL isEquipJoin;
@property BOOL hasAStoredCostValue;

@end

@implementation EQRPriceMatrixCllctnViewContentVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.equipNameLabel.text = self.myName;
    self.distIdLabel.text = self.myDistID;
    self.costField.text = self.myCost;
    self.depositField.text = self.myDeposit;
    
    if (self.hasAStoredCostValue){
        self.costField.backgroundColor = [UIColor yellowColor];
    }
    
     //Do any additional setup after loading the view from its nib.
}

-(void)viewDidLayoutSubviews{
    
    //add targets for tapping in text fields
    UITapGestureRecognizer* tapChangeCost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(costFieldTapped)];
    [self.costField addGestureRecognizer:tapChangeCost];
    
    UITapGestureRecognizer *tapChangeDeposit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(depositFieldTapped)];
    [self.depositField addGestureRecognizer:tapChangeDeposit];
    
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialSetupWithName:(NSString *)name
                     distID:(NSString *)distID
                       cost:(NSString *)cost
                    deposit:(NSString *)deposit
                  joinKeyID:(NSString *)keyID
                  indexPath:(NSIndexPath *)indexPath
                isEquipJoin:(BOOL)isEquipJoin
        hasAStoredCostValue:(BOOL)hasAStoredCostValue{
    
    self.myName = name;
    self.myDistID = distID;
    self.myCost = cost;
    self.myDeposit = deposit;
    self.myKeyID = keyID;
    self.myIndexPath = indexPath;
    self.isEquipJoin = isEquipJoin;
    self.hasAStoredCostValue = hasAStoredCostValue;
    
    self.equipNameLabel.text = self.myName;
    self.distIdLabel.text = self.myDistID;
    self.costField.text = self.myCost;
    self.depositField.text = self.myDeposit;
}

-(void)costFieldTapped{
    
    //if it has a valid dist ID, then it must be an equipJoin
    if (self.isEquipJoin){
        [self.delegate launchCostEditorWithJoinKeyID:self.myKeyID isEquipJoin:YES cost:self.myCost indexPath:self.myIndexPath];
    }else{
        [self.delegate launchCostEditorWithJoinKeyID:self.myKeyID isEquipJoin:NO cost:self.myCost indexPath:self.myIndexPath];
    }
}

-(void)depositFieldTapped{
    
    //if it has a valid dist ID, then it must be an equipJoin
    if (self.isEquipJoin){
        [self.delegate launchDepositEditorWithJoinKeyID:self.myKeyID isEquipJoin:YES deposit:self.myDeposit indexPath:self.myIndexPath];
    }else{
        [self.delegate launchDepositEditorWithJoinKeyID:self.myKeyID isEquipJoin:NO deposit:self.myDeposit indexPath:self.myIndexPath];
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
