//
//  EQRScheduleRequestManager.h
//  NWFC Reserve
//
//  Created by Ray Smith on 12/31/13.
//  Copyright (c) 2013 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRScheduleRequestItem.h"

@interface EQRScheduleRequestManager : NSObject

@property (strong, nonatomic) EQRScheduleRequestItem* request;

+(EQRScheduleRequestManager*)sharedInstance;
-(void)createNewRequest;
-(void)dismissRequest;
-(NSArray*)retrieveArrayOfEquipJoins;

@end
