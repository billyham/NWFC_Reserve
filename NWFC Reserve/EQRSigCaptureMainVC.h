//
//  EQRSigCaptureMainVC.h
//  Gear
//
//  Created by Ray Smith on 6/23/15.
//  Copyright (c) 2015 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRScheduleRequestItem.h"

@protocol EQRSigCaptureDelegate;

@interface EQRSigCaptureMainVC : UIViewController{
    __weak id <EQRSigCaptureDelegate> delegate;
}

@property (weak, nonatomic) id <EQRSigCaptureDelegate> delegate;

-(void)loadTheDataWithRequestItem:(EQRScheduleRequestItem *)requestItem;

@end

@protocol EQRSigCaptureDelegate <NSObject>

-(void)pdfHasCompletedWithName:(NSString *)pdfName timestamp:(NSDate *)pdfTimestamp;

@end