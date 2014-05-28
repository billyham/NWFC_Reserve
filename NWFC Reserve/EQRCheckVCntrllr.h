//
//  EQRCheckVCntrllr.h
//  NWFC Reserve
//
//  Created by Ray Smith on 5/14/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQRCheckVCntrllr : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSString* scheduleRequestKeyID;
@property BOOL marked_for_returning;
@property NSUInteger switch_num;

-(void)initialSetupWithInfo:(NSDictionary*)userInfo;

@end
