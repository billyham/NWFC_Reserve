//
//  EQRPasswordEntryVC.h
//  Gear
//
//  Created by Ray Smith on 2/9/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRPasswordEntryDelegate;

@interface EQRPasswordEntryVC : UIViewController{
    
    __weak id <EQRPasswordEntryDelegate> delegate;
}

@property (weak, nonatomic) id <EQRPasswordEntryDelegate> delegate;

@end


@protocol EQRPasswordEntryDelegate <NSObject>

-(void)passwordEntered:(BOOL)passwordSuccessful;

@end