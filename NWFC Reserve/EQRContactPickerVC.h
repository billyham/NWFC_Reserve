//
//  EQRContactPickerVC.h
//  Gear
//
//  Created by Ray Smith on 11/16/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQRContactPickerDelegate;


@interface EQRContactPickerVC : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    __weak id <EQRContactPickerDelegate> delegate;
}

@property (weak, nonatomic) id <EQRContactPickerDelegate> delegate;

-(id)retrieveContactItem;


@end


@protocol EQRContactPickerDelegate <NSObject>

-(void)retrieveSelectedNameItem;

@end