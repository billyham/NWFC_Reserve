//
//  EQRRenterPricingTypeTableVC.h
//  Gear
//
//  Created by Ray Smith on 10/12/15.
//  Copyright © 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRRenterPricingDelegate;

@interface EQRRenterPricingTypeTableVC : UITableViewController{
    
    __weak id <EQRRenterPricingDelegate> delegate;
}

@property (weak, nonatomic) id <EQRRenterPricingDelegate> delegate;

-(void)shouldSelect:(NSString *)renterPricingText;

@end


@protocol EQRRenterPricingDelegate <NSObject>

-(void)didSelectRenterPricingType:(NSString *)renterPricingType;

@end