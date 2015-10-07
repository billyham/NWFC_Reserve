//
//  EQRAlternateWrappperPriceMatrix.h
//  Gear
//
//  Created by Ray Smith on 9/14/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@protocol EQRPriceMatrixDelegate;

@interface EQRAlternateWrappperPriceMatrix : UIViewController{
    __weak id <EQRPriceMatrixDelegate> delegate;
}

@property (weak, nonatomic) id <EQRPriceMatrixDelegate> delegate;


-(void)provideScheduleRequest:(EQRScheduleRequestItem *)requestItem;

@end

@protocol EQRPriceMatrixDelegate <NSObject>

-(void)aChangeWasMadeToPriceMatrix;

@end
