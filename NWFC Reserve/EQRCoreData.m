//
//  EQRCoreData.m
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import "EQRCoreData.h"

@implementation EQRCoreData

+(EQRCoreData*)sharedInstance{
    
    EQRCoreData *myInstance = [[EQRCoreData alloc] init];
    return myInstance;
}

@end
