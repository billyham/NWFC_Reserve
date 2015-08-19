//
//  EQRAddNewClassVC.h
//  Gear
//
//  Created by Ray Smith on 8/18/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRClassItem.h"

@protocol EQRClassAddDelegate;

@interface EQRAddNewClassVC : UIViewController{
    
    __weak id <EQRClassAddDelegate> delegate;
}

@property (nonatomic, weak) id <EQRClassAddDelegate> delegate;

@end



@protocol EQRClassAddDelegate <NSObject>

-(void)informClassAdditionHasHappended:(EQRClassItem *)classItem;

@end