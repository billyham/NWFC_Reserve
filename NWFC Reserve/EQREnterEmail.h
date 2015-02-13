//
//  EQREnterEmail.h
//  Gear
//
//  Created by Dave Hanagan on 2/12/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQREnterEmailDelegate;

@interface EQREnterEmail : UIViewController{
    __weak id <EQREnterEmailDelegate> delegate;
}

@property (weak, nonatomic) id <EQREnterEmailDelegate> delegate;

@end


@protocol EQREnterEmailDelegate <NSObject>

-(void)emailEntered:(NSString*)email;

@end