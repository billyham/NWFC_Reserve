//
//  EQRPricingWidgetVC.m
//  Gear
//
//  Created by Ray Smith on 10/5/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPricingWidgetVC.h"
#import "EQRDataStructure.h"

@interface EQRPricingWidgetVC ()

@property (strong, nonatomic) EQRTransaction *myTransaction;
@property (strong, nonatomic) NSString *myPricingCategory;
@property (strong, nonatomic) IBOutlet UILabel *pricingCategoryValue;
@property (strong, nonatomic) IBOutlet UILabel *rentalFeeValue;
@property (strong, nonatomic) IBOutlet UILabel *depositValue;
@property (strong, nonatomic) IBOutlet UILabel *nameAndTimeStamp;
@property (strong, nonatomic) IBOutlet UILabel *xLabel;

@end

@implementation EQRPricingWidgetVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(void)viewWillAppear:(BOOL)animated{

}

-(void)viewDidAppear:(BOOL)animated{
    
    [self doAllTheLayoutWork];
    
    [super viewDidAppear:animated];
}


-(void)initialSetupWithTransaction:(EQRTransaction *)transaction pricingCategory:(NSString *)pricingCategory{
    
    self.myTransaction = transaction;
    self.myPricingCategory = pricingCategory;
    
    [self doAllTheLayoutWork];

}

-(void)doAllTheLayoutWork{
    
    self.pricingCategoryValue.text = self.myPricingCategory;
    
    if (self.myTransaction){  //Transaction is valid
        self.rentalFeeValue.text = self.myTransaction.total_due;
        self.depositValue.text = self.myTransaction.deposit_due;
        
        if (self.myTransaction.payment_timestamp && self.myTransaction.payment_staff_foreignKey){
            if (![self.myTransaction.payment_staff_foreignKey isEqualToString:@""]){
                
                NSLog(@"EQRPricingWidget > doAllTheWork this is the payment_staff_foreignKey: %@", self.myTransaction.payment_staff_foreignKey);
                
                self.nameAndTimeStamp.hidden = NO;
                self.xLabel.hidden = NO;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                dateFormatter.locale = locale;
                [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                NSString *dateAsString = [dateFormatter stringFromDate:self.myTransaction.payment_timestamp];
                self.nameAndTimeStamp.text = [NSString stringWithFormat:@"%@ - %@",self.myTransaction.first_name, dateAsString];
                
            }else{     //no payment
                
                self.nameAndTimeStamp.hidden = YES;
                self.xLabel.hidden = YES;
            }
            
        }else{
            
            self.nameAndTimeStamp.hidden = YES;
            self.xLabel.hidden = YES;
        }
    }else{  //Transaction is NIL
        
        self.rentalFeeValue.text = nil;
        self.depositValue.text = nil;
        self.nameAndTimeStamp.text = nil;
        self.nameAndTimeStamp.hidden = YES;
        self.xLabel.hidden = YES;
    }
}

-(void)deleteExistingData{
    
    self.myTransaction = nil;
    self.myPricingCategory = nil;
    
    [self doAllTheLayoutWork];
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
