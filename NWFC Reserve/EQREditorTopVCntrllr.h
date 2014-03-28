//
//  EQREditorTopVCntrllr.h
//  NWFC Reserve
//
//  Created by Dave Hanagan on 3/28/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EQREditorTopVCntrllr : UIViewController

@property (strong, nonatomic) NSString* scheduleRequestKeyID;

-(void)initialSetupWithInfo:(NSDictionary*)userInfo;

@end
