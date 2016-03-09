//
//  EQRCoreData.h
//  Gear
//
//  Created by Ray Smith on 3/7/16.
//  Copyright © 2016 Ham Again LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EQRWebData.h"

#pragma mark - Completion block definitions
typedef void (^CompletionBlockWithArray) (NSMutableArray* muteArray);
typedef void (^CompletionBlockWithBool) (BOOL isLoadingFlagUp);


@protocol EQRCoreDataDelegate;

@interface EQRCoreData : EQRWebData{
    
}

+(EQRCoreData*)sharedInstance;

@end



@protocol EQRCoreDataDelegate <NSObject>

@end
