//
//  EQREnterPhoneVC.h
//  Gear
//
//  Created by Ray Smith on 2/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQREnterPhoneDelegate;

@interface EQREnterPhoneVC : UIViewController{
    __weak id <EQREnterPhoneDelegate> delegate;
}

@property (weak, nonatomic) id <EQREnterPhoneDelegate> delegate;

@end


@protocol EQREnterPhoneDelegate <NSObject>

-(void)phoneEntered:(NSString*)phoneNumber;

@end
