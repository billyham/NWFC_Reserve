//
//  EQRClassPickerVC.h
//  Gear
//
//  Created by Ray Smith on 11/19/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRClassPickerDelegate;


@interface EQRClassPickerVC : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    __weak id <EQRClassPickerDelegate> delegate;
}

@property (weak, nonatomic) id <EQRClassPickerDelegate> delegate;

-(id)retrieveClassItem;

@end


@protocol EQRClassPickerDelegate <NSObject>

-(void)initiateRetrieveClassItem;

@end