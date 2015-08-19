//
//  EQRClassPickerVC.h
//  Gear
//
//  Created by Ray Smith on 11/19/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRClassItem.h"
#import "EQRAddNewClassVC.h"

@protocol EQRClassPickerDelegate;


@interface EQRClassPickerVC : UIViewController <UITableViewDataSource, UITableViewDelegate, EQRClassAddDelegate>{
    
    __weak id <EQRClassPickerDelegate> delegate;
}

@property (weak, nonatomic) id <EQRClassPickerDelegate> delegate;

//-(id)retrieveClassItem;

//add new class delegate method
-(void)informClassAdditionHasHappended:(EQRClassItem *)classItem;

@end


@protocol EQRClassPickerDelegate <NSObject>

-(void)initiateRetrieveClassItem:(EQRClassItem *)selectedClassItem;

@end