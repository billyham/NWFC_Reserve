//
//  EQRMiscEditVC.h
//  Gear
//
//  Created by Dave Hanagan on 2/4/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EQRMiscEditVCDelegate;

@interface EQRMiscEditVC : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    __weak id <EQRMiscEditVCDelegate> delegate;
}

@property (weak, nonatomic) id <EQRMiscEditVCDelegate> delegate;

-(void)initialSetupWithScheduleTrackingKey:(NSString*)scheduleTracking_foreignKey;
-(void)renewTheViewWithScheduleKey:(NSString*)scheduleTracking_foreignKey;

@end



@protocol EQRMiscEditVCDelegate <NSObject>

-(void)receiveMiscData:(NSString*)miscItemText;

@end