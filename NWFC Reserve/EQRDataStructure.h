//
//  EQRDataStructure.h
//  NWFC Reserve
//
//  Created by Ray Smith on 9/10/14.
//  Copyright (c) 2014 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EQRDataStructure : NSObject

+(EQRDataStructure*)sharedInstance;
+(NSArray*)turnFlatArrayToStructuredArray:(NSArray*)flatArray;

@end
