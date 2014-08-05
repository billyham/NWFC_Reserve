//
//  EQRQuickViewScrollVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 8/3/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQRQuickViewPage1VCntrllr.h"

@interface EQRQuickViewScrollVCntrllr : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView* myScrollView;
@property (nonatomic, strong) IBOutlet UIView* myContentView;
@property (nonatomic, strong) EQRQuickViewPage1VCntrllr* myScheduleRowQuickView;
@property (nonatomic, strong) IBOutlet UIView* myContentPage1;
@property (nonatomic, strong) IBOutlet UIView* myContentPage2;
@property (nonatomic, strong) IBOutlet UIView* myContentPage3;

@property (nonatomic, strong) IBOutlet UIButton* editRequestButton;

-(IBAction)slideRight:(id)sender;
-(IBAction)slideLeft:(id)sender;


@end
