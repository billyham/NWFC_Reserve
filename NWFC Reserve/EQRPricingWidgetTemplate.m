//
//  EQRPricingWidgetTemplate.m
//  Gear
//
//  Created by Ray Smith on 10/27/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import "EQRPricingWidgetTemplate.h"
#import "EQRDataStructure.h"

@interface EQRPricingWidgetTemplate ()

@property (strong, nonatomic) EQRTransaction *myTransaction;
@property (strong, nonatomic) IBOutlet UILabel *pricingCategoryValue;
@property (strong, nonatomic) IBOutlet UILabel *rentalFeeValue;
@property (strong, nonatomic) IBOutlet UILabel *depositValue;
@property (strong, nonatomic) IBOutlet UILabel *nameAndTimeStamp;
@property (strong, nonatomic) IBOutlet UILabel *xLabel;

@end

@implementation EQRPricingWidgetTemplate

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self doAllTheLayoutWork];
    
    [super viewDidAppear:animated];
}

-(void)initialSetupWithTransaction:(EQRTransaction *)transaction{
    
    self.myTransaction = transaction;
    
    [self doAllTheLayoutWork];
    
}

-(void)doAllTheLayoutWork{
    
    if (self.myTransaction){  //Transaction is valid
        self.pricingCategoryValue.text = self.myTransaction.renter_pricing_class;
        
        //font styles
        UIFont* normalFont = [UIFont systemFontOfSize:13];
        UIFont* boldFont = [UIFont boldSystemFontOfSize:15];
        NSDictionary *dictionaryOfNormalAtts = @{NSFontAttributeName:normalFont, NSBaselineOffsetAttributeName:[NSNumber numberWithFloat:2.0]};
        NSDictionary *dictionaryOfBoldAtts = @{NSFontAttributeName:boldFont};
        
        NSMutableAttributedString *feeAtt = [[NSMutableAttributedString alloc] initWithString:@"$" attributes:dictionaryOfNormalAtts];
        NSMutableAttributedString *depositAtt = [[NSMutableAttributedString alloc] initWithString:@"$" attributes:dictionaryOfNormalAtts];
        
        NSAttributedString *feeValue = [[NSAttributedString alloc] initWithString:self.myTransaction.total_due attributes:dictionaryOfBoldAtts];
        NSAttributedString *depositValue = [[NSAttributedString alloc] initWithString:self.myTransaction.deposit_due attributes:dictionaryOfBoldAtts];
        
        [feeAtt appendAttributedString:feeValue];
        [depositAtt appendAttributedString:depositValue];
        
        self.rentalFeeValue.attributedText = feeAtt;
        self.depositValue.attributedText = depositAtt;
        
//        NSLog(@"EQRPricingWidgetTemplate > doAlltheLayout says transaction is valid, setting rental value");
//        NSLog(@"setting rentalFeeValue as: %@", self.myTransaction.total_due);
        
        if (self.myTransaction.payment_timestamp && self.myTransaction.payment_staff_foreignKey){
            if (![self.myTransaction.payment_staff_foreignKey isEqualToString:@""]){
                
                //                NSLog(@"EQRPricingWidget > doAllTheWork this is the payment_staff_foreignKey: %@", self.myTransaction.payment_staff_foreignKey);
                
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
        
        self.pricingCategoryValue.text = nil;
        self.rentalFeeValue.text = nil;
        self.depositValue.text = nil;
        self.nameAndTimeStamp.text = nil;
        self.nameAndTimeStamp.hidden = YES;
        self.xLabel.hidden = YES;
    }
}

-(void)deleteExistingData{
    
    self.myTransaction = nil;
    
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
